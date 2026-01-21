import UIKit

class MoreInfoBottomSheet: ChildViewController {
    
    @IBOutlet private weak var _duration: CustomLabel!
    @IBOutlet private weak var _tourTime: CustomLabel!
    @IBOutlet private weak var _departureTime: CustomLabel!
    @IBOutlet private weak var _title: CustomLabel!
    @IBOutlet private weak var _optionDesc: CustomLabel!
    @IBOutlet private weak var _canclellationDesc: LinkDetectingLabel!
    @IBOutlet private weak var _address: CustomLabel!
    @IBOutlet private weak var _termsConditionDesc: CustomLabel!
    @IBOutlet private weak var _operationdays: CustomLabel!
    @IBOutlet private weak var _termstitle: CustomLabel!
    @IBOutlet private weak var _chiledPolicyTitle: CustomLabel!
    @IBOutlet private weak var _chiledPoilicyDesc: LinkDetectingLabel!
    @IBOutlet private weak var _cancellationTitle: CustomLabel!
    @IBOutlet private weak var _inclusionTitle: CustomLabel!
    @IBOutlet private weak var _inclusionDescription: LinkDetectingLabel!
    @IBOutlet private weak var _exclutionTitle: CustomLabel!
    @IBOutlet private weak var _exclusionDescription: LinkDetectingLabel!
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _infoTabButton: UIButton!
    @IBOutlet weak var _cancelPolicyTabButton: UIButton!
    @IBOutlet weak var _tabView: UIView!
    private var moreInfo: MoreInfoModel?
    public var optionID: String = kEmptyString
    public var ticketId: String = kEmptyString
    public var tourId: String = kEmptyString
    private let kLoadingCellIdentifire = String(describing: LoadingCell.self)
    private let kCellIdentifire = String(describing: MoreInfoDetailsTableCell.self)
    private var kCellIdentifier = String(describing: CancellationPolicyTableCell.self)
    private var kCellIdentifierDesc = String(describing: CancellationDescTableCell.self)
    public var tourOptionModel: TourOptionsModel?
    public var travelOptionModel: TourOptionModel?
    public var tourOptionDataModel: TourOptionDataModel?
    public var _raynaTourPolicyModel: [TourPolicyModel] = []
    public var _octoPolicy: String = kEmptyString
    public var params: [String: Any] = [:]
    private var _isInfoLoaded = false
    private var _isCancelPolicyLoaded = false
    public var isRefundable: Bool = false

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _selectInfoTab()
    }
    
    override func setupUi() {
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
        _loadData(isLoading: true)
        _tableView.proxyDelegate = self
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        _tabView.isHidden = !isRefundable
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kLoadingCellIdentifire, kCellNibNameKey: kLoadingCellIdentifire, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
                [kCellIdentifierKey: kCellIdentifire, kCellNibNameKey: kCellIdentifire, kCellClassKey: MoreInfoDetailsTableCell.self, kCellHeightKey: MoreInfoDetailsTableCell.height],
                [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: CancellationPolicyTableCell.self), kCellClassKey: CancellationPolicyTableCell.self, kCellHeightKey: CancellationPolicyTableCell.height],
                         [kCellIdentifierKey: kCellIdentifierDesc, kCellNibNameKey: String(describing: CancellationDescTableCell.self), kCellClassKey: CancellationDescTableCell.self, kCellHeightKey: CancellationDescTableCell.height],
        ]
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifire,
                kCellTagKey: kLoadingCellIdentifire,
                kCellObjectDataKey: "loading",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        }
        else {
            if !isRefundable {
                var model = InfoModel()
                model.key = "cancellation_policy".localized()
                model.value = "non_refundable".localized()
                cellData.append([
                    kCellIdentifierKey: kCellIdentifire,
                    kCellTagKey: kCellIdentifire,
                    kCellObjectDataKey: model,
                    kCellClassKey: MoreInfoDetailsTableCell.self,
                    kCellHeightKey: MoreInfoDetailsTableCell.height
                ])
            }
            moreInfo?.info.forEach { model in
                print(model.key)
                print(model.days)
                if Utils.isValidTextOrHTML(model.value) || model.days != nil {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifire,
                        kCellTagKey: kCellIdentifire,
                        kCellObjectDataKey: model,
                        kCellClassKey: MoreInfoDetailsTableCell.self,
                        kCellHeightKey: MoreInfoDetailsTableCell.height
                    ])
                }
            }

        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)

    }
    
    private func _loadCancelPolicyData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifire,
                kCellTagKey: kLoadingCellIdentifire,
                kCellObjectDataKey: true,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        }
        
        if !_raynaTourPolicyModel.isEmpty && !isLoading{
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: true,
                kCellClassKey: CancellationPolicyTableCell.self,
                kCellHeightKey: CancellationPolicyTableCell.height
            ])
            
            _raynaTourPolicyModel.forEach { policies in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: policies,
                    kCellClassKey: CancellationPolicyTableCell.self,
                    kCellHeightKey: CancellationPolicyTableCell.height
                ])
            }
        }
        
        if !Utils.stringIsNullOrEmpty(tourOptionModel?.optionDetail?.cancellationPolicyDescription) && !isLoading {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDesc,
                kCellTagKey: kCellIdentifierDesc,
                kCellObjectDataKey: tourOptionModel?.optionDetail?.cancellationPolicyDescription ?? kEmptyString,
                kCellClassKey: CancellationDescTableCell.self,
                kCellHeightKey: CancellationDescTableCell.height
            ])
        } else if !Utils.stringIsNullOrEmpty(tourOptionDataModel?.cancellationPolicyDescription) {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDesc,
                kCellTagKey: kCellIdentifierDesc,
                kCellObjectDataKey: tourOptionDataModel?.cancellationPolicyDescription ?? kEmptyString,
                kCellClassKey: CancellationDescTableCell.self,
                kCellHeightKey: CancellationDescTableCell.height
            ])
        }
        
        if !Utils.stringIsNullOrEmpty(_octoPolicy) {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDesc,
                kCellTagKey: kCellIdentifierDesc,
                kCellObjectDataKey: _octoPolicy,
                kCellClassKey: CancellationDescTableCell.self,
                kCellHeightKey: CancellationDescTableCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private func _selectInfoTab() {
        _infoTabButton.backgroundColor = ColorBrand.brandPink
        _cancelPolicyTabButton.backgroundColor = .clear
        
        if !_isInfoLoaded {
            _getInfo()
            _isInfoLoaded = true
        } else {
            _loadData()
        }
    }

    private func _selectCancelPolicyTab() {
        _cancelPolicyTabButton.backgroundColor = ColorBrand.brandPink
        _infoTabButton.backgroundColor = .clear
        
        if !_isCancelPolicyLoaded {
            _loadCancelPolicyData(true)
            switch BOOKINGMANAGER.ticketModel?.bookingType {
            case "whosin":
                _requestWhosinTourPolicy()
            case "rayna":
                _requestRaynaTourPolicy()
            case "travel-desk":
                _requestTravelTourPolicy()
            case "whosin-ticket":
                _requestWhosinTicketRules()
            case "big-bus", "hero-balloon" :
                _requestOctoPolicy()
            default:
                break
            }
            _isCancelPolicyLoaded = true
        } else {
            _loadCancelPolicyData()
        }
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _getInfo() {
        print(ticketId)
        WhosinServices.moreInfo(customTicketId: ticketId) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.moreInfo = data.first(where: { $0.tourOptionId == self.optionID })
            self._loadData()
        }
    }
    
    private func _requestRaynaTourPolicy() {
        let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(tourOptionModel?.tourOptionId ?? 0)" })
        let contractId = Utils.stringIsNullOrEmpty(BOOKINGMANAGER.ticketModel?.contractId) ? BOOKINGMANAGER.ticketModel?.tourData?.contractId ?? kEmptyString : BOOKINGMANAGER.ticketModel?.contractId ?? kEmptyString
        let params: [String : Any] = ["tourId": tourOptionModel?.tourId ?? kEmptyString,
                                      "tourOptionId": tourOptionModel?.tourOptionId ?? kEmptyString,
                                      "contractId": contractId,
                                      "date": Utils.stringIsNullOrEmpty(option?.tourDate) ? tourOptionModel?.inititalDate : option?.tourDate,
                                      "time": option?.startTime ?? "00:00:00",
                                      "transferId": tourOptionModel?.transferId ?? kEmptyString,
                                      "noOfAdult": option?.adult ?? 1,
                                      "noOfChild": option?.child ?? 0,
                                      "noOfInfant": option?.infant ?? 0]
        WhosinServices.raynaTourPolicy(params: params) { [weak self] container, error in
            guard let self = self else {
                self?._loadCancelPolicyData()
                return
            }
            if error != nil {
                self._loadCancelPolicyData()
            }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._raynaTourPolicyModel = data
            self._loadCancelPolicyData()
        }
    }
    
    private func _requestTravelTourPolicy() {
        let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(travelOptionModel?.id ?? 0)" })
        var params: [String : Any] = ["tourId": travelOptionModel?.tourId ?? kEmptyString,
                                      "optionId": travelOptionModel?.id ?? kEmptyString,
                                      "date": Utils.stringIsNullOrEmpty(option?.tourDate) ? Utils.dateToString(Calendar.current.date(byAdding: .day, value: 1, to: Date()), format: kFormatDate) : option?.tourDate ?? "",
                                      "adults": option?.adult ?? 1,
                                      "childs": option?.child ?? 0,
                                      "infant": option?.infant ?? 0]
        if !self.params.isEmpty {
            params = self.params
        }
        WhosinServices.travelTourPolicy(params: params) { [weak self] container, error in
            guard let self = self else {
                self?._loadCancelPolicyData()
                return
            }
            if error != nil {
                self._loadCancelPolicyData()
            }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._raynaTourPolicyModel = data
            self._loadCancelPolicyData()
        }
    }
    
    private func _requestWhosinTourPolicy() {
        let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == tourOptionModel?._id })
        var params: [String : Any] = ["ticketId": tourOptionModel?.customTicketId ?? kEmptyString,
                                      "optionId": tourOptionModel?._id ?? kEmptyString,
                                      "date": option?.tourDate ?? "",
                                      "time": option?.timeSlot ?? "00:00:00",
                                      "adults": option?.adult ?? 1,
                                      "childs": option?.child ?? 0,
                                      "infants": option?.infant ?? 0]
        if !self.params.isEmpty {
            params = self.params
        }
        WhosinServices.whsoinBookingRules(params: params) { [weak self] container, error in
            guard let self = self else {
                self?._loadCancelPolicyData()
                return
            }
            if error != nil {
                self._loadCancelPolicyData()
            }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._raynaTourPolicyModel = data
            self._loadCancelPolicyData()
        }
    }
    
    private func _requestWhosinTicketRules() {
        let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == tourOptionModel?.optionId })
        var params: [String : Any] = ["tourId": option?.tourId ?? tourId,
                                      "tourOptionId": option?.optionId ?? optionID,
                                      "slotId": option?.timeSlotId ?? "",
                                      "date": Utils.stringIsNullOrEmpty(option?.tourDate) ? Utils.dateToString(Calendar.current.date(byAdding: .day, value: 1, to: Date()), format: kFormatDate) : option?.tourDate ?? "",
                                      "time": option?.timeSlot ?? "00:00:00",
                                      "adults": option?.adult ?? 1,
                                      "childs": option?.child ?? 0,
                                      "infants": option?.infant ?? 0]
        if !self.params.isEmpty {
            params = self.params
        }
        WhosinServices.whsoinTicketRules(params: params) { [weak self] container, error in
            guard let self = self else {
                self?._loadCancelPolicyData()
                return
            }
            if error != nil {
                self._loadCancelPolicyData()
            }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._raynaTourPolicyModel = data
            self._loadCancelPolicyData()
        }
    }
    
    private func _requestOctoPolicy() {
        let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == optionID })
        var params: [String : Any] = ["tourId": tourId,
                                      "optionId": optionID,
                                      "date": Utils.stringIsNullOrEmpty(option?.tourDate) ? Utils.dateToString(Calendar.current.date(byAdding: .day, value: 1, to: Date()), format: kFormatDate) : option?.tourDate ?? ""]
        if !self.params.isEmpty {
            params = self.params
        }
        WhosinServices.octoPolicy(params: params) { [weak self] container, error in
            guard let self = self else {
                self?._loadCancelPolicyData()
                return
            }
            if error != nil {
                self._loadCancelPolicyData()
            }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._octoPolicy = data
            self._loadCancelPolicyData()
        }
    }

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func _handleInfoTabSelectEvent(_ sender: UIButton) {
        _selectInfoTab()
    }
    
    @IBAction func _handleCancelPolicyTabEvent(_ sender: UIButton) {
        _selectCancelPolicyTab()
    }
    
}

extension MoreInfoBottomSheet: CustomNoKeyboardTableViewDelegate, UITableViewDelegate {
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
        else if let cell = cell as? MoreInfoDetailsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? InfoModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? CancellationPolicyTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? TourPolicyModel {
                cell.setupData(object)
                _ = indexPath.row == 1
                let lastRow = _raynaTourPolicyModel.count
                let isLastRow = indexPath.row == lastRow
                cell.setCorners(lastRow: isLastRow, firstRow: false)
            } else if let object = cellDict?[kCellObjectDataKey] as? Bool {
                cell.setupFirstCellData()
            }
        } else if let cell = cell as? CancellationDescTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? String {
                cell._descLabel.text = Utils.convertHTMLToPlainText(from: object)
            }
        }
    }
}

class LinkDetectingLabel: UILabel {
    private let layoutManager = NSLayoutManager()
    private let textContainer = NSTextContainer(size: .zero)
    private let textStorage = NSTextStorage()
    private var linkRanges: [(NSRange, URL)] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isUserInteractionEnabled = true
        numberOfLines = 0

        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    func setHTML(_ html: String) {
        guard let attributed = Utils.convertHTMLToAttributedString(from: html) else { return }

        attributedText = attributed
        textStorage.setAttributedString(attributed)

        // Update link ranges
        linkRanges.removeAll()
        attributed.enumerateAttribute(.link, in: NSRange(location: 0, length: attributed.length)) { value, range, _ in
            if let url = value as? URL {
                linkRanges.append((range, url))
            }
        }

        setNeedsDisplay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textContainer.size = bounds.size
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let attributedText = attributedText else { return }

        let location = gesture.location(in: self)

        // Create NSTextStorage stack
        let boundingBox = layoutManager.usedRect(for: textContainer)
        let textOffset = CGPoint(
            x: (bounds.size.width - boundingBox.size.width) / 2 - boundingBox.origin.x,
            y: (bounds.size.height - boundingBox.size.height) / 2 - boundingBox.origin.y
        )

        let textLocation = CGPoint(x: location.x - textOffset.x, y: location.y - textOffset.y)
        let index = layoutManager.characterIndex(for: textLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        for (range, url) in linkRanges {
            if NSLocationInRange(index, range) {
                UIApplication.shared.open(url)
                break
            }
        }
    }
}

