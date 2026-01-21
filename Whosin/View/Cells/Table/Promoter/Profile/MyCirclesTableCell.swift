import UIKit

class MyCirclesTableCell: UITableViewCell {
    
    @IBOutlet weak var _seeAllBtn: CustomButton!
    @IBOutlet weak var _addMoreBtn: CustomButton!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet weak var _collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var _emptyView: UIView!
    private let kCellIdentifierShareWith = String(describing: MyVenuesCollectionCell.self)
    private var circleList: [UserDetailModel] = []
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    class var identifier : String { String(describing: MyCirclesTableCell.self) }
    
    class var protocole: [String: Any] {
        [kCellIdentifierKey: identifier, kCellNibNameKey: identifier, kCellClassKey: MyCirclesTableCell.self, kCellHeightKey: height]
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
        let spacing = 10
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 3,
                              rows: 2,
                              edgeInsets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: "empty_circle".localized(),
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData(_ model: [UserDetailModel]) {
        _collectionHeight.constant = model.count < 4 ? 150 : 320
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var id = 0
        model.forEach({ model in
            if id < 10 {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierShareWith,
                    kCellTagKey: kCellIdentifierShareWith,
                    kCellObjectDataKey: model,
                    kCellClassKey: MyVenuesCollectionCell.self,
                    kCellHeightKey: MyVenuesCollectionCell.height
                ])
                id = id + 1
            }
        })
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: MyVenuesCollectionCell.self), kCellNibNameKey: String(describing: MyVenuesCollectionCell.self), kCellClassKey: MyVenuesCollectionCell.self, kCellHeightKey: MyVenuesCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: [UserDetailModel], isPublic: Bool = false) {
        _addMoreBtn.isHidden = isPublic
        _seeAllBtn.isHidden = isPublic
        circleList = model
        if model.count == 0 {
            _emptyView.isHidden = false
            _collectionView.isHidden = true
            _seeAllBtn.isHidden = true
        } else {
            _emptyView.isHidden = true
            _collectionView.isHidden = false
        }
        _loadData(model)
        if !isPublic {
            _addMoreBtn.backgroundColor = UIColor(hexString: "#2D2A2C")
            _seeAllBtn.backgroundColor = UIColor(hexString: "#2D2A2C")
        }
//        if Preferences.isSubAdmin {
//            _addMoreBtn.isHidden = true
//        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleAddMoreEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(CreateCirclebottomsheet.self)
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
    @IBAction func _handleSeeAllEvent(_ sender: CustomButton) {
    }
}

extension MyCirclesTableCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? MyVenuesCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.venueImg.layer.cornerRadius = 52
            cell.setupCircle(object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: (kScreenWidth - 48) / 3, height: 150)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
//        guard !Preferences.isSubAdmin else { return }
        if APPSESSION.userDetail?.isRingMember == false {
            let vc = INIT_CONTROLLER_XIB(MyCircleDetailVC.self)
            vc.circleModel = object
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
