import UIKit
import Hero

class SmallVenueComponentDetailVC: ChildViewController {
    
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _titleLable: UILabel!
    @IBOutlet private weak var _subTitleTextLabel: UILabel!
    
    private let kCellIdentifier = String(describing: SmallVenueCollectionCell.self)
    var venueListModel: [VenueDetailModel] = []
    var titleStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupUi()
        _loadData()
    }
    
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: SmallVenueCollectionCell.self, kCellHeightKey: SmallVenueCollectionCell.height]]
    }
    
    override func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 6,
                              scrollDirection: .vertical,
                              emptyDataText: "There is no venue available",
                              emptyDataIconImage: UIImage(named: "icon_empty_data"),
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        venueListModel.forEach { venueModel in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: venueModel.id,
                kCellObjectDataKey: venueModel,
                kCellClassKey: SmallVenueCollectionCell.self,
                kCellHeightKey: SmallVenueCollectionCell.height
            ])
        }
        _titleLable.text = titleStr
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    @IBAction private func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
}

extension SmallVenueComponentDetailVC: CustomCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SmallVenueCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            cell.setUpdata(object)
            cell.prepareForReuse()
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 2, height: 65)
    }
    
}
