import UIKit

class MyCircleListTableCell: UITableViewCell {
    
    @IBOutlet weak var _menuBtn: UIButton!
    @IBOutlet weak var _menuBtnWidth: NSLayoutConstraint!
    @IBOutlet private weak var _userCountView: UIView!
    @IBOutlet private weak var _usersCount: CustomLabel!
    @IBOutlet private weak var _circleAbout: CustomLabel!
    @IBOutlet private weak var _circleName: CustomLabel!
    @IBOutlet private weak var _circleImage: UIImageView!
    @IBOutlet private weak var _imgCollectionView: CustomCollectionView!
    private let kCollectionCellIdentifier = String(describing: ImageViewCell.self)
    private let userList: [UserDetailModel] = []
    private var circleModel: UserDetailModel?
    public var circleId: String = kEmptyString
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height : CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUI()
    }
    
    func setupUI() {
        _imgCollectionView.setup(cellPrototypes: _prototype,
                                 hasHeaderSection: false,
                                 enableRefresh: false,
                                 columns:12,
                                 rows: 1,
                                 scrollDirection: .horizontal,
                                 emptyDataText: nil,
                                 emptyDataIconImage: nil,
                                 delegate: self)
        _imgCollectionView.showsVerticalScrollIndicator = false
        _imgCollectionView.showsHorizontalScrollIndicator = false
//        if Preferences.isSubAdmin {
//            _menuBtnWidth.constant = 0
//            _menuBtn.isHidden = true
//        }
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        userList.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCollectionCellIdentifier,
                kCellTagKey: kCollectionCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: ImageViewCell.self,
                kCellHeightKey: ImageViewCell.height
            ])
        })
    }

    public func setupData(_ model: UserDetailModel) {
        circleModel = model
        _circleName.text = model.title
        _circleImage.loadWebImage(model.avatar)
        _circleAbout.text = model.descriptions
        _usersCount.text = LANGMANAGER.localizedString(forKey: "user_count", arguments: ["value": "\(model.totalMembers)"])
        _userCountView.isHidden = model.totalMembers == 0
        _loadData()
    }
    
    private func _openBottomSheet() {
        guard let model = circleModel else { return }
        let alert = UIAlertController(title: model.title, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "edit".localized(), style: .default, handler: { action in
            self.editCircle()
        }))
        
        alert.addAction(UIAlertAction(title: "delete_circle".localized(), style: .default, handler: { action in
            self.parentBaseController?.confirmAlert(message: LANGMANAGER.localizedString(forKey: "delete_circle_alert", arguments: ["value": model.title]), okHandler: { action in
                self._requestDelete(model.id)
            })
        }))
                
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    private func _requestDelete(_ id: String) {
        self.parentBaseController?.showHUD()
        WhosinServices.deleteCircle(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD()
            guard let data = container?.data else { return }
            NotificationCenter.default.post(name: .reloadPromoterProfileNotifier, object: nil, userInfo: ["circleModel": data, "isDelete": true])
        }
    }
    
    private func editCircle() {
        let vc = INIT_CONTROLLER_XIB(CreateCirclebottomsheet.self)
        vc.isUpdate = true
        vc.circleModel = circleModel
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }

    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCollectionCellIdentifier, kCellNibNameKey: String(describing: ImageViewCell.self), kCellClassKey: ImageViewCell.self, kCellHeightKey: ImageViewCell.height]]
    }
    
    @IBAction private func _handleOptionEvent(_ sender: UIButton) {
        _openBottomSheet()
    }
}

extension MyCircleListTableCell:CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ImageViewCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        cell._imageView.cornerRadius = cell._imageView.frame.height / 2
        cell.setupData(imageUrl: object.image)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 30, height: 30)
    }
}
