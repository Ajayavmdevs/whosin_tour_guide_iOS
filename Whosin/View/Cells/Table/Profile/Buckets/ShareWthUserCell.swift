import UIKit
import GSPlayer
import Hero

class ShareWthUserCell: UITableViewCell {
    
    @IBOutlet private weak var _safeHieght: NSLayoutConstraint!
    @IBOutlet private weak var _collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _storyCollectionView: CustomCollectionView!
    private let kCellIdentifierStory = String(describing: StoryUserCell.self)
    private var contactModel: [UserModel] = []
    public var bucketId: String = kEmptyString
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    private func setupUi() {
        if let statusBarHeight = APP.window?.windowScene?.statusBarManager?.statusBarFrame.height {
            _safeHieght.constant = statusBarHeight
        } else {
            _safeHieght.constant = 20
        }
        _collectionViewHeightConstraint.constant = 0
        _storyCollectionView.setup(cellPrototypes: _storyPrototype,
                                   hasHeaderSection: false,
                                   enableRefresh: false,
                                   columns: 5,
                                   rows: 1,
                                   edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0),
                                   scrollDirection: .horizontal,
                                   emptyDataText: nil,
                                   emptyDataIconImage: nil,
                                   delegate: self)
        _storyCollectionView.showsVerticalScrollIndicator = false
        _storyCollectionView.showsHorizontalScrollIndicator = false
        
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if !contactModel.isEmpty {
            contactModel.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierStory,
                    kCellTagKey: contact.id,
                    kCellObjectDataKey: contact,
                    kCellClassKey: StoryUserCell.self,
                    kCellHeightKey: StoryUserCell.height
                ])
            }
            _collectionViewHeightConstraint.constant = 120
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _storyCollectionView.loadData(cellSectionData)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [UserModel]) {
        contactModel = data
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _storyPrototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierStory, kCellNibNameKey: String(describing: StoryUserCell.self), kCellClassKey: StoryUserCell.self, kCellHeightKey: StoryUserCell.height]]
    }
    
}

extension ShareWthUserCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? StoryUserCell,
              let object = cellDict?[kCellObjectDataKey] as? UserModel else { return }
        cell.storyContact(model: object, bucketId: bucketId)
        cell.prepareForReuse()
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 90, height: StoryUserCell.height)
    }
}
