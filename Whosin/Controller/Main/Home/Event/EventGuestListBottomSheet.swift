import UIKit

class EventGuestListBottomSheet: PanBaseViewController {

    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet weak var _title: UILabel!
    private let kCellIdentifier = String(describing: EventGuestListTableCell.self)
    public var _userList: [UserDetailModel]?
    private var _invitationList: [InvitationModel] = []
    var eventId: String = kEmptyString
    private var _page : Int = 1
    var inviteStatus: String = kEmptyString
    public var isMutualFriend: Bool = false
    public var isFromOuting: Bool = false 
    private var footerView: LoadingFooterView?
    public var userOpenCallBack: ((_ userId: String) -> Void)?
    public var openChatCallBack: ((_ chatModel: ChatModel) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _title.text = isFromOuting ? "invited Guests" : isMutualFriend ? "mutual_friends".localized() : "Invited Guests"
        isFromOuting ? _loadData() : isMutualFriend ? _loadData() : _eventGuestListData()
    }
    
    override func setupUi() {
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no guest available",
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.proxyDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleReload), name: Notification.Name("reloadGuestList"), object: nil)
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------

    private func _eventGuestListData() {
        self.isRequesting = true
        WhosinServices.getEventGuestList(eventId: eventId, inviteStatus: inviteStatus, page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.footerView?.stopAnimating()
            guard let data = container?.data else { return }
            if self._invitationList.isEmpty {
                self._invitationList = data.invitation.toArrayDetached(ofType: InvitationModel.self)
                self._userList = data.user.toArrayDetached(ofType: UserDetailModel.self)
            } else {
                self._invitationList.append(contentsOf: data.invitation.toArrayDetached(ofType: InvitationModel.self))
                self._userList?.append(contentsOf:data.user.toArrayDetached(ofType: UserDetailModel.self))
            }

            self._loadData()
            self.isRequesting = false
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if isMutualFriend {
            _userList?.forEach({ user in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: user,
                    kCellClassKey: EventGuestListTableCell.self,
                    kCellHeightKey: EventGuestListTableCell.height
                ])
            })
        } else if isFromOuting {
            _userList?.forEach({ user in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: user,
                    kCellClassKey: EventGuestListTableCell.self,
                    kCellHeightKey: EventGuestListTableCell.height
                ])
            })
        }else {
            self._invitationList.forEach { guestList in
                if let user = _userList?.first(where: { $0.id == guestList.userId}) {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: kCellIdentifier,
                        kCellObjectDataKey: guestList,
                        kCellItemsKey: user,
                        kCellClassKey: EventGuestListTableCell.self,
                        kCellHeightKey: EventGuestListTableCell.height
                    ])
                }
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)

    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: EventGuestListTableCell.self), kCellClassKey: EventGuestListTableCell.self, kCellHeightKey: EventGuestListTableCell.height] ]
    }
    
    @objc func handleReload() {
        _eventGuestListData()
    }

    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func _handleInviteEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
}


extension EventGuestListBottomSheet: CustomTableViewDelegate,UIScrollViewDelegate,UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height * 0.8
        
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isRequesting {
            performPagination()
        }
    }

    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        let cell = cell as? EventGuestListTableCell
        if isMutualFriend {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            cell?.setupMutualFriends(userModel: object)
        } else if isFromOuting {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            cell?.setupInvitationData(nil, userModel: object, isFromOuting: true)
        } else {
            guard let object = cellDict?[kCellObjectDataKey] as? InvitationModel else { return }
            guard let user = cellDict?[kCellItemsKey] as? UserDetailModel else { return }
            cell?.setupInvitationData(object, userModel:user)
        }
        cell?.chatOpenCallBack = { chatModel in
//            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
//            vc.hidesBottomBarWhenPushed = true
//            vc.chatModel = chatModel
            self.dismiss(animated: true) {
                self.openChatCallBack?(chatModel)
            }
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if isMutualFriend {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            guard let userDetail = APPSESSION.userDetail else { return }
            if object.id != userDetail.id {
                dismiss(animated: true) {
                    self.userOpenCallBack?(object.id)
                }
            }
        } else if isFromOuting {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            guard let userDetail = APPSESSION.userDetail else { return }
            if object.id != userDetail.id {
                dismiss(animated: true) {
                    self.userOpenCallBack?(object.id)
                }
            }
        } else {
            guard let object = cellDict?[kCellItemsKey] as? UserDetailModel else { return }
            guard let userDetail = APPSESSION.userDetail else { return }
            if object.id != userDetail.id {
                dismiss(animated: true) {
                    self.userOpenCallBack?(object.id)
                }
            }
        }
    }
    
    private func performPagination() {
        if !isRequesting, (_invitationList.count) % 30 == 0 {
            footerView?.startAnimating()
            _page += 1
            footerView?.startAnimating()
            _eventGuestListData()
        }
    }
}
