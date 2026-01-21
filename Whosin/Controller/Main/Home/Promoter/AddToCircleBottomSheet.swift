import UIKit
import MessageUI
import MHLoadingButton

class AddToCircleBottomSheet: BaseViewController {
    
    @IBOutlet weak var _addBtn: CustomActivityButton!
    @IBOutlet private weak var _sendViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var _sendView: UIView!
    @IBOutlet private weak var _title: UILabel!
    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifier = String(describing: ContactsTableCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _selectedCircleList: [UserDetailModel] = []
    private var circleList: [UserDetailModel] = []
    public var alreadyInCircleList: [UserDetailModel] = []
    public var profileId: String = kEmptyString
    public var isApprove: Bool = false
    public var isPromoter: Bool = false

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
        _loadData(true)
        _requestGetProfile()
    }
    
    // --------------------------------------
    // MARK: SetUp method
    // --------------------------------------
    
    public func _setupUi() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "Oops! Looks a bit empty? Let's toss and kickstart those adventures!",
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: kEmptyString,
            delegate: self)
        _tableView.showsVerticalScrollIndicator = false
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    // --------------------------------------
    // MARK: Private method
    // --------------------------------------
    
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ContactsTableCell.self, kCellHeightKey: ContactsTableCell.height],
                 [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]
        ]
    }
    
    private func _loadData(_ isLoading: Bool = false) {
        
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierLoading,
                kCellTagKey: kCellIdentifierLoading,
                kCellObjectDataKey: true,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            circleList.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: contact.id,
                    kCellObjectDataKey: contact,
                    kCellStatusKey: false,
                    kCellClassKey: ContactsTableCell.self,
                    kCellHeightKey: ContactsTableCell.height
                ])
            }
        }
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        
        _tableView.loadData(cellSectionData)
    }
    
    private func _addCircles() {
//        _addBtn.showActivity()
        _requestAddtoCircles(profileId, circlesId: _selectedCircleList.map({ $0.id }))
//        let totalRequests = _selectedCircleList.count
        
//        var completedRequests = 0
//
//        for circle in _selectedCircleList {
//            _requestAddMembers([profileId], circle.id, completion: {
//                completedRequests += 1
//                if completedRequests == totalRequests {
//                    self.dismiss(animated: true)
//                }
//            })
//        }
    }
    
    private func _requestAddtoCircles(_ memberID: String, circlesId: [String]) {
        showHUD(loadingText: "take_time_wait_alert".localized())
        WhosinServices.addMemberToCircles(id: memberID, circleIds: circlesId) { [weak self] container, error in
            guard let self = self else { return }
//            self._addBtn.hideActivity()
            self.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                showSuccessMessage("user_added_in_circle".localized(), subtitle: "")
            }
            NotificationCenter.default.post(name: .reloadUsersNotification, object: nil)
            DISPATCH_ASYNC_MAIN_AFTER(0.1) {
                self.dismiss(animated: true)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Service method
    // --------------------------------------
    
    private func _requestGetProfile() {
//        showHUD()
        WhosinServices.getPromoterProfiel { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return}
            self.circleList = data.circles.toArrayDetached(ofType: UserDetailModel.self).filter { contact in
                !self.alreadyInCircleList.contains(where: { $0.id == contact.id })
            }
            _sendView.isHidden = self.circleList.isEmpty
            self._loadData()
        }
    }
    
    private func _requestAddMembers(_ membersIds: [String], _ id: String, completion: @escaping () -> Void) {
        showHUD()
        WhosinServices.addToCircle(id: id, memberIds: membersIds) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            guard let data = container else { return }
            if data.code == 1 {
                self.showToast(data.message)
                NotificationCenter.default.post(name: .reloadPromoterProfileNotifier, object: nil)
                NotificationCenter.default.post(name: kRelaodActivitInfo, object: nil)
                NotificationCenter.default.post(name: .reloadUsersNotification, object: nil)
            }
            completion()
        }
    }
    
    private func _requestUpdateStatus(withoutCircles: Bool = false) {
        showHUD()
        var params: [String: Any] = ["status": "accepted"]
        if isPromoter {
            params["promoterId"] = profileId
        } else {
            params["memberId"] = profileId
        }
        WhosinServices.promoterStatus(params: params, isPromoter: isPromoter) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return }
            self.showSuccessMessage(data.message, subtitle: kEmptyString)
            NotificationCenter.default.post(name: .reloadUsersNotification, object: nil)
            if data.code == 1 {
                if withoutCircles {
                    self.dismiss(animated: true)
                } else {
                    _addCircles()
                }
            }
        }
    }
    
    // --------------------------------------
    // MARK: IBActions Event
    // --------------------------------------
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        self.view.endEditing(true)
        if isApprove {
            showCustomAlert(title: kAppName, message: "approve_without_adding_to_circle".localized()) { UIAlertAction in
                self._requestUpdateStatus(withoutCircles: true)
            } noHandler: { UIAlertAction in
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction private func _handleSendEvent(_ sender: UIButton) {
        if _selectedCircleList.isEmpty {
            alert(title: kAppName, message: "select_circle".localized())
            return
        }
        
        if isApprove {
            _requestUpdateStatus()
        } else {
            _addCircles()
        }
        
    }
    
}


// --------------------------------------
// MARK: CustomCollectionViewDelegate
// --------------------------------------

extension AddToCircleBottomSheet: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ContactsTableCell,
              let model = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        let isFirstRow = indexPath.row == 0
        let lastRow = _tableView.numberOfRows(inSection: indexPath.section) - 1
        let isLastRow = indexPath.row == lastRow
        cell.setPrifileConstraint(lastRow: isLastRow, firstRow: isFirstRow)
        let isSelect = _selectedCircleList.contains(where: { $0.id == model.id })
        cell.setupCircleData(model, isSelected: isSelect)
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        self.view.endEditing(true)
        guard let cell = cell as? ContactsTableCell else { return }
        let selectedContact = circleList[indexPath.row]
        
        if let index = _selectedCircleList.firstIndex(where: { $0.id == selectedContact.id }) {
            _selectedCircleList.remove(at: index)
        } else {
            _selectedCircleList.append(selectedContact)
        }
        _tableView.reload()
    }
    
}
