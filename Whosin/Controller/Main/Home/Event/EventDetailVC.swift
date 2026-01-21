import UIKit
import StripePaymentSheet

class EventDetailVC: ChildViewController {
    
    @IBOutlet weak var _venueView: CustomVenueInfoView!
    @IBOutlet private weak var _outView: GradientView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _cancelView: GradientView!
    @IBOutlet private weak var _letsGoView: UIStackView!
    @IBOutlet private weak var _bottomView: UIView!
    @IBOutlet weak var _letsGoBtn: CustomActivityButton!
    @IBOutlet weak var _imOutBtn: CustomActivityButton!
    @IBOutlet weak var _cancelBtn: CustomActivityButton!
    
    private let kCellIdentifierStory = String(describing: EventAdminsTableCell.self)
    private let kCellIdentifierOffers = String(describing: EventInfoTableCell.self)
    private let kCellIdentifierUserInvuted = String(describing: EventInvitedUserTableCell.self)
    private let kLoadingCellIdentifire = String(describing: LoadingCell.self)
    private let kCellIdentifierHighlights = String(describing: EventHighlightsCell.self)
    
    private var _eventModel: EventDetailModel?
    public var event: EventModel?
    public var eventId: String = kEmptyString
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupUi()
        _requestEventDetails()
        _loadData(isLoading: true)
    }
    
    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no event detail available",
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.proxyDelegate = self
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 120, right: 0)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReload), name: kReloadEventDetail, object: nil)
        _visualEffectView.alpha = 0
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestEventDetails() {
        var _eventId = ""
        if let eId = event?.id, !eId.isEmpty {
            _eventId = eId
        } else if !eventId.isEmpty {
            _eventId = eventId
        } else {
            self._dismissView()
            return
        }
        WhosinServices.getEventDetail(eventId: _eventId) { [weak self] container, error in
            guard let self = self else { return }
            self.showError(error)
            guard let data = container?.data else {
                self._dismissView()
                return
            }
            self._eventModel = data
            self._loadData(isLoading: false)
        }
    }
    
    private func _updateInviteStatus(inviteStatus: String) {
        WhosinServices.updateEventInviteStatus(eventId: event?.id ?? eventId, inviteStatus: inviteStatus) { [weak self] container, error in
            guard let self = self else { return }
            self._imOutBtn.hideActivity()
            self._cancelBtn.hideActivity()
            self._letsGoBtn.hideActivity()
            self._outView.isHidden = true
            self._cancelView.isHidden = true
            self._letsGoView.isHidden = false
            self._letsGoBtn.setTitle("Let’s GO!", for: .normal)
            self.view.makeToast(container?.message)
            NotificationCenter.default.post(name: kReloadEventDetail, object: nil, userInfo: nil)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifire,
                kCellTagKey: kLoadingCellIdentifire,
                kCellObjectDataKey: "",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            guard let _eventModel = _eventModel else { return }
            if Utils.isVenueDetailEmpty(_eventModel.event?.venueDetail) {
                _dismissView()
            }
            if let org = _eventModel.event?.orgData {
                _venueView.setupData(venue: org)
            }            
            if _eventModel.event?.myInvitationStatus == "in" {
                _letsGoView.isHidden = true
                _cancelView.isHidden = false
                self._cancelBtn.setTitle("cancel".localized(), for: .normal)
            } else if _eventModel.event?.myInvitationStatus == "out" {
                _bottomView.isHidden = false
                _letsGoView.isHidden = false
                _outView.isHidden = true
            } else {
                _letsGoView.isHidden = false
                _cancelView.isHidden = true
            }
            
            if Utils.isDateExpired(dateString: _eventModel.event?.eventTime, format: kStanderdDate) {
                _bottomView.isHidden = true
            } else {
                _bottomView.isHidden = false
            }

            if let admin = _eventModel.event?.admins {
                let admins = _eventModel.user.toArray(ofType: UserDetailModel.self).filter { admin.contains($0.id) }
                if !admins.isEmpty {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierStory,
                        kCellTagKey: kCellIdentifierStory,
                        kCellObjectDataKey: admins,
                        kCellClassKey: EventAdminsTableCell.self,
                        kCellHeightKey: EventAdminsTableCell.height
                    ])
                }
            }
            cellData.append([
                kCellIdentifierKey: kCellIdentifierOffers,
                kCellTagKey: kCellIdentifierOffers,
                kCellObjectDataKey: _eventModel.event,
                kCellClassKey: EventInfoTableCell.self,
                kCellHeightKey: EventInfoTableCell.height
            ])
            if !(_eventModel.event?.invitedGuest.isEmpty ?? true) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierUserInvuted,
                    kCellTagKey: kCellIdentifierUserInvuted,
                    kCellObjectDataKey: _eventModel.event,
                    kCellClassKey: EventInvitedUserTableCell.self,
                    kCellHeightKey: EventInvitedUserTableCell.height
                ])
            }
            
//            cellData.append([
//                kCellIdentifierKey: kCellIdentifierHighlights,
//                kCellTagKey: kCellIdentifierHighlights,
//                kCellObjectDataKey: _eventModel.event,
//                kCellClassKey: EventHighlightsCell.self,
//                kCellHeightKey: EventHighlightsCell.height
//            ])
        }
        
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierStory, kCellNibNameKey: kCellIdentifierStory, kCellClassKey: EventAdminsTableCell.self, kCellHeightKey: EventAdminsTableCell.height],
            [kCellIdentifierKey: kLoadingCellIdentifire, kCellNibNameKey: kLoadingCellIdentifire, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifierOffers, kCellNibNameKey: kCellIdentifierOffers, kCellClassKey: EventInfoTableCell.self, kCellHeightKey: EventInfoTableCell.height],
            [kCellIdentifierKey: kCellIdentifierUserInvuted, kCellNibNameKey: kCellIdentifierUserInvuted, kCellClassKey: EventInvitedUserTableCell.self, kCellHeightKey: EventInvitedUserTableCell.height],
            [kCellIdentifierKey: kCellIdentifierHighlights, kCellNibNameKey: kCellIdentifierHighlights, kCellClassKey: EventHighlightsCell.self, kCellHeightKey: EventHighlightsCell.height]
        ]
    }
    
    func _openChat(_ chatModel: ChatModel, chatType: ChatType = .user) {
        let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
        vc.chatModel = chatModel
        vc.chatType = chatType
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleCancelEvent(_ sender: UIButton) {
        _cancelBtn.showActivity()
        _updateInviteStatus(inviteStatus: "out")
    }
    
    @IBAction func _handleMessageEvent(_ sender: UIButton) {
        if !Utils.isDateExpired(dateString: _eventModel?.event?.eventTime, format: kStanderdDate) {
            self.feedbackGenerator?.impactOccurred()
            if let _event = _eventModel?.event {
                let _tmpChatModel = ChatModel(_event: _event)
                _openChat(_tmpChatModel, chatType: .event)
            }
        }
    }
    
    @IBAction private func _handleImOutEvent(_ sender: UIButton) {
        _imOutBtn.showActivity()
        _updateInviteStatus(inviteStatus: "out")
    }
    
    @IBAction private func _handleLetsGoEvent(_ sender: UIButton) {
//        if _eventModel?.event?.myInvitationStatus == "out" {
//            _letsGoBtn.showActivity()
//            _letsGoBtn.setTitle("")
//            _updateInviteStatus(inviteStatus: "in")
//        } else {
            let invitedGuest = _eventModel?.event?.invitedGuest.toArrayDetached(ofType: InvitedGuestsModel.self)
            let presentedViewController = INIT_CONTROLLER_XIB(EventAddBottomSheet.self)
            presentedViewController.eventModel = _eventModel
            presentedViewController.eventId = _eventModel?.event?.id ?? ""
            presentedViewController.userIds = invitedGuest?.map { $0.user?.id ?? kEmptyString } ?? []
            presentAsPanModal(controller: presentedViewController)
        //}
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        _dismissView()
    }
    
    @IBAction func _handleOpenEventOrganizer(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(EventOrganisierVC.self)
        controller.orgId = _eventModel?.event?.orgId ?? kEmptyString
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func _dismissView() {
        if self.isVCPresented {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc func handleReload() {
        _requestEventDetails()
    }
    
}

extension EventDetailVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
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
        if let cell = cell as? EventAdminsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return }
            cell.setupData(object)
        } else if let cell = cell as? EventInfoTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            cell.setupData(object, isFromEvent: true)
        } else if let cell = cell as? EventInvitedUserTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            cell.setupData(object, userModel: _eventModel?.user.toArrayDetached(ofType: UserDetailModel.self) ?? [])
        } else if let cell = cell as? EventHighlightsCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            cell.setupData(object, userModel: _eventModel?.user.toArrayDetached(ofType: UserDetailModel.self) ?? [])
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
}
