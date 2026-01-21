import UIKit
import SnapKit

class CustomUserListView: UIView {
    
    @IBOutlet weak var _seeAllBtn: CustomButton!
    @IBOutlet weak var _collecitonView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _titleLabel: CustomLabel!
    @IBOutlet weak var _countLabel: CustomLabel!
    private let kCellIdentifierShareWith = String(describing: MyVenuesCollectionCell.self)
    public var openSeeAll: (()-> Void)?

    
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
        _collecitonView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18),
                              spacing: CGSize(width: 0, height: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: "",
                              emptyDataIconImage: UIImage(named: ""),
                              delegate: self)
        _collecitonView.showsVerticalScrollIndicator = false
        _collecitonView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData(_ model: [UserDetailModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        model.forEach({ model in
            cellData.append([
                kCellDifferenceContentKey: model.id,
                kCellDifferenceIdentifierKey: model.hashValue,
                kCellIdentifierKey: kCellIdentifierShareWith,
                kCellTagKey: kCellIdentifierShareWith,
                kCellObjectDataKey: model,
                kCellClassKey: MyVenuesCollectionCell.self,
                kCellHeightKey: MyVenuesCollectionCell.height
            ])
        })
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        DispatchQueue.main.async {
            self._collecitonView.loadData(cellSectionData)
        }
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: MyVenuesCollectionCell.self), kCellNibNameKey: String(describing: MyVenuesCollectionCell.self), kCellClassKey: MyVenuesCollectionCell.self, kCellHeightKey: MyVenuesCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomUserListView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    public func setupData(_ model: [UserDetailModel], title: String = kEmptyString, counts: String = kEmptyString, isshowCount: Bool = false, titleFont: UIFont = FontBrand.SFmediumFont(size: 11.0)) {
        _titleLabel.text = title
        _titleLabel.font = titleFont
        _countLabel.text = counts
        _countLabel.isHidden = !isshowCount
        _loadData(model)
    }
    
    @IBAction func _handleSeeAllEvent(_ sender: CustomButton) {
        self.openSeeAll?()
    }
    
}

extension CustomUserListView: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? MyVenuesCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.venueImg.cornerRadius = 23
            cell.setUpUser(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {

    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 70)
    }
    
}

