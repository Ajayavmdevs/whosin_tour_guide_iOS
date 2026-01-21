import UIKit

class ParticipantDetailVC: ChildViewController {

    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _nextButton: CustomActivityButton!
    private var kCellIdentifier = String(describing: ParticipantTableCell.self)
    private var kCellIdentifierMsg = String(describing: ParticipantMsgPickupCell.self)
    public var ticketModel: TicketModel?
    public var isHotelBooking: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        _loadData()
        DispatchQueue.main.async {
            self.updateNextButtonState()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            if isHotelBooking {
                HOTELBOOKINGMANAGER.bookingModel.passengers.removeAll()
            } else {
                BOOKINGMANAGER.bookingModel.passengers.removeAll()
            }
        }
    }
    
    // --------------------------------------
    // MARK: SetUp
    // --------------------------------------
    
    private func setupUI() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "preview_empty".localized(),
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        if !isHotelBooking {
            BOOKINGMANAGER.initializeGuestList()
        }
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: ParticipantTableCell.self), kCellClassKey: ParticipantTableCell.self, kCellHeightKey: ParticipantTableCell.height],
                 [kCellIdentifierKey: kCellIdentifierMsg, kCellNibNameKey: String(describing: ParticipantMsgPickupCell.self), kCellClassKey: ParticipantMsgPickupCell.self, kCellHeightKey: ParticipantMsgPickupCell.height],
                 [kCellIdentifierKey: String(describing: HotelGuestTableCell.self), kCellNibNameKey: String(describing: HotelGuestTableCell.self), kCellClassKey: HotelGuestTableCell.self, kCellHeightKey: HotelGuestTableCell.height]
        ]
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if isHotelBooking {
            HOTELBOOKINGMANAGER.bookingModel.passengers.forEach { model in
                cellData.append([
                    kCellIdentifierKey: String(describing: HotelGuestTableCell.self),
                    kCellTagKey: String(describing: HotelGuestTableCell.self),
                    kCellObjectDataKey: model,
                    kCellClassKey: HotelGuestTableCell.self,
                    kCellHeightKey: HotelGuestTableCell.height
                ])
            }
        } else {
            var id = 0
            BOOKINGMANAGER.bookingModel.passengers.forEach { member in
                if member.leadPassenger == 1 {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: id,
                        kCellObjectDataKey: member,
                        kCellClassKey: ParticipantTableCell.self,
                        kCellHeightKey: ParticipantTableCell.height
                    ])
                }
            }
            
            let allowedTypes = [41843, 41844]
            BOOKINGMANAGER.bookingModel.tourDetails.forEach { option in
                let selectedOption = BOOKINGMANAGER.optionsList.first(where: { BOOKINGMANAGER.matchesOption($0, optionId: option.optionId, transferId: option.transferId) })
                let selectedTravelOption = BOOKINGMANAGER.ticketModel?.travelDeskTourData.first?.optionData.first(where: { "\($0.id)" == option.optionId})
                let selectedWhosinOption = BOOKINGMANAGER.ticketModel?.whosinModuleTourData.first?.optionData.first(where: { $0.optionId == option.optionId })
                if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk", selectedTravelOption?.isDirectReporting == false {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierMsg,
                        kCellTagKey: id,
                        kCellObjectDataKey: option,
                        kCellClassKey: ParticipantMsgPickupCell.self,
                        kCellHeightKey: ParticipantMsgPickupCell.height
                    ])
                } else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin-ticket", selectedOption?.isPickup == true {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierMsg,
                        kCellTagKey: id,
                        kCellObjectDataKey: option,
                        kCellClassKey: ParticipantMsgPickupCell.self,
                        kCellHeightKey: ParticipantMsgPickupCell.height
                    ])
                } else if allowedTypes.contains(selectedOption?.transferId ?? 0) {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierMsg,
                        kCellTagKey: id,
                        kCellObjectDataKey: option,
                        kCellClassKey: ParticipantMsgPickupCell.self,
                        kCellHeightKey: ParticipantMsgPickupCell.height
                    ])
                }
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private func updateNextButtonState() {
        if isHotelBooking {
            if let errorMessage = HOTELBOOKINGMANAGER.validateMembers() {
                _nextButton.isEnabled = false
                _nextButton.backgroundColor = UIColor(hexString: "#ADADAD")
            } else {
                _nextButton.isEnabled = true
                _nextButton.backgroundColor = ColorBrand.brandPink
            }
        } else {
            if let errorMessage = BOOKINGMANAGER.validateMembers() {
                _nextButton.isEnabled = false
                _nextButton.backgroundColor = UIColor(hexString: "#ADADAD")
            } else {
                _nextButton.isEnabled = true
                _nextButton.backgroundColor = ColorBrand.brandPink
            }
        }
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _CloseEvent(_ sender: Any) {
        BOOKINGMANAGER.bookingModel.passengers.removeAll()
        dismissOrBack()
    }
    
    @IBAction private func _handleNextEvent(_ sender: UIButton) {
        LOGMANAGER.logTicketEvent(.addUserInfo, id: ticketModel?._id ?? "", name: ticketModel?.title ?? "")
        if isHotelBooking {
            if let errorMessage = HOTELBOOKINGMANAGER.validateMembers() {
                alert(title: kAppName, message: errorMessage)
                return
            }
            let vc = INIT_CONTROLLER_XIB(HotelBookingPreviewVC.self)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if let errorMessage = BOOKINGMANAGER.validateMembers() {
                alert(title: kAppName, message: errorMessage)
                return
            }
            let vc = INIT_CONTROLLER_XIB(TicketPreviewVC.self)
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }
    
}

// --------------------------------------
// MARK: <CustomTableViewDelegate>
// --------------------------------------

extension ParticipantDetailVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? ParticipantTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? PassengersModel, let number = cellDict?[kCellTagKey] as? Int {
                let isPrimaryGuest = indexPath.row == 0
                cell.setupData(object, isPrimaryGuest)
                cell._titleLbl.text =  isPrimaryGuest ? "primary_guest_details".localized() : LANGMANAGER.localizedString(forKey: "guest_number_details_optional", arguments: ["value": "\(number)"])
                cell.callback = {
                    self.updateNextButtonState()
                }
            }
        } else if let cell = cell as? ParticipantMsgPickupCell {
            if let object = cellDict?[kCellObjectDataKey] as? TourOptionDetailModel {
                cell.setupData(object)
                cell.callback = {
                    self.updateNextButtonState()
                }
            }
        } else if let cell = cell as? HotelGuestTableCell, let object = cellDict?[kCellObjectDataKey] as? JPPassengerModel {
            let isPrimaryGuest = indexPath.row == 0
            cell.setupData(object, isPrimaryGuest)
            if isPrimaryGuest {
                cell._titleLbl.text = "primary_guest_details".localized()
            } else {
                let pax = object
                let paxAge = Int(pax.age) ?? 0
                let paxType: String = paxAge < 12 ? "childTitle".localized() : "adult".localized()
                cell._titleLbl.text = "\(object.id). \(paxType) detail"
            }
            cell.callback = {
                self.updateNextButtonState()
            }
        }
    }
}

