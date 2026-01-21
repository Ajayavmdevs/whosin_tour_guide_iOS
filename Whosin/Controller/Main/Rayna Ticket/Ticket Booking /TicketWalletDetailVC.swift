import UIKit

class TicketWalletDetailVC: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private var kCellIdentifier = String(describing: BookingDetailTableCell.self)
    private var kCellIdentifierPassenger = String(describing: BookingGuestInfoCell.self)
    private var kCellIdentifierGuest = String(describing: HotelGuestDetailCell.self)
    private var kCellIdentifierTicket = String(describing: BookedTicketInfoTableCell.self)
    private var kCellIdentifierHotel = String(describing: BookedHotelInfoTableCell.self)
    private var kCellPolicyIdentifier = String(describing: CancellationPolicyTableCell.self)
    public var bookingModel: TicketBookingModel?
    public var voucherModel: VouchersListModel?
    public var isHistory: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        _loadData()

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
        _loadData()
    }
        
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private var _prototypes: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: BookingDetailTableCell.self), kCellClassKey: BookingDetailTableCell.self, kCellHeightKey: BookingDetailTableCell.height],
            [kCellIdentifierKey: kCellIdentifierTicket, kCellNibNameKey: kCellIdentifierTicket, kCellClassKey: BookedTicketInfoTableCell.self, kCellHeightKey: BookedTicketInfoTableCell.height],
            [kCellIdentifierKey: kCellIdentifierPassenger, kCellNibNameKey: kCellIdentifierPassenger, kCellClassKey: BookingGuestInfoCell.self, kCellHeightKey: BookingGuestInfoCell.height],
            [kCellIdentifierKey: kCellIdentifierGuest, kCellNibNameKey: kCellIdentifierGuest, kCellClassKey: HotelGuestDetailCell.self, kCellHeightKey: HotelGuestDetailCell.height],
            [kCellIdentifierKey: kCellPolicyIdentifier, kCellNibNameKey: kCellPolicyIdentifier, kCellClassKey: CancellationPolicyTableCell.self, kCellHeightKey: CancellationPolicyTableCell.height],
            [kCellIdentifierKey: kCellIdentifierHotel, kCellNibNameKey: kCellIdentifierHotel, kCellClassKey: BookedHotelInfoTableCell.self, kCellHeightKey: BookedHotelInfoTableCell.height],
        ]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifier,
            kCellTagKey: voucherModel,
            kCellObjectDataKey: bookingModel,
            kCellClassKey: BookingDetailTableCell.self,
            kCellHeightKey: BookingDetailTableCell.height
        ])
        
        if bookingModel?.bookingType == "juniper-hotel" {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierGuest,
                    kCellTagKey: kCellIdentifierGuest,
                    kCellObjectDataKey: bookingModel?.hotelGuest,
                    kCellClassKey: HotelGuestDetailCell.self,
                    kCellHeightKey: HotelGuestDetailCell.height
                ])
        } else {
            bookingModel?.passengers.forEach({ model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierPassenger,
                    kCellTagKey: kCellIdentifierPassenger,
                    kCellObjectDataKey: model,
                    kCellClassKey: BookingGuestInfoCell.self,
                    kCellHeightKey: BookingGuestInfoCell.height
                ])
            })
        }
        
        if bookingModel?.jpCancellationPolicy.isEmpty == false {
            cellData.append([
                kCellIdentifierKey: kCellPolicyIdentifier,
                kCellTagKey: kCellPolicyIdentifier,
                kCellObjectDataKey: true,
                kCellClassKey: CancellationPolicyTableCell.self,
                kCellHeightKey: CancellationPolicyTableCell.height
            ])
            
            bookingModel?.jpCancellationPolicy.forEach { policies in
                cellData.append([
                    kCellIdentifierKey: kCellPolicyIdentifier,
                    kCellTagKey: kCellPolicyIdentifier,
                    kCellObjectDataKey: policies,
                    kCellClassKey: CancellationPolicyTableCell.self,
                    kCellHeightKey: CancellationPolicyTableCell.height
                ])
            }
        }
        
        if bookingModel?.bookingStatus != "initiated" {
            if bookingModel?.bookingType == "whosin-ticket" {
                bookingModel?.tourDetails.forEach({ model in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierTicket,
                        kCellObjectDataKey: model,
                        kCellClassKey: BookedTicketInfoTableCell.self,
                        kCellHeightKey: BookedTicketInfoTableCell.height
                    ])
                })
            } else if bookingModel?.bookingType == "travel-desk" {
                bookingModel?.tourDetails.forEach({ model in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierTicket,
                        kCellObjectDataKey: model,
                        kCellClassKey: BookedTicketInfoTableCell.self,
                        kCellHeightKey: BookedTicketInfoTableCell.height
                    ])
                })
            } else if bookingModel?.bookingType == "big-bus" || bookingModel?.bookingType == "hero-balloon" {
                bookingModel?.tourDetails.forEach({ model in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierTicket,
                        kCellObjectDataKey: model,
                        kCellClassKey: BookedTicketInfoTableCell.self,
                        kCellHeightKey: BookedTicketInfoTableCell.height
                    ])
                })
            } else if bookingModel?.bookingType == "juniper-hotel", let model = bookingModel, !model.tourDetails.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierHotel,
                    kCellObjectDataKey: model,
                    kCellClassKey: BookedHotelInfoTableCell.self,
                    kCellHeightKey: BookedHotelInfoTableCell.height
                ])
            } else {
                bookingModel?.details.forEach({ model in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierTicket,
                        kCellTagKey: bookingModel?.tourDetails.first(where: { "\($0.serviceUniqueId)" == model.serviceUniqueId}),
                        kCellObjectDataKey: model,
                        kCellClassKey: BookedTicketInfoTableCell.self,
                        kCellHeightKey: BookedTicketInfoTableCell.height
                    ])
                })
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------


    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// --------------------------------------
// MARK: <CustomTableViewDelegate>
// --------------------------------------

extension TicketWalletDetailVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? BookingDetailTableCell, let object = cellDict?[kCellObjectDataKey] as? TicketBookingModel, let voucher = cellDict?[kCellTagKey] as? VouchersListModel {
            cell.setup(object, voucher: voucher)
        } else if let cell = cell as? BookedTicketInfoTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? BookingDetailsModel,let booking = cellDict?[kCellTagKey] as?  TourDetailsModel, let model = bookingModel {
                cell.setup(object, details: booking, _ticketModel: model )
            } else if let object = cellDict?[kCellObjectDataKey] as? TourDetailsModel, let model = bookingModel {
                cell.setup(details: object, _ticketModel: model)
            }
        } else if let cell = cell as? BookingGuestInfoCell, let object = cellDict?[kCellObjectDataKey] as? PassengersModel {
            cell.setupData(object)
        } else if let cell = cell as? HotelGuestDetailCell, let object = cellDict?[kCellObjectDataKey] as? [JPPassengerModel] {
            cell.setupdata(object, isFromWallet: true)
        } else if let cell = cell as? CancellationPolicyTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? JPCancellationPolicyModel {
               cell.setupData(object)
                let lastRow = 2 + (bookingModel?.jpCancellationPolicy.count ?? 0)
               let isLastRow = indexPath.row == lastRow
               cell.setCorners(lastRow: isLastRow, firstRow: false)
           } else if let object = cellDict?[kCellObjectDataKey] as? Bool {
               cell.setupFirstCellData()
           }
        } else if let cell = cell as? BookedHotelInfoTableCell,let object = cellDict?[kCellObjectDataKey] as? TicketBookingModel {
            cell.setup(object, details: object.tourDetails.first)
        }
     }
}
