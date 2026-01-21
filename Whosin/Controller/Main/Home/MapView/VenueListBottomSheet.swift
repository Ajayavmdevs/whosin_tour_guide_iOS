import UIKit
import MessageUI
import MHLoadingButton

class VenueListBottomSheet: ChildViewController {
    
    @IBOutlet weak var _donebtn: GradientView!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _searchBar: UISearchBar!
    private let kCellIdentifier = String(describing: VenueListTable.self)
    private let kCellIdentifierCollection = String(describing: SelectVenueCollectionCell.self)
    public var selectedvenueId: String = kEmptyString
    public var _homeBlock: HomeBlockModel?
    public var venueListModel: [VenueDetailModel] = []
    public var onShareButtonTapped: ((VenueDetailModel) -> Void)?
    public var isPromoter: Bool = false
    private var isSearching = false
    private var filteredVenueList: [VenueDetailModel] = []
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // --------------------------------------
    // MARK: SetUp method
    // --------------------------------------
    
    private func _setupCollectionView() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 2,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              spacing: CGSize(width: 5, height: 5),
                              scrollDirection: .vertical,
                              emptyDataText: "There is no venue available",
                              emptyDataIconImage: UIImage(named: "empty_offers"),
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _searchBar.delegate = self
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white
        if venueListModel.isEmpty {
            _requestMyVenues()
        } else {
            _loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Private method
    // --------------------------------------
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: VenueListTable.self, kCellHeightKey: VenueListTable.height] ]
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: SelectVenueCollectionCell.self), kCellNibNameKey: String(describing: SelectVenueCollectionCell.self), kCellClassKey: SelectVenueCollectionCell.self, kCellHeightKey: SelectVenueCollectionCell.height]]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isSearching{
            filteredVenueList.forEach { venueDetail in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierCollection,
                    kCellTagKey: venueDetail.id,
                    kCellObjectDataKey: venueDetail,
                    kCellClassKey: SelectVenueCollectionCell.self,
                    kCellHeightKey: SelectVenueCollectionCell.height
                ])
            }
        } else {
            venueListModel.forEach { venueDetail in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierCollection,
                    kCellTagKey: venueDetail.id,
                    kCellObjectDataKey: venueDetail,
                    kCellClassKey: SelectVenueCollectionCell.self,
                    kCellHeightKey: SelectVenueCollectionCell.height
                ])
            }
        }
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _donebtn.isHidden = venueListModel.isEmpty
        _collectionView.loadData(cellSectionData)
    }
        
    private func _requestMyVenues() {
        showHUD()
        WhosinServices.getMyVenuesList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.venueListModel = data
            _loadData()
        }
    }

    // --------------------------------------
    // MARK: IBActions Event
    // --------------------------------------
    
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        venueListModel.forEach({ venueDetailModel in
            if venueDetailModel.id == selectedvenueId {
                onShareButtonTapped?(venueDetailModel)
                dismiss(animated: true)
            }
        })
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true) {
            self.hideHUD()
        }
    }
}

// --------------------------------------
// MARK: CustomCollectionViewDelegate
// --------------------------------------

extension VenueListBottomSheet: CustomNoKeyboardCollectionViewDelegate {

    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SelectVenueCollectionCell, let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel {
            cell.setUpdata(object, isSelected: selectedvenueId == object.id)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
        selectedvenueId = object.id
        _collectionView.reload()
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = 2
        let padding: CGFloat = 5 * (numberOfColumns + 1)
        let availableWidth = kScreenWidth - padding
        let cellWidth = availableWidth / numberOfColumns
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}

extension VenueListBottomSheet: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            _loadData()
        } else {
            isSearching = true
            filteredVenueList = venueListModel.filter({ $0.name.localizedCaseInsensitiveContains(searchText) })
            _loadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
