import UIKit

class MySpedcialOfferCell: UITableViewCell {

    @IBOutlet weak var _collectionView: CustomCollectionView!
    private let kCellIdentifierDeals = String(describing: BucketDealCollectionCell.self)
    private var _bucketDealsList: [DealsModel] = []

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

    func setupUi() {
        _collectionView.setup(cellPrototypes: _collectionPrototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
                              spacing: CGSize(width: 10, height: 10),
                              scrollDirection: .horizontal,
                              emptyDataText: "There is no buckets available",
                              emptyDataIconImage: UIImage(named: "empty_explore"),
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }


    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadColletionData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _bucketDealsList.forEach { deals in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDeals,
                kCellTagKey: kCellIdentifierDeals,
                kCellObjectDataKey: deals,
                kCellClassKey: BucketDealCollectionCell.self,
                kCellHeightKey: BucketDealCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _collectionPrototype: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifierDeals, kCellNibNameKey: String(describing: BucketDealCollectionCell.self), kCellClassKey: BucketDealCollectionCell.self, kCellHeightKey: BucketDealCollectionCell.height] ]
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: [DealsModel]) {
        _bucketDealsList = model
        _loadColletionData()
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction private  func _handleSeeAllEvent(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(SeeAllOutingListVC.self)
        controller.modalPresentationStyle = .overFullScreen
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension MySpedcialOfferCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? BucketDealCollectionCell ,let object = cellDict?[kCellObjectDataKey] as? DealsModel else { return }
        cell.setupData(object)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if _bucketDealsList.count == 1 {
            return CGSize(width: collectionView.frame.width - 20, height: BucketDealCollectionCell.height)
        } else {
            return CGSize(width: 270, height: BucketDealCollectionCell.height)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? DealsModel else { return }
        let vc = INIT_CONTROLLER_XIB(DealsDetailVC.self)
        vc.dealsModel = object
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
