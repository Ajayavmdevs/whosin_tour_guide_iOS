import UIKit

class BookedTicketInfoTableCell: UITableViewCell {
    
    @IBOutlet private weak var _buttonView: UIView!
    @IBOutlet private weak var _cancelBtn: UIButton!
    @IBOutlet private weak var _optiontitle: CustomLabel!
    @IBOutlet private weak var _transfertype: CustomLabel!
    @IBOutlet private weak var _numberOfPax: CustomLabel!
    @IBOutlet private weak var _optionDate: CustomLabel!
    @IBOutlet private weak var _optionTime: CustomLabel!
    @IBOutlet private weak var _totalAmount: CustomLabel!
    @IBOutlet weak var _cancellationPolicy: CustomButton!
    @IBOutlet weak var _transferView: UIStackView!
    @IBOutlet weak var _ticketPrice: CustomLabel!
    
    @IBOutlet weak var _addOnView: CustomAddOnOptionsView!
    private var _bookingModel: BookingDetailsModel?
    private var _detail: TourDetailsModel?
    private var ticketBooking: TicketBookingModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setup(_ booking: BookingDetailsModel,details: TourDetailsModel, _ticketModel: TicketBookingModel) {
        ticketBooking = _ticketModel
        _bookingModel = booking
        _detail = details
        if let model = details.whosinOptionData {
            _optiontitle.text = model.displayName
        } else {
            _optiontitle.text = details.tourOption?.optionName
            
        }
        _buttonView.isHidden = Utils.isNonRefundable(policies: _ticketModel.cancellationPolicy.filter({ $0.optionIdIntValue == _detail?.optionId })) || _ticketModel.bookingStatus == "completed" || _ticketModel.tourDetails.first?.tourOption?.isRefundable == false
        if Utils.stringIsNullOrEmpty(details.tourOption?.transferName) {
            _transfertype.text = Utils.getTransferName(details.transferId)
        } else {
            _transfertype.text = details.tourOption?.transferName ?? ""
        }
        if let date = Utils.stringToDate(details.tourDate, format: kStanderdDate) {
            _optionDate.text = Utils.dateToString(date, format: kFormatDate)
        } else {
            _optionDate.text = details.tourDate
        }
        if let time = Utils.stringToDate(details.startTime, format: "HH:mm:ss") {
            _optionTime.text = Utils.dateToString(time, format: "HH:mm")
        } else {
            _optionTime.text = !Utils.stringIsNullOrEmpty(details.startTime)
                ? details.startTime
                : details.timeSlot
        }
        _ticketPrice.attributedText =  "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(Double(details.whosinTotal) ?? 0).formattedWithoutDecimal())".withCurrencyFont(16)
        _totalAmount.attributedText =  "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(Double(_ticketModel.totalAmount) ?? 0).formattedWithoutDecimal())".withCurrencyFont(16)
        let paxes = LANGMANAGER.localizedString(forKey: "numberOfPax", arguments:
                                                    ["value1": "\(details.adult)",
                                                     "value2": Utils.stringIsNullOrEmpty(details.adultTitle) ? "Adult" : details.adultTitle ,
                                                     "value3": "\(details.child)",
                                                     "value4": Utils.stringIsNullOrEmpty(details.childTitle) ? "Child" : details.childTitle,
                                                     "value5": "\(details.infant)" ,
                                                     "value6": Utils.stringIsNullOrEmpty(details.infantTitle) ? "Infant" : details.infantTitle])
        if _ticketModel.bookingStatus == "cancelled" {
            booking.status = "cancelled"
        }
        
        _buttonView.backgroundColor = booking.status.lowercased() == "cancelled" ? UIColor.clear : ColorBrand.brandPink
        _cancelBtn.setTitle(booking.status.lowercased() == "cancelled" ? "cancelled".localized() : "cancel_booking".localized())
        _cancelBtn.setTitleColor(booking.status.lowercased() == "cancelled" ? ColorBrand.brandPink : UIColor.white, for: .normal)
        
        _cancellationPolicy.isEnabled = _ticketModel.tourDetails.first?.tourOption?.isRefundable == true
        _cancellationPolicy.setTitle(_ticketModel.tourDetails.first?.tourOption?.isRefundable == true ? "cancellation_policy".localized() : "non_refundable".localized())
        _cancellationPolicy.backgroundColor = _ticketModel.tourDetails.first?.tourOption?.isRefundable == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
        _buttonView.isHidden = _ticketModel.tourDetails.first?.tourOption?.isRefundable == false && booking.status.lowercased() != "cancelled"
    }
    
    public func setup(details: TourDetailsModel, _ticketModel: TicketBookingModel) {
        ticketBooking = _ticketModel
        _detail = details
        _addOnView.isHidden = details.addons.count == 0
        _addOnView.setupWalletData(model: details.addons.toArrayDetached(ofType: TourDetailsModel.self))
        _buttonView.isHidden = Utils.isNonRefundable(policies: _ticketModel.cancellationPolicy.filter({ "\($0.optionId)" == _detail?.ticketOptionId })) || _ticketModel.bookingStatus == "completed" || _ticketModel.tourDetails.first?.tourOption?.isRefundable == false
        if Utils.stringIsNullOrEmpty(details.tourOption?.transferName) {
            _transfertype.text = Utils.getTransferName(details.transferId)
        } else {
            _transfertype.text = details.tourOption?.transferName ?? ""
        }
        if let date = Utils.stringToDate(details.tourDate, format: kStanderdDate) {
            _optionDate.text = Utils.dateToString(date, format: kFormatDate)
        } else {
            _optionDate.text = details.tourDate.toDisplayDate()
        }
        if _ticketModel.bookingType == "travel-desk" {
            _buttonView.isHidden = true
            _transferView.isHidden = false
            _transfertype.text = details.pickup
            _optiontitle.text = details.optionData?.name
            _optionTime.text = details.timeSlot
            _cancellationPolicy.isEnabled = _ticketModel.tourDetails.first?.customTicket?.isFreeCancellation == true
            _cancellationPolicy.setTitle(_ticketModel.tourDetails.first?.customTicket?.isFreeCancellation == true ? "cancellation_policy".localized() : "non_refundable".localized())
            _cancellationPolicy.backgroundColor = _ticketModel.tourDetails.first?.customTicket?.isFreeCancellation == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
        } else if _ticketModel.bookingType == "big-bus" || _ticketModel.bookingType == "hero-balloon" {
            let tourDetails = _ticketModel.bigBusDetails.first(where: { $0.optionId == details.ticketOptionId})
            _buttonView.isHidden = tourDetails?.cancellable == false
            _transferView.isHidden = Utils.stringIsNullOrEmpty(details.pickup)
            _transfertype.text = details.pickup
            _optiontitle.text = details.optionData?.title
            _optionTime.text = details.timeSlot
            _cancellationPolicy.isEnabled = tourDetails?.cancellable == true
            _cancellationPolicy.setTitle(tourDetails?.cancellable == true ? "cancellation_policy".localized() : "non_refundable")
            _cancellationPolicy.backgroundColor = tourDetails?.cancellable == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
        } else if let model = details.whosinOptionData {
            //            _buttonView.isHidden = true
            _transferView.isHidden = Utils.stringIsNullOrEmpty(details.pickup)
            _transfertype.text = details.pickup
            _optiontitle.text = model.displayName
            _optionTime.text = details.timeSlot
            _cancellationPolicy.isEnabled = model.cancellationPolicy != "non_refundable".localized()
            _cancellationPolicy.setTitle(model.cancellationPolicy != "non_refundable".localized() ? "cancellation_policy".localized() : "non_refundable".localized())
            _cancellationPolicy.backgroundColor = model.cancellationPolicy != "non_refundable".localized() ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
        } else {
            _transferView.isHidden = true
            _optiontitle.text = details.tourOption?.title
            if let time = Utils.stringToDate(details.startTime, format: "HH:mm:ss") {
                _optionTime.text = Utils.dateToString(time, format: "HH:mm")
            } else {
                _optionTime.text = !Utils.stringIsNullOrEmpty(details.startTime)
                    ? details.startTime
                    : details.timeSlot
            }
            _cancellationPolicy.isEnabled = _ticketModel.tourDetails.first?.tourOption?.isRefundable == true
            _cancellationPolicy.setTitle(_ticketModel.tourDetails.first?.tourOption?.isRefundable == true ? "cancellation_policy".localized() : "non_refundable".localized())
            _cancellationPolicy.backgroundColor = _ticketModel.tourDetails.first?.tourOption?.isRefundable == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
            
        }
        _ticketPrice.attributedText =  "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(Double(details.whosinTotal) ?? 0).formattedWithoutDecimal())".withCurrencyFont(16)
        _totalAmount.attributedText =  "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(Double(_ticketModel.totalAmount) ?? 0).formattedWithoutDecimal())".withCurrencyFont(16)
        let paxes = LANGMANAGER.localizedString(forKey: "numberOfPax", arguments:
                                                    ["value1": "\(details.adult)",
                                                     "value2": Utils.stringIsNullOrEmpty(details.adultTitle) ? "Adult" : details.adultTitle ,
                                                     "value3": "\(details.child)",
                                                     "value4": Utils.stringIsNullOrEmpty(details.childTitle) ? "Child" : details.childTitle,
                                                     "value5": "\(details.infant)" ,
                                                     "value6": Utils.stringIsNullOrEmpty(details.infantTitle) ? "Infant" : details.infantTitle])

        if _ticketModel.bookingStatus.lowercased() == "cancelled" {
            details.status = "cancelled"
        }
        
        _buttonView.backgroundColor = details.status.lowercased() == "cancelled" ? UIColor.clear : ColorBrand.brandPink
        _cancelBtn.setTitle(details.status.lowercased() == "cancelled" ? "cancelled".localized() : "cancel_booking".localized())
        _cancelBtn.setTitleColor(details.status.lowercased() == "cancelled" ? ColorBrand.brandPink : UIColor.white, for: .normal)
        
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requstCancelBooking(_ text: String) {
        if ticketBooking?.bookingType == "whosin-ticket" {
            guard let id = ticketBooking?.id, let bookingId = ticketBooking?.tourDetails.first?.bookingId else { return }
            parentBaseController?.showHUD()
            WhosinServices.whosinTicketCancel(id: id, bookingId: bookingId, reason: text) { [weak self] container, error in
                guard let self = self else { return }
                parentBaseController?.hideHUD(error: error)
                guard container?.code == 1 else { return }
                parentBaseController?.showSuccessMessage(LANGMANAGER.localizedString(forKey: "cancel_ticket", arguments: ["value": _detail?.tour?.name ?? ""]), subtitle: kEmptyString)
                NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil)
                parentBaseController?.navigationController?.popViewController(animated: true)
            }
        } else if ticketBooking?.bookingType == "big-bus" || ticketBooking?.bookingType == "hero-balloon" {
            guard let id = ticketBooking?.id, let bookingId = _detail?.bookingId else { return }
            parentBaseController?.showHUD()
            WhosinServices.octoBookingCancel(id: id, bookingId: bookingId, reson: text) { [weak self] container, error in
                guard let self = self else { return }
                parentBaseController?.hideHUD(error: error)
                guard container?.code == 1 else { return }
                parentBaseController?.showSuccessMessage(LANGMANAGER.localizedString(forKey: "cancel_ticket", arguments: ["value": _detail?.optionData?.title ?? ""]), subtitle: kEmptyString)
                NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil)
                parentBaseController?.navigationController?.popViewController(animated: true)
            }
        } else {
            guard let id = ticketBooking?.id, let bookingId = _bookingModel?.bookingId else { return }
            parentBaseController?.showHUD()
            WhosinServices.raynaBookingCancel(id: id, bookingId: bookingId, cancellationReason: text) { [weak self] container, error in
                guard let self = self else { return }
                parentBaseController?.hideHUD(error: error)
                guard container?.code == 1 else { return }
                parentBaseController?.showSuccessMessage(LANGMANAGER.localizedString(forKey: "cancel_ticket", arguments: ["value": _detail?.tour?.name ?? ""]), subtitle: kEmptyString)
                NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil)
                parentBaseController?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction func _handleCancelEvent(_ sender: UIButton) {
        if _bookingModel?.status.lowercased() == "cancelled" {
            return
        } else if ticketBooking?.bookingType == "whosin-ticket" && _detail?.status == "cancelled" {
            return
        } else if ticketBooking?.bookingType == "travel-desk" && _detail?.status == "cancelled" {
            return
        }
        let amount = Utils.convertCurrent(Double(_detail?.whosinTotal ?? "0") ?? 0).formattedWithoutDecimal()
        var refundAMount: Double = 0
        if ticketBooking?.bookingType == "travel-desk" {
            refundAMount = Utils.calculateRefundAmount(amount: amount, policies: ticketBooking?.cancellationPolicy ?? []) ?? 0
        } else if ticketBooking?.bookingType == "whosin-ticket" {
            refundAMount = Utils.calculateRefundAmount(amount: amount, policies: ticketBooking?.cancellationPolicy.filter({ "\($0.optionId)" == _detail?.ticketOptionId }) ?? []) ?? 0
        } else {
            refundAMount = Utils.calculateRefundAmount(amount: amount, policies: ticketBooking?.cancellationPolicy.filter({ "\($0.optionId)" == "\(_detail?.optionId ?? 0)" }) ?? []) ?? 0
        }
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
        
        
        if ticketBooking?.bookingType == "whosin-ticket" {
            let vc = INIT_CONTROLLER_XIB(CancelBookingVC.self)
            vc.refundAmount = refundAMount
            vc.submitCallback = { [weak self] text in
                guard let self = self else { return }
                self._requstCancelBooking(text)
            }
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            parentBaseController?.present(vc, animated: true)
        } else if ticketBooking?.bookingType == "whosin-ticket" || ticketBooking?.bookingType == "travel-desk" {
            self.parentBaseController?.confirmAlert(
                message: fullMessage,
                okHandler: { okAction in
                    self._requstCancelBooking("")
                },
                noHandler: { action in
                }
            )
        } else if ticketBooking?.bookingType == "big-bus" || ticketBooking?.bookingType == "hero-balloon" {
            let vc = INIT_CONTROLLER_XIB(CancelBookingVC.self)
            vc.isOctotype = true
            vc.refundAmount = refundAMount
            vc.submitCallback = { [weak self] text in
                guard let self = self else { return }
                self._requstCancelBooking(text)
            }
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            parentBaseController?.present(vc, animated: true)
        } else if ticketBooking?.bookingType == "ticket"  {
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
    
    @IBAction func _handleCancellationPolicy(_ sender: Any) {
        let vc = INIT_CONTROLLER_XIB(CancellationPolicyBottomSheet.self)
        vc.isFromBooking = true
        if let option = ticketBooking?.tourDetails.first?.tourOption {
            vc.tourOptionDataModel = option
        }
        if ticketBooking?.bookingType == "whosin-ticket", let model = _detail?.whosinOptionData, let option = ticketBooking?.tourDetails.first {
            let params: [String : Any] = ["tourId": model.tourIdString,
                                          "tourOptionId": model.optionId,
                                          "slotId": model.timeSlotId,
                                          "date": option.tourDate,
                                          "time": Utils.stringIsNullOrEmpty(_detail?.timeSlot) ? _detail?.startTime ?? "" : _detail?.timeSlot ?? "00:00:00",
                                          "adults": option.adult,
                                          "childs": option.child,
                                          "infants": option.infant]
            vc.params = params
            vc.type = "whosin"
        } else if ticketBooking?.bookingType == "whosin-ticket" {
            let params: [String : Any] = ["ticketId": _detail?.travelTourId ?? "",
                                          "optionId": _detail?.ticketOptionId ?? kEmptyString,
                                          "date": _detail?.tourDate ?? "",
                                          "time": Utils.stringIsNullOrEmpty(_detail?.timeSlot) ? _detail?.startTime ?? "" : _detail?.timeSlot ?? "00:00:00",
                                          "adults": _detail?.adult ?? 1,
                                          "childs": _detail?.child ?? 0,
                                          "infants": _detail?.infant ?? 0]
            vc.params = params
            vc.type = ticketBooking?.bookingType ?? "rayna"
        } else if ticketBooking?.bookingType == "travel-desk" {
            vc.params = ["tourId": _detail?.travelTourId ?? kEmptyString,
                         "optionId": _detail?.ticketOptionId ?? kEmptyString,
                         "date": _detail?.tourDate ?? "",
                         "adults": _detail?.adult ?? 1,
                         "childs": _detail?.child ?? 0,
                         "infant": _detail?.infant ?? 0]
        } else if ticketBooking?.bookingType == "big-bus" || ticketBooking?.bookingType == "hero-balloon" {
            vc.params = ["tourId": _detail?.travelTourId ?? kEmptyString,
                         "optionId": _detail?.ticketOptionId ?? kEmptyString,
                         "date": _detail?.tourDate ?? "",
                         ]

        } else {
            vc._raynaTourPolicyModel = ticketBooking?.cancellationPolicy.filter({ $0.optionIdIntValue == _detail?.optionId}) ?? []
        }
        vc.type = ticketBooking?.bookingType ?? ""
        parentBaseController?.present(vc, animated: true)
    }
    
}
