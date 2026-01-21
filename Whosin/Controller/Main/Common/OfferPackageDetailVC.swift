import UIKit

class OfferPackageDetailVC: PanBaseViewController {
    
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifiereheader = String(describing: OfferDetailHeader.self)
    private let kCellIdentifierDescription = String(describing: VenueDescTableCell.self)
    private let kCellIdentifirePackages = String(describing: PackageOfferTableCell.self)
    private let kCellIdentifireNote = String(describing: OffersNoteCell.self)
    private let kCellIdentifireLoading = String(describing: LoadingCell.self)
    private var offerdata: OffersModel?
    public var offerId: String = kEmptyString
    public var venueModel: VenueDetailModel?
    public var timingModel: [TimingModel]?
    public var vanueOpenCallBack: ((_ venueId: String, _ venueModel: VenueDetailModel?) -> Void)?
    public var buyNowOpenCallBack: ((_ offer: OffersModel?, _ venue: VenueDetailModel,_ timing: [TimingModel]) -> Void)?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if let venue = venueModel {
            _venueInfoView.setupData(venue: venue)
        }
        _requestgetOfferDetailById()
        _loadData(true)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestgetOfferDetailById() {
        WhosinServices.getOfferDetail(offerId: offerId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else {
                if self.isVCPresented {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            self.offerdata = data
            self.venueModel = data.venue
            self._loadData(false)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifiereheader, kCellNibNameKey: kCellIdentifiereheader, kCellClassKey: OfferDetailHeader.self, kCellHeightKey: OfferDetailHeader.height],
            [kCellIdentifierKey: kCellIdentifierDescription, kCellNibNameKey: kCellIdentifierDescription, kCellClassKey: VenueDescTableCell.self, kCellHeightKey: VenueDescTableCell.height],
            [kCellIdentifierKey: kCellIdentifirePackages, kCellNibNameKey: kCellIdentifirePackages, kCellClassKey: PackageOfferTableCell.self, kCellHeightKey: PackageOfferTableCell.height],
            [kCellIdentifierKey: kCellIdentifireLoading, kCellNibNameKey: kCellIdentifireLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifireNote, kCellNibNameKey: kCellIdentifireNote, kCellClassKey: OffersNoteCell.self, kCellHeightKey: OffersNoteCell.height]
        ]
    }
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if let _venue = venueModel {
            _venueInfoView.setupData(venue: _venue, isAllowClick: true)
        }
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kCellIdentifireLoading,
                kCellTagKey: kCellIdentifireLoading,
                kCellObjectDataKey: kEmptyString,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            guard let offerdata = offerdata else { return }
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereheader,
                kCellTagKey: kCellIdentifiereheader,
                kCellObjectDataKey: offerdata,
                kCellClassKey: OfferDetailHeader.self,
                kCellHeightKey: OfferDetailHeader.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDescription,
                kCellTagKey: kCellIdentifierDescription,
                kCellObjectDataKey: offerdata,
                kCellClassKey: VenueDescTableCell.self,
                kCellHeightKey: VenueDescTableCell.height
            ])
            
            offerdata.packages.forEach({ packageModel in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifirePackages,
                    kCellTagKey: kCellIdentifirePackages,
                    kCellObjectDataKey: packageModel,
                    kCellClassKey: PackageOfferTableCell.self,
                    kCellHeightKey: PackageOfferTableCell.height
                ])
            })
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifireNote,
                kCellTagKey: kCellIdentifireNote,
                kCellObjectDataKey: offerdata,
                kCellClassKey: OffersNoteCell.self,
                kCellHeightKey: OffersNoteCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        if self.isVCPresented {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction private func _handleOpenVenueEvent(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.vanueOpenCallBack?(self.venueModel?.id ?? kEmptyString, self.venueModel)
        }
    }
}

// --------------------------------------
// MARK: TableView Delegate
// --------------------------------------

extension OfferPackageDetailVC: CustomTableViewDelegate,UIScrollViewDelegate {
    
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
        if let cell = cell as? OfferDetailHeader {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel, let venue = venueModel else { return }
            cell.timingModel = timingModel
            cell.setupData(object, venueModel: venue)
        } else if let cell = cell as? VenueDescTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            cell.setupDescriptionData(object.descriptions,title: object.title)
        } else if let cell = cell as? PackageOfferTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PackageModel else { return }
            cell.setupData(object, venueModel: venueModel, isOfferDetail: true, promoModel: nil)
        } else if let cell = cell as? OffersNoteCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel, let venue = venueModel else { return }
            cell.timingModel = timingModel
            cell.setupData(object, venueModel: venue, callback: { (bool, error) in
                self.dismiss(animated: true) {
                    self.buyNowOpenCallBack?(object, venue, self.timingModel ?? [])
                }
            })
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
}
