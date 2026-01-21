import UIKit

class YachtComponentTableCell: UITableViewCell {
    
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet private weak var _titleLbl: UILabel!
    @IBOutlet private weak var _subTitleLbl: UILabel!
    private let kCellIdentifier = String(describing: YachtCollectionCell.self)
    private var homeBlockModel: HomeBlockModel?
    @IBOutlet weak var _collectionHeight: NSLayoutConstraint!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: YachtCollectionCell.self, kCellHeightKey: YachtCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              spacing: CGSize(width: 10, height: 10),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        self._collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        guard let _homeBlock = self.homeBlockModel else { return }
        if self._collectionView.numberOfSections > 0 && self._collectionView.numberOfItems(inSection: 0) > 0 {
            let indexPath = IndexPath(item: 0, section: 0)
            self._collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        }
        
//        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
//            guard let self = self else { return }
            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()
            if _homeBlock.cellType == .yacht {
                _homeBlock.yachtList.forEach { yachtModel in
                    self._collectionHeight.constant = yachtModel.features.isEmpty ? 300 : yachtModel.features.count > 3 ? 370 : 334
                    cellData.append([
                        kCellIdentifierKey: self.kCellIdentifier,
                        kCellTagKey: yachtModel.id,
                        kCellObjectDataKey: yachtModel,
                        kCellClassKey: YachtCollectionCell.self,
                        kCellHeightKey: YachtCollectionCell.height,
                        kCellClickEffectKey:true
                    ])
                }
            } else if _homeBlock.cellType == .yachtOffer {
                _homeBlock.yachtOfferList.forEach { yachtOfferModel in
                    self._collectionHeight.constant = yachtOfferModel.yacht?.features.isEmpty == true ? 300 : yachtOfferModel.yacht?.features.count ?? 0 > 3 ? 370 : 334
                    cellData.append([
                        kCellIdentifierKey: self.kCellIdentifier,
                        kCellTagKey: yachtOfferModel.id,
                        kCellObjectDataKey: yachtOfferModel,
                        kCellClassKey: YachtCollectionCell.self,
                        kCellHeightKey: YachtCollectionCell.height,
                        kCellClickEffectKey: true
                    ])
                }
            }
            
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            DispatchQueue.main.async {
                self._collectionView.loadData(cellSectionData)
            }
//        }
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: HomeBlockModel) {
        homeBlockModel = nil
        homeBlockModel = data
        _loadData()
        _titleLbl.text = data.title
        _subTitleLbl.text = data.descriptions

    }
    
}

extension YachtComponentTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? YachtCollectionCell {
            if let object = cellDict?[kCellObjectDataKey] as? YachtDetailModel {
                cell.setUpdata(object)
            } else if let object = cellDict?[kCellObjectDataKey] as? YachtOfferDetailModel {
                cell.setUpOfferdata(object)
            }
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        if let object = cellDict?[kCellObjectDataKey] as? YachtOfferDetailModel {
            let vc = INIT_CONTROLLER_XIB(YachtOfferDetailVC.self)
            vc.offerId = object.id
            vc.yachDetailModel = object
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        guard let _homeBlock = homeBlockModel else { return .zero }
        if let object = cellDict?[kCellObjectDataKey] as? YachtDetailModel {
            let cellHeight: CGFloat = object.features.isEmpty ? 300 : object.features.count > 3 ? 360 : 325
            let width = _homeBlock.yachts.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90
            
            return CGSize(width: width, height: cellHeight)
        } else if let object = cellDict?[kCellObjectDataKey] as? YachtOfferDetailModel {
            let width = _homeBlock.yachtOffer.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90
            let cellHeight: CGFloat = object.yacht?.features.isEmpty == true ? 300 : object.yacht?.features.count ?? 0 > 3 ? 360 : 325
            return CGSize(width: width, height: cellHeight)
        } else { return .zero }
    }
    
}

