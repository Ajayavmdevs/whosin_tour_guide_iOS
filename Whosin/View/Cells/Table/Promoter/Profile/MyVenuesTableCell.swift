
import UIKit

class MyVenuesTableCell: UITableViewCell {
    
    @IBOutlet weak var _seeAllBtn: CustomButton!
    @IBOutlet private weak var venueCountLbl: CustomLabel!
    @IBOutlet private weak var myVenuesCollectionView: CustomCollectionView!
    @IBOutlet weak var _emptyView: UIView!
    private let kCollectionCellIdentifier = String(describing: MyVenuesCollectionCell.self)
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height : CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life-cycle
    // --------------------------------------
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUI()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUI() {
        myVenuesCollectionView.setup(cellPrototypes: _prototype,
                                     hasHeaderSection: false,
                                     enableRefresh: false,
                                     columns:4,
                                     rows: 2,
                                     edgeInsets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18),
                                     scrollDirection: .horizontal,
                                     emptyDataText: "There is no venues available",
                                     emptyDataIconImage: nil,
                                     delegate: self)
        myVenuesCollectionView.showsVerticalScrollIndicator = false
        myVenuesCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCollectionCellIdentifier, kCellNibNameKey: String(describing: MyVenuesCollectionCell.self), kCellClassKey: MyVenuesCollectionCell.self, kCellHeightKey: MyVenuesCollectionCell.height]]
    }
    
    private func _loadData(_ model: [VenueDetailModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        model.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCollectionCellIdentifier,
                kCellTagKey: kCollectionCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: MyVenuesCollectionCell.self,
                kCellHeightKey: MyVenuesCollectionCell.height
            ])
        })
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        myVenuesCollectionView.loadData(cellSectionData)
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: CommanPromoterVenueModel, isPublic: Bool = false) {
        venueCountLbl.text = "(\(model.venueList.count))"
        _seeAllBtn.isHidden = isPublic ? true : model.venueList.isEmpty
        _emptyView.isHidden = !model.venueList.isEmpty
        myVenuesCollectionView.isHidden = model.venueList.isEmpty
        _loadData(model.venueList.toArrayDetached(ofType: VenueDetailModel.self))
        if !isPublic {
            _seeAllBtn.backgroundColor = UIColor(hexString: "#2D2A2C")
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleSeeAllEvent(_ sender: CustomButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let vc = INIT_CONTROLLER_XIB(SeeAllDetailVC.self)
        vc.detailType = "venues"
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// --------------------------------------
// MARK: Collection Delegate
// --------------------------------------


extension MyVenuesTableCell: CustomCollectionViewDelegate,UICollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? MyVenuesCollectionCell,
              let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
        cell.venueImg.cornerRadius = 10
        cell.setup(object)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 140)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? MyVenuesCollectionCell,
              let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
        let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        vc.venueId = object.id
        vc.venueDetailModel = object
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
