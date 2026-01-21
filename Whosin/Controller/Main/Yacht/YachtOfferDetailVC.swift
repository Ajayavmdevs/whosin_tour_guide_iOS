import UIKit

class YachtOfferDetailVC: ChildViewController {

    @IBOutlet weak var _subTitle: UILabel!
    @IBOutlet weak var _titileText: UILabel!
    @IBOutlet private weak var _tableview: CustomTableView!
    @IBOutlet private weak var _backButton: UIButton!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    private let kCellIdentifierVenueDetail = String(describing: YachtOfferDetailCell.self)
    private let kCellIdentifierDescription = String(describing: YachtDescTableCell.self)
    private let kCellIdentifierFeatures = String(describing: YachFeaturesTableCell.self)
    private let kLoadingCellIdentifierPackage = String(describing: YachPackagesCell.self)
    private let kSpecificationCell = String(describing: SpecificationsTableCell.self)
    private let kCollapsCell = String(describing: CollapsibleDescCell.self)
    private let kButtonsCell = String(describing: YachButtonTableCell.self)
    private let kLoadingCellIdentifier = String(describing: LoadingCell.self)
    private let kTimeSlotsCell = String(describing: YachtTimeSlotsTableCell.self)
    private let kHourlyPackageCell = String(describing: YachHourlyPackageCell.self)
    public var offerId: String = kEmptyString
    public var yachDetailModel: YachtOfferDetailModel?
    

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    override func setupUi() {
        //TABEL VIEW
        _tableview.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no data available",
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: nil,
            delegate: self)
        _tableview.proxyDelegate = self
        _tableview.contentInset = UIEdgeInsets(top: -70, left: 0, bottom: 70, right: 0)
        _titileText.text = yachDetailModel?.yacht?.name
        _subTitle.text = yachDetailModel?.yacht?.about
        _visualEffectView.alpha = 0
        _requestDetail()
    }

    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let yachDetailModel = yachDetailModel else { return }
        _titileText.text = yachDetailModel.yacht?.name
        _subTitle.text = yachDetailModel.yacht?.about
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierVenueDetail,
            kCellTagKey: kCellIdentifierVenueDetail,
            kCellObjectDataKey: yachDetailModel,
            kCellClassKey: YachtOfferDetailCell.self,
            kCellHeightKey: YachtOfferDetailCell.height
        ])
        
        if yachDetailModel.yacht?.specifications.isEmpty == false {
            cellData.append([
                kCellIdentifierKey: kSpecificationCell,
                kCellTagKey: kSpecificationCell,
                kCellObjectDataKey: yachDetailModel.yacht?.specifications.toArrayDetached(ofType: SpecificationsModel.self),
                kCellClassKey: SpecificationsTableCell.self,
                kCellHeightKey: SpecificationsTableCell.height
            ])
        }
        
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifier,
                kCellTagKey: kLoadingCellIdentifier,
                kCellObjectDataKey: yachDetailModel,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDescription,
                kCellTagKey: kCellIdentifierDescription,
                kCellObjectDataKey: yachDetailModel,
                kCellClassKey: YachtDescTableCell.self,
                kCellHeightKey: YachtDescTableCell.height
            ])
            
            if !(yachDetailModel.yacht?.features.isEmpty ?? false) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierFeatures,
                    kCellTagKey: kCellIdentifierFeatures,
                    kCellObjectDataKey: yachDetailModel.yacht?.features.toArrayDetached(ofType: CommonSettingsModel.self),
                    kCellClassKey: YachFeaturesTableCell.self,
                    kCellHeightKey: YachFeaturesTableCell.height
                ])
            }
            
            if !yachDetailModel.packages.isEmpty {
                if yachDetailModel.packageType == "hourly" {
                    cellData.append([
                        kCellIdentifierKey: kHourlyPackageCell,
                        kCellTagKey: kHourlyPackageCell,
                        kCellObjectDataKey: yachDetailModel.packages.toArrayDetached(ofType: YachtPackgeModel.self),
                        kCellClassKey: YachHourlyPackageCell.self,
                        kCellHeightKey: YachHourlyPackageCell.height
                    ])
                } else {
                    cellData.append([
                        kCellIdentifierKey: kLoadingCellIdentifierPackage,
                        kCellTagKey: kLoadingCellIdentifierPackage,
                        kCellObjectDataKey: yachDetailModel.packages.toArrayDetached(ofType: YachtPackgeModel.self),
                        kCellClassKey: YachPackagesCell.self,
                        kCellHeightKey: YachPackagesCell.height
                    ])
                }
            }

//            if yachDetailModel.packageType == "hourly" {
//                cellData.append([
//                    kCellIdentifierKey: kTimeSlotsCell,
//                    kCellTagKey: kTimeSlotsCell,
//                    kCellObjectDataKey: yachDetailModel,
//                    kCellClassKey: YachTimeSlotsTableCell.self,
//                    kCellHeightKey: YachTimeSlotsTableCell.height
//                ])
//            }
            
            if !yachDetailModel.addOns.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kLoadingCellIdentifierPackage,
                    kCellTagKey: kLoadingCellIdentifierPackage,
                    kCellObjectDataKey: yachDetailModel.addOns.toArrayDetached(ofType: AddOnsModel.self),
                    kCellClassKey: YachPackagesCell.self,
                    kCellHeightKey: YachPackagesCell.height
                ])
            }
            
            if !Utils.stringIsNullOrEmpty(yachDetailModel.needToKnow) {
                cellData.append([
                    kCellIdentifierKey: kCollapsCell,
                    kCellTagKey: "needToKnow",
                    kCellObjectDataKey: yachDetailModel,
                    kCellClassKey: CollapsibleDescCell.self,
                    kCellHeightKey: CollapsibleDescCell.height
                ])
            }
            
            if !Utils.stringIsNullOrEmpty(yachDetailModel.importantNotice) {
                cellData.append([
                    kCellIdentifierKey: kCollapsCell,
                    kCellTagKey: "importantNotice",
                    kCellObjectDataKey: yachDetailModel,
                    kCellClassKey: CollapsibleDescCell.self,
                    kCellHeightKey: CollapsibleDescCell.height
                ])
            }
            
            if !Utils.stringIsNullOrEmpty(yachDetailModel.disclaimer) {
                cellData.append([
                    kCellIdentifierKey: kCollapsCell,
                    kCellTagKey: "disclaimer",
                    kCellObjectDataKey: yachDetailModel,
                    kCellClassKey: CollapsibleDescCell.self,
                    kCellHeightKey: CollapsibleDescCell.height
                ])
            }
            
            cellData.append([
                kCellIdentifierKey: kButtonsCell,
                kCellTagKey: kButtonsCell,
                kCellObjectDataKey: yachDetailModel,
                kCellClassKey: YachButtonTableCell.self,
                kCellHeightKey: YachButtonTableCell.height
            ])

        }
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        
        DISPATCH_ASYNC_MAIN {
            self._tableview.loadData(cellSectionData)
        }
        
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestDetail() {
        showHUD()
        WhosinServices.getyachtOfferDetail(offerId: offerId) { [weak self] container, error in
            guard let self = self else { return }
            hideHUD(error: error)
            guard let data = container?.data else { return }
            self.yachDetailModel = data
            self._loadData()
        }
    }
    
    private func _requestTimeSlots(_ id:String) {
        showHUD()
        WhosinServices.getPackageTimeSlot(packageId: id) { [weak self] container, error in
            guard let self = self else { return }
            hideHUD(error: error)
            guard let data = container?.data else { return }
//            self.yachDetailModel = data
            self._loadData()
        }
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierVenueDetail, kCellNibNameKey: kCellIdentifierVenueDetail, kCellClassKey: YachtOfferDetailCell.self, kCellHeightKey: YachtOfferDetailCell.height],
            [kCellIdentifierKey: kCellIdentifierDescription, kCellNibNameKey: kCellIdentifierDescription, kCellClassKey: YachtDescTableCell.self, kCellHeightKey: YachtDescTableCell.height],
            [kCellIdentifierKey: kCellIdentifierFeatures, kCellNibNameKey: kCellIdentifierFeatures, kCellClassKey: YachFeaturesTableCell.self, kCellHeightKey: YachFeaturesTableCell.height],
            [kCellIdentifierKey: kLoadingCellIdentifierPackage, kCellNibNameKey: kLoadingCellIdentifierPackage, kCellClassKey: YachPackagesCell.self, kCellHeightKey: YachPackagesCell.height],
            [kCellIdentifierKey: kCollapsCell, kCellNibNameKey: kCollapsCell, kCellClassKey: CollapsibleDescCell.self, kCellHeightKey: CollapsibleDescCell.height],
            [kCellIdentifierKey: kSpecificationCell, kCellNibNameKey: kSpecificationCell, kCellClassKey: SpecificationsTableCell.self, kCellHeightKey: SpecificationsTableCell.height],
            [kCellIdentifierKey: kButtonsCell, kCellNibNameKey: kButtonsCell, kCellClassKey: YachButtonTableCell.self, kCellHeightKey: YachButtonTableCell.height],
            [kCellIdentifierKey: kTimeSlotsCell, kCellNibNameKey: kTimeSlotsCell, kCellClassKey: YachtTimeSlotsTableCell.self, kCellHeightKey: YachtTimeSlotsTableCell.height],
            [kCellIdentifierKey: kHourlyPackageCell, kCellNibNameKey: kHourlyPackageCell, kCellClassKey: YachHourlyPackageCell.self, kCellHeightKey: YachHourlyPackageCell.height],
            [kCellIdentifierKey: kLoadingCellIdentifier, kCellNibNameKey: kLoadingCellIdentifier, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]
        ]
        
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
}


extension YachtOfferDetailVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
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
                self._visualEffectView.alpha = 0
            }, completion: nil)
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? YachtOfferDetailCell {
            guard let object = cellDict?[kCellObjectDataKey] as? YachtOfferDetailModel else { return }
            cell.setup(model: object)
        } else if let cell = cell as? SpecificationsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [SpecificationsModel] else { return }
            cell.setupData(object)
        } else if let cell = cell as? YachtDescTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? YachtOfferDetailModel else { return }
            cell.setupabout(object.descriptions)
            cell._bottomConstraint.constant = 10
        } else if let cell = cell as? YachFeaturesTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [CommonSettingsModel] else { return }
            cell.setup(object, isOffer: true)
        } else if let cell = cell as? YachPackagesCell {
            if let object = cellDict?[kCellObjectDataKey] as? [YachtPackgeModel] {
                cell.setupPackage(object, type: yachDetailModel?.packageType ?? kEmptyString)
            } else if let object = cellDict?[kCellObjectDataKey] as? [AddOnsModel] {
                cell.setupAddon(object)
            }
        } else if let cell = cell as? YachHourlyPackageCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [YachtPackgeModel] else { return }
            cell.setupPackage(object, type: "Hourly")
        } else if let cell = cell as? CollapsibleDescCell {
            guard let object = cellDict?[kCellObjectDataKey] as? YachtOfferDetailModel else { return }
            guard let type = cellDict?[kCellTagKey] as? String else { return }
            if type == "needToKnow" {
                cell.setupData(object.needToKnow, type: "NEED TO KNOW")
            } else if type == "importantNotice" {
                cell.setupData(object.importantNotice, type: "IMPORTANT NOTICE")
            } else if type == "disclaimer" {
                cell.setupData(object.disclaimer, type: "🚨 DISCLAIMER")
            }
            cell.reloadCallback = { isExpand in
                self._tableview.beginUpdates()
                self._tableview.endUpdates()
                cell.layoutIfNeeded()
            }
        } else if let cell = cell as? YachButtonTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? YachtOfferDetailModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
}
