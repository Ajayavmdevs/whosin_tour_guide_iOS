import UIKit

class PromoterPublicProfileVc: BaseViewController {
    
    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _promoterName: UILabel!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    private let kCellIdentifierReview = String(describing: RatingTableCell.self)
    private let kCellIdentifierMyVenues = String(describing: MyVenuesTableCell.self)
    private let kCellMyEvents = String(describing: ComplementaryMyEventTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    public var isFromPersonal: Bool = false
    public var promoterId: String?
    private var _promoterModel: PromoterProfileModel?
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        checkSession()
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReload), name: kRelaodActivitInfo, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    override func setupUi() {
        _visualEffectView.alpha = 0
        _promoterName.alpha = 0
        _userImg.alpha = 0
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "empty_promoter_detail".localized(),
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        _userImg.loadWebImage(_promoterModel?.profile?.image ?? kEmptyString,name: _promoterModel?.profile?.firstName ?? kEmptyString)
        _promoterName.text = _promoterModel?.profile?.fullName
        _requestGetProfile()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            PromoterProfileHeaderCell.protocole, MyRingsTableViewCell.protocole, MyCirclesTableCell.protocole,
            [kCellIdentifierKey: kCellIdentifierReview, kCellNibNameKey: kCellIdentifierReview, kCellClassKey: RatingTableCell.self, kCellHeightKey: RatingTableCell.height],
            [kCellIdentifierKey: kCellIdentifierMyVenues, kCellNibNameKey: kCellIdentifierMyVenues, kCellClassKey: MyVenuesTableCell.self, kCellHeightKey: MyVenuesTableCell.height],
            [kCellIdentifierKey: kCellMyEvents, kCellNibNameKey: kCellMyEvents, kCellClassKey: ComplementaryMyEventTableCell.self, kCellHeightKey: ComplementaryMyEventTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height]
        ]
    }
    
    private func _loadData(isLoading: Bool = false,selectedIndex: Int = 0) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if let _promoterModel = _promoterModel {
            _userImg.loadWebImage(_promoterModel.profile?.image ?? kEmptyString,name: _promoterModel.profile?.firstName ?? kEmptyString)
            _promoterName.text = _promoterModel.profile?.fullName

            cellData.append([
                kCellIdentifierKey: PromoterProfileHeaderCell.identifier,
                kCellTagKey: PromoterProfileHeaderCell.identifier,
                kCellObjectDataKey: _promoterModel,
                kCellClassKey: PromoterProfileHeaderCell.self,
                kCellHeightKey: PromoterProfileHeaderCell.height
            ])
            cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
            cellData.removeAll()
            
            if _promoterModel.events.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kEmptyCellIdentifier,
                    kCellTagKey: kEmptyCellIdentifier,
                    kCellObjectDataKey: ["title" : "My Events looking a bit empty? Toss in some vouchers and kickstart those adventures!", "icon": "empty_event"],
                    kCellClassKey: EmptyDataCell.self,
                    kCellHeightKey: EmptyDataCell.height
                ])
            } else {
                _promoterModel.events.forEach { event in
                    if event.status != "cancelled" &&    event.status != "completed" {
                        cellData.append([
                            kCellIdentifierKey: kCellMyEvents,
                            kCellTagKey: kCellMyEvents,
                            kCellObjectDataKey: event,
                            kCellClassKey: ComplementaryMyEventTableCell.self,
                            kCellHeightKey: ComplementaryMyEventTableCell.height
                        ])
                    }
                }
            }
            cellSectionData.append([kSectionTitleKey: "  Events", kSectionDataKey: cellData])
            
//            cellData.append([
//                kCellIdentifierKey: MyRingsTableViewCell.identifier,
//                kCellTagKey: MyRingsTableViewCell.identifier,
//                kCellObjectDataKey: _promoterModel.rings,
//                kCellClassKey: MyRingsTableViewCell.self,
//                kCellHeightKey: MyRingsTableViewCell.height
//            ])
            
//            cellData.append([
//                kCellIdentifierKey: kCellIdentifierReview,
//                kCellTagKey: kCellIdentifierReview,
//                kCellObjectDataKey: _promoterModel.review,
//                kCellClassKey: RatingTableCell.self,
//                kCellHeightKey: RatingTableCell.height
//            ])
            
        }
        
//        cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }
    
    // --------------------------------------
    // MARK: Data/Service
    // --------------------------------------
    
    private func _requestGetProfile() {
        guard let promoterId = promoterId else { return }
        showHUD()
        WhosinServices.getPromoterProfiel(promoterId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return}
            self._promoterModel = data
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @objc func handleReload() {
        _requestGetProfile()
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        if isFromPersonal {
            guard let controller = self.navigationController?.viewControllers.first(where: {$0.isKind(of: NewSearchVC.self)}) else {
                self.navigationController?.popToRootViewController(animated: true)
                return
            }
            self.navigationController?.popToViewController(controller, animated: true)
        } else {
            if self.isVCPresented {
                dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }

}

// --------------------------------------
// MARK: Delegate methods
// --------------------------------------

extension PromoterPublicProfileVc: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 70
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
                self._promoterName.alpha = 1.0
                self._userImg.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 0.0
                self._promoterName.alpha = 0.0
                self._userImg.alpha = 0.0
            }, completion: nil)
        }

    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PromoterProfileHeaderCell {
            guard let object = cellDict?[kCellObjectDataKey] as?  PromoterProfileModel else { return }
            cell.isFromPersonal = isFromPersonal
            cell.setupData(object, isPublic: true)
        } else if let cell = cell as? MyRingsTableViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as?  CommanPromoterRingModel else { return }
            cell.setupData(object, isPublic: true)
        } else if let cell = cell as? MyCirclesTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as?  [UserDetailModel] else { return }
            cell.setupData(object, isPublic: true)
        } else  if let cell = cell as? RatingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? RatingListModel  else { return }
            cell.setupPublicRattings(object, user: _promoterModel?.profile, isFromPromoter: true)
        }  else if let cell = cell as? MyVenuesTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? CommanPromoterVenueModel else { return }
            cell.setupData(object, isPublic: true)
        } else if let cell = cell as? ComplementaryMyEventTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is ComplementaryMyEventTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return}
            let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
            vc.eventModel = object
            vc.id = object.id
            vc.isComplementary = true
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
