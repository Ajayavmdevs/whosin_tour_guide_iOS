import UIKit

enum SuggestedTicketFlowType {
    case horizontal
    case vertical
}

class SuggestedTicketCell: UITableViewCell {

    @IBOutlet weak var titleText: CustomLabel!
    @IBOutlet weak var _subTitleTextLabel: UILabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _collectionHeight: NSLayoutConstraint!
    private let kCellIdentifier = String(describing: SuggestedTicketCollectionViewCell.self)
    private var ticketModel: [TicketModel] = []
    private var flowType: SuggestedTicketFlowType = .vertical

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
        disableSelectEffect()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: SuggestedTicketCollectionViewCell.self, kCellHeightKey: SuggestedTicketCollectionViewCell.height]]
    }
    
    private func setupUi() {
        _collectionView.register(UINib(nibName: kCellIdentifier, bundle: nil), forCellWithReuseIdentifier: kCellIdentifier)
        let isHorizontal = flowType == .horizontal

        _collectionView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            enableRefresh: false,
            columns: 1.01,
            rows: isHorizontal ? 1 : ticketModel.count,
            edgeInsets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 8),
            scrollDirection: isHorizontal ? .horizontal : .vertical,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            delegate: self
        )
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    

    
    private func _loadData() {

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var cellSectionData = [[String: Any]]()
            guard !ticketModel.isEmpty else {
                DispatchQueue.main.async {
                    self._collectionView.loadData(cellSectionData)
                }
                return
            }

            let cellData = ticketModel.map { model in
                [
                    kCellIdentifierKey: self.kCellIdentifier,
                    kCellTagKey: self.kCellIdentifier,
                    kCellDifferenceContentKey: model._id,
                    kCellDifferenceIdentifierKey: model._id,
                    kCellObjectDataKey: model,
                    kCellClassKey: SuggestedTicketCollectionViewCell.self,
                    kCellHeightKey: SuggestedTicketCollectionViewCell.height
                ]
            }

            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            DispatchQueue.main.async {
                self._collectionView.updateData(cellSectionData)
            }
        }
    }
    
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: [TicketModel], scrollingFlow : SuggestedTicketFlowType = .horizontal) {
        flowType = scrollingFlow
        _collectionView.isScrollEnabled = scrollingFlow == .vertical ? false : true
        _collectionView.isUserInteractionEnabled = scrollingFlow == .vertical ? false : true
        ticketModel = data
        setupUi()
        updateCollectionHeight()
        _loadData()
    }
    
    private func updateCollectionHeight() {
        switch flowType {
        case .horizontal:
            _collectionHeight.constant = SuggestedTicketCollectionViewCell.height

        case .vertical:
            _collectionHeight.constant =
                (SuggestedTicketCollectionViewCell.height * CGFloat(ticketModel.count)) + 20
        }
    }


    // --------------------------------------
    // MARK: Event
    // --------------------------------------

}

// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension SuggestedTicketCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? SuggestedTicketCollectionViewCell, let object = cellDict?[kCellObjectDataKey] as? TicketModel {
            cell.setUpdata(object)
        }
    }

    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SuggestedTicketCollectionViewCell, let object = cellDict?[kCellObjectDataKey] as? TicketModel {
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = object._id
            vc.hidesBottomBarWhenPushed = true
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView,cellDict: [String: Any]?,indexPath: IndexPath) -> CGSize {
        switch flowType {
        case .horizontal:
            let width = kScreenWidth * 0.60

            return CGSize(
                width: width,
                height: SuggestedTicketCollectionViewCell.height
            )

        case .vertical:
            return CGSize(
                width: kScreenWidth - 28,
                height: SuggestedTicketCollectionViewCell.height
            )
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard flowType == .horizontal, scrollView == _collectionView else { return }

        _collectionView.visibleCells
            .compactMap { $0 as? SuggestedTicketCollectionViewCell }
            .forEach { $0._gallaryView?.stopAutoScroll() }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard flowType == .horizontal, scrollView == _collectionView else { return }

        _collectionView.visibleCells
            .compactMap { $0 as? SuggestedTicketCollectionViewCell }
            .forEach { $0._gallaryView?.startAutoScroll() }
    }

    
}
