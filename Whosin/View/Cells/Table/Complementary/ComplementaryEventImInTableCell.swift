import UIKit

class ComplementaryEventImInTableCell: UITableViewCell {
    
    @IBOutlet weak var _cellTitle: CustomLabel!
    @IBOutlet weak var _seeAllBtn: CustomButton!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _emptyView: UIView!
    private var _inEventsModel: [PromoterEventsModel] = []
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _setupCollectionView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func _setupCollectionView() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14),
                              spacing: CGSize(width: 10, height: 10),
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
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
    
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return []
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [PromoterEventsModel], cellTitle: String) {
        _cellTitle.text = cellTitle
        _inEventsModel = data
        _emptyView.isHidden = !data.isEmpty
        _collectionView.isHidden = data.isEmpty
        _seeAllBtn.isHidden = data.isEmpty
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleSeeAllEvent(_ sender: CustomButton) {
        
    }
}

extension ComplementaryEventImInTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {

    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        
    }
    
}
