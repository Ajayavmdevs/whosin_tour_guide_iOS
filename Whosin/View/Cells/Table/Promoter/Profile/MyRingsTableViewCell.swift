import UIKit

class MyRingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var _customRingsUsrs: CustomPublicRingsView!
    @IBOutlet weak var _seeAllBtn: CustomButton!
    @IBOutlet weak var _ringsPublicView: UIView!
    @IBOutlet weak var _ringsCollectionBgView: UIView!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var _usersCount: CustomLabel!
    @IBOutlet weak var _emptyView: UIView!
    @IBOutlet weak var _maleCount: CustomLabel!
    @IBOutlet weak var _femaleCount: CustomLabel!
    @IBOutlet weak var _unknownUserCount: CustomLabel!
    private let kCellIdentifierShareWith = String(describing: MyVenuesCollectionCell.self)
    private var ringMembers: [UserDetailModel] = []
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    class var identifier : String { String(describing: MyRingsTableViewCell.self) }
    
    class var protocole: [String: Any] {
        [kCellIdentifierKey: identifier, kCellNibNameKey: identifier, kCellClassKey: MyVenuesCollectionCell.self, kCellHeightKey: height]
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _setupCollectionView()
    }
    
    
    private func _setupCollectionView() {
        let spacing = 0
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 2,
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              emptyDataDescription: "",
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData(_ model: [UserDetailModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _collectionHeight.constant = model.count <= 5 ? 90 : 180
        var id = 0
        ringMembers = model
        model.forEach({ model in
            if id < 10 {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierShareWith,
                    kCellTagKey: kCellIdentifierShareWith,
                    kCellDifferenceContentKey: model.id,
                    kCellObjectDataKey: model,
                    kCellClassKey: MyVenuesCollectionCell.self,
                    kCellHeightKey: MyVenuesCollectionCell.height
                ])
                id = id + 1
            }
        })
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.updateData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: MyVenuesCollectionCell.self), kCellNibNameKey: String(describing: MyVenuesCollectionCell.self), kCellClassKey: MyVenuesCollectionCell.self, kCellHeightKey: MyVenuesCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: public
    // --------------------------------------

    public func setupData(_ model: CommanPromoterRingModel, isPublic: Bool = false) {
        _maleCount.text = "\(model.maleCount)"
        _femaleCount.text = "\(model.femaleCount)"
        _unknownUserCount.text = "\(model.preferNotToSay)"
        _seeAllBtn.isHidden = isPublic
        _ringsPublicView.isHidden = !isPublic
        _ringsCollectionBgView.isHidden = isPublic
        if isPublic {
            let images = model.ringList.toArrayDetached(ofType: UserDetailModel.self)
            _customRingsUsrs.setupData(images, totalUsers: model.count)
            _emptyView.isHidden = !images.isEmpty
            _ringsPublicView.isHidden = images.isEmpty
        } else {
            if model.ringList.toArrayDetached(ofType: UserDetailModel.self).count == 0 {
                _emptyView.isHidden = false
                _ringsCollectionBgView.isHidden = true
                _seeAllBtn.isHidden = true
            } else {
                _seeAllBtn.backgroundColor = UIColor(hexString: "#2D2A2C")
                _emptyView.isHidden = true
                _ringsCollectionBgView.isHidden = false
                _loadData(model.ringList.toArrayDetached(ofType: UserDetailModel.self))
            }
        }
        _usersCount.text = "(\(model.count) " + "users".localized() + ")"
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleSeeAllEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(SeeAllDetailVC.self)
        vc.detailType = "rings"
//        if Preferences.isSubAdmin {
//            vc.usersListModel = ringMembers
//        }
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension MyRingsTableViewCell:  CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? MyVenuesCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.venueImg.cornerRadius = 28
            cell.setUpRings(object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.standardized.width / 5, height: 88)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let model = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
        vc.complimentryId = model.userId
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
