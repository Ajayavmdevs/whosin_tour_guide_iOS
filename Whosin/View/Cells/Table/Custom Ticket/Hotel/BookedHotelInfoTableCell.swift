import UIKit

class BookedHotelInfoTableCell: UITableViewCell {
    
    @IBOutlet private weak var _checkOUtStack: UIStackView!
    @IBOutlet private weak var _checkInStack: UIStackView!
    @IBOutlet private weak var _buttonView: UIView!
    @IBOutlet private weak var _cancelBtn: UIButton!
    @IBOutlet private weak var _optiontitle: CustomLabel!
    @IBOutlet private weak var _numberOfPax: CustomLabel!
    @IBOutlet private weak var _optionDate: CustomLabel!
    @IBOutlet private weak var _optionTime: CustomLabel!
    @IBOutlet private weak var _totalAmount: CustomLabel!
    @IBOutlet weak var _checkOut: CustomLabel!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _height: NSLayoutConstraint!

    private let kCellIdentifier = String(describing: RoomsCollectionCell.self)

    
    private var _detail: TourDetailsModel?
    private var ticketBooking: TicketBookingModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setup(_ booking: TicketBookingModel,details: TourDetailsModel?) {
        ticketBooking = booking
        _detail = details
        _height.constant = CGFloat((details?.jpHoleOptionData?.rooms.count ?? 0) * 72)
        _loadData()

        _optiontitle.text = details?.tourData?.name
        _buttonView.isHidden = Utils.isHotelNonRefundable(policies: booking.jpCancellationPolicy) || booking.bookingStatus == "completed"
        _optionDate.text = (details?.startDate ?? "") + " To " + (details?.endDate ?? "")
        _optionTime.text = details?.tourData?.checkIn
        _checkInStack.isHidden = Utils.stringIsNullOrEmpty(details?.tourData?.checkIn)
        _checkOUtStack.isHidden = Utils.stringIsNullOrEmpty(details?.tourData?.checkOut)
        _checkOut.text = details?.tourData?.checkOut
        _totalAmount.attributedText =  "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(Double(details?.whosinTotal ?? "") ?? 0).formattedWithoutDecimal())".withCurrencyFont(16)
        _numberOfPax.text = LANGMANAGER.localizedString(forKey: "numberOfPaxHotel", arguments: ["value1": "\(details?.adult ?? 0)","value2": "\(details?.child ?? 0)"])
        
        if booking.bookingStatus == "cancelled" {
            booking.bookingStatus = "cancelled"
        }
        _buttonView.backgroundColor = booking.bookingStatus.lowercased() == "cancelled" ? UIColor.clear : ColorBrand.brandPink
        _cancelBtn.setTitle(booking.bookingStatus.lowercased() == "cancelled" ? "cancelled".localized() : "cancel_booking".localized())
        _cancelBtn.setTitleColor(booking.bookingStatus.lowercased() == "cancelled" ? ColorBrand.brandPink : UIColor.white, for: .normal)
        _buttonView.isHidden = (Utils.isHotelNonRefundable(policies: booking.jpCancellationPolicy) || booking.bookingStatus == "completed") && booking.bookingStatus.lowercased() != "cancelled"
        _buttonView.isHidden = !(booking.paymentStatus == "paid" && booking.bookingStatus == "confirmed")
    }

    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: RoomsCollectionCell.self, kCellHeightKey: RoomsCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            enableRefresh: false,
            columns: 1,
            rows: 3,
            scrollDirection: .horizontal,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            delegate: self
        )
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }

    private func _loadData() {
        guard let roomModel = _detail?.jpHoleOptionData?.rooms else { return }
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        roomModel.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: RoomsCollectionCell.self,
                kCellHeightKey: RoomsCollectionCell.height
            ])
        }

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        self._collectionView.loadData(cellSectionData)
    }


    
    private func _requstCancelBooking(_ text: String) {
        guard let id = ticketBooking?.bookingCode, let bookingId = ticketBooking?.id else { return }
        parentBaseController?.showHUD()
        WhosinServices.travelBookingCancel(id: bookingId, bookingId: id,bookingType: "juniper-hotel", reason: text) { [weak self] container, error in
            guard let self = self else { return }
            parentBaseController?.hideHUD(error: error)
            guard container?.code == 1 else { return }
            parentBaseController?.showSuccessMessage(LANGMANAGER.localizedString(forKey: "cancel_ticket", arguments: ["value": _detail?.tourData?.name ?? ""]), subtitle: kEmptyString)
            DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil)
                self.parentBaseController?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction func _handleCancelEvent(_ sender: UIButton) {
        if ticketBooking?.bookingStatus.lowercased() == "cancelled" {
            return
        }
        let amount = Utils.convertCurrent(Double(_detail?.whosinTotal ?? "0") ?? 0)
        var refundAMount: Double = 0
        refundAMount = Utils.calculateRefundAmount(amount: amount, policies: ticketBooking?.jpCancellationPolicy ?? []) ?? 0
        let formattedRefundAmount = Double(round(100 * (refundAMount)) / 100)
        let refundMessage: String
        if formattedRefundAmount == 0 {
            refundMessage = "noRefundText".localized()
        } else {
            var currency = APPSESSION.userDetail?.currency ?? ""
            if currency.isEmpty { currency = "AED" }
            refundMessage = LANGMANAGER.localizedString(forKey: "refundText", arguments: ["value1": "\(currency)", "value2": "\(formattedRefundAmount)" ])
        }
        let title = _detail?.tourOption?.title ?? ""
        let fullMessage = LANGMANAGER.localizedString(forKey: "cancelConfirmationTicket", arguments: ["value1": title,"value2": refundMessage])
        
        let vc = INIT_CONTROLLER_XIB(CancelBookingVC.self)
        vc.refundAmount = refundAMount
        vc.submitCallback = { [weak self] text in
            guard let self = self else { return }
            self._requstCancelBooking(text)
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        parentBaseController?.present(vc, animated: true)
    }
    
}


// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension BookedHotelInfoTableCell: CustomNoKeyboardCollectionViewDelegate {

    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? RoomsCollectionCell, let object = cellDict?[kCellObjectDataKey] as? JPHotelRoomModel {
            cell.setupData(object, hideCapacity: true)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }

}
