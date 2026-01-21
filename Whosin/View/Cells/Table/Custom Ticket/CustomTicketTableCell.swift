import UIKit

class CustomTicketTableCell: UITableViewCell {

    @IBOutlet weak var titleText: CustomLabel!
    @IBOutlet weak var _subTitleTextLabel: UILabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: NewTicketCollectionCell.self)
    private var ticketModel: [TicketModel] = []
    private var _homeBlock: HomeBlockModel?

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
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadOnLike(_:)), name: .reloadOnLike, object: nil)
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
            edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 8),
            scrollDirection: .horizontal,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            delegate: self
        )
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    @objc private func handleReloadOnLike(_ notification: Notification) {
        if let data = notification.object as? [String: Any],
           let id = data["id"] as? String,
           let flag = data["flag"] as? Bool {
            if _homeBlock?.favoriteTicketIds.isEmpty == false {
                if _homeBlock?.type == "favorite_ticket" {
                    if let index = _homeBlock?.favoriteTicketIds.firstIndex(of: id) {
                        _homeBlock?.favoriteTicketIds.remove(at: index)
                        _homeBlock?.ticketList.removeAll(where: { $0._id == id })
                    } else {
                        _homeBlock?.favoriteTicketIds.append(id)
                        if let ticket = APPSETTING.ticketList?.first(where: { $0._id == id }),
                           !(_homeBlock?.ticketList.contains(where: { $0._id == id }) ?? false) {
                                _homeBlock?.ticketList.append(ticket)
                            }
                    }
                    _homeBlock?.ticketList.first(where: { $0._id == id })?.isFavourite = flag
                }
                _loadData()
            }
        }
    }

    
    private func _loadData() {
        guard let homeBlock = _homeBlock else { return }

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
                    kCellDifferenceContentKey: model._id,
                    kCellDifferenceIdentifierKey: model._id,
                    kCellObjectDataKey: model,
                    kCellClassKey: NewTicketCollectionCell.self,
                    kCellHeightKey: NewTicketCollectionCell.height
                ]
            }

            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            DispatchQueue.main.async {
                self._collectionView.updateData(cellSectionData)
            }
        }
    }
    
    private func _loadDataExplore() {
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
        _homeBlock = data
        titleText.isHidden = Utils.stringIsNullOrEmpty(data.descriptions)
        _subTitleTextLabel.text = data.title
        titleText.text = data.descriptions
        _loadData()
    }
    
    public func setupExploreData(_ data: HomeBlockModel) {
        ticketModel = data.ticketList
        titleText.isHidden = Utils.stringIsNullOrEmpty(data.descriptions)
        _subTitleTextLabel.text = data.title
        titleText.text = data.descriptions
        _loadDataExplore()
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleSeeAllEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(SeeAllTicketsVC.self)
        vc.ticketList = ticketModel
        vc.titleText = _subTitleTextLabel.text ?? "tickets".localized()
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension CustomTicketTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? NewTicketCollectionCell, let object = cellDict?[kCellObjectDataKey] as? TicketModel {
            cell.setUpdata(object)
        }
    }

    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? NewTicketCollectionCell, let object = cellDict?[kCellObjectDataKey] as? TicketModel {
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = object._id
            vc.hidesBottomBarWhenPushed = true
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String: Any]?, indexPath: IndexPath) -> CGSize {
        guard let homeBlock = _homeBlock, !homeBlock.ticketList.isEmpty else {
            return CGSize(width: ticketModel.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90, height: NewTicketCollectionCell.height)
        }
        return CGSize(width: homeBlock.ticketList.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90, height: NewTicketCollectionCell.height)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView == _collectionView else { return }

        for cell in _collectionView.visibleCells {
            if let ticketCell = cell as? NewTicketCollectionCell {
                ticketCell._gallaryView?.stopAutoScroll()
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == _collectionView else { return }

        for cell in _collectionView.visibleCells {
            if let ticketCell = cell as? NewTicketCollectionCell {
                ticketCell._gallaryView?.startAutoScroll()
            }
        }
    }
    
}
