import UIKit

class UserPlusOneEventTableCell: UITableViewCell {

    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _emptyImg: UIImageView!
    @IBOutlet weak var _emptyText: UILabel!
    private let kCellIdentifier = String(describing: CMEventListCollectionCell.self)
    private var eventModel: [PromoterEventsModel] = []
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 410 }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: CMEventListCollectionCell.self, kCellHeightKey: CMEventListCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                                   hasHeaderSection: false,
                                   enableRefresh: false,
                                   columns: 1.01,
                                   rows: 1,
                                   edgeInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15),
                                   scrollDirection: .horizontal,
                                   emptyDataText: nil,
                                   emptyDataIconImage: nil,
                                   delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if eventModel.isEmpty {
            DispatchQueue.main.async {
                self._emptyImg.isHidden = false
                self._emptyText.isHidden = false
            }
        } else {
            eventModel.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: model.id,
                    kCellObjectDataKey: model,
                    kCellClassKey: CMEventListCollectionCell.self,
                    kCellHeightKey: CMEventListCollectionCell.height
                ])
            }
            DispatchQueue.main.async {
                self._emptyImg.isHidden = true
                self._emptyText.isHidden = true
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        DispatchQueue.main.async {
            self._collectionView.loadData(cellSectionData)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: [PromoterEventsModel]) {
        eventModel = data
        _loadData()
    }

}

extension UserPlusOneEventTableCell: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CMEventListCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
            cell.setupPlusData(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let data = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
        let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
        vc.isplusOne = true
        vc.eventModel = data
        vc.id = data.id
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: eventModel.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90, height: CMEventListCollectionCell.height)
    }
    
}

