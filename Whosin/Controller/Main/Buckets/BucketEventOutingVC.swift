import UIKit

class BucketEventOutingVC: ContactBaseVC {
    
    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifierVenueDetail = String(describing: BucketTableCell.self)
    private let kEventCellIdentifier = String(describing: MyEventCollectionCell.self)
    private let kOutingCellIdentifier = String(describing: OutingListCell.self)
    private let kSpecialOfferCellIdentifier = String(describing: MySpedcialOfferCell.self)
    private let kLoadingCellIdentifier = String(describing: LoadingCell.self)
    private var _bucketDealsList: [DealsModel] = []
    private var _outingList: [OutingListModel] = []
    private var _eventList: [EventModel] = []
    private var _bucketList: [BucketDetailModel] = []
    public var _type: String = kEmptyString
    
    override var customTableView: CustomTableView? { _tableView }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _requestBucketList(true)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReloadList), name: kReloadBucketList, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _requestBucketList()
    }

    override func setupUi() {
        
        hideNavigationBar()
        hideLeftBarButton(true)
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: true,
            isShowRefreshing: true,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_bucket"),
            emptyDataDescription: "Bucket list looking a bit empty? Toss in some vouchers and kickstart those adventures",
            delegate: self)
        _tableView.showsVerticalScrollIndicator = false
        _tableView.isScrollEnabled = false
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: kCollectionDefaultMargin, right: 0)
        
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestBucketList(_ shouldRefresh: Bool = false) {
        if shouldRefresh { showHUD() }
        WhosinServices.requestMyBucketList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._bucketList = data.bucketList.toArrayDetached(ofType: BucketDetailModel.self)
            self._eventList = data.events.toArrayDetached(ofType: EventModel.self)
            self._outingList = data.outings.toArrayDetached(ofType: OutingListModel.self)
            self._bucketDealsList = data.deals.toArrayDetached(ofType: DealsModel.self)
            self._loadData()
        }
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if _type == "event" {
            _eventList.forEach { model in
                if !Utils.isVenueDetailEmpty(model.venueDetail) {
                    cellData.append([
                        kCellIdentifierKey: kEventCellIdentifier,
                        kCellTagKey: kEventCellIdentifier,
                        kCellObjectDataKey: model,
                        kCellClassKey: MyEventCollectionCell.self,
                        kCellHeightKey: MyEventCollectionCell.height
                    ])
                }
            }
        } else if _type == "outing" {
            _outingList.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kOutingCellIdentifier,
                    kCellTagKey: kOutingCellIdentifier,
                    kCellObjectDataKey: _outingList,
                    kCellClassKey: OutingListCell.self,
                    kCellHeightKey: OutingListCell.height
                ])
            }
        } else if _type == "bucket" {
            cellData.append([
                kCellIdentifierKey: String(describing: MyOutingTableCell.self),
                kCellTagKey: String(describing: MyOutingTableCell.self),
                kCellObjectDataKey: _outingList,
                kCellClassKey: MyOutingTableCell.self,
                kCellHeightKey: MyOutingTableCell.height
            ])
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            cellData.removeAll()
            _bucketList.forEach { BucketDetailModel in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierVenueDetail,
                    kCellTagKey: kCellIdentifierVenueDetail,
                    kCellObjectDataKey: BucketDetailModel,
                    kCellClassKey: BucketTableCell.self,
                    kCellHeightKey: BucketTableCell.height
                ])
            }
        }
        
        cellSectionData.append([kSectionTitleKey: self.title ?? kEmptyString, kSectionRightInfoKey: _type == "bucket" ? "Create +" : "see_all".localized(),
                           kSectionIdentifierKey: 1,
         kSectionShowRightInforAsActionButtonKey: true,
                       kSectionRightTextColorKey: UIColor.white,
                        kSectionRightTextBgColor: _type == "bucket" ? ColorBrand.brandGreen : ColorBrand.brandPink,
                                 kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierVenueDetail, kCellNibNameKey: kCellIdentifierVenueDetail, kCellClassKey: BucketTableCell.self, kCellHeightKey: BucketTableCell.height],
            [kCellIdentifierKey: kOutingCellIdentifier, kCellNibNameKey: kOutingCellIdentifier, kCellClassKey: OutingListCell.self, kCellHeightKey: OutingListCell.height],
            [kCellIdentifierKey: kEventCellIdentifier, kCellNibNameKey: kEventCellIdentifier, kCellClassKey:  MyEventCollectionCell.self, kCellHeightKey: MyEventCollectionCell.height],
            [kCellIdentifierKey: String(describing: MyOutingTableCell.self), kCellNibNameKey: String(describing: MyOutingTableCell.self), kCellClassKey:  MyOutingTableCell.self, kCellHeightKey: MyOutingTableCell.height]]
    }
    
    
    @objc private func handleReloadList() {
        _requestBucketList(false)
    }
}

extension BucketEventOutingVC: CustomTableViewDelegate {
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll(scrollView: scrollView)
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? BucketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? OutingListCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OutingListModel else { return }
            cell.setupData(object)
        }  else if let cell = cell as? MyEventCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            cell.setupEventData(object)
        } else if let cell = cell as? MyOutingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [OutingListModel] else { return }
            cell.setupData(object, "My outings")
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is OutingListCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OutingListModel else { return }
            let controller = INIT_CONTROLLER_XIB(OutingDetailVC.self)
            controller.outingId = object.id
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
            // TODO: kReloadBucketList for check
            // NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
        } else if cell is MyEventCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            let vc = INIT_CONTROLLER_XIB(EventDetailVC.self)
            vc.event = object
            self.navigationController?.pushViewController(vc, animated: true)
        } else if cell is BucketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel else { return }
            let destinationViewController = INIT_CONTROLLER_XIB(BucketDetailVC.self)
            destinationViewController.bucketDetail = object
            destinationViewController.bucketId = object.id
            self.navigationController?.pushViewController(destinationViewController, animated: true)
        }
        
    }
    
    func handleHeaderActionEvent(section: Int, identifier: Int) {
        if _type == "bucket" {
            let presentedViewController = INIT_CONTROLLER_XIB(CreateBucketBottomSheet.self)
//            presentedViewController.modalPresentationStyle = .custom
//            presentedViewController.transitioningDelegate = self
            presentAsPanModal(controller: presentedViewController)
        }
        else if _type == "outing" {
            let controller = INIT_CONTROLLER_XIB(SeeAllOutingListVC.self)
            controller.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if _type == "event" {
            let controller = INIT_CONTROLLER_XIB(SeeAllEventListVC.self)
            controller.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func refreshData() {
        _requestBucketList(true)
    }
    
}

extension BucketEventOutingVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}
