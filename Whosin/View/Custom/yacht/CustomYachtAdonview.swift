import Foundation
import RealmSwift
import UIKit
import SnapKit


class CustomYachtAdonview: UIView {
    
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    private let kCellIdentifier = String(describing: YachtPackageCollectionCell.self)
    private var selectedIndex: Int?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
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
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomYachtAdonview", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 5,
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.isUserInteractionEnabled = false
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: YachtPackageCollectionCell.self, kCellHeightKey: YachtPackageCollectionCell.height]]
    }
    
    
    private func _loadData(_ model: [AddOnsModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        DISPATCH_ASYNC_BG {
            model.forEach { packages in
                cellData.append([
                    kCellIdentifierKey: self.kCellIdentifier,
                    kCellTagKey: packages.id,
                    kCellObjectDataKey: packages.detached(),
                    kCellClassKey: YachtPackageCollectionCell.self,
                    kCellHeightKey: YachtPackageCollectionCell.height
                ])
            }
            
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            DISPATCH_ASYNC_MAIN {
                self._collectionViewHieghtConstraint.constant =  CGFloat(cellData.count) * YachtPackageCollectionCell.height
                self._collectionView.loadData(cellSectionData)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    public func setupData(model: [AddOnsModel]) {
        _loadData(model)
    }
    
}


extension CustomYachtAdonview: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? YachtPackageCollectionCell ,let object = cellDict?[kCellObjectDataKey] as? AddOnsModel else { return }
        if selectedIndex == indexPath.row {
            cell.select(true)
        } else {
            cell.unselect(true)
        }
        cell.setupAddOns(model: object)
        
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        selectedIndex = indexPath.row
        _collectionView.reload()
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let object = cellDict?[kCellObjectDataKey] as? AddOnsModel
        return CGSize(width: collectionView.frame.width, height: YachtPackageCollectionCell.height)
    }
    
}
