import UIKit

class EventAdminsTableCell: UITableViewCell {
    
    @IBOutlet weak var _collectionView: CustomCollectionView!
    
    private let kCellIdentifierStory = String(describing: SharedUsersCollectionCell.self)
    private var contactList: [UserDetailModel] = []
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
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
        disableSelectEffect()
        _collectionView.setup(cellPrototypes: _storyPrototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _loadData()
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        contactList.forEach { contact in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierStory,
                kCellTagKey: contact.id,
                kCellObjectDataKey: contact,
                kCellClassKey: SharedUsersCollectionCell.self,
                kCellHeightKey: SharedUsersCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private var _storyPrototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierStory, kCellNibNameKey: kCellIdentifierStory, kCellClassKey: SharedUsersCollectionCell.self, kCellHeightKey: SharedUsersCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    public func setupData(_ userModel: [UserDetailModel] = []) {
        contactList = userModel
        _loadData()
    }
}

extension EventAdminsTableCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SharedUsersCollectionCell,
              let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        cell.setupData(object)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 60, height: SharedUsersCollectionCell.height)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SharedUsersCollectionCell,
              let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }

    }
}
