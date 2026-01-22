import UIKit

class AllCustomTicketTableCell: UITableViewCell {

    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifierActivity = String(describing: NewTicketCollectionCell.self)
    private var _ticketModel: [TicketModel] = []


    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        360
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
        _titleLabel.text = "tickets".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func setupUi() {
        let spacing = 0
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1.1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.reload()
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _ticketModel.forEach { activity in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierActivity,
                kCellTagKey: kCellIdentifierActivity,
                kCellObjectDataKey: activity,
                kCellClassKey: NewTicketCollectionCell.self,
                kCellHeightKey: NewTicketCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        _collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .right, animated: true)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifierActivity, kCellNibNameKey: kCellIdentifierActivity, kCellClassKey: NewTicketCollectionCell.self, kCellHeightKey: NewTicketCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: [TicketModel]) {
        _ticketModel = data
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleMoreEvent(_ sender: UIButton) {
//        delegate?.didSelectCategory("ticket")
    }
    
}

// --------------------------------------
// MARK: Custom Collection View
// --------------------------------------

extension AllCustomTicketTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? NewTicketCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
            cell.setUpdata(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
        let firstImageURL = object.images.compactMap { $0 as String }
            .first { ["jpg", "jpeg", "png"].contains(URL(string: $0)?.pathExtension.lowercased() ?? "") } ?? kEmptyString
        APPSETTING.addSearchHistory(id: object._id, title: object.title, subtitle: object.descriptions, type: "ticket", image: firstImageURL )
        let controller = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
        controller.ticketID = object._id
        controller.hidesBottomBarWhenPushed = true
        self.parentViewController?.navigationController?.pushViewController(controller, animated: true)

    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if _ticketModel.count == 1 {
            return CGSize(width: collectionView.frame.width - 28, height: NewTicketCollectionCell.height)
        } else {
            return CGSize(width: kScreenWidth * 0.9, height: NewTicketCollectionCell.height)
        }
    }

}

