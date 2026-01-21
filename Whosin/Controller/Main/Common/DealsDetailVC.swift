import UIKit

class DealsDetailVC: ChildViewController {
    
    @IBOutlet private weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifierDescription = String(describing: VenueDescTableCell.self)
    private let kCellIdentifirePackages = String(describing: PackageOfferTableCell.self)
    private let kCellIdentifireNote = String(describing: OffersNoteCell.self)
    private let kCellIdentifierActivityList = String(describing: DealsFeaturesCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    public var dealsModel: DealsModel?
    public var dealId: String?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dealId = dealId {
            getDetals(dealId)
        } else {
            getDetals(dealsModel?.id ?? kEmptyString)
        }
        setupUi()
    }
    
    override func setupUi() {
        hideNavigationBar()
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no notificaiton yet!",
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: nil,
            delegate: self)
        _visualEffectView.alpha = 0
        _loadData(true)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierDescription, kCellNibNameKey: kCellIdentifierDescription, kCellClassKey: VenueDescTableCell.self, kCellHeightKey: VenueDescTableCell.height],
            [kCellIdentifierKey: kCellIdentifirePackages, kCellNibNameKey: kCellIdentifirePackages, kCellClassKey: PackageOfferTableCell.self, kCellHeightKey: PackageOfferTableCell.height],
            [kCellIdentifierKey: kCellIdentifireNote, kCellNibNameKey: kCellIdentifireNote, kCellClassKey: OffersNoteCell.self, kCellHeightKey: OffersNoteCell.height],
            [kCellIdentifierKey: kCellIdentifierActivityList, kCellNibNameKey: kCellIdentifierActivityList, kCellClassKey: DealsFeaturesCell.self, kCellHeightKey: DealsFeaturesCell.height],
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]]
    }
    
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
            if let venue = dealsModel?.venueModel {
                _venueInfoView.setupData(venue: venue, isAllowClick: true)
            }
            guard let dealsModel = dealsModel else { return }

            
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDescription,
                kCellTagKey: kCellIdentifierDescription,
                kCellObjectDataKey: dealsModel,
                kCellClassKey: VenueDescTableCell.self,
                kCellHeightKey: VenueDescTableCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifierActivityList,
                kCellTagKey: kCellIdentifierActivityList,
                kCellObjectDataKey: dealsModel,
                kCellClassKey: DealsFeaturesCell.self,
                kCellHeightKey: DealsFeaturesCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func getDetals(_ dealsId: String) {
        WhosinServices.getDealsDetail(dealsId: dealsId) { [weak self] container, error in
            guard let self = self else { return }
            if let data = container?.data {
                self.dealsModel = data
                self._loadData()
            } else {
                self.showError(error)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// --------------------------------------
// MARK: TableView Delegate
// --------------------------------------


extension DealsDetailVC: CustomTableViewDelegate,UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 20
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath){
      if let cell = cell as? DealsFeaturesCell {
            guard let object = cellDict?[kCellObjectDataKey] as? DealsModel else { return }
            cell.setupDealsData(object)
        }
    }
}

