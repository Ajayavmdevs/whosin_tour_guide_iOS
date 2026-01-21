import UIKit
import MediaBrowser
import CoreMedia

class BucketDetailVC: ChildViewController {
    
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _bucketName: UILabel!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    public var bucketDetail: BucketDetailModel?
    public var bucketId: String = kEmptyString
    private var _selectedIndex: Int = 0
    private let kCellIdentifierHeader = String(describing: BucketHeaderTableCell.self)
    private let kCellIdentifierBucketDetail = String(describing: BucketOffersTableCell.self)
    private let kCellIdentifierBucketActivity = String(describing: ActivityOfferTableCell.self)
    private let kCellIdentifierBucketEvent = String(describing: EventOffersTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private var _emptyData = [[String:Any]]()
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _requestBucketDetails(true)
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        _requestBucketDetails(false)
    }
    
    override func setupUi() {
        _visualEffectView.alpha = 0
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no bucket detail available",
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.proxyDelegate = self
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReloadList), name: kReloadBucketList, object: nil)
        _emptyData.append(["type": "offer","title" : "Bucket offers looking a bit empty? Toss in some vouchers and kickstart those adventures!", "icon": "empty_offers"])
        _emptyData.append(["type": "activity","title" : "Bucket activitys looking a bit empty? Toss in some vouchers and kickstart those adventures!", "icon": "empty_search"])
        _emptyData.append(["type": "event","title" : "Bucket events looking a bit empty? Toss in some vouchers and kickstart those adventures!", "icon": "empty_event"])


    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierHeader, kCellNibNameKey: kCellIdentifierHeader, kCellClassKey: BucketHeaderTableCell.self, kCellHeightKey: BucketHeaderTableCell.height],
            [kCellIdentifierKey: kCellIdentifierBucketDetail, kCellNibNameKey: kCellIdentifierBucketDetail, kCellClassKey: BucketOffersTableCell.self, kCellHeightKey: BucketOffersTableCell.height],
            [kCellIdentifierKey: kCellIdentifierBucketActivity, kCellNibNameKey: kCellIdentifierBucketActivity, kCellClassKey: ActivityOfferTableCell.self, kCellHeightKey: ActivityOfferTableCell.height],
            [kCellIdentifierKey: kCellIdentifierBucketEvent, kCellNibNameKey: kCellIdentifierBucketEvent, kCellClassKey: EventOffersTableCell.self, kCellHeightKey: EventOffersTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height]

        ]
    }
    
    private func _loadData(isLoading: Bool = false,selectedIndex: Int = 0) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let _bucketDetail = bucketDetail else { return }
        self._bucketName.text = _bucketDetail.name
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierHeader,
            kCellTagKey: kCellIdentifierHeader,
            kCellObjectDataKey: _bucketDetail,
            kCellClassKey: BucketHeaderTableCell.self,
            kCellHeightKey: BucketHeaderTableCell.height
        ])
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        cellData.removeAll()
        switch selectedIndex {
        case 0:
            if !_bucketDetail.offersModel.isEmpty {
                _bucketDetail.offersModel.forEach { bucketItemsModel in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierBucketDetail,
                        kCellTagKey: bucketItemsModel.id,
                        kCellObjectDataKey: bucketItemsModel,
                        kCellClassKey: BucketOffersTableCell.self,
                        kCellHeightKey: BucketOffersTableCell.height
                    ])
                }
            } else {
                _emptyData.forEach { data in
                    if data["type"] as! String == "offer" {
                        cellData.append([
                            kCellIdentifierKey: kEmptyCellIdentifier,
                            kCellTagKey: data,
                            kCellObjectDataKey: data,
                            kCellClassKey: EmptyDataCell.self,
                            kCellHeightKey: EmptyDataCell.height
                        ])
                    }
                }
            }
        case 1:
            if !_bucketDetail.activitiesModel.isEmpty {
                _bucketDetail.activitiesModel.forEach { activitiesModel in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierBucketActivity,
                        kCellTagKey: activitiesModel.id,
                        kCellObjectDataKey: activitiesModel,
                        kCellClassKey: ActivityOfferTableCell.self,
                        kCellHeightKey: ActivityOfferTableCell.height
                    ])
                }
            } else {
                _emptyData.forEach { data in
                    if data["type"] as! String == "activity" {
                        cellData.append([
                            kCellIdentifierKey: kEmptyCellIdentifier,
                            kCellTagKey: data,
                            kCellObjectDataKey: data,
                            kCellClassKey: EmptyDataCell.self,
                            kCellHeightKey: EmptyDataCell.height
                        ])
                    }
                }
            }
        case 2:
            if !_bucketDetail.eventsModel.isEmpty {
                _bucketDetail.eventsModel.forEach { eventsModel in
//                    let venue = Utils.getModelFromId(model: APPSETTING.venueModel, id: eventsModel.venue)
                    if !Utils.isVenueDetailEmpty(eventsModel.venueDetail) {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierBucketEvent,
                            kCellTagKey: eventsModel.id,
                            kCellObjectDataKey: eventsModel,
                            kCellClassKey: EventOffersTableCell.self,
                            kCellHeightKey: EventOffersTableCell.height
                        ])
                    }
                }
            } else {
                _emptyData.forEach { data in
                    if data["type"] as! String == "event" {
                        cellData.append([
                            kCellIdentifierKey: kEmptyCellIdentifier,
                            kCellTagKey: data,
                            kCellObjectDataKey: data,
                            kCellClassKey: EmptyDataCell.self,
                            kCellHeightKey: EmptyDataCell.height
                        ])
                    }
                }
            }
        default:
            break
        }
        
        cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }
    
    @objc private func handleReloadList() {
        _requestBucketDetails()
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestBucketDetails(_ shouldRefresh: Bool = false) {
        if shouldRefresh { showHUD() }
        WhosinServices.getBucketDetail(bucketId: bucketId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.bucketDetail = data
            self._loadData(selectedIndex: self._selectedIndex)
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleChatEvent(_ sender: UIButton) {
        guard let _bucket = bucketDetail else { return }
        let _tmpChatModel = ChatModel()
        _tmpChatModel.chatId = _bucket.id
        _tmpChatModel.chatType = "bucket"
        _tmpChatModel.title = _bucket.name
        _tmpChatModel.image = _bucket.coverImage
        let sharedUser = _bucket.sharedWith.map({ $0.id })
        _tmpChatModel.members.append(objectsIn: sharedUser)
        if !_tmpChatModel.members.contains(where: {$0 == _bucket.userId}) {
            _tmpChatModel.members.append(_bucket.userId)
        }
        if let userDetail = APPSESSION.userDetail {
            if !_tmpChatModel.members.contains(where: { $0 == userDetail.id }) {
                _tmpChatModel.members.append(userDetail.id)
            }
        }
        let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
        vc.chatType = .bucket
        vc.chatModel = _tmpChatModel
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        if self.isVCPresented {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension BucketDetailVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 20
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? BucketHeaderTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? BucketOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            cell.delegate = self
            cell.setupData(object)
            cell.bucketId = bucketDetail?.id ?? kEmptyString
            cell.bucketModel = bucketDetail
        } else if let cell = cell as? ActivityOfferTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            cell.delegate = self
            cell.setupData(object, isFromBucket: true)
            cell.bucketId = bucketDetail?.id ?? kEmptyString
        } else if let cell = cell as? EventOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            cell.delegate = self
            cell.setupData(object, isFromBucket: true)
            cell.bucketId = bucketDetail?.id ?? kEmptyString
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is BucketOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            let vc = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
            vc.modalPresentationStyle = .overFullScreen
            vc.offerId = object.id
            vc.venueModel = object.venue
            vc.timingModel = object.venue?.timing.toArrayDetached(ofType: TimingModel.self)
            vc.vanueOpenCallBack = { venueId, venueModel in
                let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                vc.venueId = venueId
                vc.venueDetailModel = venueModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
            vc.buyNowOpenCallBack = { offer, venue, timing in
                let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
                vc.isFromActivity = false
                vc.type = "offers"
                vc.timingModel = timing
                vc.offerModel = offer
                vc.venue = venue
                vc.setCallback {
                    let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
                    controller.modalPresentationStyle = .overFullScreen
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            presentAsPanModal(controller: vc)

        } else if cell is ActivityOfferTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            let controller = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
            controller.activityId = object.id
            controller.activityName = object.name
            self.navigationController?.pushViewController(controller, animated: true)
        } else if cell is EventOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            let controller = INIT_CONTROLLER_XIB(EventDetailVC.self)
            controller.event = object
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 50: 0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = CustomTableHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50))
        headerView.setupData(_selectedIndex)
        headerView.delegate = self
        return headerView
    }
    
}

extension BucketDetailVC: CustomHeaderViewDelegate {
    func notificationType(type: String) {
    }
    
    func didSelectTab(at index: Int) {
        _selectedIndex = index
        _loadData(isLoading: false, selectedIndex: index)
    }
}

extension BucketDetailVC: ReloadBucketList {
    func reload() {
        _requestBucketDetails(false)
    }
}
