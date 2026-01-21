import UIKit

class MyCircleDetailVC: ChildViewController {
    
    @IBOutlet weak var _menuBtn: UIButton!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _aboutLabel: CustomLabel!
    @IBOutlet weak var _nameLabel: CustomLabel!
    @IBOutlet weak var _iamgeView: UIImageView!
    @IBOutlet weak var _tableView: CustomTableView!
    @IBOutlet weak var _addUserButton: UIButton!
    @IBOutlet weak var _searchBar: UISearchBar!
    private let kCellIdentifierVenue = String(describing: SeeAllListTableCell.self)
    public var circleModel: UserDetailModel?
    public var id: String = kEmptyString
    private var isSearching: Bool = false
    private var filteredCircleMembers: [UserDetailModel] = []
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadProfile(_:)), name: .reloadPromoterProfileNotifier, object: nil)
        setupUi()
        getCircleDetail()
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
            emptyDataText: "your_member_list_looking_bit_empty".localized(),
            emptyDataIconImage: UIImage(named: "empty_following"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.proxyDelegate = self
        _searchBar.delegate = self
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white

//        if Preferences.isSubAdmin {
//            _addUserButton.isHidden = true
//            _menuBtn.isHidden = true
//        }
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierVenue, kCellNibNameKey: kCellIdentifierVenue, kCellClassKey: SeeAllListTableCell.self, kCellHeightKey: SeeAllListTableCell.height]
        ]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let circleModel = circleModel else { return }
        _iamgeView.loadWebImage(circleModel.avatar, name: circleModel.title)
        _nameLabel.text = circleModel.title
        _aboutLabel.text = circleModel.descriptions
        
        if isSearching {
            filteredCircleMembers.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierVenue,
                    kCellTagKey: kCellIdentifierVenue,
                    kCellObjectDataKey: model,
                    kCellClassKey: SeeAllListTableCell.self,
                    kCellHeightKey: SeeAllListTableCell.height
                ])
            }
        } else {
            circleModel.members.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierVenue,
                    kCellTagKey: kCellIdentifierVenue,
                    kCellObjectDataKey: model,
                    kCellClassKey: SeeAllListTableCell.self,
                    kCellHeightKey: SeeAllListTableCell.height
                ])
            }
        }
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
    }
    
    private func getCircleDetail() {
        guard let id = circleModel?.id else { return }
        showHUD()
        WhosinServices.getCircleDetail(id: id) { [weak self] contaienr, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = contaienr?.data else { return }
            self.circleModel = data
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    private func _requestAddMembers(_ membersIds: [String], _ id: String) {
        showHUD()
        WhosinServices.addToCircle(id: id, memberIds: membersIds) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            guard let data = container else { return }
            if data.code == 1 {
                self.showToast(data.message)
                self.getCircleDetail()
                NotificationCenter.default.post(name: .reloadPromoterProfileNotifier, object: nil)
            }
        }
    }
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _handleAddUserEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(ContactShareBottomSheet.self)
        presentedViewController.onShareButtonTapped = { [weak self] selectedContacts in
            let validUserIds = selectedContacts.compactMap { contact in
                if !Utils.stringIsNullOrEmpty(contact.userId) {
                    return contact.userId
                }
                return nil
            }
            self?._requestAddMembers(validUserIds, self?.circleModel?.id ?? kEmptyString)
        }
        presentedViewController.isFromCircle = true
        presentedViewController.alreadyInCircle = circleModel?.members.toArrayDetached(ofType: UserDetailModel.self).map({ $0.id }) ?? []
        presentedViewController.isFromCreateBucket = true
        presentedViewController.modalPresentationStyle = .overFullScreen
        present(presentedViewController, animated: true)
    }
    
    @IBAction func _handleMenuEvent(_ sender: Any) {
        _openBottomSheet()
    }
    
    private func _openBottomSheet() {
        guard let model = circleModel else { return }
        let alert = UIAlertController(title: model.title, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "edit".localized(), style: .default, handler: { action in
            self.editCircle()
        }))
        
        alert.addAction(UIAlertAction(title: "delete_circle".localized(), style: .default, handler: { action in
            self.confirmAlert(message: LANGMANAGER.localizedString(forKey: "delete_circle_alert", arguments: ["value": "\(model.title)?"]) , okHandler: { action in
                self._requestDelete(model.id)
            })
        }))
                
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parent?.present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }

    private func editCircle() {
        let vc = INIT_CONTROLLER_XIB(CreateCirclebottomsheet.self)
        vc.isUpdate = true
        vc.circleModel = circleModel
        parent?.presentAsPanModal(controller: vc)
    }
    
    @objc func handleReloadProfile(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let circle = userInfo["circleModel"] as? UserDetailModel, let isDelete = userInfo["isDelete"] as? Bool {
            if isDelete {
                navigationController?.popViewController(animated: true)
            } else {
                if let members = circleModel?.members {
                    circle.members = members
                }
                circleModel = circle
                _loadData()
            }
        }
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.parent?.dismiss(animated: true, completion: nil)
    }
    
    private func _requestDelete(_ id: String) {
        self.showHUD()
        WhosinServices.deleteCircle(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            guard let data = container?.data else { return }
            NotificationCenter.default.post(name: .reloadPromoterProfileNotifier, object: nil, userInfo: ["circleModel": data, "isDelete": true])
        }
    }
}

// --------------------------------------
// MARK: TableView Delegate
// --------------------------------------

extension MyCircleDetailVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 30
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
        if let cell = cell as? SeeAllListTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
                cell._imageView.cornerRadius = cell._imageView.frame.height / 2
                cell.setupUser(object, isCircle: true, circleId: circleModel?.id ?? kEmptyString)
                cell.removeCallback = { type in
                    if type == "circle" {
                        self.getCircleDetail()
                    }
                }
            }
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
    }
    
}

// --------------------------------------
// MARK: Search Delegate
// --------------------------------------

extension MyCircleDetailVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            _loadData()
        } else {
            isSearching = true
            filteredCircleMembers = circleModel?.members.toArrayDetached(ofType: UserDetailModel.self).filter({ $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) }) ?? []
            _loadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
