import UIKit

class MyEventTableCell: UITableViewCell {
    
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    
    var _eventList: [EventModel] = []
    private var isOneRecord: Bool = false
    
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
    
    func setupUi() {
        disableSelectEffect()
        _collectionView.setup(cellPrototypes: _storyPrototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
                              spacing: CGSize(width: 10, height: 10),
                              scrollDirection: .vertical,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _loadData(true)
    }
    
    private var _storyPrototype: [[String: Any]]? {
        return []
    }
    
    private func _loadData(_ isloading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: [EventModel]) {
        isOneRecord = model.count == 1
        _eventList = model
        setupUi()
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private  func _handleSeeAllEvent(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(SeeAllEventListVC.self)
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension MyEventTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
    
    }
    
}
