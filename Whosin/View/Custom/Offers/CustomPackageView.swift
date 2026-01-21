import Foundation
import RealmSwift
import UIKit
import SnapKit


class CustomPackageView: UIView {
    
    @IBOutlet private weak var _offersStack: UIStackView!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    private let kCellIdentifier = String(describing: PackagesCollectionCell.self)
//    private var offersModel: OffersModel?
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
        if var view = Bundle.main.loadNibNamed("CustomPackageView", owner: self, options: nil)?.first as? UIView {
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
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: PackagesCollectionCell.self), kCellClassKey: PackagesCollectionCell.self, kCellHeightKey: PackagesCollectionCell.height] ]
    }
    
    private func _loadData(_ model: List<PackageModel>) {
        
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var height = 0.0
        
        model.forEach { packages in
            height += Utils.stringIsNullOrEmpty(packages.descriptions) ? 33 : 50
            cellData.append([
                kCellIdentifierKey: self.kCellIdentifier,
                kCellTagKey: packages.id,
                kCellObjectDataKey: packages.detached(),
                kCellClassKey: PackagesCollectionCell.self,
                kCellHeightKey: PackagesCollectionCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        self._collectionView.loadData(cellSectionData)
        self._collectionViewHieghtConstraint.constant = height
        self._offersStack.isHidden = model.isEmpty
    }
    
    private func _loadData(_ model: [PackageModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var height = 0.0
        
        //        DISPATCH_ASYNC_BG {
        model.forEach { packages in
            height += Utils.stringIsNullOrEmpty(packages.descriptions) ? 33 : 50
            cellData.append([
                kCellIdentifierKey: self.kCellIdentifier,
                kCellTagKey: packages.id,
                kCellObjectDataKey: packages.detached(),
                kCellClassKey: PackagesCollectionCell.self,
                kCellHeightKey: PackagesCollectionCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionViewHieghtConstraint.constant = height
        _offersStack.isHidden = model.isEmpty
        
        DispatchQueue.main.async {
            self._collectionView.loadData(cellSectionData)
        }
        //        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    public func setupData(model: [PackageModel]) {
        _loadData(model)
    }
    
    public func setupData(model: List<PackageModel>) {
        _loadData(model)
    }

}


extension CustomPackageView: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? PackagesCollectionCell ,let object = cellDict?[kCellObjectDataKey] as? PackageModel else { return }
        cell.setupData(object)
        
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let object = cellDict?[kCellObjectDataKey] as? PackageModel
        if Utils.stringIsNullOrEmpty(object?.descriptions) {
            return CGSize(width: collectionView.frame.width, height: 33)
        } else {
            return CGSize(width: collectionView.frame.width, height: 50)
        }
    }
    
}
