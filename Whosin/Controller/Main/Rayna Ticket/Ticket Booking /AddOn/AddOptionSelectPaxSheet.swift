import UIKit
import IQKeyboardManagerSwift

class AddOptionSelectPaxSheet: PanBaseViewController {
    
    @IBOutlet private weak var _customAdultView: CustomAdultsView!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _addonImage: UIImageView!
    @IBOutlet weak var _addonTitle: CustomLabel!
    @IBOutlet weak var _addonDesc: CustomLabel!
    @IBOutlet weak var _slotTitle: UILabel!
    @IBOutlet weak var _slotView: UIView!
    @IBOutlet weak var _doneBtn: UIButton!
    @IBOutlet weak var _infoStack: UIStackView!
    private let kCellIdentifier = String(describing: OptionTimeSlotCollectionCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCollectionCell.self)
    
    private let kLoadingCellIdentifier = String(describing: LoadingCell.self)
    private let kTimeSlotCellIdentifier = String(describing: AddOnTimeSlotTableCell.self)
    private let kMoreInfoCellIdentifier = String(describing: MoreInfoDetailsTableCell.self)
    private let kTitleCell = String(describing: CommonTitleCell.self)
    
    public var optionDetail: TourOptionDetailModel?
    public var selectedFilter : TourTimeSlotModel? = nil
    public var addOnOption: TourOptionsModel?
    private var adult: Int = 0
    private var child: Int = 0
    private var infant: Int = 0
    private var _addOnOptions: TourOptionsModel?
    
    public var reloadCallback: (() -> Void)?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        _loadData(true)
        requestGetAddOnAvailibility()
    }
    
    private func checkAndPrefillData() {
        guard let parent = optionDetail,
              let addon = _addOnOptions,
              let existingAddon = parent.Addons.first(where: {
                  if BOOKINGMANAGER.ticketModel?.bookingType == "rayna" {
                      return $0.optionId == "\(addon.tourOptionId)"
                  } else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin" {
                      return $0.optionId == addon._id
                  } else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin-ticket" {
                      return $0.optionId == addon.optionId
                  }
                  return false
              }) else { return }
        
        self.adult = existingAddon.adult
        self.child = existingAddon.child
        self.infant = existingAddon.infant
        
        _customAdultView.setInitialCounts(adult: adult, child: child, infant: infant, model: addOnOption, isAddon: true, detailModel: optionDetail)
        
        if addon.availabilityType == "slot" {
             if let slot = addon.availabilityTimeSlot.first(where: {
                 if BOOKINGMANAGER.ticketModel?.bookingType == "rayna" {
                     return $0.timeSlotId == existingAddon.timeSlotId
                 } else {
                     return $0.id == existingAddon.timeSlotId || $0.availabilityTime == existingAddon.timeSlot
                 }
             }) {
                 self.selectedFilter = slot
             }
        }
    }
    
    private func setup() {
        _collectionView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            enableRefresh: false,
            columns: 1,
            rows: 1,
            edgeInsets: UIEdgeInsets(top: kCollectionViewDefaultSpacing, left: .zero, bottom: kCollectionViewDefaultSpacing, right: .zero),
            spacing: .zero,
            scrollDirection: .vertical,
            isDummyLoad: true,
            delegate: self
        )
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        
        
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "no_ticket_available".localized(),
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: "no_ticket_detail".localized(),
            delegate: self)

        _customAdultView.callback = { [weak self] adult, child, infant in
            guard let self = self else { return }
            self.adult = adult
            self.child = child
            self.infant = infant
        }
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kLoadingCellIdentifier, kCellNibNameKey: kLoadingCellIdentifier, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
                [kCellIdentifierKey: kTimeSlotCellIdentifier, kCellNibNameKey: kTimeSlotCellIdentifier, kCellClassKey: AddOnTimeSlotTableCell.self, kCellHeightKey: AddOnTimeSlotTableCell.height],
                [kCellIdentifierKey: kMoreInfoCellIdentifier, kCellNibNameKey: kMoreInfoCellIdentifier, kCellClassKey: MoreInfoDetailsTableCell.self, kCellHeightKey: MoreInfoDetailsTableCell.height],
                [kCellIdentifierKey: kTitleCell, kCellNibNameKey: kTitleCell, kCellClassKey: CommonTitleCell.self, kCellHeightKey: CommonTitleCell.height],
        ]
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: OptionTimeSlotCollectionCell.self), kCellClassKey: OptionTimeSlotCollectionCell.self, kCellHeightKey: TimeCalenderCell.height],[kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCollectionCell.self, kCellHeightKey: LoadingCollectionCell.height]]
    }

    
    private func requestGetAddOnAvailibility() {
        guard let model = optionDetail else { return }
        let params: [String: Any] = [
            "optionId": optionDetail?.optionId ?? "",
            "addonOptionIds": [addOnOption?._id],
            "adults": optionDetail?.adult ?? "",
            "childs": optionDetail?.child ?? "",
            "date": optionDetail?.tourDate ?? ""
        ]
        WhosinServices.whosinAddOnAvailability(params: params) { [weak self] container, error in
            guard let self = self else { return }
            if let error = error, error.localizedDescription.localizedCaseInsensitiveContains("Session expired, please login again!") {
                self.alert(message: "session_expired".localized()) { UIAlertAction in
                    APPSESSION.logout { [weak self] success, error in
                        guard let self = self else { return }
                        self.hideHUD(error: error)
                        guard success else { return }
                        guard let window = APP.window else { return }
                        let navController = NavigationController(rootViewController: INIT_CONTROLLER_XIB(LoginVC.self))
                        navController.setNavigationBarHidden(true, animated: false)
                        window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
                    }
                }
                return
            }
            if error != nil {
                alert(message: error?.localizedDescription) { UIAlertAction in
                    self.dismiss(animated: true)
                }
            }
//            self.hideHUD(error: error)
//            if error != nil { }
            guard let data = container?.data else { return }
            self._addOnOptions = data.first
            let imageUrl = data.first?.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) }).first ?? kEmptyString
            _addonImage.loadWebImage(imageUrl)
            self._addonTitle.text = Utils.stringIsNullOrEmpty(data.first?.optionName) ? data.first?.title : data.first?.optionName
            self._addonDesc.text = data.first?.sortDescription
            self._customAdultView.setupData(BOOKINGMANAGER.ticketModel, data.first, isAddon: true, detailModel: optionDetail)
            self.checkAndPrefillData()
            self._loadData()
            self._customAdultView.isHidden = false
            self._infoStack.isHidden = false
        }
        
    }
    
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifier,
                kCellTagKey: kLoadingCellIdentifier,
                kCellObjectDataKey: "loading",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            if _addOnOptions?.availabilityType != "same_as_option" {
                cellData.append([
                    kCellIdentifierKey: kTitleCell,
                    kCellTagKey: kTitleCell,
                    kCellObjectDataKey: "Available Timeslots",
                    kCellClassKey: CommonTitleCell.self,
                    kCellHeightKey: CommonTitleCell.height
                ])
            }
            if _addOnOptions?.availabilityType == "slot" {
                _addOnOptions?.availabilityTimeSlot.forEach { model in
                    cellData.append([
                        kCellIdentifierKey: kTimeSlotCellIdentifier,
                        kCellTagKey: kTimeSlotCellIdentifier,
                        kCellObjectDataKey: model,
                        kCellClassKey: AddOnTimeSlotTableCell.self,
                        kCellHeightKey: AddOnTimeSlotTableCell.height
                    ])
                }
            } else if _addOnOptions?.availabilityType == "regular" {
                let model = TourTimeSlotModel()
                model.availabilityTime = _addOnOptions?.availabilityTime ?? _addOnOptions?.slotText ?? ""
                model.totalSeats = _addOnOptions?.totalSeats ?? 0
                model.id = "0"
                cellData.append([
                    kCellIdentifierKey: kTimeSlotCellIdentifier,
                    kCellTagKey: kTimeSlotCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: AddOnTimeSlotTableCell.self,
                    kCellHeightKey: AddOnTimeSlotTableCell.height
                ])
                
            } else if _addOnOptions?.availabilityType == "same_as_option" {
                let model = TourTimeSlotModel()
                model.availabilityTime = optionDetail?.timeSlot ?? ""
                model.timeSlot = optionDetail?.timeSlot ?? ""
                model.totalSeats = 0
                model.timeSlotId = optionDetail?.timeSlotId ?? ""
                model.id = optionDetail?.timeSlotId ?? ""
                model.slotId = optionDetail?.timeSlotId ?? ""
                selectedFilter = model
            }
            
            if _addOnOptions?.availabilityType != "same_as_option" {
                cellData.append([
                    kCellIdentifierKey: kTitleCell,
                    kCellTagKey: kTitleCell,
                    kCellObjectDataKey: "",
                    kCellClassKey: CommonTitleCell.self,
                    kCellHeightKey: CommonTitleCell.height
                ])
            }
            
            cellData.append([
                kCellIdentifierKey: kTitleCell,
                kCellTagKey: kTitleCell,
                kCellObjectDataKey: "More Info",
                kCellClassKey: CommonTitleCell.self,
                kCellHeightKey: CommonTitleCell.height
            ])
            
            
            let infoItems: [(String, String?)] = [
                ("Add-On Name", _addOnOptions?.title),
                ("Add-On Description", _addOnOptions?.longDescription),
                ("Inclusion", _addOnOptions?.inclusion),
                ("Exclusion", _addOnOptions?.tourExclusion)
            ]
            
            for (key, value) in infoItems {
                guard let value, !value.isEmpty else { continue }
                
                let model = InfoModel()
                model.key = key
                model.value = value
                
                if Utils.isValidTextOrHTML(model.value) {
                    cellData.append([
                        kCellIdentifierKey: kMoreInfoCellIdentifier,
                        kCellTagKey: kMoreInfoCellIdentifier,
                        kCellObjectDataKey: model,
                        kCellClassKey: MoreInfoDetailsTableCell.self,
                        kCellHeightKey: MoreInfoDetailsTableCell.height
                    ])
                }
            }
            
            let operationDay = InfoModel()
            operationDay.key = "Operation Days"
            operationDay.days = _addOnOptions?.operationdays
            
            cellData.append([
                kCellIdentifierKey: kMoreInfoCellIdentifier,
                kCellTagKey: kMoreInfoCellIdentifier,
                kCellObjectDataKey: operationDay,
                kCellClassKey: MoreInfoDetailsTableCell.self,
                kCellHeightKey: MoreInfoDetailsTableCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    @IBAction func _closeEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }

    
}


extension AddOptionSelectPaxSheet: CustomCollectionViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomCollectionViewDelegate>
    // --------------------------------------
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if collectionView == _collectionView {
            return CGSize(width: collectionView.frame.width, height: OptionTimeSlotCollectionCell.height)
        } else { return .zero }
    }
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? OptionTimeSlotCollectionCell {
            if let object = cellDict?[kCellObjectDataKey] as? TourTimeSlotModel {
                cell.setupData(object, object == selectedFilter)
            }
        } else if let cell = cell as? LoadingCollectionCell {
            cell.setupUi()
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? OptionTimeSlotCollectionCell {
            if let object = cellDict?[kCellObjectDataKey] as? TourTimeSlotModel {
                selectedFilter = object
            }
            _collectionView.reload()
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard let parent = optionDetail,
              let addon = _addOnOptions else { return }
        let totalPax = adult + child + infant
        if totalPax > 0 && _addOnOptions?.availabilityType != "same_as_option" {
            guard let slot = selectedFilter else {
                alert(message: "Please select time slot")
                return
            }
        }

        
        BOOKINGMANAGER.addOrUpdateAddon(
            parentOptionId: parent.optionId,
            addonModel: addon,
            adult: adult,
            child: child,
            infant: infant,
            timeSlot: selectedFilter
        )
        dismiss(animated: true) {
            self.reloadCallback?()
        }
    }
}


extension AddOptionSelectPaxSheet: CustomNoKeyboardTableViewDelegate {
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? LoadingCell {
            cell.setupUi()
        } else if let cell = cell as? AddOnTimeSlotTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? TourTimeSlotModel {
                cell.setupData(object, object == selectedFilter)
            }
        }
        else if let cell = cell as? MoreInfoDetailsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? InfoModel else { return }
            cell.setupData(object)
            cell.leadingStack.constant = 10
            cell.trailingStack.constant = 10
        } else if let cell = cell as? CommonTitleCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
            cell.setup(object, subTitle: "")
            cell._seperatorView.isHidden = object != "More Info"
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? AddOnTimeSlotTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? TourTimeSlotModel {
                selectedFilter = object
            }
            _tableView.reload()
        }
    }
}
