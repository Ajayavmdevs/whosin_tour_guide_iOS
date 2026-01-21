import UIKit
import SwiftUI

class FastPicksTableCell: UITableViewCell {

    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: FastpicksCollectionCell.self)
    private var venueModel: [VenueDetailModel] = []

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        280
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setupUi()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: FastpicksCollectionCell.self, kCellHeightKey: FastpicksCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                                   hasHeaderSection: false,
                                   enableRefresh: false,
                                   columns: 1,
                                   rows: 3,
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
        var id = 0
        venueModel.forEach { venueModel in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: id,
                kCellObjectDataKey: venueModel,
                kCellClassKey: FastpicksCollectionCell.self,
                kCellHeightKey: FastpicksCollectionCell.height
            ])
            id += 1
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData() {
        setupUi()
    }

    
}

extension FastPicksTableCell: CustomCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? FastpicksCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            cell.setUpdata(object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: kScreenWidth * 0.85, height: 60)
    }
}
