import UIKit

class HotelGuestDetailCell: UITableViewCell {

    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet private weak var _collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var _mainBgView: UIView!
    
    private let kCellIdentifier = String(describing: GuestInfoCollectionCell.self)
    private var guestList: [JPPassengerModel] = []


    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: 
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Public setup
    // --------------------------------------

    public func setupdata(_ model: [JPPassengerModel], isFromWallet: Bool = false) {
        _mainBgView.backgroundColor = isFromWallet ? ColorBrand.paigerBgColor : UIColor.init(hexString: "#343434")
        _collectionHeight.constant = CGFloat(model.count * 120)
        guestList = model
        _loadData()

    }

    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: GuestInfoCollectionCell.self, kCellHeightKey: GuestInfoCollectionCell.height]]
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

    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guestList.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: GuestInfoCollectionCell.self,
                kCellHeightKey: GuestInfoCollectionCell.height
            ])
        }

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        self._collectionView.loadData(cellSectionData)
    }

    
}

// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension HotelGuestDetailCell: CustomNoKeyboardCollectionViewDelegate {

    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? GuestInfoCollectionCell, let object = cellDict?[kCellObjectDataKey] as? JPPassengerModel {
            cell.setupData(object, lastRow: (guestList.count - 1) == indexPath.row)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 120)
    }

}
