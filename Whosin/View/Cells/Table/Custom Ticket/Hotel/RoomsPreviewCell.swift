import UIKit

class RoomsPreviewCell: UITableViewCell {

    @IBOutlet weak var _roomType: CustomLabel!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _height: NSLayoutConstraint!

    private let kCellIdentifier = String(describing: RoomsCollectionCell.self)
    private var hotelInfo: JPHotelInfoModel?
    private var availibility: JPHotelAvailibilityOptionModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: LifeCycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
        disableSelectEffect()
    }
    
    public func setupData(_ model: JPPriceInformation) {
        _roomType.text = (model.board?.boardName ?? "") + " | " + (model.board?.typeCode ?? "")
        _height.constant = CGFloat(model.hotelRooms.count * 82)
        _loadData(model.hotelRooms.toArrayDetached(ofType:JPHotelRoomModel.self))
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: RoomsCollectionCell.self, kCellHeightKey: RoomsCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            enableRefresh: false,
            columns: 1,
            rows: 3,
            scrollDirection: .horizontal,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            delegate: self
        )
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }

    private func _loadData(_ model: [JPHotelRoomModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        model.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: RoomsCollectionCell.self,
                kCellHeightKey: RoomsCollectionCell.height
            ])
        }

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        self._collectionView.loadData(cellSectionData)
    }
    

}

// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension RoomsPreviewCell: CustomNoKeyboardCollectionViewDelegate {

    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? RoomsCollectionCell, let object = cellDict?[kCellObjectDataKey] as? JPHotelRoomModel {
            cell.setupData(object, isNoBackground: true)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }

}
