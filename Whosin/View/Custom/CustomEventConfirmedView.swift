import UIKit
import NVActivityIndicatorView

class CustomEventConfirmedView: UIView {
    
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let KCellIdentifier = String(describing: MyVenuesCollectionCell.self)
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setup()
    }
    
    private func _setup() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              spacing: CGSize(width: 0, height: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: "",
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.isPagingEnabled = true
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: KCellIdentifier,
            kCellTagKey: KCellIdentifier,
            kCellObjectDataKey: "",
            kCellClassKey: MyVenuesCollectionCell.self,
            kCellHeightKey: MyVenuesCollectionCell.height
        ])
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: MyVenuesCollectionCell.self), kCellNibNameKey: String(describing: MyVenuesCollectionCell.self), kCellClassKey: MyVenuesCollectionCell.self, kCellHeightKey: MyVenuesCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomEventConfirmedView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: PromoterEventsModel) {
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    

}

extension CustomEventConfirmedView: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {


    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
    }

    
}

