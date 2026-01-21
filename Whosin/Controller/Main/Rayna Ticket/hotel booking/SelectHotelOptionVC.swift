import UIKit

class SelectHotelOptionVC: ChildViewController {

    // --------------------------------------
    // MARK: Outlets
    // --------------------------------------

    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet private weak var _nextButton: CustomActivityButton!
    @IBOutlet weak var _priceView: UIView!
    @IBOutlet weak var _totalPriceLabel: CustomLabel!

    // --------------------------------------
    // MARK: Constants
    // --------------------------------------

    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private let kCellIdentifierRoomOptionCell = String(describing: HotelRoomsOptionCell.self)
    
    // --------------------------------------
    // MARK: Variables
    // --------------------------------------

    private var _jpHotelModel: JPHotelAvailibilityModel?
    public var ticketModel: TicketModel?
    private var selectedOption: JPHotelAvailibilityOptionModel? = nil {
        didSet {
            _priceView.isHidden = selectedOption == nil
            _totalPriceLabel.setPrice(Double(selectedOption?.price?.nett ?? "0") ?? 0.0)
            self._nextButton.isEnabled = selectedOption != nil
            self._nextButton.backgroundColor = selectedOption == nil ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
        }
    }
    public var params: [String: Any] = [:]

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        if BOOKINGMANAGER.ticketModel == nil {
            _requestTicketDetail()
        }
        setupUI()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
        }
    }
    
    // --------------------------------------
    // MARK: SetUp
    // --------------------------------------
    
    private lazy var _prototypes: [[String: Any]] = [
        [
            kCellIdentifierKey: kCellIdentifierRoomOptionCell,
            kCellNibNameKey: kCellIdentifierRoomOptionCell,
            kCellClassKey: HotelRoomsOptionCell.self,
            kCellHeightKey: HotelRoomsOptionCell.height
        ],
        [
            kCellIdentifierKey: kCellIdentifierLoading,
            kCellNibNameKey: kCellIdentifierLoading,
            kCellClassKey: LoadingCell.self,
            kCellHeightKey: LoadingCell.height
        ]
    ]

    
    private func setupUI() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "no_tour_options".localized(),
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _loadData(true)
        _nextButton.isEnabled = false
        switch ticketModel?.bookingType {
        case "juniper-hotel":
            _requestJPHotelAvailibility()
        default:
            _requestJPHotelAvailibility()
        }
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestBookingRules(_ param: [String: Any]) {
        print(param)
        showHUD()
        WhosinServices.jpHotelBookingRuls(params: param) { [weak self] container, error in
            guard let self = self else {return}
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            HOTELBOOKINGMANAGER.bookingRuls = data
            if let requiredFields = data.hotelBookingRequiredFields {
                HOTELBOOKINGMANAGER.saveRequiredFields(from: requiredFields, cancellationPolicy: data.cancellationPolicy?.PolicyRules.toArrayDetached(ofType: JPCancellationPolicyModel.self))
            }
            print(HOTELBOOKINGMANAGER.bookingModel.toJSON())
            let vc = INIT_CONTROLLER_XIB(ParticipantDetailVC.self)
            vc.isHotelBooking = true
            vc.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // ----------------------------------

    
    private func _requestTicketDetail() {
        guard let id = ticketModel?._id else { return }
        WhosinServices.getTicketDetail(id: id) { [weak self] container, _ in
            guard let self = self else {
                self?._loadData()
                return
            }
            guard let data = container?.data else { return }
            BOOKINGMANAGER.ticketModel = data
        }
    }

    private func _requestJPHotelAvailibility() {
        WhosinServices.jpHotelAvailability(params: params) { [weak self] container, error in
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
            self.hideHUD()
            if error != nil {
                if let error = error {
                    alert(message: error.localizedDescription) { UIAlertAction in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                _loadData()
            }
            guard let data = container?.data else { return }
            self._jpHotelModel = data
            HOTELBOOKINGMANAGER.availibilityModel = data
            if data.hotelOptions.count == 1 {
                selectedOption = data.hotelOptions.first
            }
            self._loadData()
        }
    }
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierLoading,
                kCellTagKey: kCellIdentifierLoading,
                kCellObjectDataKey: "loading",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            _jpHotelModel?.hotelOptions.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierRoomOptionCell,
                    kCellTagKey: kCellIdentifierRoomOptionCell,
                    kCellObjectDataKey: model,
                    kCellClassKey: HotelRoomsOptionCell.self,
                    kCellHeightKey: HotelRoomsOptionCell.height
                ])
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }

    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismissOrBack()
    }

    @IBAction private func _handleNextEvent(_ sender: UIButton) {
        HOTELBOOKINGMANAGER.saveSelectedOption(selectedOption)
        let parameters: [String: Any] = [
            "hotelCode": BOOKINGMANAGER.ticketModel?.code ?? "",
            "startDate": Utils.dateToString(HOTELBOOKINGMANAGER.selectedStartDate, format: kFormatDate),
            "endDate": Utils.dateToString(HOTELBOOKINGMANAGER.selectedEndDate, format: kFormatDate),
            "ratePlanCode": selectedOption?.ratePlanCode ?? ""
        ]
        _requestBookingRules(parameters)
    }

}

extension SelectHotelOptionVC: CustomNoKeyboardTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? HotelRoomsOptionCell {
            if let object = cellDict?[kCellObjectDataKey] as? JPHotelAvailibilityOptionModel {
                cell.setupdata(object,hotelInfo: _jpHotelModel?.hotelInfo, isSelected: selectedOption == object)   
            }
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? JPHotelAvailibilityOptionModel else { return }
        if selectedOption == object {
            selectedOption = nil
        } else {
            selectedOption = object
        }
        _tableView.reload()
    }
    
}
