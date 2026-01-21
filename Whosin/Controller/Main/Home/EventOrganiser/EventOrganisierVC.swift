import UIKit
import RealmSwift
import Hero

class EventOrganisierVC: ChildViewController {
    
    @IBOutlet private weak var _tableview: CustomTableView!
    @IBOutlet private weak var _venueAddress: UILabel!
    @IBOutlet private weak var _venueName: UILabel!
    @IBOutlet private weak var _logoImage: UIImageView!
    @IBOutlet private weak var _backButton: UIButton!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    private let kCellIdentifierEventDetail = String(describing: EventDetailsTableCell.self)
    private let kCellIdentifierRating = String(describing: RatingTableCell.self)
    private let kCellIdentifierEventOffers = String(describing: EventOffersTableCell.self)
    private let kCellIdentifierVenueDesc = String(describing: VenueDescTableCell.self)
    private let kLoadingCellIdentifier = String(describing: LoadingCell.self)
    
    public var venueId: String = kEmptyString
    public var orgId: String = kEmptyString
    private var _organizationModel: OrganizaitionDetailModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _requestOrganization()
        _loadData(isLoading: true)
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestOrganization() {
        showHUD()
        WhosinServices.getOrganizationDetail(orgId: orgId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._organizationModel = data
            self._loadData(isLoading: false)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    override func setupUi() {
        hideNavigationBar()
        _tableview.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no event detail available",
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: nil,
            delegate: self)
        _tableview.proxyDelegate = self
        _visualEffectView.alpha = 0
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReload), name: kRelaodActivitInfo, object: nil)
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let organizationModel = _organizationModel else {
            return
        }
        cellData.append([
            kCellIdentifierKey: kCellIdentifierEventDetail,
            kCellTagKey: kCellIdentifierEventDetail,
            kCellObjectDataKey: organizationModel,
            kCellClassKey: EventDetailsTableCell.self,
            kCellHeightKey: EventDetailsTableCell.height
        ])
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifier,
                kCellTagKey: kLoadingCellIdentifier,
                kCellObjectDataKey: organizationModel,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierRating,
                kCellTagKey: kCellIdentifierRating,
                kCellObjectDataKey: organizationModel,
                kCellClassKey: RatingTableCell.self,
                kCellHeightKey: RatingTableCell.height
            ])
        }
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        cellData.removeAll()
        guard let eventModel = _organizationModel?.eventModel else { return }
        eventModel.forEach { eventModel in
            if !Utils.isVenueDetailEmpty(eventModel.venueDetail) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierEventOffers,
                    kCellTagKey: kCellIdentifierEventOffers,
                    kCellObjectDataKey: eventModel,
                    kCellClassKey: EventOffersTableCell.self,
                    kCellHeightKey: EventOffersTableCell.height
                ])
            }
        }
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: "Check out our Events", kSectionDataKey: cellData])
        }
        _logoImage.loadWebImage(organizationModel.logo, name: organizationModel.name)
        _venueName.text = organizationModel.name
        _venueAddress.text = organizationModel.website
        _tableview.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierEventDetail, kCellNibNameKey: kCellIdentifierEventDetail, kCellClassKey: EventDetailsTableCell.self, kCellHeightKey: EventDetailsTableCell.height],
            [kCellIdentifierKey: kCellIdentifierRating, kCellNibNameKey: kCellIdentifierRating, kCellClassKey: RatingTableCell.self, kCellHeightKey: RatingTableCell.height],
            [kCellIdentifierKey: kCellIdentifierEventOffers, kCellNibNameKey: kCellIdentifierEventOffers, kCellClassKey: EventOffersTableCell.self, kCellHeightKey: EventOffersTableCell.height],
            [kCellIdentifierKey: kCellIdentifierVenueDesc, kCellNibNameKey: kCellIdentifierVenueDesc, kCellClassKey: VenueDescTableCell.self, kCellHeightKey: VenueDescTableCell.height],
            [kCellIdentifierKey: kLoadingCellIdentifier, kCellNibNameKey: kLoadingCellIdentifier, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]
        ]
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleReload() { _requestOrganization() }
    
}

extension EventOrganisierVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
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
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EventDetailsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OrganizaitionDetailModel else { return }
            cell.setupData(object) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        } else if let cell = cell as? VenueDescTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            cell.setupData(object, isShowTitle: true)
        } else if let cell = cell as? RatingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OrganizaitionDetailModel else { return }
            cell.delegate = self
            cell.setupEventData(object, isFromEvent: true)
        } else if let cell = cell as? EventOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            cell.setupData(object)
        }else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is EventOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            let vc = INIT_CONTROLLER_XIB(EventDetailVC.self)
            vc.event = object
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

extension EventOrganisierVC: desableScrollWhenRatingDelegate {
    func enableScrollEffect() {
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self._tableview.isScrollEnabled = true
        }
    }
    
    func desableScrollEffect() {
        _tableview.isScrollEnabled = false
    }
}
