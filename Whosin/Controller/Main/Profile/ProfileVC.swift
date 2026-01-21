import UIKit
import IQKeyboardManagerSwift
import Parchment
import SnapKit
import ExpandableLabel
import MessageUI
import StickyHeader
import Contacts

class ProfileVC: ChildViewController {
    
    var minContentInsetTop: CGFloat = 40.0
    var maxContentInsetTop: CGFloat = 230.00
    var hideShowContentValue: CGFloat = 80.0
    var previousScrollOffset: CGFloat = 0.0
    var collectionHeight: CGFloat = 0.0
    
    @IBOutlet weak var _tableView: CustomTableView!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    
    private var _feedData: [UserFeedModel] = []
    private let kCellIdentifierUserActivity = String(describing: UserActivityCell.self)
    private let kCellIdentifierOffer = String(describing: CommanOffersTableCell.self)
    private let kCellIdentifierEvent = String(describing: FeedEventCell.self)
    private let kCellIdentifierContact = String(describing: ContactsTableCell.self)
    private let kCellIdentifierVenueDetail = String(describing: BucketTableCell.self)
    private let kEventCellIdentifier = String(describing: MyEventCollectionCell.self)
    private let kOutingCellIdentifier = String(describing: OutingListCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kLoadingCell = String(describing: LoadingCell.self)
    private var _bucketDealsList: [DealsModel] = []
    private var _outingList: [OutingListModel] = []
    private var _eventList: [EventModel] = []
    private var _bucketList: [BucketDetailModel] = []
    
    var filteredDataInvite: [UserDetailModel] = []
    var filteredDataContact: [UserDetailModel] = []
    private var _selectedContacts: [UserDetailModel] = []
//    private var _selectedIndexpath: [Int] = []
    var isSearching = false
    private var isPaginating = false
    private var _page: Int = 1
    public var _selectedtype: String = "Feed"
    public var selectedIndexType: Int  = 0
    private var headerView: ProfileHeaderView?
    private var footerView: LoadingFooterView?
    private var _emptyData = [[String:Any]]()

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        checkSession()
        _feedData.append(UserFeedModel())
        _setupUi()
        _requestData()
        emptyData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _requestData() {
        //"64edd6f8bf6c21af837c699a"
        _requestSuggestedFriend(APPSESSION.userDetail?.id ?? kEmptyString)
        _requestFeedData(true)
        _requestContactList()
        _requestBucketList(false)
        headerView?.getProfileData()
    }

    private func _setupUi() {
        hideNavigationBar()
        if APPSESSION.userDetail?.isPromoter == true {
            Preferences.profileType = ProfileType.promoterProfile
        } else if APPSESSION.userDetail?.isRingMember == true {
            Preferences.profileType = ProfileType.complementaryProfile
        } else {
            Preferences.profileType = ProfileType.profile
        }
        NotificationCenter.default.addObserver(self, selector:  #selector(handleContacts), name: kReloadContacts, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReloadList), name: kReloadBucketList, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReload), name: kReloadEventDetail, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_handleBadgeEvent), name: .readUpdatesState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleVenueFollowState(_:)), name: .changeVenueFollowState, object: nil)
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: nil,
            delegate: self)
        setHeader()
        _tableView.contentInset = UIEdgeInsets(top: self.maxContentInsetTop + collectionHeight, left: 0, bottom: 0, right: 0)
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
        _handleBadgeEvent()
        
    }
    
    private func setHeader(data: [UserDetailModel] = []) {
        _tableView.stickyHeader.view = nil
        headerView = ProfileHeaderView.initFromNib()
        headerView?.segment.setSelectedSegmentIndex(selectedIndexType)
        headerView?.translatesAutoresizingMaskIntoConstraints = false
        headerView?.delegate = self
        headerView?._searchBar.delegate = self
        headerView?.suggestedUsers = data
        _tableView.stickyHeader.view = self.headerView
        _setStickyHeaderMinAndMaxHeight()
    }
    
    private func _requestSuggestedFriend(_ id: String) {
        WhosinServices.getSuggestedUserById(userId: id) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.collectionHeight = data.count == 0 ? 0 : Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.bio) ? 65 : 90
            self.setHeader(data: data)
        }
    }
   
    
    @objc private func _handleBadgeEvent() {
        guard let model = APPSESSION.getUpdateModel else { return }
        if model.bucket || model.outing {
            headerView?.showBucketBadgeValue(isHide: false)
        } else {
            headerView?.showBucketBadgeValue(isHide: true)
        }

        if  model.event {
            headerView?.showEventBadgeValue(isHide: false)
        } else {
            headerView?.showEventBadgeValue(isHide: true)
        }
    }

    private func _setStickyHeaderMinAndMaxHeight() {
        self._tableView.stickyHeader.height = maxContentInsetTop + collectionHeight
        self._tableView.stickyHeader.minimumHeight = minContentInsetTop
    }
    
    private func emptyData() {
        _emptyData.append(["type": "invitations".localized(),"title" : "Bucket list looking a bit empty? Toss in some vouchers and kickstart those adventures", "icon": "empty_bucket"])
        _emptyData.append(["type": "my_events".localized(),"title" : "empty_event_list".localized(), "icon": "empty_bucket"])
        _emptyData.append(["type": "friends".localized(),"title" : "your_friends_list".localized(), "icon": "empty_following"])
    }

//    private func updateEmptyData() {
//        _tableView.verticleOffset = self.maxContentInsetTop + collectionHeight / 2
//        var image: UIImage = UIImage()
//        var msg: String = kEmptyString
//        if _selectedtype == "Feed" {
//            image = UIImage(named: "empty_feed") ?? UIImage()
//            msg = "Your feed's looking a little too quiet Follow your favorite venues or friends to Keep up with the latest offers and happenings"
//        } else if _selectedtype == "Invitations" {
//            image = UIImage(named: "empty_bucket") ?? UIImage()
//            msg = "Bucket list looking a bit empty? Toss in some vouchers and kickstart those adventures"
//        } else if _selectedtype == "My Event" {
//            image = UIImage(named: "empty_bucket") ?? UIImage()
//            msg = "Event list looking a bit empty? Toss in some vouchers and kickstart those adventures"
//        } else if _selectedtype == "Friends" {
//            image = UIImage(named: "empty_following") ?? UIImage()
//            msg = "Your friends list could use some company! Add friends, and let the good times roll"
//        }
//        _tableView.updateEmptyDataText(title: kEmptyString, description: msg, image: image)
//    }
    
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierUserActivity, kCellNibNameKey: kCellIdentifierUserActivity, kCellClassKey: UserActivityCell.self, kCellHeightKey: UserActivityCell.height],
            [kCellIdentifierKey: kCellIdentifierOffer, kCellNibNameKey: kCellIdentifierOffer, kCellClassKey: CommanOffersTableCell.self, kCellHeightKey: CommanOffersTableCell.height],
            [kCellIdentifierKey: kCellIdentifierEvent, kCellNibNameKey: kCellIdentifierEvent, kCellClassKey: FeedEventCell.self, kCellHeightKey: FeedEventCell.height],
            [kCellIdentifierKey: kCellIdentifierContact, kCellNibNameKey: kCellIdentifierContact, kCellClassKey: ContactsTableCell.self, kCellHeightKey: ContactsTableCell.height],
            [kCellIdentifierKey: kCellIdentifierVenueDetail, kCellNibNameKey: kCellIdentifierVenueDetail, kCellClassKey: BucketTableCell.self, kCellHeightKey: BucketTableCell.height],
            [kCellIdentifierKey: kOutingCellIdentifier, kCellNibNameKey: kOutingCellIdentifier, kCellClassKey: OutingListCell.self, kCellHeightKey: OutingListCell.height],
            [kCellIdentifierKey: kEventCellIdentifier, kCellNibNameKey: kEventCellIdentifier, kCellClassKey:  MyEventCollectionCell.self, kCellHeightKey: MyEventCollectionCell.height],
            [kCellIdentifierKey: String(describing: MyOutingTableCell.self), kCellNibNameKey: String(describing: MyOutingTableCell.self), kCellClassKey:  MyOutingTableCell.self, kCellHeightKey: MyOutingTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kLoadingCell, kCellNibNameKey: kLoadingCell, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if _selectedtype == "Feed" {
            if _feedData.count == 1 && _feedData[0].type.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kLoadingCell,
                    kCellTagKey: kEmptyString,
                    kCellObjectDataKey: "Loading...",
                    kCellClassKey: LoadingCell.self,
                    kCellHeightKey: LoadingCell.height
                ])
            } else if _feedData.isEmpty {
                _emptyData.forEach { data in
                    if data["type"] as! String == "Feed" {
                        cellData.append([
                            kCellIdentifierKey: kEmptyCellIdentifier,
                            kCellTagKey: data,
                            kCellObjectDataKey: data,
                            kCellClassKey: EmptyDataCell.self,
                            kCellHeightKey: EmptyDataCell.height
                        ])
                    }
                }
            } else {
                _feedData.forEach { feeds in
                    if feeds.type == "friend_updates" {
                        if feeds.user != nil {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierUserActivity,
                                kCellTagKey: kCellIdentifierUserActivity,
                                kCellObjectDataKey: feeds,
                                kCellClassKey: UserActivityCell.self,
                                kCellHeightKey: UserActivityCell.height
                            ])
                        }
                    } else if feeds.type == "venue_updates" {
                        if feeds.venue != nil {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierOffer,
                                kCellTagKey: kCellIdentifierOffer,
                                kCellObjectDataKey: feeds,
                                kCellClassKey: CommanOffersTableCell.self,
                                kCellHeightKey: CommanOffersTableCell.height
                            ])
                        }
                    } else if feeds.type == "event_checkin" {
                        if feeds.user != nil {
                            if !Utils.isVenueDetailEmpty(feeds.event?.venueDetail) {
                                cellData.append([
                                    kCellIdentifierKey: kCellIdentifierEvent,
                                    kCellTagKey: kCellIdentifierEvent,
                                    kCellObjectDataKey: feeds,
                                    kCellClassKey: FeedEventCell.self,
                                    kCellHeightKey: FeedEventCell.height
                                ])
                            }
                        }
                    }
                }
            }
            if cellData.count != .zero {
                cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            }
        }
        else if _selectedtype == "Invitations" {
            
            cellData.append([
                kCellIdentifierKey: String(describing: MyOutingTableCell.self),
                kCellTagKey: String(describing: MyOutingTableCell.self),
                kCellObjectDataKey: _outingList,
                kCellClassKey: MyOutingTableCell.self,
                kCellHeightKey: MyOutingTableCell.height
            ])
            
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            cellData.removeAll()
            if _bucketList.isEmpty {
                _emptyData.forEach { data in
                    if data["type"] as! String == "Invitations" {
                        cellData.append([
                            kCellIdentifierKey: kEmptyCellIdentifier,
                            kCellTagKey: data,
                            kCellObjectDataKey: data,
                            kCellClassKey: EmptyDataCell.self,
                            kCellHeightKey: EmptyDataCell.height
                        ])
                    }
                }
            } else {
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
            
            cellSectionData.append([kSectionTitleKey: "My Buckets" , kSectionRightInfoKey: "Create +",
                               kSectionIdentifierKey: 1,
             kSectionShowRightInforAsActionButtonKey: true,
                           kSectionRightTextColorKey: UIColor.white,
                            kSectionRightTextBgColor:  ColorBrand.brandGreen,
                                     kSectionDataKey: cellData])
            cellData.removeAll()
        }
        else if _selectedtype == "My Event" {
            
            if _eventList.isEmpty {
                _emptyData.forEach { data in
                    if data["type"] as! String == "My Event" {
                        cellData.append([
                            kCellIdentifierKey: kEmptyCellIdentifier,
                            kCellTagKey: data,
                            kCellObjectDataKey: data,
                            kCellClassKey: EmptyDataCell.self,
                            kCellHeightKey: EmptyDataCell.height
                        ])
                    }
                }
            } else {
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
            }
            
            cellSectionData.append([kSectionTitleKey: "My Events", kSectionRightInfoKey: "see_all".localized(),
                               kSectionIdentifierKey: 1,
             kSectionShowRightInforAsActionButtonKey: true,
                           kSectionRightTextColorKey: UIColor.white,
                            kSectionRightTextBgColor: ColorBrand.brandPink,
                                     kSectionDataKey: cellData])
            cellData.removeAll()
            
        }
        else if _selectedtype == "Friends" {
            if isSearching {
                filteredDataContact.forEach { contact in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierContact,
                        kCellTagKey: contact.id,
                        kCellObjectDataKey: contact,
                        kCellStatusKey: false,
                        kCellClassKey: ContactsTableCell.self,
                        kCellHeightKey: ContactsTableCell.height
                    ])
                }
                if cellData.count != .zero {
                    cellSectionData.append([kSectionTitleKey: "Friends on WhosIN", kSectionDataKey: cellData, kSectionFontSize: 16, kSectionFontColor: ColorBrand.sectionTitleColor])
                }
                
                cellData.removeAll()
                filteredDataInvite.forEach { contact in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierContact,
                        kCellTagKey: contact.id,
                        kCellObjectDataKey: contact,
                        kCellTitleKey: "\(contact.firstName) \(contact.lastName)",
                        kCellDifferenceContentKey: Utils.stringIsNullOrEmpty(contact.phone) ? contact.email : contact.phone,
                        kCellImageUrlKey: contact.image,
                        kCellButtonTitleKey: contact.follow,
                        kCellStatusKey: true,
                        kCellClassKey: ContactsTableCell.self,
                        kCellHeightKey: ContactsTableCell.height
                    ])
                }
                
                if cellData.count != .zero {
                    cellSectionData.append([kSectionIdentifierKey :1,kSectionTitleKey: "Invite your friends",kSectionShowRightInforAsActionButtonKey: true,kSectionRightTextBgColor: ColorBrand.brandGreen, kSectionRightInfoKey :"Invite(\(_selectedContacts.count))", kSectionDataKey: cellData , kSectionFontSize: 16, kSectionFontColor: ColorBrand.sectionTitleColor])
                }
                
            }
            else {
                WHOSINCONTACT.contactList.forEach { contact in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierContact,
                        kCellTagKey:  contact.id,
                        kCellObjectDataKey: contact,
                        kCellStatusKey: false,
                        kCellClassKey: ContactsTableCell.self,
                        kCellHeightKey: ContactsTableCell.height
                    ])
                }
                
                if cellData.count != .zero {
                    cellSectionData.append([kSectionTitleKey: "Friends on WhosIN", kSectionDataKey: cellData, kSectionFontSize: 16, kSectionFontColor: ColorBrand.sectionTitleColor])
                }
                
                cellData.removeAll()
                WHOSINCONTACT.inviteContactList.forEach { contact in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierContact,
                        kCellTagKey: contact.id,
                        kCellObjectDataKey: contact,
                        kCellStatusKey: true,
                        kCellClassKey: ContactsTableCell.self,
                        kCellHeightKey: ContactsTableCell.height
                    ])
                }
                cellSectionData.append([kSectionIdentifierKey :1,kSectionTitleKey: "Invite your friends",kSectionShowRightInforAsActionButtonKey: true,kSectionRightTextBgColor: ColorBrand.brandGreen, kSectionRightInfoKey :"Invite(\(_selectedContacts.count))", kSectionDataKey: cellData, kSectionFontSize: 16, kSectionFontColor: ColorBrand.sectionTitleColor])
            }
            
        }
        _tableView.loadData(cellSectionData)
    }
    
    @objc private func handleVenueFollowState(_ notification: Notification) {
        _feedData.removeAll()
        _requestFeedData()
    }

    @objc func handleContacts() {
        _requestContactList()
    }
    
    @objc private func handleReloadList() {
        _requestBucketList()
    }
    
    @objc func handleReload() {
        _requestBucketList()
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestFeedData(_ shouldRefresh: Bool = false) {
        if shouldRefresh { showHUD() }
        WhosinServices.getFeedList(page: _page, limit: 30) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.footerView?.stopAnimating()
            guard let data = container?.data else { return }
            self.isPaginating = false
            _emptyData.append(["type": "Feed","title" : "feed_fragment_empty_message".localized(), "icon": "empty_feed"])
            if !data.isEmpty {
                self._feedData.append(contentsOf: data)
                self._loadData()
            } else if _feedData.count == 1 && _feedData[0].type.isEmpty {
                self._feedData.removeAll()
                self._loadData()
            }
        }
    }
    
    private func _requestContactList() {
//        if WHOSINCONTACT.inviteContactList.isEmpty {
//            showHUD()
//            WHOSINCONTACT.sync { [weak self] error in
//                guard let self = self else { return }
//                self.hideHUD( error: error)
//                self._loadData()
//            }
//        } else {
//            WHOSINCONTACT.sync { [weak self] error in
//                guard let self = self else { return }
//                self.hideHUD( error: error)
//                self._loadData()
//            }
//        }
    }
    
    private func _requestBucketList(_ shouldRefresh: Bool = false) {
        if shouldRefresh { showHUD() }
        WhosinServices.requestMyBucketList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._bucketList = data.bucketList.toArrayDetached(ofType: BucketDetailModel.self)
            self._eventList = data.events.toArrayDetached(ofType: EventModel.self)
            let outingList = data.outings.toArrayDetached(ofType: OutingListModel.self)
            self._outingList = outingList.filter({ $0.owner != nil })
            self._bucketDealsList = data.deals.toArrayDetached(ofType: DealsModel.self)
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true) {
            self.hideHUD()
        }
    }
    
}

extension ProfileVC: CustomTableViewDelegate, UITableViewDelegate {

    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? UserActivityCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? CommanOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            cell.setup(object.offer ?? OffersModel(), type: .feed, object)
            cell._feedInfoView.isHidden = false
        } else if let cell = cell as? FeedEventCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            cell.setupData(object)
        } else  if let cell = cell as? ContactsTableCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel, let isInvite = cellDict?[kCellStatusKey] as? Bool {
//            var isSelected = false
            //let selectedContact = isSearching ? filteredDataInvite[indexPath.row] : WHOSINCONTACT.inviteContactList[indexPath.row]
            let isSelected = _selectedContacts.contains(where: { ($0.phone == object.phone && !$0.phone.isEmpty) || ($0.email == object.email && !$0.email.isEmpty)  })
            let isFirstRow = indexPath.row == 0
            let lastRow = _tableView.numberOfRows(inSection: indexPath.section) - 1
            let isLastRow = indexPath.row == lastRow
            cell.setPrifileConstraint(lastRow: isLastRow, firstRow: isFirstRow)
            cell.setupData(object, isInvite: isInvite, isSelected: isSelected)
        } else if let cell = cell as? BucketTableCell {
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
            cell.setupData(object, "invitations".localized())
        } else if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is CommanOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            let vc = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
            vc.modalPresentationStyle = .overFullScreen
            vc.offerId = object.offer?.id ?? ""
            vc.venueModel = object.offer?.venue
            vc.timingModel = object.offer?.venue?.timing.toArrayDetached(ofType: TimingModel.self)
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
        } else if cell is UserActivityCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            let controller = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            controller.venueDetailModel = object.venue
            controller.venueId = object.venue?.id ?? ""
            navigationController?.pushViewController(controller, animated: true)
        } else if cell is FeedEventCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            let controller = INIT_CONTROLLER_XIB(EventDetailVC.self)
            controller.eventId = object.event?.id ?? ""
            self.navigationController?.pushViewController(controller, animated: true)
        } else if sectionTitle == "Invite your friends"  {
            let selectedContact = isSearching ? filteredDataInvite[indexPath.row] : WHOSINCONTACT.inviteContactList[indexPath.row]
            if _selectedContacts.contains(selectedContact) {
                if let index = _selectedContacts.firstIndex(of: selectedContact) {
                    _selectedContacts.remove(at: index)
                }
            } else {
                _selectedContacts.append(selectedContact)
            }
            _loadData()
        } else if cell is ContactsTableCell {
            let user = WHOSINCONTACT.contactList[indexPath.row]
            guard let userDetail = APPSESSION.userDetail, userDetail.id != user.id else { return }
            if user.isPromoter, userDetail.isRingMember {
                let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                vc.promoterId = user.id
                vc.isFromPersonal = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if user.isRingMember, userDetail.isPromoter {
                let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                vc.complimentryId = user.id
                vc.isFromPersonal = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                vc.contactId = user.id
                vc.followStateCallBack = { id, isFollow in
                    WHOSINCONTACT.contactList.first(where: { $0.id == id})?.follow = isFollow
                    self.filteredDataContact.first(where: { $0.id == id})?.follow = isFollow
                    self._loadData()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if cell is OutingListCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OutingListModel else { return }
            let controller = INIT_CONTROLLER_XIB(OutingDetailVC.self)
            controller.outingId = object.id
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
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
        if _selectedtype == "Invitations" {
            if section == 1 {
                let presentedViewController = INIT_CONTROLLER_XIB(CreateBucketBottomSheet.self)
                presentAsPanModal(controller: presentedViewController)
            }
        }
        else if _selectedtype == "My Event" {
            let controller = INIT_CONTROLLER_XIB(SeeAllEventListVC.self)
            controller.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let contact = WHOSINCONTACT.inviteContactList.filter { whosinContact in
                return _selectedContacts.contains { selectedContact in
                    return whosinContact.phone == selectedContact.phone
                }
            }
            let numbers = contact.map { $0.phone }
            if numbers.isEmpty { return }
            guard MFMessageComposeViewController.canSendText() else { return }
            let messageVC = MFMessageComposeViewController()
            messageVC.body = kInviteMessage;
            messageVC.recipients = numbers
            messageVC.messageComposeDelegate = self;
            self.present(messageVC, animated: false, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if _selectedtype == "Feed" {
            let scrollOffsetThreshold = scrollView.contentSize.height - scrollView.bounds.height
            if scrollOffsetThreshold > 0 && scrollView.contentOffset.y > scrollOffsetThreshold && !isPaginating {
                performPagination()
            }
        }
        if(scrollView.contentOffset.y > 40) { return }

        let scrollDirection: CGFloat = scrollView.contentOffset.y > previousScrollOffset ? 0.5 : 20.0
        previousScrollOffset = scrollView.contentOffset.y
        var yOffset = abs(scrollView.contentOffset.y) + scrollDirection
        if yOffset < minContentInsetTop {
            yOffset = minContentInsetTop
        } else if yOffset > maxContentInsetTop + collectionHeight {
            yOffset = maxContentInsetTop + collectionHeight
        } else if yOffset < hideShowContentValue {
            headerView?._userBioLabel.isHidden = true
//            headerView?.editProfilebtn.isHidden = true
            headerView?._collectionView.isHidden = true
        } else if yOffset > hideShowContentValue {
            headerView?._userBioLabel.isHidden = false
//            headerView?.editProfilebtn.isHidden = false
            headerView?._collectionView.isHidden = false
        }
        self._tableView.contentInset = UIEdgeInsets(top: yOffset, left: 0, bottom: 0, right: 0)
    }

    private func performPagination() {
        guard !isPaginating else { return }
        if _feedData.count % 30 == 0 {
            isPaginating = true
            _page += 1
            footerView?.startAnimating()
            _requestFeedData(false)
        }
    }
    
    func refreshData() {
        _requestBucketList(true)
    }
    
}

extension ProfileVC: ProfileTableHeaderViewDelegate {
    func profileHeaderdidSelectTab(index: Int, newHeight: CGFloat, isExpanded: Bool) {
        self.view.endEditing(true)
        if let type = ContentType.returnType(for: index) {
            _selectedtype = type
            if _selectedtype == "Friends" {
                if isExpanded {
                    minContentInsetTop = 96.0
                    maxContentInsetTop = 260 + newHeight + collectionHeight
                    hideShowContentValue = 170.0
                } else {
                    minContentInsetTop = 96.0
                    maxContentInsetTop = 286.00 + collectionHeight
                    hideShowContentValue = 160.0
                }
            } else {
                if isExpanded {
                    minContentInsetTop = 40.0
                    maxContentInsetTop = 230.00 + newHeight + collectionHeight
                    hideShowContentValue = 100.0
                } else {
                    minContentInsetTop = 40.0
                    maxContentInsetTop = 230.00 + collectionHeight
                    hideShowContentValue = 90.0
                }
                if index == 2 {
                    APPSESSION.readUpdate(type: "event")
                    APPSESSION.getUpdateModel?.event = false
                    _handleBadgeEvent()
                } else if index == 1 {
                    APPSESSION.readUpdate(type: "bucket")
                    APPSESSION.getUpdateModel?.bucket = false
                    APPSESSION.readUpdate(type: "outing")
                    APPSESSION.getUpdateModel?.outing = false
                    _handleBadgeEvent()
                }
            }
            self._setStickyHeaderMinAndMaxHeight()
            _loadData()
        }
    }

    func didSelectTab(at index: Int) {
        self.view.endEditing(true)
        if let type = ContentType.returnType(for: index) {
            _selectedtype = type
            if _selectedtype == "Friends" {
                minContentInsetTop = 96.0
                maxContentInsetTop = 286.00 + collectionHeight
                hideShowContentValue = 150.0
            } else {
                minContentInsetTop = 40.0
                maxContentInsetTop = 230.00 + collectionHeight
                hideShowContentValue = 80.0
                if index == 2 {
                    APPSESSION.readUpdate(type: "event")
                    APPSESSION.getUpdateModel?.event = false
                    _handleBadgeEvent()
                } else if index == 1 {
                    APPSESSION.readUpdate(type: "bucket")
                    APPSESSION.getUpdateModel?.bucket = false
                    APPSESSION.readUpdate(type: "outing")
                    APPSESSION.getUpdateModel?.outing = false
                    _handleBadgeEvent()
                }
            }
            self._setStickyHeaderMinAndMaxHeight()
            _loadData()
        }
    }
}

extension ProfileVC : MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
}

extension ProfileVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            _loadData()
        } else {
            isSearching = true
            filteredDataContact = WHOSINCONTACT.contactList.filter({ $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) })
            filteredDataInvite = WHOSINCONTACT.inviteContactList.filter({ $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) })
            _loadData()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}
