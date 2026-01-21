import UIKit
import FAPanels
import RealmSwift
import GSPlayer
import SDWebImage
import Hero
import SwiftLocation
import OneSignalFramework
import OneSignalCore
import FirebaseCrashlytics

class HomeVC: NavigationBarViewController {
    
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _headerHeightConstraint: NSLayoutConstraint!
    private var lastContentOffset: CGFloat = 0
    private var isAnimating = false
    private let kCellIdentifierStoryView = String(describing: HomeStoryViewCell.self)
    private let kCellIdentifierCategories = String(describing: CategoryTableCell.self)
    private let kLoadingCell = String(String(describing: LoadingCell.self))
    
    private var _visibleVideoCell: VideoComponentTableCell?
    private var _visibleSingleVideoCell: SingleVideoTableCell?
    private var homeModel: HomeModel?
    private var promotionBannerModel: PromotionalBannerItemModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _loadData(true)
        _requestHomeData()
        setupUi()
        DISPATCH_ASYNC_MAIN_AFTER(1) {
            guard let promotion =  APPSETTING.subscriptionPromo else { return }
            let vc = INIT_CONTROLLER_XIB(UpgradePlanPopUpVC.self)
            vc.modalPresentationStyle = .overFullScreen
            vc.subscriptionModel = promotion
            self.present(vc, animated: true, completion: nil)
        }
        startInitialAPIChecks()
        self.checkForAppUpdate()
        OneSignal.login(externalId: APPSESSION.userDetail?.id ?? "", token: APPSESSION.token)
    }
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(animated)
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    //            self.playPauseVideoIfVisible()
    //        }
    //    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.pauseVideoWhenDisappear()
    }
    
    func pauseVideoWhenDisappear() {
        if self._tableView == nil { return }
        self._tableView.setContentOffset(_tableView.contentOffset, animated: false)
        DISPATCH_ASYNC_MAIN {
            self._tableView.visibleCells.forEach { cell in
                if cell is VideoComponentTableCell {
                    (cell as? VideoComponentTableCell)?.pauseVideo()
                } else if cell is SingleVideoTableCell {
                    (cell as? SingleVideoTableCell)?.pauseVideo()
                } else if cell is BannerAdsTableCell {
                    (cell as? BannerAdsTableCell)?.pause()
                }
            }
        }
    }
    
    func setupBottomBar() {
    }
    
    
    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: true,
            isShowRefreshing: true,
            emptyDataText: "home_screen_empty".localized(),
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.proxyDelegate = self
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForGround), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenVenueDetail(_:)), name: kopenVenueDetailNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenWebView(_:)), name: kOpenWebViewPackagePayment, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdate(_:)), name: .updateLocationState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_handleReload(_:)), name: .reloadShoutouts, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleOpenUser(_:)), name: Notification.Name("openuser"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_handleReload), name: .changereloadNotificationUpdateState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_handleReloadLike), name: .reloadOnLike, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateLabel(_:)), name: Notification.Name("addtoCartCount"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .updateLocationState, object: nil)
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    @objc private func handleUpdateLabel(_ notification: Notification) {
        getCartData()
    }
    
    func startInitialAPIChecks() {
        let group = DispatchGroup()
        
        // 1. Session Check
        group.enter()
        APPSESSION.sessionCheck { message, error in
            defer { group.leave() }
            
            if !Utils.stringIsNullOrEmpty(message) {
                DispatchQueue.main.async {
                    if message == "Session expired, please login again!" {
                        self.alert(message: "session_expired".localized()) { _ in
                            APPSESSION.clearSessionData()
                            APPSESSION._moveToLogin()
                        }
                    } else {
                        self.alert(message: message)
                    }
                }
            }
        }
        
        // 2. Cart Data
        group.enter()
        WhosinServices.viewCart { [weak self] container, error in
            defer { group.leave() }
            guard let self = self else { return }
            guard let data = container?.data else { return }
            APPSETTING.ticketCartModel = data
        }
        
        // 3. Rayna Review
        group.enter()
        WhosinServices.checkRaynaReview { [weak self] container, error in
            defer { group.leave() }
            guard let self = self else { return }
            guard let data = container?.data else { return }
            
            if data.reviewStatus == "pending" {
                NotificationCenter.default.post(name: .openTicketReview, object: nil, userInfo: ["ticketId": data.customTicketId])
            }
        }
        
        group.enter()
        APPSESSION.getUnreadInAPPNotifications { model in
            defer { group.leave() }
            if model.isEmpty { return }
            DISPATCH_ASYNC_MAIN_AFTER(3) {
                NotificationCenter.default.post(name: kInAppNotification, object: model.first)
            }
        }
        
        
        group.notify(queue: .main) {
            self.hideHUD()
        }
    }
    
    private func getCartData() {
        WhosinServices.viewCart { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            guard let data = container?.data else { return }
            APPSETTING.ticketCartModel = data
        }
    }
    
    private func _requestHomeData(_ shouldRefreshs: Bool = false) {
        if shouldRefreshs {
            self._tableView.startRefreshing()
        }
        let repo = HomeRepository()
        repo.getHome(shouldRefresh: shouldRefreshs) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self._tableView.endRefreshing()
            if let homeData = container {
                self.homeModel = homeData
                APPSETTING.venueModel = container?.venues.toArray(ofType: VenueDetailModel.self)
                APPSETTING.offers = container?.offers.toArray(ofType: OffersModel.self)
                APPSETTING.activities = container?.activities.toArray(ofType: ActivitiesModel.self)
                APPSETTING.events = container?.events.toArray(ofType: EventModel.self)
                APPSETTING.users = container?.users.toArray(ofType: UserDetailModel.self)
                APPSETTING.membershipPackage = container?.membershipPackages.toArrayDetached(ofType: MembershipPackageModel.self)
                APPSETTING.yachtModel = container?.yachts.toArrayDetached(ofType: YachtDetailModel.self)
                APPSETTING.yachtOfferModel = container?.yachtOffers.toArrayDetached(ofType: YachtOfferDetailModel.self)
                APPSETTING.categories = container?.categories.toArrayDetached(ofType: CategoryDetailModel.self)
                APPSETTING.ticketCategories = container?.ticketCategories.toArrayDetached(ofType: CategoryDetailModel.self)
                APPSETTING.ticketList = container?.tickets.toArrayDetached(ofType: TicketModel.self)
                APPSETTING.exploreBanners?.removeAll()
                APPSETTING.exploreBanners = container?.banners.toArrayDetached(ofType: ExploreBannerModel.self)
                APPSETTING.exploreBanners?.append(contentsOf: container?.customComponents.toArrayDetached(ofType: ExploreBannerModel.self) ?? [])
                APPSETTING.cityList = container?.cities.toArrayDetached(ofType: CategoryDetailModel.self)
                self._loadData()
            } else {
                DISPATCH_ASYNC_MAIN_AFTER(0.5, closure: {
                    self.showError(error)
                })
            }
        }
    }
    
    private func _requestConfirmedEvents() {

    }
    
    private func checkRaynaReview() {
        WhosinServices.checkRaynaReview {  [weak self] container , error in
            guard let self = self else { return }
            self.hideHUD()
            guard let data = container?.data else { return }
            if (data.reviewStatus == "pending") {
                NotificationCenter.default.post(name: .openTicketReview, object: nil, userInfo: ["ticketId": data.customTicketId])
            }
        }
    }
    
    private func _loadData(_ isLoading: Bool = false) {
        guard !isLoading else {
            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()
            cellData.append([
                kCellIdentifierKey: kLoadingCell,
                kCellTagKey: kLoadingCell,
                kCellAllowCacheKey: false,
                kCellObjectDataKey: true,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
            
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            _tableView.loadData(cellSectionData)
            return
        }
        
        guard let homeModel = homeModel else { return }
        
        let stories = homeModel.storiesModel.toArray(ofType: VenueDetailModel.self).flatMap({$0.storie.toArray(ofType: StoryModel.self)})
        var videoUrls: [URL] = stories.filter({ !$0.isImage && URL(string: $0.mediaUrl) != nil }).map({URL(string: $0.mediaUrl)!})
        
        let imageUrls = stories.filter({ $0.isImage && URL(string: $0.mediaUrl) != nil }).map({URL(string: $0.mediaUrl)!})
        SDWebImagePrefetcher.shared.prefetchURLs(imageUrls)
        
        let videosBlock = homeModel.homeblocksModel.toArray(ofType: HomeBlockModel.self).flatMap({ $0.videos })
        let comVideoUrl = videosBlock.filter({ URL(string: $0.videoUrl) != nil }).map({ URL(string: $0.videoUrl)!})
        videoUrls.append(contentsOf: comVideoUrl)
        videoUrls.forEach { url in
            Utils.downloadVideo(url)
        }
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if !homeModel.storiesModel.isEmpty {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierStoryView,
                kCellTagKey: kCellIdentifierStoryView,
                kCellAllowCacheKey: true,
                kCellObjectDataKey: homeModel.storiesModel.toArrayDetached(ofType: VenueDetailModel.self),
                kCellClassKey: HomeStoryViewCell.self,
                kCellHeightKey: HomeStoryViewCell.height
            ])
        }
        
        if !homeModel.categories.isEmpty {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierCategories,
                kCellTagKey: kCellIdentifierCategories,
                kCellAllowCacheKey: false,
                kCellObjectDataKey: homeModel.categories.toArrayDetached(ofType: CategoryDetailModel.self),
                kCellClassKey: CategoryTableCell.self,
                kCellHeightKey: CategoryTableCell.height
            ])
        }
        
        if let bannerModel = promotionBannerModel {
            cellData.append([
                kCellIdentifierKey: BannerAdsTableCell.identifier,
                kCellTagKey: "promotionBanner",
                kCellAllowCacheKey: false,
                kCellObjectDataKey: bannerModel,
                kCellClassKey: BannerAdsTableCell.self,
                kCellHeightKey: BannerAdsTableCell.height(bannerModel.size?.ratio ?? "1:1")
            ])
        }
        
        _ = homeModel.homeblocksModel.first(where: { $0.type == "apply-ring" })?.applicationStatus == "pending"
        
        //        if APPSESSION.userDetail?.requiredFields() == true, !isCMStatusPending, !Preferences.isGuest {
        //            cellData.append([
        //                kCellIdentifierKey: kCompleteProfile,
        //                kCellTagKey: "CompleteProfile",
        //                kCellObjectDataKey: true,
        //                kCellClassKey: CompleteProfileTableCell.self,
        //                kCellHeightKey: CompleteProfileTableCell.height
        //            ])
        //        }
        
        homeModel.homeblocksModel.forEach { data in
            if !data.isVisible { return }
            cellData.append([
                kCellIdentifierKey: data.cellType.identifier,
                kCellTagKey: data.type == "membership-package" ? "membership-package" : data.id,
                kCellAllowCacheKey: data.cellType.isNeedCacheCell,
                kCellCacheKey : data.cellType.cachedCell ?? nil,
                //                    kCellCacheKey: data.type == "ticket" || data.type == "favorite_ticket" ?  Bundle.main.loadNibNamed(data.cellType.identifier , owner: self, options: nil)?.first as! UITableViewCell : kEmptyString,
                kCellObjectDataKey: data,
                kCellHeightKey: data.cellType.height
            ])
        }
        
        DISPATCH_ASYNC_MAIN {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            self._tableView.loadData(cellSectionData)
            self._tableView.fetchAndInsertBanner()
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [HomeBlockCellType.ticket.prototype, HomeBlockCellType.video.prototype, HomeBlockCellType.ticketCategoryRounded.prototype,  [kCellIdentifierKey: kCellIdentifierCategories, kCellNibNameKey: kCellIdentifierCategories, kCellClassKey: CategoryTableCell.self, kCellHeightKey: CategoryTableCell.height],
                [kCellIdentifierKey: kCellIdentifierStoryView, kCellNibNameKey: kCellIdentifierStoryView, kCellClassKey: HomeStoryViewCell.self, kCellHeightKey: HomeStoryViewCell.height],
                [kCellIdentifierKey: BannerAdsTableCell.identifier,
                    kCellNibNameKey: BannerAdsTableCell.identifier,
                      kCellClassKey: BannerAdsTableCell.self,
                     kCellHeightKey: BannerAdsTableCell.height("1:1")],
                [kCellIdentifierKey: kLoadingCell, kCellNibNameKey: kLoadingCell, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height], HomeBlockCellType.banner.prototype, HomeBlockCellType.bigCategory.prototype, HomeBlockCellType.cities.prototype, HomeBlockCellType.singleVideo.prototype, HomeBlockCellType.smallCategory.prototype,HomeBlockCellType.contactUs.prototype
        ]
        
    }
    
    @objc private func handleOpenVenueDetail(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let ticketId = userInfo["ticketId"] as? String, !Utils.stringIsNullOrEmpty(ticketId) {
                guard let rootVc = APP.window?.rootViewController else { return }
                if let visibleVc = Utils.getVisibleViewController(from: rootVc) as? CustomTicketDetailVC, visibleVc.ticketID == ticketId {
                    return
                }
                let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
                vc.ticketID = ticketId
                vc.hidesBottomBarWhenPushed = true
                if let visibleVc = Utils.getVisibleViewController(from: rootVc) {
                    visibleVc.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @objc func handleOpenWebView(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let url = userInfo["url"] as? URL {
            let vc = INIT_CONTROLLER_XIB(WebViewController.self)
            vc.url = url
            guard let rootVc = APP.window?.rootViewController else { return }
            if let visibleVc = Utils.getVisibleViewController(from: rootVc) {
                visibleVc.present(vc, animated: true, completion: nil)
            } else {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleOpenUser(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Any] {
            guard let rootVc = APP.window?.rootViewController else { return }
            guard let visibleVc = Utils.getVisibleViewController(from: rootVc) else { return }
            guard let userDetail = APPSESSION.userDetail else { return }
            let model = data["contact"] as? UserDetailModel

        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc private func locationUpdate(_ notification: Notification) {
        if APPSETTING.currentLocation != nil {
            self._requestHomeData(true)
        }
    }
    
    @objc private func _handleReload(_ notification: Notification) {
        self._requestHomeData(true)
      
    }
    
    @objc private func _handleReloadLike(_ notification: Notification) {
        if let data = notification.object as? [String: Any],
           let id = data["id"] as? String,
           let flag = data["flag"] as? Bool {
            if let favoriteBlock = homeModel?.homeblocksModel.first(where: { $0.type == "favorite_ticket" }) {
                if favoriteBlock.favoriteTicketIds.isEmpty || (favoriteBlock.favoriteTicketIds.count == 1 && flag == true) {
                    if let index = favoriteBlock.favoriteTicketIds.firstIndex(of: id) {
                        favoriteBlock.favoriteTicketIds.remove(at: index)
                    } else {
                        favoriteBlock.favoriteTicketIds.append(id)
                    }
                    APPSETTING.ticketList?.first(where: { $0._id == id })?.isFavourite = flag
                    _loadData()
                }
            }
        }
    }
    
    @objc private func _handleSwitchEvent(mySwitch: UISwitch) {
        if mySwitch.isOn {
            let currentStatus = SwiftLocation.authorizationStatus
            if currentStatus == .denied || currentStatus == .restricted {
                alert(title: "location_service_disabled".localized(), message: "enable_location_service".localized(), okActionTitle: "go_to_setting".localized()) { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } cancelHandler: { _ in
                    mySwitch.isOn = false
                }
            }
        }
    }
    
    @objc private func enterBackGround() {
        _visibleVideoCell?.pauseVideo()
        _visibleSingleVideoCell?.pauseVideo()
    }
    
    @objc private func enterForGround() {
        _visibleVideoCell?.resumeVideo()
        _visibleSingleVideoCell?.resumeVideo()
    }
}


extension HomeVC: CustomNoKeyboardTableViewDelegate, UITableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? HomeStoryViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [VenueDetailModel] else { return }
            cell.setupData(object)
        }
        else if let cell = cell as? VideoComponentTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
            DISPATCH_ASYNC_MAIN_AFTER(0.01) {
                self.playPauseVideoIfVisible()
            }
        }
        else if let cell = cell as? CategoryTableCell {
            if let categories = cellDict?[kCellObjectDataKey] as? [CategoryDetailModel] {
                cell.setupData(categories)
            } else {
                guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
                cell.setupData(object)
            }
        }
        else if let cell = cell as? CustomTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
        }
        else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
        else if let cell = cell as? ExploreCategoryTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupHomeData(object)
        }
        else if let cell = cell as? CitiesListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
        }
        else if let cell = cell as? SingleVideoTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
            DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                self.playPauseVideoIfVisible()
            }
        }
        else if let cell = cell as? ExploreBannerTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setup(object)
        }
        else if let cell = cell as? ExploreTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
            cell.setUpdata(object)
        }
        else if let cell = cell as? BannerAdsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromotionalBannerItemModel else { return }
            cell.setupData(object)
            DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                self.playPauseVideoIfVisible()
            }
        }
        else if let cell = cell as? ConnectUSTableViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel, let model = object.contactUsBlock.first else { return }
            cell.setup(model, screen: .homeBlock)
        }
    }
    
    func playPauseVideoIfVisible() {
        guard let superview = _tableView.superview else { return }
        
        for cell in _tableView.visibleCells {
            guard let indexPath = _tableView.indexPath(for: cell) else { continue }
            
            let cellRect = _tableView.rectForRow(at: indexPath)
            let convertedRect = _tableView.convert(cellRect, to: superview)
            let intersect = _tableView.frame.intersection(convertedRect)
            let visibleHeight = intersect.height
            let cellHeight = cellRect.height
            let ratio = visibleHeight / cellHeight
            
            // Minimum visible threshold
            let threshold: CGFloat = 0.22
            
            switch cell {
            case let videoCell as VideoComponentTableCell:
                if ratio <= threshold {
                    videoCell.pauseVideo()
                } else if videoCell._replyView.isHidden {
                    videoCell.resumeVideo()
                }
                
            case let singleVideoCell as SingleVideoTableCell:
                if ratio <= threshold {
                    singleVideoCell.pauseVideo()
                } else if singleVideoCell._replyView.isHidden {
                    singleVideoCell.resumeVideo()
                }
            case let bannerCell as BannerAdsTableCell:
                if ratio <= threshold {
                    bannerCell.pause()
                } else {
                    bannerCell.resume()
                }
                
            default:
                break
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < 0 {
            self._headerHeightConstraint.constant = 105
            let offsetY = scrollView.contentOffset.y
            self.lastContentOffset = offsetY
            return
        }
        DISPATCH_ASYNC_MAIN {
            
            if scrollView.contentOffset.y + scrollView.visibleSize.height < scrollView.contentSize.height {
                let offsetY = scrollView.contentOffset.y
                let scrollDiff = offsetY - self.lastContentOffset
                if scrollDiff == 0 {
                    return
                }
                if offsetY > self.lastContentOffset && offsetY > 0 {
                    self._headerHeightConstraint.constant -= abs(scrollDiff)
                    if self._headerHeightConstraint.constant < 0 {
                        self._headerHeightConstraint.constant = 0
                    }
                } else {
                    self._headerHeightConstraint.constant += abs(scrollDiff)
                    if self._headerHeightConstraint.constant > 105 {
                        self._headerHeightConstraint.constant = 105
                    }
                }
                self._tableView.layoutIfNeeded()
                self.lastContentOffset = offsetY
            }
            self.playPauseVideoIfVisible()
        }
        
    }
    
    func refreshData() {
        _requestHomeData(true)
    }
}


extension HomeVC: ReloadProfileDelegate {
    func didRequestReload() {
        _loadData()
    }
}

