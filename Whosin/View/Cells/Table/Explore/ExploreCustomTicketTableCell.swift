import UIKit

class ExploreCustomTicketTableCell: UITableViewCell {

    @IBOutlet weak var titleText: CustomLabel!
    @IBOutlet weak var _subTitleTextLabel: CustomLabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: NewTicketCollectionCell.self)
    private var ticketModel: [TicketModel] = []
    private var _exploreBlock: HomeBlockModel?

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
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: NewTicketCollectionCell.self, kCellHeightKey: NewTicketCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.register(UINib(nibName: kCellIdentifier, bundle: nil), forCellWithReuseIdentifier: kCellIdentifier)
        _collectionView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            enableRefresh: false,
            columns: 1.01,
            rows: 1,
            edgeInsets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14),
            scrollDirection: .horizontal,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            delegate: self
        )
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }

    
    private func _loadData() {
        guard let homeBlock = _exploreBlock else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var cellSectionData = [[String: Any]]()
            guard !homeBlock.ticketList.isEmpty else {
                DispatchQueue.main.async {
                    self._collectionView.loadData(cellSectionData)
                }
                return
            }

            self.ticketModel = homeBlock.ticketList
            let cellData = homeBlock.ticketList.map { model in
                [
                    kCellIdentifierKey: self.kCellIdentifier,
                    kCellTagKey: self.kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: NewTicketCollectionCell.self,
                    kCellHeightKey: NewTicketCollectionCell.height
                ]
            }

            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            DispatchQueue.main.async {
                self._collectionView.loadData(cellSectionData)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: HomeBlockModel) {
        _exploreBlock = data
        titleText.text = data.title
        _subTitleTextLabel.text = data.descriptions
        titleText.isHidden = !data.showTitle
        _subTitleTextLabel.isHidden = !data.showTitle
        _loadData()
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleSeeAllEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(SeeAllTicketsVC.self)
        vc.ticketList = ticketModel
        vc.isHotelSearch = _exploreBlock?.type == "juniper-hotel"
        vc.titleText = titleText.text ?? "tickets".localized()
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension ExploreCustomTicketTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? NewTicketCollectionCell, let object = cellDict?[kCellObjectDataKey] as? TicketModel {
            cell.setUpdata(object)
        }
    }

    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? NewTicketCollectionCell,let data = cellDict?[kCellObjectDataKey] as? TicketModel {
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = data._id
            vc.hidesBottomBarWhenPushed = true
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String: Any]?, indexPath: IndexPath) -> CGSize {
        guard let homeBlock = _exploreBlock, !homeBlock.ticketList.isEmpty else {
            return CGSize(width: ticketModel.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90, height: NewTicketCollectionCell.height)
        }
        return CGSize(width: homeBlock.ticketList.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90, height: NewTicketCollectionCell.height)
    }
    
}
