import UIKit

class BucketTableCell: UITableViewCell {
    
    @IBOutlet private weak var _bucketImageView: UIImageView!
    @IBOutlet private weak var _menu: UIButton!
    @IBOutlet private weak var _bucketName: UILabel!
    @IBOutlet private weak var _bucketCreatedDate: UILabel!
    @IBOutlet weak var _memberCount: UILabel!
    @IBOutlet weak var _bucketOwnerName: UILabel!
    @IBOutlet weak var _ownerImage: UIImageView!
    @IBOutlet weak var _usersCollectionView: CustomCollectionView!
    private let kCellIdentifierStory = String(describing: SharedUsersCollectionCell.self)
    private var bucketId: String = kEmptyString
    private var _bucketModel: BucketDetailModel?
    private var _sharedWith: [UserDetailModel] = []
    private var isFromSheet: Bool = false
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        disableSelectEffect()
    }
    
    private func setupUI() {
        _usersCollectionView.setup(cellPrototypes: _storyPrototype,
                                   hasHeaderSection: false,
                                   enableRefresh: false,
                                   columns: 5,
                                   rows: 1,
                                   edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                                   scrollDirection: .vertical,
                                   emptyDataText: nil,
                                   emptyDataIconImage: nil,
                                   delegate: self)
        _usersCollectionView.showsVerticalScrollIndicator = false
        _usersCollectionView.showsHorizontalScrollIndicator = false
        
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestUpdateBucket(_ name: String) {
        WhosinServices.updateBucket(id: bucketId, name: name) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            NotificationCenter.default.post(name: kReloadBucketList, object: nil, userInfo: nil)
            self.parentViewController?.view.makeToast(data.message)
        }
    }
    
    private func _requestRemoveBucket() {
        WhosinServices.removeBucket(bucketId: bucketId) { [weak self] container, error in
            guard let self = self else { return }
            NotificationCenter.default.post(name: kReloadBucketList, object: nil, userInfo: nil)
            self.parentViewController?.view.makeToast(container?.message)
        }
    }
    
    private func _requestExitFromBucket() {
        WhosinServices.exitFromBucket(id: bucketId) { [weak self] container, error in
            guard let self = self else { return }
            NotificationCenter.default.post(name: kReloadBucketList, object: nil, userInfo: nil)
            self.parentViewController?.view.makeToast(container?.message)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
        
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        cellData.removeAll()
        if _sharedWith.isEmpty {
            _usersCollectionView.isHidden = true
        } else {
            _usersCollectionView.isHidden = false
            _sharedWith.forEach({ users in
                if !users.firstName.isEmpty {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierStory,
                        kCellTagKey: users.id,
                        kCellObjectDataKey: users,
                        kCellClassKey: SharedUsersCollectionCell.self,
                        kCellHeightKey: SharedUsersCollectionCell.height
                    ])
                }
            })
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _usersCollectionView.loadData(cellSectionData)
    }
    
    private var _storyPrototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierStory, kCellNibNameKey: kCellIdentifierStory, kCellClassKey: SharedUsersCollectionCell.self, kCellHeightKey: SharedUsersCollectionCell.height]]
    }
    
    private func transferOwnership() {
        let vc = INIT_CONTROLLER_XIB(TransferOwnershipBottomSheet.self)
        vc.sharedWith = _sharedWith
        vc.bucketId = bucketId
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
    private func alert(title: String = kAppName, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { _ in }))
        DISPATCH_ASYNC_MAIN {[weak self] in self?.parentViewController?.present(alert, animated: true) }
    }
    
    private func _openEditDialogue() {
        let alert = UIAlertController(title: "edit_bucket".localized(), message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "enter_bucket_name".localized()
            textField.text = self._bucketName.text
        }
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: {action in
            
        }))
        alert.addAction(UIAlertAction(title: "done".localized(), style: .default, handler: { action in
            DISPATCH_ASYNC_MAIN {
                guard let bucketName = alert.textFields?[0].text else {
                    self.alert(title: kAppName, message: "please_enter_bucketlist_name".localized())
                    return
                }
                if !bucketName.isEmpty {
                    self._requestUpdateBucket(bucketName)
                } else {
                    self.alert(title: kAppName, message: "please_enter_bucketlist_name".localized())
                }
            }
        }))
        DISPATCH_ASYNC_MAIN {[weak self] in self?.parentViewController?.present(alert, animated: true) }
    }
    
    private func _openOwnerActionSheet() {
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "rename".localized(), style: .default, handler: {action in
            DISPATCH_ASYNC_MAIN { self._openEditDialogue() }
        }))
        alert.addAction(UIAlertAction(title: "delete".localized(), style: .destructive, handler: {action in
            DISPATCH_ASYNC_MAIN {
                self.parentBaseController?.showCustomAlert(title: kAppName, message: "delete_bucket_alert".localized(), yesButtonTitle: "yes".localized(), noButtonTitle: "no".localized(), okHandler: { UIAlertAction in
                    self._requestRemoveBucket()
                }, noHandler:  { UIAlertAction in
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "change_ownership".localized(), style: .default, handler: {action in
            DISPATCH_ASYNC_MAIN { self.transferOwnership() }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
        
    }
    
    private func _openShareUserActionSheet() {
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "exit_from_bucket".localized(), style: .destructive, handler: {action in
            DISPATCH_ASYNC_MAIN {
                self.parentBaseController?.showCustomAlert(title: kAppName, message: "exit_from_bucket_alert".localized(), yesButtonTitle: "yes".localized(), noButtonTitle: "no".localized(), okHandler: { UIAlertAction in
                    self._requestExitFromBucket()
                }, noHandler:  { UIAlertAction in
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: BucketDetailModel, userModel: [UserDetailModel] = [], isFromSheet: Bool = false) {
        self.isFromSheet = isFromSheet
        _bucketModel = model
        _ownerImage.loadWebImage(model.owner?.image ?? kEmptyString, name: model.owner?.firstName ?? kEmptyString)
        _bucketOwnerName.text = "\(model.owner?.firstName ?? kEmptyString) \(model.owner?.lastName ?? kEmptyString)"
        _sharedWith = model.sharedWith.toArrayDetached(ofType: UserDetailModel.self)
        _loadData()
        _memberCount.text = LANGMANAGER.localizedString(forKey: "members_count", arguments: ["value": "\(_sharedWith.count)"])
        _bucketName.text = model.name
        _bucketImageView.loadWebImage(model.coverImage, name: model.name)
        let time = Utils.stringToDate(model.createdAt, format: kStanderdDate)
        let createdAt = Utils.dateToString(time, format: kFormatEventDate)
        _bucketCreatedDate.text = createdAt
        bucketId = model.id
        _menu.isHidden = isFromSheet
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleBucketActionEvent(_ sender: UIButton) {
        if !isFromSheet {
            if _bucketModel?.userId == APPSESSION.userDetail?.id {
                _openOwnerActionSheet()
            } else {
                _openShareUserActionSheet()
            }
        }
    }
    
}

extension BucketTableCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SharedUsersCollectionCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.setupData(object, inviteStatus: true)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let model = cellDict?[kCellObjectDataKey] as? UserDetailModel, let userDetail = APPSESSION.userDetail else { return }

    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 40, height: SharedUsersCollectionCell.height)
    }
}
