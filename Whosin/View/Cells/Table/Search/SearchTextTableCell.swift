import UIKit

protocol SearchTextTapDelegate: AnyObject {
    func searchTextTapped(_ data: String)
}

class SearchTextTableCell: UITableViewCell {

    weak var delegate: SearchTextTapDelegate?
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: SearchTagCollectionCell.self)
    @IBOutlet private weak var _collectionHeight: NSLayoutConstraint!
    private var _searchText: [String] = []
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    private func _setupUi() {
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 1,
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototypes: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: SearchTagCollectionCell.self, kCellHeightKey: SearchTagCollectionCell.height]
        ]
    }
    
    private func _loadData() {
        
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _searchText.forEach { txt in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: txt,
                kCellClassKey: SearchTagCollectionCell.self,
                kCellHeightKey: SearchTagCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [String]) {
        _searchText = data
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
    }
}


// ------------------------------
// MARK: TagListViewDelegate
// ------------------------------

extension SearchTextTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SearchTagCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
        delegate?.searchTextTapped(object)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        guard let object = cellDict?[kCellObjectDataKey] as? String else {
            return CGSize(width: 100, height: 40)
        }
        let text = object.widthOfString(usingFont: FontBrand.SFregularFont(size: 16))
        return CGSize(width: text + 55, height: 40)
    }

}
