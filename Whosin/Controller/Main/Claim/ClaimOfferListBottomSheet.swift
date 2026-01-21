import UIKit

protocol GetSelectedOfferDelegate {
    func didSelectedOffer(_ model: OffersModel)
}

class ClaimOfferListBottomSheet: ChildViewController {

    @IBOutlet weak var _tableView: CustomTableView!
    private let kCellIdentifier = String(describing: VenueListTable.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    public var brunchList: [OffersModel] = []
    public var venueId: String = kEmptyString
    public var isFromInvite: Bool = false
    public var onButtonButtonTapped: ((OffersModel) -> Void)?
    public var selectedvenueId: String = kEmptyString
    public var delegate: GetSelectedOfferDelegate?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self._loadData(false)
    }

    override func setupUi() {
        hideNavigationBar()
        hideLeftBarButton(true)
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: "offers looking a bit empty? Toss in some vouchers and kickstart those adventures!",
            delegate: self)
        _tableView.showsVerticalScrollIndicator = false
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: kCollectionDefaultMargin, right: 0)
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierLoading,
                kCellTagKey: kCellIdentifierLoading,
                kCellObjectDataKey: kEmptyString,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            brunchList.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: model.id,
                    kCellObjectDataKey: model,
                    kCellClassKey: VenueListTable.self,
                    kCellHeightKey: VenueListTable.height
                ])
            }
        }
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
    }

    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: VenueListTable.self, kCellHeightKey: VenueListTable.height],
                 [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]]
    }
    
    @IBAction private func _handleCloseEvent(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

extension ClaimOfferListBottomSheet: CustomTableViewDelegate {
        
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? VenueListTable, let object = cellDict?[kCellObjectDataKey] as? OffersModel {
            cell.setOffersUpdata(object, isSelected: selectedvenueId == object.id)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? VenueListTable, let object = cellDict?[kCellObjectDataKey] as? OffersModel {
            selectedvenueId = object.id
            _tableView.reload()
            brunchList.forEach({ model in
                if model.id == selectedvenueId {
                    delegate?.didSelectedOffer(model)
                    dismiss(animated: true)
                }
            })
        }

    }

}
