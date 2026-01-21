import UIKit

class MyPlusOneGroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellTitleText: CustomLabel!
    @IBOutlet weak var _addMoreBtn: CustomButton!
    @IBOutlet weak var _bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var _seeAllBtn: CustomButton!
    @IBOutlet weak var _customRingsUsrs: CustomPublicRingsView!
    @IBOutlet weak var _ringsPublicView: UIView!
    @IBOutlet weak var _ringsCollectionBgView: UIView!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var _usersCount: CustomLabel!
    @IBOutlet weak var _emptyView: UIView!
    private let kCellIdentifierShareWith = String(describing: MyVenuesCollectionCell.self)
    private var ringMembers: [UserDetailModel] = []
    private var isNormal: Bool = false
    
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
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
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
    
    private func _loadData(_ model: [UserDetailModel], isNormalUser: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _collectionHeight.constant = 90
        ringMembers = model
        
        if !isNormalUser {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierShareWith,
                kCellTagKey: kCellIdentifierShareWith,
                kCellDifferenceContentKey: kCellIdentifierShareWith,
                kCellObjectDataKey: UserDetailModel(),
                kCellClassKey: MyVenuesCollectionCell.self,
                kCellHeightKey: MyVenuesCollectionCell.height
            ])
        }
            
        model.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierShareWith,
                kCellTagKey: kCellIdentifierShareWith,
                kCellDifferenceContentKey: model.id,
                kCellObjectDataKey: model,
                kCellClassKey: MyVenuesCollectionCell.self,
                kCellHeightKey: MyVenuesCollectionCell.height
            ])
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
    
    public func setupData(_ model: [UserDetailModel], isNormal: Bool = false) {
        self.isNormal = isNormal
        _ringsPublicView.isHidden = true
        _ringsCollectionBgView.isHidden = false
        _seeAllBtn.isHidden = model.isEmpty
        _seeAllBtn.backgroundColor = UIColor(hexString: "#2D2A2C")
        _emptyView.isHidden = true
        _ringsCollectionBgView.isHidden = false
        _loadData(model, isNormalUser: isNormal)
        _bottomConstraint.constant = isNormal ? 0 : 12
        cellTitleText.text = isNormal ? "my_plus_one_group".localized() : "my_plus_one".localized()
        let pending = model.filter({ $0.plusOneStatus == "pending" || $0.adminStatusOnPlusOne == "pending"})
        _usersCount.text = isNormal ?  LANGMANAGER.localizedString(forKey: "my_plusone_group_count", arguments: ["value": "\(model.count)"]) : LANGMANAGER.localizedString(forKey: "my_plusone_count", arguments: ["value1": "\(model.count)", "value2": "\(pending.count)"])
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    @IBAction private func _handleAddmoreEvent(_ sender: Any) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let vc = INIT_CONTROLLER_XIB(PlusOneInivteBottomSheet.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.groupMembers = ringMembers
        parentViewController?.present(vc, animated: true)
    }
    
    @IBAction private func _handleSeeAllEvent(_ sender: UIButton) {
    }
    
}

extension MyPlusOneGroupTableViewCell:  CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? MyVenuesCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.venueImg.cornerRadius = cell.venueImg.frame.height / 2
            cell.venueImg.clipsToBounds = true
            cell.setUpRings(object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 5
        return CGSize(width: cellWidth, height: 88)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let model = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        if Utils.stringIsNullOrEmpty(model.image) && Utils.stringIsNullOrEmpty(model.fullName) {
            parentBaseController?.feedbackGenerator?.impactOccurred()
            let vc = INIT_CONTROLLER_XIB(PlusOneInivteBottomSheet.self)
            vc.modalPresentationStyle = .overFullScreen
            vc.groupMembers = ringMembers
            parentViewController?.present(vc, animated: true)
        }
    }
    
}
