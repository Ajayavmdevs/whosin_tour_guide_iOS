import UIKit

class AllActivitySearchTableCell: UITableViewCell {

    weak var delegate: ShowCategoryDetailsDelegate?
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifierActivity = String(describing: ActivitySearchCollectionCell.self)
    private var _activityModel: [ActivitiesModel] = []


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
        setupUi()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func setupUi() {
        let spacing = 0
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1.1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: .zero, left: 0, bottom: .zero, right: 0),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.reload()
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _activityModel.forEach { activity in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierActivity,
                kCellTagKey: kCellIdentifierActivity,
                kCellObjectDataKey: activity,
                kCellClassKey: ActivitySearchCollectionCell.self,
                kCellHeightKey: ActivitySearchCollectionCell.height
            ])
        }

        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifierActivity, kCellNibNameKey: kCellIdentifierActivity, kCellClassKey: ActivitySearchCollectionCell.self, kCellHeightKey: ActivitySearchCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: [ActivitiesModel]) {
        _activityModel = data
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleMoreEvent(_ sender: UIButton) {
        delegate?.didSelectCategory("activity")
    }
    
}

// --------------------------------------
// MARK: Custom Collection View
// --------------------------------------

extension AllActivitySearchTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ActivitySearchCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
   

    }
}

