import UIKit
import SnapKit


class FollowListVC: ChildViewController {

    @IBOutlet private weak var _titleName: UILabel!
    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifier = String(describing: ContactsTableCell.self)
    private let kCellIdentifierpending = String(describing: PendingRequestTableCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var contactList: [UserDetailModel] = []
    public var isFollowerList: Bool = false
    public var followId: String = kEmptyString
    public var delegate: ActionButtonDelegate?
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _requestPendingFollowRequest()
        isFollowerList ? _requestFollowersList() : _requestFollowingList()
        setupUi()
    }
    
    
    override func setupUi() {
        hideNavigationBar()
        hideLeftBarButton(true)
        _titleName.text = isFollowerList ? "followers".localized() : "following".localized()
        //TABLE VIEW
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: isFollowerList ?  UIImage(named: "empty_follower") : UIImage(named: "empty_following"),
            emptyDataDescription: isFollowerList ? "empty_follow_list".localized() : "following_list_lonely".localized(),
            delegate: self)
        _tableView.showsVerticalScrollIndicator = false
        _tableView.isScrollEnabled = true
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: kCollectionDefaultMargin, right: 0)
        _visualEffectView.alpha = 0.0
        
        if !isFollowerList && (followId == APPSESSION.userDetail?.id || followId == APPSESSION.userDetail?.userId) {
            NotificationCenter.default.addObserver(self, selector: #selector(_handleFollowStatusEvent(_:)), name: kReloadFollowStatus, object: nil)
        }
    }
    
    @objc func _handleFollowStatusEvent(_ notification: Notification) {
        guard let model = notification.object as? UserDetailModel else { return }
        if model.status == "unfollowed" {
            contactList.removeAll { $0.id == model.id }
            _loadData()
        } else {
            _requestFollowingList()
        }
    }
    
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestFollowersList() {
        showHUD()
        WhosinServices.getFollowersList(id: followId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.contactList = data
            self._loadData(false)
        }
    }
    
    private func _requestFollowingList() {
        showHUD()
        WhosinServices.getFollowingList(id: followId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.contactList = data
            self._loadData(false)
        }
    }
    
    private func _requestPendingFollowRequest() {
        WhosinServices.followRequestList { [weak self]container, error in
            guard let self = self else { return }
            self.showError(error)
            guard let data = container?.data else { return }
            APPSETTING.pendingRequestList = data
        }
    }

    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData(_ isLoading: Bool = false) {
        self.hideHUD()
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()

        let isPrivate = APPSESSION.userDetail?.isProfilePrivate == true && followId == APPSESSION.userId && isFollowerList
        if isPrivate {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierpending,
                kCellTagKey: kCellIdentifierpending,
                kCellObjectDataKey: APPSETTING.pendingRequestList,
                kCellClassKey: PendingRequestTableCell.self,
                kCellHeightKey: PendingRequestTableCell.height
            ])
        }
        
        _contactList.forEach { contact in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellDifferenceIdentifierKey: contact.id,
                kCellDifferenceContentKey : contact.hashValue,
                kCellTagKey: contact.id,
                kCellObjectDataKey: contact,
                kCellClassKey: ContactsTableCell.self,
                kCellHeightKey: ContactsTableCell.height
            ])
        }

        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        DISPATCH_ASYNC_MAIN {
            self._tableView.updateData(cellSectionData)
        }
    }
    
    var _contactList: [UserDetailModel] {
        if isFollowerList { return contactList }
        else if followId != APPSESSION.userDetail?.id { return contactList }
        else { return contactList.filter { $0.follow == "approved" } }
    }
    
    private var _prototypes: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ContactsTableCell.self, kCellHeightKey: ContactsTableCell.height],
            [kCellIdentifierKey: kCellIdentifierpending, kCellNibNameKey: kCellIdentifierpending, kCellClassKey: PendingRequestTableCell.self, kCellHeightKey: PendingRequestTableCell.height],
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]]
    }
    
    @IBAction func _handleSelectHomeTabEvent(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        delegate?.buttonClicked!(0)
    }

    func handleReloadList() {
        isFollowerList ? _requestFollowersList() : _requestFollowingList()
    }
    
}

// --------------------------------------
// MARK: <CustomTableViewDelegate>
// --------------------------------------

extension FollowListVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
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
        if let cell = cell as? ContactsTableCell, let model = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.setupData(model)
            let isPrivate = APPSESSION.userDetail?.isProfilePrivate == true && followId == APPSESSION.userId && isFollowerList
            let isFirstRow = indexPath.row == (isPrivate ? 1 : 0)
            let lastRow = _contactList.count - 1
            let isLastRow = indexPath.row == lastRow
            cell.setPrifileConstraint(lastRow: isLastRow, firstRow: isFirstRow)
        } else if let cell = cell as? PendingRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel]  else { return }
            cell.setupData(object)
        }
        else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? ContactsTableCell {
            guard let model = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            guard let userDetail = APPSESSION.userDetail else { return }

        } else if let cell = cell as? PendingRequestTableCell {
            if !APPSETTING.pendingRequestList.isEmpty {
                let vc = INIT_CONTROLLER_XIB(FollowRequestListVC.self)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
}

