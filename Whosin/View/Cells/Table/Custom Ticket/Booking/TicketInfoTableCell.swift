import UIKit

class TicketInfoTableCell: UITableViewCell {
    
    @IBOutlet weak var _pricePerTripStack: UIStackView!
    @IBOutlet weak var _pricePerTripText: CustomLabel!
    @IBOutlet private weak var _city: CustomLabel!
    @IBOutlet private weak var _date: CustomLabel!
    @IBOutlet private weak var _tourTitle: CustomLabel!
    @IBOutlet private weak var _tourDesc: CustomLabel!
    @IBOutlet private weak var _duration: CustomLabel!
    @IBOutlet private weak var _tourTime: CustomLabel!
    @IBOutlet private weak var _transferType: CustomLabel!
    @IBOutlet private weak var _adultCount: CustomLabel!
    @IBOutlet private weak var _childCount: CustomLabel!
    @IBOutlet private weak var _infantCount: CustomLabel!
    @IBOutlet private weak var _adultPrice: CustomLabel!
    @IBOutlet private weak var _childPrice: CustomLabel!
    @IBOutlet private weak var _infantPrice: CustomLabel!
    @IBOutlet private weak var _totalPrice: CustomLabel!
    @IBOutlet private weak var _discountPrice: CustomLabel!
    @IBOutlet private weak var _finalPrice: CustomLabel!
    @IBOutlet private weak var _discountStack: UIStackView!
    @IBOutlet private weak var _finalAmountStack: UIStackView!
    @IBOutlet private weak var _vatPercentage: UIStackView!
    @IBOutlet private weak var _vatTitle: CustomLabel!
    @IBOutlet private weak var _vatAmmount: CustomLabel!
    @IBOutlet private weak var _promoCodeStack: UIStackView!
    @IBOutlet private weak var _promoCodePrice: CustomLabel!
    @IBOutlet private weak var _departureTime: CustomLabel!
    @IBOutlet private weak var _ticketDetailView: UIView!
    @IBOutlet private weak var _priceBreakdownView: UIView!
    @IBOutlet weak var _timeSlotLabel: CustomLabel!
    @IBOutlet weak var _cancellationPolicyBtn: CustomButton!
    @IBOutlet weak var _moreInfoBtn: CustomButton!
    @IBOutlet weak var _locationStack: UIStackView!
    @IBOutlet weak var _transferStack: UIStackView!
    @IBOutlet weak var _customAddOnview: CustomAddOnOptionsView!
    @IBOutlet weak var _addonPriceStack: UIStackView!
    @IBOutlet weak var _addOnPrice: CustomLabel!
    
    private var _tourOption: TourOptionsModel?
    private var _travelOption: TourOptionModel?
    private var _bigBusOption: BigBusOptionsModel?
    let titleFont = FontBrand.SFboldFont(size: 12.0)
    let subtitleFont = FontBrand.SFregularFont(size: 12.0)
    private var isRefundable: Bool = false
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        self._ticketDetailView.layer.cornerRadius = 9
        self._ticketDetailView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self._ticketDetailView.clipsToBounds = true
        self._priceBreakdownView.layer.cornerRadius = 9
        self._priceBreakdownView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self._priceBreakdownView.clipsToBounds = true
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: TourOptionDetailModel, discount: Int = 0, promo: PromoBaseModel?) {
        _customAddOnview.isHidden = data.Addons.isEmpty
        _customAddOnview.setupData(model: data.Addons)
        _addonPriceStack.isHidden = data.Addons.isEmpty
        if let raynaOptions = BOOKINGMANAGER.optionsList.first(where: { BOOKINGMANAGER.matchesOption($0, optionId: data.optionId, transferId: data.transferId) }) {
            _tourOption = raynaOptions
            guard let option = _tourOption else { return }
            _tourTitle.text = option.optionDetail?.optionName
            _tourDesc.text = option.optionDetail?.optionDescription
            self.isRefundable = option.optionDetail?.isRefundable == true
            _cancellationPolicyBtn.isEnabled = option.optionDetail?.isRefundable == true
            _cancellationPolicyBtn.setTitle(option.optionDetail?.isRefundable == true ? "cancellation_policy".localized() : "non_refundable".localized())
            _cancellationPolicyBtn.backgroundColor = option.optionDetail?.isRefundable == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
            
            let time = Utils.stringToDate(option.startTime, format: "HH:mm:ss")
            _tourTime.attributedText = Utils.setAtributedTitleText(title: "start_time".localized(), subtitle: Utils.dateToString(time, format: "HH:mm"), titleFont: titleFont, subtitleFont: subtitleFont)
            _duration.attributedText = Utils.setAtributedTitleText(title: "duration".localized(), subtitle: option.optionDetail?.duration ?? kEmptyString, titleFont: titleFont, subtitleFont: subtitleFont)
            _departureTime.attributedText = Utils.setAtributedTitleText(title: "pickup_timing".localized(), subtitle: option.departureTime, titleFont: titleFont, subtitleFont: subtitleFont)
            _timeSlotLabel.text = data.timeSlot
            _transferType.text = option.transferName
            _adultCount.text = LANGMANAGER.localizedString(forKey: "adult_count", arguments: ["value1": "\(data.adult)","value2": data.adultTitle])
            _childCount.text = LANGMANAGER.localizedString(forKey: "child_count", arguments: ["value1": "\(data.child)","value2": data.childTitle])
            _infantCount.text = LANGMANAGER.localizedString(forKey: "infant_count", arguments: ["value1": "\(data.infant)","value2": data.infantTitle])
            _promoCodeStack.isHidden = true
            _moreInfoBtn.isHidden = false
            _locationStack.isHidden = false
            _transferStack.isHidden = false
            _pricePerTripText.isHidden = true
            let adultPrice = option.withoutDiscountAdultPrice.formatted() * Double(data.adult)
            let childPrice = option.withoutDiscountChildPrice.formatted() * Double(data.child)
            let infantPrice = option.withoutDiscountInfantPrice.formatted() * Double(data.infant)
            let addonPrice = data.Addons.reduce(0.0) { $0 + $1.serviceTotal }

            let adultTotal = option.adultPrice.formatted() * Double(data.adult)
            let childTotal = option.childPrice.formatted() * Double(data.child)
            let infantTotal = option.infantPrice.formatted() * Double(data.infant)
            let addonTotal = data.Addons.reduce(0.0) { $0 + $1.whosinTotal }

            
            let totalAmount = adultPrice + childPrice + infantPrice
            let priceToPay = adultTotal + childTotal + infantTotal + addonTotal
            
            Utils.setPriceLabel(label: _adultPrice, originalPrice: adultPrice, discountedPrice: adultTotal)
            Utils.setPriceLabel(label: _childPrice, originalPrice: childPrice, discountedPrice: childTotal)
            Utils.setPriceLabel(label: _infantPrice, originalPrice: infantPrice, discountedPrice: infantTotal)
            Utils.setPriceLabel(label: _addOnPrice, originalPrice: addonPrice, discountedPrice: addonTotal)
            
            _vatPercentage.isHidden = true
            _promoCodePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(promo?.promoDiscount.formattedDecimal() ?? "")".withCurrencyFont(13)
            _totalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount.formattedDecimal())".withCurrencyFont(13)
            let discoutntedPriceText = totalAmount - priceToPay
            _discountStack.isHidden = discoutntedPriceText <= 0
            _discountPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(discoutntedPriceText.formattedDecimal())".withCurrencyFont(13)
            _finalPrice.attributedText =  "\(Utils.getCurrentCurrencySymbol())\(priceToPay.formattedDecimal())".withCurrencyFont(13)
            _city.text = BOOKINGMANAGER.ticketModel?.city ?? kEmptyString
            _date.text = data.tourDate
        }
        else if let model = BOOKINGMANAGER.ticketModel?.optionData.first(where: { $0._id == data.optionId }) {
            _tourOption = model
            _tourTitle.text = model.title
            _tourDesc.text = model.descriptions
            self.isRefundable = model.isRefundable == true
            _cancellationPolicyBtn.isEnabled = model.isRefundable == true
            _cancellationPolicyBtn.setTitle(model.isRefundable == true ? "cancellation_policy".localized() : "non_refundable".localized())
            _cancellationPolicyBtn.backgroundColor = model.isRefundable == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
            _moreInfoBtn.isHidden = false
            _locationStack.isHidden = true
            _transferStack.isHidden = true
            //            let time = Utils.stringToDate(option.startTime, format: "HH:mm:ss")
            _tourTime.attributedText = Utils.setAtributedTitleText(title: "start_time".localized(), subtitle: model.availabilityTime, titleFont: titleFont, subtitleFont: subtitleFont)
            _duration.isHidden = true
            _departureTime.isHidden = true
            _timeSlotLabel.text = Utils.stringIsNullOrEmpty(data.timeSlot) ? data.startTime : data.timeSlot
            _transferType.isHidden = true
            _adultCount.text = LANGMANAGER.localizedString(forKey: "adult_count", arguments: ["value1": "\(data.adult)","value2": data.adultTitle ])
            _childCount.text = LANGMANAGER.localizedString(forKey: "child_count", arguments: ["value1": "\(data.child)","value2": data.childTitle])
            _infantCount.text = LANGMANAGER.localizedString(forKey: "infant_count", arguments: ["value1": "\(data.infant)","value2": data.infantTitle])
            _promoCodeStack.isHidden = true
            _pricePerTripText.isHidden = true
            _date.text = data.tourDate
            
            let adultPrice = model.withoutDiscountAdultPrice.formatted() * Double(data.adult)
            let childPrice = model.withoutDiscountChildPrice.formatted() * Double(data.child)
            let infantPrice = model.withoutDiscountInfantPrice.formatted() * Double(data.infant)
            let addonPrice = data.Addons.reduce(0.0) { $0 + $1.serviceTotal }
            
            let adultTotal = model.adultPrice.formatted() * Double(data.adult)
            let childTotal = model.childPrice.formatted() * Double(data.child)
            let infantTotal = model.infantPrice.formatted() * Double(data.infant)
            let addonTotal = data.Addons.reduce(0.0) { $0 + $1.whosinTotal }

            let totalAmount = adultPrice + childPrice + infantPrice
            let priceToPay = adultTotal + childTotal + infantTotal + addonTotal
            
            Utils.setPriceLabel(label: _adultPrice, originalPrice: adultPrice, discountedPrice: adultTotal)
            Utils.setPriceLabel(label: _childPrice, originalPrice: childPrice, discountedPrice: childTotal)
            Utils.setPriceLabel(label: _infantPrice, originalPrice: infantPrice, discountedPrice: infantTotal)
            Utils.setPriceLabel(label: _addOnPrice, originalPrice: addonPrice, discountedPrice: addonTotal)
            _vatPercentage.isHidden = true
            _promoCodePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(promo?.promoDiscount.formattedDecimal() ?? "")".withCurrencyFont(16)
            _totalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount.formattedDecimal())".withCurrencyFont(16)
            let discoutntedPriceText = totalAmount - priceToPay
            _discountStack.isHidden = discoutntedPriceText <= 0
            _discountPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(discoutntedPriceText.formattedDecimal())".withCurrencyFont(16)
            _finalPrice.attributedText =  "\(Utils.getCurrentCurrencySymbol())\(priceToPay.formattedDecimal())".withCurrencyFont(16)
        }
        else if let whosinModule = BOOKINGMANAGER.ticketModel?.whosinModuleTourData.first?.optionData.first(where: { $0.optionId == data.optionId }) {
            _tourOption = whosinModule
            _tourTitle.text = whosinModule.displayName
            _tourDesc.text = whosinModule.optionDescription
            self.isRefundable = whosinModule.isRefundable == true
            _cancellationPolicyBtn.isEnabled = whosinModule.isRefundable == true
            _cancellationPolicyBtn.setTitle(whosinModule.isRefundable == true ? "cancellation_policy".localized() : "non_refundable".localized())
            _cancellationPolicyBtn.backgroundColor = whosinModule.isRefundable == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
            _moreInfoBtn.isHidden = false
            _locationStack.isHidden = true
            _transferStack.isHidden = true
            _tourTime.attributedText = Utils.setAtributedTitleText(title: "start_time".localized(), subtitle: whosinModule.availabilityTime, titleFont: titleFont, subtitleFont: subtitleFont)
            _duration.isHidden = true
            _departureTime.isHidden = true
            _timeSlotLabel.text = Utils.stringIsNullOrEmpty(data.timeSlot) ? data.startTime : data.timeSlot
            _transferType.isHidden = true
            _adultCount.text = LANGMANAGER.localizedString(forKey: "adult_count", arguments: ["value1": "\(data.adult)", "value2": data.adultTitle])
            _childCount.text = LANGMANAGER.localizedString(forKey: "child_count", arguments: ["value1": "\(data.child)","value2": data.childTitle])
            _infantCount.text = LANGMANAGER.localizedString(forKey: "infant_count", arguments: ["value1": "\(data.infant)", "value2": data.infantTitle])
            _promoCodeStack.isHidden = true
            _pricePerTripText.isHidden = true
            _date.text = data.tourDate
            
            let adultPrice = whosinModule.withoutDiscountAdultPrice.formatted() * Double(data.adult)
            let childPrice = whosinModule.withoutDiscountChildPrice.formatted() * Double(data.child)
            let infantPrice = whosinModule.withoutDiscountInfantPrice.formatted() * Double(data.infant)
            let addonPrice = data.Addons.reduce(0.0) { $0 + $1.serviceTotal }

            
            let adultTotal = whosinModule.adultPrice.formatted() * Double(data.adult)
            let childTotal = whosinModule.childPrice.formatted() * Double(data.child)
            let infantTotal = whosinModule.infantPrice.formatted() * Double(data.infant)
            let addonTotal = data.Addons.reduce(0.0) { $0 + $1.whosinTotal }

            let totalAmount = adultPrice + childPrice + infantPrice
            let priceToPay = adultTotal + childTotal + infantTotal + addonTotal
            
            Utils.setPriceLabel(label: _adultPrice, originalPrice: adultPrice, discountedPrice: adultTotal)
            Utils.setPriceLabel(label: _childPrice, originalPrice: childPrice, discountedPrice: childTotal)
            Utils.setPriceLabel(label: _infantPrice, originalPrice: infantPrice, discountedPrice: infantTotal)
            Utils.setPriceLabel(label: _addOnPrice, originalPrice: addonPrice, discountedPrice: addonTotal)
            _vatPercentage.isHidden = true
            _promoCodePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(promo?.promoDiscount.formattedDecimal() ?? "")".withCurrencyFont(16)
            _totalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount.formattedDecimal())".withCurrencyFont(16)
            let discoutntedPriceText = totalAmount - priceToPay
            _discountStack.isHidden = discoutntedPriceText <= 0
            _discountPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(discoutntedPriceText.formattedDecimal())".withCurrencyFont(16)
            _finalPrice.attributedText =  "\(Utils.getCurrentCurrencySymbol())\(priceToPay.formattedDecimal())".withCurrencyFont(16)
        }
        else if let travelModel = BOOKINGMANAGER.ticketModel?.travelDeskTourData.first?.optionData.first(where: { "\($0.id)" == data.optionId}) {
            _travelOption = travelModel
            _tourTitle.text = travelModel.name
            _tourDesc.text = Utils.convertHTMLToPlainText(from: travelModel.descriptionText ?? "")
            self.isRefundable = BOOKINGMANAGER.ticketModel?.isFreeCancellation == true
            _cancellationPolicyBtn.isEnabled = BOOKINGMANAGER.ticketModel?.isFreeCancellation == true
            _cancellationPolicyBtn.setTitle(BOOKINGMANAGER.ticketModel?.isFreeCancellation == true ? "cancellation_policy".localized() : "non_refundable".localized())
            _cancellationPolicyBtn.backgroundColor = BOOKINGMANAGER.ticketModel?.isFreeCancellation == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
            
            _tourTime.attributedText = Utils.setAtributedTitleText(title: "start_time".localized(), subtitle: data.tourDate, titleFont: titleFont, subtitleFont: subtitleFont)
            _duration.attributedText = Utils.setAtributedTitleText(title: "duration".localized(), subtitle: "\(Utils.convertMinutesToTime(data.startTime)) - \(Utils.convertMinutesToTime(data.endTime))", titleFont: titleFont, subtitleFont: subtitleFont)
            _departureTime.isHidden = true
            _timeSlotLabel.text = data.timeSlot
            _transferType.isHidden = true
            _adultCount.text = LANGMANAGER.localizedString(forKey: "adult_count", arguments: ["value1": "\(data.adult)", "value2": data.adultTitle])
            _childCount.text = LANGMANAGER.localizedString(forKey: "child_count", arguments: ["value1": "\(data.child)", "value2": data.childTitle])
            _infantCount.text = LANGMANAGER.localizedString(forKey: "infant_count", arguments: ["value1": "\(data.infant)", "value2": data.infantTitle])
            _promoCodeStack.isHidden = true
            _moreInfoBtn.isHidden = false
            _locationStack.isHidden = false
            _transferStack.isHidden = true
            _pricePerTripText.isHidden = false
            _city.text = BOOKINGMANAGER.ticketModel?.city ?? kEmptyString
            _date.text = data.tourDate
            
            guard let priceModel = travelModel.pricingPeriods.first else { return }
            let adultPrice = priceModel.pricePerAdultBeforeDiscount.formatted() * Double(data.adult)
            let childPrice = priceModel.pricePerChildBeforeDiscount.formatted() * Double(data.child)
            let infantPrice = priceModel.pricePerInfantBeforeDiscount.formatted() * Double(data.infant)
            
            let adultTotal = priceModel.pricePerAdult.formatted() * Double(data.adult)
            let childTotal = priceModel.pricePerChild.formatted() * Double(data.child)
            let infantTotal = priceModel.pricePerInfant.formatted() * Double(data.infant)
            
            let totalAmount = adultPrice + childPrice + infantPrice + priceModel.pricePerTrip
            let priceToPay = adultTotal + childTotal + infantTotal + priceModel.pricePerTrip
            
            Utils.setPriceLabel(label: _adultPrice, originalPrice: adultPrice, discountedPrice: adultTotal)
            Utils.setPriceLabel(label: _childPrice, originalPrice: childPrice, discountedPrice: childTotal)
            Utils.setPriceLabel(label: _infantPrice, originalPrice: infantPrice, discountedPrice: infantTotal)
            Utils.setPriceLabel(label: _pricePerTripText, originalPrice: priceModel.pricePerTrip, discountedPrice: priceModel.pricePerTrip)
            
            _vatPercentage.isHidden = true
            _promoCodePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(promo?.promoDiscount.formattedDecimal() ?? "")".withCurrencyFont(16)
            _totalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount.formattedDecimal())".withCurrencyFont(16)
            let discoutntedPriceText = totalAmount - priceToPay
            _discountStack.isHidden = discoutntedPriceText <= 0
            _discountPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(discoutntedPriceText.formattedDecimal())".withCurrencyFont(16)
            _finalPrice.attributedText =  "\(Utils.getCurrentCurrencySymbol())\(priceToPay.formattedDecimal())".withCurrencyFont(16)
        }
        else if let bigBusModel = BOOKINGMANAGER.ticketModel?.bigBusTourData.first?.options.first(where: { "\($0.id)" == data.optionId}) {
            _bigBusOption = bigBusModel
            _tourTitle.text = bigBusModel.title
            _tourDesc.text = bigBusModel.shortDescription
            self.isRefundable = BOOKINGMANAGER.ticketModel?.isFreeCancellation == true
            _cancellationPolicyBtn.isEnabled = BOOKINGMANAGER.ticketModel?.isFreeCancellation == true
            _cancellationPolicyBtn.setTitle(BOOKINGMANAGER.ticketModel?.isFreeCancellation == true ? "cancellation_policy".localized() : "non_refundable".localized())
            _cancellationPolicyBtn.backgroundColor = BOOKINGMANAGER.ticketModel?.isFreeCancellation == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
            
            _tourTime.attributedText = Utils.setAtributedTitleText(title: "start_time".localized(), subtitle: data.tourDate, titleFont: titleFont, subtitleFont: subtitleFont)
            _duration.attributedText = Utils.setAtributedTitleText(title: "duration".localized(), subtitle: "\(Utils.convertMinutesToTime(data.startTime)) - \(Utils.convertMinutesToTime(data.endTime))", titleFont: titleFont, subtitleFont: subtitleFont)
            _departureTime.isHidden = true
            _timeSlotLabel.text = data.timeSlot
            _transferType.isHidden = true
            _adultCount.text = LANGMANAGER.localizedString(forKey: "adult_count", arguments: ["value1": "\(data.adult)", "value2": data.adultTitle])
            _childCount.text = LANGMANAGER.localizedString(forKey: "child_count", arguments: ["value1": "\(data.child)", "value2": data.childTitle])
            _infantCount.text = LANGMANAGER.localizedString(forKey: "infant_count", arguments: ["value1": "\(data.infant)", "value2": data.infantTitle])
            _promoCodeStack.isHidden = true
            _moreInfoBtn.isHidden = false
            _locationStack.isHidden = false
            _transferStack.isHidden = true
            _pricePerTripText.isHidden = false
            _city.text = BOOKINGMANAGER.ticketModel?.city ?? kEmptyString
            _date.text = data.tourDate.toDisplayDate()
            var totalAmount: Double = 0
            var priceToPay: Double = 0
            if let slotModel = BOOKINGMANAGER.octoAvailibility {
                let units = slotModel.unitPricing.toArrayDetached(ofType: PricingModel.self)
                let adultUnit  = units.first { $0.unitType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "adult" }
                let childUnit  = units.first { $0.unitType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "child" }
                let infantUnit = units.first { $0.unitType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "infant" }
                
                let adultPrice = (adultUnit?.adjustedNetWithoutDiscount.roundedValue() ?? 0) * Double(data.adult)
                let childPrice = (childUnit?.adjustedNetWithoutDiscount.roundedValue() ?? 0) * Double(data.child)
                let infantPrice = (infantUnit?.adjustedNetWithoutDiscount.roundedValue() ?? 0) * Double(data.infant)
                
                let adultTotal = (adultUnit?.adjustedNet.roundedValue() ?? 0) * Double(data.adult)
                let childTotal = (childUnit?.adjustedNet.roundedValue() ?? 0) * Double(data.child)
                let infantTotal = (infantUnit?.adjustedNet.roundedValue() ?? 0) * Double(data.infant)
                
                totalAmount = adultPrice + childPrice + infantPrice
                priceToPay = adultTotal + childTotal + infantTotal
                
                Utils.setPriceLabel(label: _adultPrice, originalPrice: Double(adultPrice), discountedPrice: Double(adultTotal))
                Utils.setPriceLabel(label: _childPrice, originalPrice: Double(childPrice), discountedPrice: Double(childTotal))
                Utils.setPriceLabel(label: _infantPrice, originalPrice: Double(infantPrice), discountedPrice: Double(infantTotal))
                _pricePerTripStack.isHidden = true
            } else {
                let units = bigBusModel.units.toArray(ofType: BigBusUnitModel.self)
                let adultUnit  = units.first { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "adult" }
                let childUnit  = units.first { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "child" }
                let infantUnit = units.first { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "infant" }
                
                let adultPrice = (adultUnit?.pricingFrom.first?.withoutDiscountNet ?? 0) * data.adult
                let childPrice = (childUnit?.pricingFrom.first?.withoutDiscountNet ?? 0) * data.child
                let infantPrice = (infantUnit?.pricingFrom.first!.withoutDiscountNet ?? 0) * data.infant
                
                let adultTotal = (adultUnit?.pricingFrom.first?.net ?? 0) * data.adult
                let childTotal = (childUnit?.pricingFrom.first?.net ?? 0) * data.child
                let infantTotal = (infantUnit?.pricingFrom.first?.net ?? 0) * data.infant
                
                totalAmount = Double(adultPrice + childPrice + infantPrice)
                priceToPay = Double(adultTotal + childTotal + infantTotal)
                
                Utils.setPriceLabel(label: _adultPrice, originalPrice: Double(adultPrice), discountedPrice: Double(adultTotal))
                Utils.setPriceLabel(label: _childPrice, originalPrice: Double(childPrice), discountedPrice: Double(childTotal))
                Utils.setPriceLabel(label: _infantPrice, originalPrice: Double(infantPrice), discountedPrice: Double(infantTotal))
                _pricePerTripStack.isHidden = true
            }
            
            _vatPercentage.isHidden = true
            _promoCodePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(promo?.promoDiscount.formattedDecimal() ?? "")".withCurrencyFont(16)
            _totalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount)".withCurrencyFont(16)
            let discoutntedPriceText = totalAmount - priceToPay
            _discountStack.isHidden = discoutntedPriceText <= 0
            _discountPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(discoutntedPriceText)".withCurrencyFont(16)
            _finalPrice.attributedText =  "\(Utils.getCurrentCurrencySymbol())\(priceToPay)".withCurrencyFont(16)
        }
    }
    
    @IBAction private func _handleMoreInfoEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(MoreInfoBottomSheet.self)
        vc.ticketId = BOOKINGMANAGER.ticketModel?._id ?? ""
        vc.optionID = {
            if let tourOptionId = _tourOption?.tourOptionId, tourOptionId != 0 {
                return "\(tourOptionId)"
            } else if let optionId = _tourOption?._id, !Utils.stringIsNullOrEmpty(optionId), BOOKINGMANAGER.ticketModel?.bookingType != "whosin-ticket" {
                return optionId
            } else if let oID = _tourOption?.optionId, !Utils.stringIsNullOrEmpty(oID) {
                return oID
            } else if let opId = _bigBusOption?.id, !Utils.stringIsNullOrEmpty(opId) {
                return opId
            }  else {
                return "\(_travelOption?.id ?? 0)"
            }
        }()
        vc.tourId = BOOKINGMANAGER.ticketModel?.code ?? ""
        vc.tourOptionModel = _tourOption
        vc.travelOptionModel = _travelOption
        vc.isRefundable = isRefundable
        self.parentBaseController?.navigationController?.present(vc, animated: true)
    }
    
    @IBAction private func _handleCancellationPolicyEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(CancellationPolicyBottomSheet.self)
        vc.tourOptionModel = _tourOption
        vc.travelOptionModel = _travelOption
        parentViewController?.present(vc, animated: true)
    }
}
