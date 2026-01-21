import UIKit

class HomeCmEventTableCell: UITableViewCell {

    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var titleText: CustomLabel!
    @IBOutlet weak var _subTitleTextLabel: UILabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    
    private let kCellIdentifier = String(describing: CMEventListCollectionCell.self)
    private var eventModel: [PromoterEventsModel] = []
    private weak var _homeBlock: HomeBlockModel?

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

    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        guard let _homeBlock = _homeBlock else {
            return
        }
        
        _subTitleTextLabel.text = _homeBlock.title
        
        if !_homeBlock.promoterEvents.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                let detachedEvents = _homeBlock.promoterEvents.toArrayDetached(ofType: PromoterEventsModel.self)
                let sortedEvents = detachedEvents.sorted { ($0.startingSoon ?? Date()) < ($1.startingSoon ?? Date()) }
                let filteredEvents = sortedEvents.filter { $0.status != "completed" && $0.status != "cancelled" }
                
                var cellSectionData: [[String: Any]] = []
                var cellData: [[String: Any]] = []
                
                for model in filteredEvents {
                    cellData.append([
                        kCellIdentifierKey: self.kCellIdentifier,
                        kCellTagKey: model.id,
                        kCellObjectDataKey: model,
                        kCellClassKey: CMEventListCollectionCell.self,
                        kCellHeightKey: CMEventListCollectionCell.height
                    ])
                }
                
                cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
                
                DispatchQueue.main.async {
                    self._collectionView.loadData(cellSectionData)
                }
            }
        } else {
            DispatchQueue.main.async {
                self._collectionView.clear()
            }
        }
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private var _prototype: [[String: Any]] {
        return [[
            kCellIdentifierKey: kCellIdentifier,
            kCellNibNameKey: kCellIdentifier,
            kCellClassKey: CMEventListCollectionCell.self,
            kCellHeightKey: CMEventListCollectionCell.height
        ]]
    }
    
    private func setupUi() {
        _collectionView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            enableRefresh: false,
            columns: 1.01,
            rows: 1,
            edgeInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 10),
            scrollDirection: .horizontal,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            delegate: self
        )
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._bgView.roundCorners(corners: [.bottomLeft , .topLeft], radius: 10)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: HomeBlockModel) {
        _homeBlock = data
        _subTitleTextLabel.text = data.title
        titleText.text = data.descriptions

        if !data.promoterEvents.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                self.eventModel = data.promoterEvents.toArrayDetached(ofType: PromoterEventsModel.self)
                let sortedEvents = self.eventModel.sorted { ($0.startingSoon ?? Date()) < ($1.startingSoon ?? Date()) }
                let filteredEvents = sortedEvents.filter { $0.status != "completed" && $0.status != "cancelled" }

                var cellSectionData: [[String: Any]] = []
                var cellData: [[String: Any]] = []
                
                for model in filteredEvents {
                    cellData.append([
                        kCellIdentifierKey: self.kCellIdentifier,
                        kCellTagKey: model.id,
                        kCellObjectDataKey: model,
                        kCellClassKey: CMEventListCollectionCell.self,
                        kCellHeightKey: CMEventListCollectionCell.height
                    ])
                }
                
                cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
                
                DispatchQueue.main.async {
                    self._collectionView.loadData(cellSectionData)
                }
            }
        } else {
            DispatchQueue.main.async {
                self._collectionView.clear()
            }
        }
    }

    @IBAction private func seeAllButtonEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        self.parentViewController?.tabBarController?.selectedIndex = 2
    }
}

extension HomeCmEventTableCell: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        guard let cell = cell as? CMEventListCollectionCell,
              let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
        cell.setupData(object)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String: Any]?, indexPath: IndexPath) {
        guard let cell = cell as? CMEventListCollectionCell,
              let data = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
        
        let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
        vc.isComplementary = true
        vc.eventModel = data
        vc.id = data.id
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String: Any]?, indexPath: IndexPath) -> CGSize {
        guard let _homeBlock = _homeBlock else { return .zero }
        return CGSize(
            width: _homeBlock.promoterEvents.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90,
            height: CMEventListCollectionCell.height
        )
    }
}
