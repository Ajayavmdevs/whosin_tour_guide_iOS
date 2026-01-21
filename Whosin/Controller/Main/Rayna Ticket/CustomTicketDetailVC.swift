import UIKit
import MapKit

class CustomTicketDetailVC: ChildViewController {
    
    // --------------------------------------
    // MARK: Outlets
    // --------------------------------------
    
    @IBOutlet weak var _ticketTitle: CustomLabel!
    @IBOutlet weak var _getTicketBtn: CustomButton!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _msgAdminBtn: CustomButton!
    @IBOutlet weak var _likeBtn: CustomLikeButton!
    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    
    // --------------------------------------
    // MARK: Variables
    // --------------------------------------
    
    private let kLoadingCellIdentifire = String(describing: LoadingCell.self)
    private let kCellIdentifireHeader = String(describing: CustomTicketDetailHeaderCell.self)
    private let kCellIdentifireFeature = String(describing: TicketFeaturesTableCell.self)
    private let kCellIdentifireBasic = String(describing: TicketBasicDetailTableCell.self)
    private let kCellIdentifireLocation = String(describing: LocationMapViewCell.self)
    private let kCellIdentifireOption = String(describing: TicketOptionsTableCell.self)
    private let kCellIdentifireOptionTitle = String(describing: TitleTextTableCell.self)
    private let kCellIdentifireOptions = String(describing: CustomTourOptionTableCell.self)
    private let kCellIdentifireOverView = String(describing: OverViewTableCell.self)
    private let kCellIdentifireReview = String(describing: CustomTicketRatingTableCell.self)
    private let kCellIdentifireJuniperOptions = String(describing: JuniperTourDataTableCell.self)
    private let kCellIdentifireWhosinOptions = String(describing: WhosinTourDataTableCell.self)
    private let kCellFeaturedCell = String(describing:  SuggestedTicketCell.self)
    private let kCellContactUsCell = String(describing:  ConnectUSTableViewCell.self)
    private var _ticketDetail: TicketModel?
    public var ticketID: String = kEmptyString
    private var _address: String = kEmptyString
    private var _ticketList: [TicketModel] = []
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupUi()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Home VC Disapper")
        if isMovingFromParent {
            BOOKINGMANAGER.clearManager()
        }
        self.pauseVideoWhenDisappear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.pauseVideoWhenDisappear()
    }
    
    func pauseVideoWhenDisappear() {
        if self._tableView == nil { return }
        self._tableView.setContentOffset(_tableView.contentOffset, animated: false)
        DISPATCH_ASYNC_MAIN {
            self._tableView.visibleCells.forEach { cell in
                if cell is CustomTicketDetailHeaderCell {
                    (cell as? CustomTicketDetailHeaderCell)?._gallayView.pauseVideos()
                }
            }
        }
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _fetchData() {
        let group = DispatchGroup()
        
        group.enter()
        _requestTicketDetail {
            group.leave()
        }
        
        group.enter()
        _requestSearch {
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?._tableView.refreshControl?.endRefreshing()
            self?._loadData(isLoading: false)
        }
    }
    
    private func _requestTicketDetail(completion: (() -> Void)? = nil) {
        print(ticketID)
        WhosinServices.getTicketDetail(id: ticketID) { [weak self] container, error in
            guard let self = self else {
                completion?()
                return
            }
            if error != nil {
                self.hideHUD(error: error)
                completion?()
                return
            }
            guard let data = container?.data else {
                self.hideHUD()
                completion?()
                return
            }
            
            Utils.getAddressFromLatLng(lat: data.location?.coordinates[1] ?? 0.0, lng: data.location?.coordinates[0] ?? 0.0) { address in
                if Utils.stringIsNullOrEmpty(address) {
                    self._address = "\(data.tourData?.cityName ?? "") \(data.tourData?.countryName ?? "")"
                } else {
                    self._address = address ?? ""
                }
                completion?()
            }
            self.btnEnable(true)
            self._ticketDetail = data
            LOGMANAGER.logTicketEvent(.viewTicket, id: ticketID, name: data.title)
            self._ticketTitle.text = data.title
            self._likeBtn.isSelected = data.isFavourite
            BOOKINGMANAGER.ticketModel = data
        }
    }
    
    private func _requestSearch(completion: (() -> Void)? = nil) {
        WhosinServices.suggestedTicketList(params:  ["ticketId": ticketID]) { [weak self] containers, error in
            guard let self = self else {
                completion?()
                return
            }
            self.hideHUD()
            let data = containers?.data ?? []
            self._ticketList = data
            completion?()
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "no_ticket_available".localized(),
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: "no_ticket_detail".localized(),
            delegate: self)
        _tableView.proxyDelegate = self
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        _tableView.refreshControl = refreshControl
        btnEnable()
        _loadData(isLoading: true)
        _fetchData()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: kRelaodActivitInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadOnLike(_:)), name: .reloadOnLike, object: nil)
    }
    
    @objc func reloadData() {
        _fetchData()
    }
    
    private func btnEnable(_ isEnable: Bool = false) {
        _getTicketBtn.isEnabled = isEnable
        _getTicketBtn.backgroundColor = isEnable ? ColorBrand.brandPink : ColorBrand.brandLightGray
        _msgAdminBtn.isEnabled = isEnable
        _msgAdminBtn.backgroundColor = isEnable ? ColorBrand.brandGreen : ColorBrand.brandLightGray
    }
    
    @objc private func handleReloadOnLike(_ notification: Notification) {
        if let data = notification.object as? [String: Any],
           let id = data["id"] as? String,
           let flag = data["flag"] as? Bool {
            if id == _ticketDetail?._id {
                _ticketDetail?.isFavourite = flag
            }
        }
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifire,
                kCellTagKey: kLoadingCellIdentifire,
                kCellObjectDataKey: "loading",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        }
        else {
            guard let model = _ticketDetail else { return }
            cellData.append([
                kCellIdentifierKey: kCellIdentifireHeader,
                kCellTagKey: kCellIdentifireHeader,
                kCellObjectDataKey: model,
                kCellClassKey: CustomTicketDetailHeaderCell.self,
                kCellHeightKey: CustomTicketDetailHeaderCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifireBasic,
                kCellTagKey: kCellIdentifireBasic,
                kCellObjectDataKey: model,
                kCellClassKey: TicketBasicDetailTableCell.self,
                kCellHeightKey: TicketBasicDetailTableCell.height
            ])
            
            if Utils.isValidTextOrHTML(model.overview) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifireOverView,
                    kCellTagKey: "overview".localized(),
                    kCellObjectDataKey: model,
                    kCellClassKey: OverViewTableCell.self,
                    kCellHeightKey: OverViewTableCell.height
                ])
            }
            
            if Utils.isValidTextOrHTML(model.inclusion) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifireOverView,
                    kCellTagKey: "inclusion".localized(),
                    kCellObjectDataKey: model,
                    kCellClassKey: OverViewTableCell.self,
                    kCellHeightKey: OverViewTableCell.height
                ])
            }
            
            if Utils.isValidTextOrHTML(model.tourExclusion) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifireOverView,
                    kCellTagKey: "exclusion".localized(),
                    kCellObjectDataKey: model,
                    kCellClassKey: OverViewTableCell.self,
                    kCellHeightKey: OverViewTableCell.height
                ])
            }
            
            if Utils.isValidTextOrHTML(model.importantInformation) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifireOverView,
                    kCellTagKey: "important_information".localized(),
                    kCellObjectDataKey: model,
                    kCellClassKey: OverViewTableCell.self,
                    kCellHeightKey: OverViewTableCell.height
                ])
            }
            
            if Utils.isValidTextOrHTML(model.usefulInformation) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifireOverView,
                    kCellTagKey: "useful_information".localized(),
                    kCellObjectDataKey: model,
                    kCellClassKey: OverViewTableCell.self,
                    kCellHeightKey: OverViewTableCell.height
                ])
            }
            
            if Utils.isValidTextOrHTML(model.faqDetails) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifireOverView,
                    kCellTagKey: "faq_details".localized(),
                    kCellObjectDataKey: model,
                    kCellClassKey: OverViewTableCell.self,
                    kCellHeightKey: OverViewTableCell.height
                ])
            }
            
            if Utils.isValidTextOrHTML(model.howToRedeem) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifireOverView,
                    kCellTagKey: "how_to_redeem".localized(),
                    kCellObjectDataKey: model,
                    kCellClassKey: OverViewTableCell.self,
                    kCellHeightKey: OverViewTableCell.height
                ])
            }
            
            if !model.features.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifireFeature,
                    kCellTagKey: "features",
                    kCellObjectDataKey: model.features.toArrayDetached(ofType: CommonSettingsModel.self),
                    kCellClassKey: TicketFeaturesTableCell.self,
                    kCellHeightKey: TicketFeaturesTableCell.height
                ])
            }
            
            if !model.whatsInclude.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifireFeature,
                    kCellTagKey: "whatsInclude",
                    kCellObjectDataKey: model.whatsInclude.toArrayDetached(ofType: CommonSettingsModel.self),
                    kCellClassKey: TicketFeaturesTableCell.self,
                    kCellHeightKey: TicketFeaturesTableCell.height
                ])
            }
            
            if Utils.isValidTextOrHTML(model.raynaToursAdvantage) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifireOverView,
                    kCellTagKey: "rayna_advantage".localized(),
                    kCellObjectDataKey: model,
                    kCellClassKey: OverViewTableCell.self,
                    kCellHeightKey: OverViewTableCell.height
                ])
            }
            
            if (model.isEnableRating || model.isEnableReview) || (model.isEnableRating && model.isEnableReview) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifireReview,
                    kCellTagKey: kCellIdentifireReview,
                    kCellObjectDataKey: model,
                    kCellClassKey: CustomTicketRatingTableCell.self,
                    kCellHeightKey: CustomTicketRatingTableCell.height
                ])
            }
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifireLocation,
                kCellTagKey: _address,
                kCellObjectDataKey: model,
                kCellClassKey: LocationMapViewCell.self,
                kCellHeightKey: LocationMapViewCell.height
            ])
            

        }
        
        if !_ticketList.isEmpty {
            cellData.append([
                kCellIdentifierKey: kCellFeaturedCell,
                kCellTagKey: kCellFeaturedCell,
                kCellObjectDataKey: _ticketList,
                kCellClassKey: SuggestedTicketCell.self,
                kCellHeightKey: SuggestedTicketCell.height
            ])
        }
        
        if let model = _ticketDetail?.contactUsBlock, model.isEnabled(screenName: .ticket){
            cellData.append([
                kCellIdentifierKey: kCellContactUsCell,
                kCellTagKey: kCellContactUsCell,
                kCellObjectDataKey: model,
                kCellClassKey: ConnectUSTableViewCell.self,
                kCellHeightKey: ConnectUSTableViewCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        
        _tableView.loadData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kLoadingCellIdentifire, kCellNibNameKey: kLoadingCellIdentifire, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifireFeature, kCellNibNameKey: kCellIdentifireFeature, kCellClassKey: TicketFeaturesTableCell.self, kCellHeightKey: TicketFeaturesTableCell.height],
            [kCellIdentifierKey: kCellIdentifireBasic, kCellNibNameKey: kCellIdentifireBasic, kCellClassKey: TicketBasicDetailTableCell.self, kCellHeightKey: TicketBasicDetailTableCell.height],
            [kCellIdentifierKey: kCellIdentifireOption, kCellNibNameKey: kCellIdentifireOption, kCellClassKey: TicketOptionsTableCell.self, kCellHeightKey: TicketOptionsTableCell.height],
            [kCellIdentifierKey: kCellIdentifireOptionTitle, kCellNibNameKey: kCellIdentifireOptionTitle, kCellClassKey: TitleTextTableCell.self, kCellHeightKey: TitleTextTableCell.height],
            [kCellIdentifierKey: kCellIdentifireHeader, kCellNibNameKey: kCellIdentifireHeader, kCellClassKey: CustomTicketDetailHeaderCell.self, kCellHeightKey: CustomTicketDetailHeaderCell.height],
            [kCellIdentifierKey: kCellIdentifireOverView, kCellNibNameKey: kCellIdentifireOverView, kCellClassKey: OverViewTableCell.self, kCellHeightKey: OverViewTableCell.height],
            [kCellIdentifierKey: kCellIdentifireReview, kCellNibNameKey: kCellIdentifireReview, kCellClassKey: CustomTicketRatingTableCell.self, kCellHeightKey: CustomTicketRatingTableCell.height],
            [kCellIdentifierKey: kCellIdentifireOptions, kCellNibNameKey: kCellIdentifireOptions, kCellClassKey: CustomTourOptionTableCell.self, kCellHeightKey: CustomTourOptionTableCell.height],
            [kCellIdentifierKey: kCellIdentifireLocation, kCellNibNameKey: kCellIdentifireLocation, kCellClassKey: LocationMapViewCell.self, kCellHeightKey: LocationMapViewCell.height],
            [kCellIdentifierKey: kCellIdentifireJuniperOptions, kCellNibNameKey: kCellIdentifireJuniperOptions, kCellClassKey: JuniperTourDataTableCell.self, kCellHeightKey: JuniperTourDataTableCell.height],
            [kCellIdentifierKey: kCellIdentifireWhosinOptions, kCellNibNameKey: kCellIdentifireWhosinOptions, kCellClassKey: WhosinTourDataTableCell.self, kCellHeightKey: WhosinTourDataTableCell.height],
            [kCellIdentifierKey: kCellFeaturedCell, kCellNibNameKey: kCellFeaturedCell, kCellClassKey: SuggestedTicketCell.self, kCellHeightKey: SuggestedTicketCell.height],
            [kCellIdentifierKey: kCellContactUsCell, kCellNibNameKey: kCellContactUsCell, kCellClassKey: ConnectUSTableViewCell.self, kCellHeightKey: ConnectUSTableViewCell.height]
        ]
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    @IBAction func _handleChatAdminEvent(_ sender: CustomButton) {
        guard let userDetail = APPSESSION.userDetail else { return }
        let chatModel = ChatModel()
        chatModel.image = "https://whosin-bucket.nyc3.digitaloceanspaces.com/file/1721896083557_image-1721896083557.jpg"
        chatModel.title = "Whosin Admin"
        chatModel.members.append(kLiveAdminId)
        chatModel.members.append(userDetail.id)
        let chatIds = [kLiveAdminId, userDetail.id].sorted()
        chatModel.chatId = chatIds.joined(separator: ",")
        chatModel.chatType = "friend"
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.chatModel = chatModel
            vc.ticketChatJSON = self._jsonStringTicketObject() ?? kEmptyString
            vc.hidesBottomBarWhenPushed = true
            Utils.openViewController(vc)
        }
    }
    
    private func _jsonStringTicketObject() -> String? {
        guard let ticket = _ticketDetail else { return kEmptyString }
        let model =  ChatTicketModel(model: ticket)
        return model.toJSONString()
    }
    
    @IBAction func _handleShareEvent(_ sender: UIButton) {
        feedbackGenerator?.impactOccurred()
        let vc = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        vc.ticketModel = _ticketDetail
        vc.isFromTicket = true
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @IBAction private func _handleLikeEvent(_ sender: CustomLikeButton) {
        guard let model = _ticketDetail else { return }
        
        _likeBtn.showActivity()
        
        let willBeFavourite = !model.isFavourite
        
        WhosinServices.requestAddRemoveFav(id: model._id, type: "ticket") { [weak self] container, error in
            guard let self = self else { return }
            self._likeBtn.hideActivity()
            self.showError(error)
            guard container != nil else { return }
            self._requestTicketDetail {
                self._loadData()
            }
            model.isFavourite = willBeFavourite
            self._ticketDetail?.isFavourite = willBeFavourite
            self._likeBtn.isSelected = willBeFavourite
            LOGMANAGER.logTicketEvent(.addToWishlist, id: model._id, name: model.title)
            NotificationCenter.default.post(name: .reloadOnLike, object: ["id": model._id, "flag": !willBeFavourite])

            self.showSuccessMessage(
                willBeFavourite ? "thank_you".localized() : "oh_snap".localized(),
                subtitle: willBeFavourite ?
                LANGMANAGER.localizedString(forKey: "add_favourite", arguments: ["value": model.title]) :
                    LANGMANAGER.localizedString(forKey: "remove_favourite", arguments: ["value": model.title])
            )
        }

    }
    
    @IBAction private func _handleBackEvent(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _handleGetTicketEvent(_ sender: CustomButton) {
        if self._ticketDetail?.bookingType == "juniper-hotel" {
            BOOKINGMANAGER.ticketModel = self._ticketDetail
            let vc = INIT_CONTROLLER_XIB(DateAndPaxSelectionSheetVC.self)
            vc.ticketModel = self._ticketDetail
            vc.hidesBottomBarWhenPushed = true
            Utils.pushViewController(vc)
        } else {
            BOOKINGMANAGER.ticketModel = self._ticketDetail
            let vc = INIT_CONTROLLER_XIB(SelectTourOptionsBottomSheet.self)
            vc.ticketModel = self._ticketDetail
            vc.hidesBottomBarWhenPushed = true
            Utils.pushViewController(vc)
        }
        
        if let ticket = self._ticketDetail {
            LOGMANAGER.logTicketEvent(.getTicket, id: ticket._id, name: ticket.title)
        }
    }
    
}

// --------------------------------------
// MARK: TableView Delegates
// --------------------------------------

extension CustomTicketDetailVC: CustomNoKeyboardTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 20
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
                self._ticketTitle.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 0.0
                self._ticketTitle.alpha = 0.0
            }, completion: nil)
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(playPauseVideoIfVisible), object: nil)
        self.perform(#selector(playPauseVideoIfVisible), with: nil, afterDelay: 0.01)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        playPauseVideoIfVisible()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playPauseVideoIfVisible()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            playPauseVideoIfVisible()
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
        else if let cell = cell as? CustomTicketDetailHeaderCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
            cell.setupData(object)
        }
        else if let cell = cell as? TicketFeaturesTableCell {
            guard let type = cellDict?[kCellTagKey] as? String, let object = cellDict?[kCellObjectDataKey] as? [CommonSettingsModel] else { return }
            if type == "features" {
                cell.setupData(model: object, title: "feature".localized())
            } else if type == "whatsInclude" {
                cell.setupData(model: object, title: "whats_included".localized())
            }
        }
        else if let cell = cell as? TicketBasicDetailTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
            cell.setupData(model: object)
        }
        else if let cell = cell as? TicketOptionsTableCell {
            guard let ticket = cellDict?[kCellTagKey] as? TicketModel, let object = cellDict?[kCellObjectDataKey] as? TourOptionDataModel else { return }
            cell.setupData(ticket, option: object)
        }
        else if let cell = cell as? OverViewTableCell {
            guard let ticket = cellDict?[kCellObjectDataKey] as? TicketModel,let type = cellDict?[kCellTagKey] as? String else { return }
            if type == "overview".localized() {
                cell.setupData(ticket.overview, type: type)
                cell.reloadCallback = { isExpand in
                    self._tableView.beginUpdates()
                    self._tableView.endUpdates()
                    cell.layoutIfNeeded()
                }
            } else if type == "inclusion".localized() {
                cell.setupData(ticket.inclusion, type: type)
                cell.reloadCallback = { isExpand in
                    self._tableView.beginUpdates()
                    self._tableView.endUpdates()
                    cell.layoutIfNeeded()
                }
            } else if type == "exclusion".localized() {
                cell.setupData(ticket.tourExclusion, type: type)
                cell.reloadCallback = { isExpand in
                    self._tableView.beginUpdates()
                    self._tableView.endUpdates()
                    cell.layoutIfNeeded()
                }
            } else if type == "useful_information".localized() {
                cell.setupData(ticket.usefulInformation, type: type)
                cell.reloadCallback = { isExpand in
                    self._tableView.beginUpdates()
                    self._tableView.endUpdates()
                    cell.layoutIfNeeded()
                }
            } else if type == "important_information".localized() {
                cell.setupData(ticket.importantInformation, type: type)
                cell.reloadCallback = { isExpand in
                    self._tableView.beginUpdates()
                    self._tableView.endUpdates()
                    cell.layoutIfNeeded()
                }
            } else if type == "faq_details".localized() {
                cell.setupData(ticket.faqDetails, type: type)
                cell.reloadCallback = { isExpand in
                    self._tableView.beginUpdates()
                    self._tableView.endUpdates()
                    cell.layoutIfNeeded()
                }
            } else if type == "how_to_redeem".localized() {
                cell.setupData(ticket.howToRedeem, type: type)
                cell.reloadCallback = { isExpand in
                    self._tableView.beginUpdates()
                    self._tableView.endUpdates()
                    cell.layoutIfNeeded()
                }
            } else if type == "rayna_advantage".localized() {
                cell.setupData(ticket.raynaToursAdvantage, type: type)
                cell.reloadCallback = { isExpand in
                    self._tableView.beginUpdates()
                    self._tableView.endUpdates()
                    cell.layoutIfNeeded()
                }
            }
        }
        else if let cell = cell as? CustomTicketRatingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
            cell.setupPublicRattings(object)
        }
        else if let cell = cell as? CustomTourOptionTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [TourOptionDataModel], let ticket = cellDict?[kCellTagKey] as? TicketModel else { return }
            cell.setupData(object, ticketModel: ticket)
        }
        else if let cell = cell as? LocationMapViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel, let long = object.location?.coordinates[0], let lat = object.location?.coordinates[1], let address = cellDict?[kCellTagKey] as? String else { return }
            cell.setupData(lat: lat, long: long, address: address)
        }
        else if let cell = cell as? JuniperTourDataTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [ServiceModel] else { return }
            cell.setupData(object)
        }
        else if let cell = cell as? WhosinTourDataTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? [TourOptionsModel] {
                cell.setupData(object)
            } else if let object = cellDict?[kCellObjectDataKey] as? TravelDeskTourModel {
                cell.setupData(object)
            }
        }
        else if let cell = cell as? SuggestedTicketCell {
            if let object = cellDict?[kCellObjectDataKey] as? [TicketModel] {
                cell.setupData(object)
            }
        }
        else if let cell = cell as? ConnectUSTableViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ContactUsModel else { return }
            cell.setup(object, screen: .ticket)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? LocationMapViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel,let long = object.location?.coordinates[0], let lat = object.location?.coordinates[1]  else { return }
            openMapsAppWith(latitude: lat, longitude: long, locationName: "")
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? CustomTicketDetailHeaderCell {
            cell.cellDidDisappear()
            cell._gallayView.pauseVideos()
        }
    }
    
    @objc func playPauseVideoIfVisible() {
        self._tableView.visibleCells.forEach { cell in
            (cell as? CustomTicketDetailHeaderCell)?._gallayView.pauseVideos()
            if cell is CustomTicketDetailHeaderCell {
                guard let indexPath = self._tableView.indexPath(for: cell) else { return }
                let cellRect = self._tableView.rectForRow(at: indexPath)
                if let superview = self._tableView.superview {
                    let convertedRect = self._tableView.convert(cellRect, to:superview)
                    let intersect = self._tableView.frame.intersection(convertedRect)
                    let visibleHeight = intersect.height
                    let cellHeight = cellRect.height
                    let ratio = visibleHeight / cellHeight
                    if ratio <= 0.6 {
                        (cell as? CustomTicketDetailHeaderCell)?._gallayView.pauseVideos()
                    } else {
                        (cell as? CustomTicketDetailHeaderCell)?._gallayView.resumeVideos()
                    }
                }
            }
        }
    }
    
    func refreshData() {
        _requestTicketDetail()
    }
    
    private func openMapsAppWith(latitude: Double, longitude: Double, locationName: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = locationName
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let mapItems = [mapItem]
        let alertController = UIAlertController(title: nil, message: "open_in_maps".localized(), preferredStyle: .actionSheet)
        
        if !Utils.checkIfWazeInstalled() && !Utils.checkIfGoogleMapsInstalled() {
            MKMapItem.openMaps(with: mapItems, launchOptions: launchOptions)
        } else {
            if Utils.checkIfGoogleMapsInstalled() {
                let googleMapsAction = UIAlertAction(title: "google_maps".localized(), style: .default) { _ in
                    let destinationString = "\(latitude),\(longitude)"
                    if let googleMapsURL = URL(string: "comgooglemaps://?saddr=&daddr=\(destinationString)&directionsmode=driving") {
                        UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                    }
                }
                alertController.addAction(googleMapsAction)
            }
            
            if Utils.checkIfWazeInstalled() {
                let wazeAction = UIAlertAction(title: "waze".localized(), style: .default) { _ in
                    let wazeURLString = "waze://?ll=\(latitude),\(longitude)&navigate=yes"
                    if let wazeURL = URL(string: wazeURLString) {
                        UIApplication.shared.open(wazeURL, options: [:], completionHandler: nil)
                    }
                }
                alertController.addAction(wazeAction)
            }
            
            let appleMapsAction = UIAlertAction(title: "apple_maps".localized(), style: .default) { _ in
                MKMapItem.openMaps(with: mapItems, launchOptions: launchOptions)
            }
            alertController.addAction(appleMapsAction)
            
            let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.minX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            present(alertController, animated: true, completion: nil)
        }
    }
}

