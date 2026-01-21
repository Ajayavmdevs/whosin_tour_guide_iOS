import UIKit
import SnapKit

class CustomAdultsView: UIView {
    
    @IBOutlet private weak var _infantDesc: CustomLabel!
    @IBOutlet private weak var _childDesc: CustomLabel!
    @IBOutlet private weak var _adultDesc: CustomLabel!
    @IBOutlet private weak var _adultCounterLbl: UILabel!
    @IBOutlet private weak var _adultTitle: CustomLabel!
    @IBOutlet private weak var _infantTitle: CustomLabel!
    @IBOutlet private weak var _childTitle: CustomLabel!
    @IBOutlet private weak var _adultView: UIView!
    @IBOutlet private weak var _childrenCounterLbl: UILabel!
    @IBOutlet private weak var _childview: UIView!
    @IBOutlet private weak var _infantsCounterLbl: UILabel!
    @IBOutlet private weak var _infantView: UIView!
    @IBOutlet weak var _adultAge: CustomLabel!
    @IBOutlet weak var _childAge: CustomLabel!
    @IBOutlet weak var _infantAge: CustomLabel!
    @IBOutlet weak var _adultPrice: CustomLabel!
    @IBOutlet weak var _childPrice: CustomLabel!
    @IBOutlet weak var _infantPrice: CustomLabel!
    @IBOutlet weak var _adultOriginalPrice: CustomLabel!
    @IBOutlet weak var _childOriginalPrice: CustomLabel!
    @IBOutlet weak var _infantOriginalPrice: CustomLabel!
    
    public var ticketOptionModel: TourOptionsModel?
    public var travelDeskOptionModel: TourOptionModel?
    public var bigBusOptionModel:  BigBusOptionsModel?
    public var bigbusSlot: OctoAvailibilityModel?
    private var optionDetail: TourOptionDetailModel?
    private var isAddonMode: Bool = false
    private var units: String = ""
    private var maxRatioPax: Int? {
        guard
            isAddonMode,
            let detail = optionDetail,let option = ticketOptionModel,
            detail.adult > 0,
            option.ratioPerPax > 0
        else { return nil }

        return detail.adult * option.ratioPerPax
    }

    private var currentTotalPax: Int {
        adultstepperValue + childrenstepperValue + infantstepperValue
    }

    private func canIncreasePax() -> Bool {
        guard let limit = maxRatioPax else { return true }
        return currentTotalPax < limit
    }
    
    private var adultstepperValue: Int = 0 {
        didSet { _adultCounterLbl.text = "\(adultstepperValue) \(units)" }
    }
    private var childrenstepperValue: Int = 0 {
        didSet { _childrenCounterLbl.text = "\(childrenstepperValue) \(units)" }
    }
    private var infantstepperValue: Int = 0 {
        didSet { _infantsCounterLbl.text = "\(infantstepperValue) \(units)" }
    }
    
    private let adultstepperMinValue = 0
    private let childrenstepperMinValue = 0
    private let infantstepperMinValue = 0
    
    public var callback: ((_ adult: Int, _ child: Int, _ infant: Int) -> Void)?
    private var didApplyMinPax = false
    private var minPaxRequired: Int {
        if BOOKINGMANAGER.ticketModel?.bookingType == "whosin" {
            return ticketOptionModel?.minimumPax ?? 0
        }
        if BOOKINGMANAGER.ticketModel?.bookingType == "whosin-ticket" {
            return Int(ticketOptionModel?.minPaxString ?? "0") ?? 0
        }
        if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
            return travelDeskOptionModel?.minNumOfPeople ?? 0
        }
        if BOOKINGMANAGER.ticketModel?.bookingType == "big-bus" || BOOKINGMANAGER.ticketModel?.bookingType == "hero-balloon" {
            return bigBusOptionModel?.restrictions?.minPaxCount ?? 0
        }
        return BOOKINGMANAGER.ticketModel?.minPax ?? 0
    }


    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func updateTotal() {
        _adultView.borderColor = adultstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        _childview.borderColor = childrenstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        _infantView.borderColor = infantstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        callback?(adultstepperValue, childrenstepperValue, infantstepperValue)

        updatePriceLabels()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if let view = Bundle.main.loadNibNamed("CustomAdultsView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            self.addGestureRecognizer(tapGesture)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setInitialCounts(adult: Int, child: Int, infant: Int, model: TourOptionsModel?, isAddon: Bool = false, detailModel: TourOptionDetailModel? = nil) {
        self.adultstepperValue = adult
        self.childrenstepperValue = child
        self.infantstepperValue = infant
        self.ticketOptionModel = model
        self.optionDetail = detailModel
        self.isAddonMode = isAddon
        
        _adultCounterLbl.text = "\(adultstepperValue)"
        _childrenCounterLbl.text = "\(childrenstepperValue)"
        _infantsCounterLbl.text = "\(infantstepperValue)"
        
        _adultView.borderColor = adultstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        _childview.borderColor = childrenstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        _infantView.borderColor = infantstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        
        updatePriceLabels()
        
        guard let option = ticketOptionModel, let ticket = BOOKINGMANAGER.ticketModel else { return }
        
        _childview.isHidden = option.disableChild
        _infantView.isHidden = option.disableInfant
        
        if ticket.bookingType == "whosin" {
            _adultAge.text = "(\(option.adultAge))"
            _childAge.text = "(\(option.childAge))"
            _infantAge.text = "(\(option.infantAge))"
            _adultAge.isHidden = option.adultAge.isEmpty == true || option.adultAge == "NA"
            _childAge.isHidden = option.childAge.isEmpty == true || option.childAge == "NA"
            _infantAge.isHidden = option.infantAge.isEmpty == true || option.infantAge == "NA"
        } else if ticket.bookingType == "rayna" {
            _adultAge.text = "(\(option.optionDetail?.adultAge ?? kEmptyString))"
            _childAge.text = "(\(option.optionDetail?.childAge ?? kEmptyString))"
            _infantAge.text = "(\(option.optionDetail?.infantAge ?? kEmptyString))"
            _adultAge.isHidden = option.optionDetail?.adultAge.isEmpty == true || option.optionDetail?.adultAge == "NA"
            _childAge.isHidden = option.optionDetail?.childAge.isEmpty == true || option.optionDetail?.childAge == "NA"
            _infantAge.isHidden = option.optionDetail?.infantAge.isEmpty == true || option.optionDetail?.infantAge == "NA"
        } else if ticket.bookingType == "whosin-ticket" {
            _adultAge.text = "(\(option.adultAge))"
            _childAge.text = "(\(option.childAge))"
            _infantAge.text = "(\(option.infantAge))"
            _adultAge.isHidden = option.adultAge.isEmpty == true || option.adultAge == "NA"
            _childAge.isHidden = option.childAge.isEmpty == true || option.childAge == "NA"
            _infantAge.isHidden = option.infantAge.isEmpty == true || option.infantAge == "NA"
        }
        
        Utils.setPriceLabel(
            label: _adultOriginalPrice,
            originalPrice: option.withoutDiscountAdultPrice.formatted(),
            discountedPrice: option.adultPrice.formatted()
        )
        Utils.setPriceLabel(
            label: _childOriginalPrice,
            originalPrice: option.withoutDiscountChildPrice.formatted(),
            discountedPrice: option.childPrice.formatted()
        )
        Utils.setPriceLabel(
            label: _infantOriginalPrice,
            originalPrice: option.withoutDiscountInfantPrice.formatted(),
            discountedPrice: option.infantPrice.formatted()
        )
    }

    public func setupData(_ ticket: TicketModel?, _ option: TourOptionsModel?, isAddon: Bool = false, detailModel: TourOptionDetailModel? = nil) {
        ticketOptionModel = option
        self.optionDetail = detailModel
        self.isAddonMode = isAddon

        _adultTitle.text = Utils.stringIsNullOrEmpty(option?.adultTitle) ? "Adult" : option?.adultTitle
        _childTitle.text = Utils.stringIsNullOrEmpty(option?.childTitle) ? "Children" : option?.childTitle
        _infantTitle.text = Utils.stringIsNullOrEmpty(option?.infantTitle) ? "Infant" : option?.infantTitle
        _adultDesc.text = option?.adultDesc
        _childDesc.text = option?.childDesc
        _infantDesc.text = option?.infantDesc
        _adultDesc.isHidden = Utils.stringIsNullOrEmpty(option?.adultDesc)
        _childDesc.isHidden = Utils.stringIsNullOrEmpty(option?.childDesc)
        _infantDesc.isHidden = Utils.stringIsNullOrEmpty(option?.infantDesc)

        units = option?.unit ?? ""
        guard let ticket = ticket else { return }
        _childview.isHidden = option?.disableChild ?? false
        _infantView.isHidden = option?.disableInfant ?? false
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(option?.tourOptionId ?? 0)" }) {
            adultstepperValue = model.adult
            childrenstepperValue = model.child
            infantstepperValue = model.infant
        } else if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == option?._id }) {
            adultstepperValue = model.adult
            childrenstepperValue = model.child
            infantstepperValue = model.infant
        } else if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == option?.optionId }) {
            adultstepperValue = model.adult
            childrenstepperValue = model.child
            infantstepperValue = model.infant
        }  else {
            adultstepperValue = 0
            childrenstepperValue = 0
            infantstepperValue = 0
        }
        _adultView.borderColor = adultstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        _childview.borderColor = childrenstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        _infantView.borderColor = infantstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        updatePriceLabels()
        if ticket.bookingType == "whosin" {
            _adultAge.text = "(\(option?.adultAge ?? kEmptyString))"
            _childAge.text = "(\(option?.childAge ?? kEmptyString))"
            _infantAge.text = "(\(option?.infantAge ?? kEmptyString))"
            _adultAge.isHidden = option?.adultAge.isEmpty == true || option?.adultAge == "NA"
            _childAge.isHidden = option?.childAge.isEmpty == true || option?.childAge == "NA"
            _infantAge.isHidden = option?.infantAge.isEmpty == true || option?.infantAge == "NA"
        } else if ticket.bookingType == "rayna" {
            _adultAge.text = "(\(option?.optionDetail?.adultAge ?? kEmptyString))"
            _childAge.text = "(\(option?.optionDetail?.childAge ?? kEmptyString))"
            _infantAge.text = "(\(option?.optionDetail?.infantAge ?? kEmptyString))"
            _adultAge.isHidden = option?.optionDetail?.adultAge.isEmpty == true || option?.optionDetail?.adultAge == "NA"
            _childAge.isHidden = option?.optionDetail?.childAge.isEmpty == true || option?.optionDetail?.childAge == "NA"
            _infantAge.isHidden = option?.optionDetail?.infantAge.isEmpty == true || option?.optionDetail?.infantAge == "NA"
        } else if ticket.bookingType == "whosin-ticket" {
            _adultAge.text = "(\(option?.adultAge ?? kEmptyString))"
            _childAge.text = "(\(option?.childAge ?? kEmptyString))"
            _infantAge.text = "(\(option?.infantAge ?? kEmptyString))"
            _adultAge.isHidden = option?.adultAge.isEmpty == true || option?.adultAge == "NA"
            _childAge.isHidden = option?.childAge.isEmpty == true || option?.childAge == "NA"
            _infantAge.isHidden = option?.infantAge.isEmpty == true || option?.infantAge == "NA"
        }
        
        Utils.setPriceLabel(
            label: _adultOriginalPrice,
            originalPrice: option?.withoutDiscountAdultPrice.formatted() ?? 0,
            discountedPrice: option?.adultPrice.formatted() ?? 0
        )
        Utils.setPriceLabel(
            label: _childOriginalPrice,
            originalPrice: option?.withoutDiscountChildPrice.formatted() ?? 0,
            discountedPrice: option?.childPrice.formatted() ?? 0
        )
        Utils.setPriceLabel(
            label: _infantOriginalPrice,
            originalPrice: option?.withoutDiscountInfantPrice.formatted() ?? 0,
            discountedPrice: option?.infantPrice.formatted() ?? 0
        )
    }
    
    public func setupData(_ ticket: TicketModel?, _ option: TourOptionModel?, isAddon: Bool = false)  {
        travelDeskOptionModel = option
        _adultTitle.text = Utils.stringIsNullOrEmpty(option?.adultTitle) ? "Adult" : option?.adultTitle
        _childTitle.text = Utils.stringIsNullOrEmpty(option?.childTitle) ? "Children" : option?.childTitle
        _infantTitle.text = Utils.stringIsNullOrEmpty(option?.infantTitle) ? "Infant" : option?.infantTitle
        _adultDesc.text = option?.adultDesc
        _childDesc.text = option?.childDesc
        _infantDesc.text = option?.infantDesc
        _adultDesc.isHidden = Utils.stringIsNullOrEmpty(option?.adultDesc)
        _childDesc.isHidden = Utils.stringIsNullOrEmpty(option?.childDesc)
        _infantDesc.isHidden = Utils.stringIsNullOrEmpty(option?.infantDesc)

        units = option?.unit ?? ""
        guard let optionData = option else { return }
        _childview.isHidden = !optionData.childrenAllowed
        _infantView.isHidden = !optionData.infantsAllowed
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(option?.id ?? 0)" }) {
            adultstepperValue = model.adult
            childrenstepperValue = model.child
            infantstepperValue = model.infant
        } else {
            adultstepperValue = 0
            childrenstepperValue = 0
            infantstepperValue = 0
        }
        _adultView.borderColor = adultstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        _childview.borderColor = childrenstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        _infantView.borderColor = infantstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        updatePriceLabels()
        
        _adultAge.text = "(\(optionData.adultAge))"
        _childAge.text = "(\(optionData.childAge))"
        _infantAge.text = "(\(optionData.infantAge))"
        _adultAge.isHidden = optionData.adultAge == 0
        _childAge.isHidden = optionData.childAge == 0
        _infantAge.isHidden = optionData.infantAge == 0
        
        let priceModel = optionData.pricingPeriods.first
        Utils.setPriceLabel(
            label: _adultOriginalPrice,
            originalPrice: priceModel?.pricePerAdultBeforeDiscount.formatted() ?? 0,
            discountedPrice: priceModel?.pricePerAdult.formatted() ?? 0
        )
        Utils.setPriceLabel(
            label: _childOriginalPrice,
            originalPrice: priceModel?.pricePerChildBeforeDiscount.formatted() ?? 0,
            discountedPrice: priceModel?.pricePerChild.formatted() ?? 0
        )
        Utils.setPriceLabel(
            label: _infantOriginalPrice,
            originalPrice: priceModel?.pricePerInfantBeforeDiscount.formatted() ?? 0,
            discountedPrice: priceModel?.pricePerInfant.formatted() ?? 0
        )
        _adultOriginalPrice.isHidden = priceModel?.pricePerAdult == 0
        _childOriginalPrice.isHidden = priceModel?.pricePerChild == 0
        _infantOriginalPrice.isHidden = priceModel?.pricePerInfant == 0
    }
    
    public func setupData(_ ticket: TicketModel?, _ option:  BigBusOptionsModel?, slot: OctoAvailibilityModel? = nil)  {
        bigBusOptionModel = option
        _adultTitle.text = Utils.stringIsNullOrEmpty(option?.adultTitle) ? "Adult" : option?.adultTitle
        _childTitle.text = Utils.stringIsNullOrEmpty(option?.childTitle) ? "Children" : option?.childTitle
        _infantTitle.text = Utils.stringIsNullOrEmpty(option?.infantTitle) ? "Infant" : option?.infantTitle
        _adultDesc.text = option?.adultDesc
        _childDesc.text = option?.childDesc
        _infantDesc.text = option?.infantDesc
        _adultDesc.isHidden = Utils.stringIsNullOrEmpty(option?.adultDesc)
        _childDesc.isHidden = Utils.stringIsNullOrEmpty(option?.childDesc)
        _infantDesc.isHidden = Utils.stringIsNullOrEmpty(option?.infantDesc)

        bigbusSlot = slot
        units = option?.unit ?? ""
        guard let optionData = option else { return }
        if let slot = slot {
            let units = slot.unitPricing.toArrayDetached(ofType: PricingModel.self)
            _adultView.isHidden = !units.contains(where: { $0.unitType.lowercased() == "adult" })
            _childview.isHidden = !units.contains(where: { $0.unitType.lowercased() == "child" })
            _infantView.isHidden = !units.contains(where: { $0.unitType.lowercased() == "infant" })
            if let adult = units.first(where: { $0.unitType.lowercased() == "adult" }) {
                Utils.setPriceLabel(
                    label: _adultOriginalPrice,
                    originalPrice: Double(adult.adjustedNetWithoutDiscount.roundedValue()),
                    discountedPrice: Double(adult.adjustedNet.roundedValue())
                )
                _adultOriginalPrice.isHidden = adult.adjustedNet == 0
            }
            if let child = units.first(where: { $0.unitType.lowercased() == "child" }) {
                Utils.setPriceLabel(
                    label: _childOriginalPrice,
                    originalPrice: Double(child.adjustedNetWithoutDiscount.roundedValue()),
                    discountedPrice: Double(child.adjustedNet.roundedValue())
                )
                _childOriginalPrice.isHidden = child.adjustedNet == 0
            }
            if let infant = units.first(where: { $0.unitType.lowercased() == "infant" }) {
                Utils.setPriceLabel(
                    label: _infantOriginalPrice,
                    originalPrice: Double(infant.adjustedNetWithoutDiscount.roundedValue()),
                    discountedPrice: Double(infant.adjustedNet.roundedValue())
                )
                _infantOriginalPrice.isHidden = infant.adjustedNet == 0
            }

        } else {
            _adultView.isHidden = !optionData.units.contains(where: { $0.type.lowercased() == "adult" })
            _childview.isHidden = !optionData.units.contains(where: { $0.type.lowercased() == "child" })
            _infantView.isHidden = !optionData.units.contains(where: { $0.type.lowercased() == "infant" })
            if let adult = optionData.units.first(where: { $0.type.lowercased() == "adult" }) {
                _adultAge.text = adult.subtitle
                _adultAge.isHidden = adult.restrictions?.minAge == 0
                Utils.setPriceLabel(
                    label: _adultOriginalPrice,
                    originalPrice: Double(adult.pricingFrom.first?.withoutDiscountNet ?? 0),
                    discountedPrice: Double(adult.pricingFrom.first?.net ?? 0)
                )
                _adultOriginalPrice.isHidden = adult.pricingFrom.first?.net == 0
            }
            if let child = optionData.units.first(where: { $0.type.lowercased() == "child" }) {
                _childAge.text = child.subtitle
                _childAge.isHidden = child.restrictions?.minAge == 0
                Utils.setPriceLabel(
                    label: _childOriginalPrice,
                    originalPrice: Double(child.pricingFrom.first?.withoutDiscountNet ?? 0),
                    discountedPrice: Double(child.pricingFrom.first?.net ?? 0)
                )
                _childOriginalPrice.isHidden = child.pricingFrom.first?.net == 0
            }
            if let infant = optionData.units.first(where: { $0.type.lowercased() == "infant" }) {
                _infantAge.text = infant.subtitle
                _infantAge.isHidden = infant.restrictions?.minAge == 0
                Utils.setPriceLabel(
                    label: _infantOriginalPrice,
                    originalPrice: Double(infant.pricingFrom.first?.withoutDiscountNet ?? 0),
                    discountedPrice: Double(infant.pricingFrom.first?.net ?? 0)
                )
                _infantOriginalPrice.isHidden = infant.pricingFrom.first?.net == 0
            }

        }
        if let adult = optionData.units.first(where: { $0.type.lowercased() == "adult" }) {
            _adultAge.text = adult.subtitle
            _adultAge.isHidden = adult.restrictions?.minAge == 0
        }
        if let child = optionData.units.first(where: { $0.type.lowercased() == "child" }) {
            _childAge.text = child.subtitle
            _childAge.isHidden = child.restrictions?.minAge == 0
        }
        if let infant = optionData.units.first(where: { $0.type.lowercased() == "infant" }) {
            _infantAge.text = infant.subtitle
            _infantAge.isHidden = infant.restrictions?.minAge == 0
        }
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == option?.id }) {
            adultstepperValue = model.adult
            childrenstepperValue = model.child
            infantstepperValue = model.infant
        } else {
            adultstepperValue = 0
            childrenstepperValue = 0
            infantstepperValue = 0
        }
        _adultView.borderColor = adultstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        _childview.borderColor = childrenstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        _infantView.borderColor = infantstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        updatePriceLabels()
        
    }
    
    public func setupData(_ ticket: TicketModel?)  {
        guard let ticket = ticket else { return }
        _childview.isHidden = !ticket.allowChild
        _infantView.isHidden = true
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == ticket._id }) {
            adultstepperValue = model.adult
            childrenstepperValue = model.child
            infantstepperValue = model.infant
            _adultTitle.text = Utils.stringIsNullOrEmpty(model.adultTitle) ? "Adult" : model.adultTitle
            _childTitle.text = Utils.stringIsNullOrEmpty(model.childTitle) ? "Children" : model.childTitle
            _infantTitle.text = Utils.stringIsNullOrEmpty(model.infantTitle) ? "Infant" : model.infantTitle
            _adultDesc.text = model.adultDesc
            _childDesc.text = model.childDesc
            _infantDesc.text = model.infantDesc
            _adultDesc.isHidden = Utils.stringIsNullOrEmpty(model.adultDesc)
            _childDesc.isHidden = Utils.stringIsNullOrEmpty(model.childDesc)
            _infantDesc.isHidden = Utils.stringIsNullOrEmpty(model.infantDesc)
        }  else {
            adultstepperValue = 0
            childrenstepperValue = 0
            infantstepperValue = 0
        }
        _adultView.borderColor = adultstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        _childview.borderColor = childrenstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        _infantView.borderColor = infantstepperValue > 0 ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
        updatePriceLabels()
        _adultAge.text = "(\(ticket.adultAge))"
        _childAge.text = "(\(ticket.childAge))"
        _infantAge.text = "(\(ticket.infantAge))"
        _adultAge.isHidden = ticket.adultAge.isEmpty == true || ticket.adultAge == "NA"
        _childAge.isHidden = ticket.childAge.isEmpty == true || ticket.childAge == "NA"
        _infantAge.isHidden = ticket.infantAge.isEmpty == true || ticket.infantAge == "NA"
        _adultOriginalPrice.isHidden = true
        _childOriginalPrice.isHidden = true
        _infantOriginalPrice.isHidden = true
    }

    
    @objc func handleTap() {
        print("View tapped!")
    }
    
    private func updatePriceLabels() {
        if let option = ticketOptionModel {
            _adultPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Double(option.adultPrice.formatted() * Double(adultstepperValue).formatted()).formattedDecimal())".withCurrencyFont(14, false)
            _childPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Double(option.childPrice.formatted() * Double(childrenstepperValue).formatted()).formattedDecimal())".withCurrencyFont(14, false)
            _infantPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Double(option.infantPrice.formatted() * Double(infantstepperValue).formatted()).formattedDecimal())".withCurrencyFont(14, false)
            _childPrice.isHidden = option.childPrice == 0
            _infantPrice.isHidden = option.infantPrice == 0
            _adultPrice.isHidden = option.adultPrice == 0
        } else if let option = travelDeskOptionModel?.pricingPeriods.first {
            _adultPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Double(option.pricePerAdult.formatted() * Double(adultstepperValue).formatted()).formattedDecimal())".withCurrencyFont(14, false)
            _childPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Double(option.pricePerChild.formatted() * Double(childrenstepperValue).formatted()).formattedDecimal())".withCurrencyFont(14, false)
            _adultPrice.isHidden = option.pricePerAdult == 0
            _childPrice.isHidden = option.pricePerChild == 0
            _infantPrice.isHidden = option.pricePerInfant == 0
            _infantPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Double(option.pricePerInfant.formatted() * Double(infantstepperValue).formatted()).formattedDecimal())".withCurrencyFont(14, false)
        } else if let option = bigBusOptionModel?.units {
            if let slot = bigbusSlot {
                let units = slot.unitPricing.toArrayDetached(ofType: PricingModel.self)
                if let adult = units.first(where: { $0.unitType.lowercased() == "adult"}) {
                    _adultPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Double(adult.adjustedNet).roundedValue() * Double(adultstepperValue))".withCurrencyFont(14)
                    _adultPrice.isHidden = adult.adjustedNet == 0
                }
                
                if let child = units.first(where: { $0.unitType.lowercased() == "child"}) {
                    _childPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Double(child.adjustedNet).roundedValue() * Double(childrenstepperValue))".withCurrencyFont(14)
                    _childPrice.isHidden = child.adjustedNet == 0
                }
                if let infant = units.first(where: { $0.unitType.lowercased() == "infant"}) {
                    _infantPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Double(infant.adjustedNet).roundedValue() * Double(infantstepperValue))".withCurrencyFont(14)
                    _infantPrice.isHidden = infant.adjustedNet == 0
                }
            } else {
                if let adult = option.first(where: { $0.type.lowercased() == "adult"})?.pricingFrom.first {
                    _adultPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Double(adult.net) * Double(adultstepperValue))".withCurrencyFont(14)
                    _adultPrice.isHidden = adult.net == 0
                }
                if let child = option.first(where: { $0.type.lowercased() == "child"})?.pricingFrom.first {
                    _childPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Double(child.net) * Double(childrenstepperValue))".withCurrencyFont(14)
                    _childPrice.isHidden = child.net == 0
                }
                if let infant = option.first(where: { $0.type.lowercased() == "infant"})?.pricingFrom.first {
                    _infantPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Double(infant.net) * Double(infantstepperValue))".withCurrencyFont(14)
                    _infantPrice.isHidden = infant.net == 0
                }
            }
        } else {
            _adultPrice.isHidden = true
            _childPrice.isHidden = true
            _infantPrice.isHidden = true
            return
        }
    
    }
    
    public func isMaxPax() -> Bool {
        let totalGuests = adultstepperValue + childrenstepperValue + infantstepperValue
        if BOOKINGMANAGER.ticketModel?.bookingType == "whosin" {
            if ticketOptionModel?.availabilityType == "slot" {
                let maxSeats = ticketOptionModel?.availabilityTimeSlot.compactMap { $0.totalSeats }.max() ?? 0
                return totalGuests >= (maxSeats)
            } else {
                return totalGuests >= (ticketOptionModel?.totalSeats ?? 1000)
            }
        }
        if BOOKINGMANAGER.ticketModel?.bookingType == "whosin-ticket" {
            return totalGuests >= (Int(ticketOptionModel?.maxPaxString ?? "1000") ?? 1000)
        }
        if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
            return totalGuests >= (travelDeskOptionModel?.maxNumOfPeople ?? 1000)
        }
        if BOOKINGMANAGER.ticketModel?.bookingType == "big-bus" || BOOKINGMANAGER.ticketModel?.bookingType == "hero-balloon" {
            return totalGuests >= (bigBusOptionModel?.restrictions?.maxPaxCount == 0 ? 1000 : bigBusOptionModel?.restrictions?.maxPaxCount ?? 1000)
        }
        return totalGuests >= (BOOKINGMANAGER.ticketModel?.maxPax ?? 1000)
    }
    
    public func isMinPax() -> Bool {
        let totalGuests = adultstepperValue + childrenstepperValue + infantstepperValue
        if BOOKINGMANAGER.ticketModel?.bookingType == "whosin" {
            return totalGuests >= (ticketOptionModel?.minimumPax ?? 0)
        }
        if BOOKINGMANAGER.ticketModel?.bookingType == "whosin-ticket" {
            return totalGuests >= (Int(ticketOptionModel?.minPaxString ?? "0") ?? 0)
        }
        if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
            return totalGuests >= (travelDeskOptionModel?.minNumOfPeople ?? 0)
        }
        if BOOKINGMANAGER.ticketModel?.bookingType == "big-bus" || BOOKINGMANAGER.ticketModel?.bookingType == "hero-balloon" {
            return totalGuests >= (bigBusOptionModel?.restrictions?.minPaxCount == 0 ? 0 : bigBusOptionModel?.restrictions?.minPaxCount ?? 0)
        }
        return totalGuests >= (BOOKINGMANAGER.ticketModel?.minPax ?? 0)
    }
    
    private func showMaxToast() {
        if BOOKINGMANAGER.ticketModel!.bookingType == "whosin" && ticketOptionModel?.availabilityType == "slot" {
            let maxSeats = ticketOptionModel?.availabilityTimeSlot.compactMap { $0.totalSeats }.max() ?? 0
            parentBaseController?.showToast(LANGMANAGER.localizedString(forKey: "max_pax_alert", arguments: ["value1": "\(maxSeats)", "value2" : "\(units)"]))
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin" {
            parentBaseController?.showToast(LANGMANAGER.localizedString(forKey: "max_pax_alert", arguments: ["value1": "\(ticketOptionModel?.totalSeats ?? 0)", "value2":"\(units)"]))
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin-ticket" {
            parentBaseController?.showToast(LANGMANAGER.localizedString(forKey: "max_pax_alert", arguments: ["value1": "\(Int(ticketOptionModel?.maxPaxString ?? "1000") ?? 0)", "value2": "\(units)"]))
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
            parentBaseController?.showToast(LANGMANAGER.localizedString(forKey: "max_pax_alert", arguments: ["value1": "\(travelDeskOptionModel?.maxNumOfPeople ?? 0)", "value2": "\(units)"]))
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "big-bus" || BOOKINGMANAGER.ticketModel?.bookingType == "hero-balloon" {
            parentBaseController?.showToast(LANGMANAGER.localizedString(forKey: "max_pax_alert", arguments: ["value1": "\(bigBusOptionModel?.restrictions?.maxPaxCount ?? 0)", "value2": "\(units)"]))
        } else {
            parentBaseController?.showToast(LANGMANAGER.localizedString(forKey: "max_pax_alert", arguments: ["value1": "\(BOOKINGMANAGER.ticketModel?.maxPax ?? 0)", "value2": "\(units)"]))
        }
    }
    
    @IBAction func _adultMinusEvent(_ sender: Any) {
        Utils.performHapticFeedback()
        if ticketOptionModel?.optionDetail?.isWithoutAdult == true {
            if adultstepperValue > adultstepperMinValue {
                adultstepperValue -= 1
            }
        } else {
            if adultstepperValue > adultstepperMinValue {
                adultstepperValue -= 1
            }
            let maxInfantsAllowed = Int(ceil(Double(adultstepperValue) / 4.0))
            
            if infantstepperValue > maxInfantsAllowed {
                infantstepperValue = maxInfantsAllowed
            }
        }
        if (adultstepperValue + childrenstepperValue + infantstepperValue) == 0 {
            didApplyMinPax = false
        }
        updateTotal()
    }
    
    @IBAction func _adultPlusEvent(_ sender: Any) {
        Utils.performHapticFeedback()
        guard canIncreasePax() else {
            showRatioToastIfNeeded()
            return
        }

        guard !isMaxPax() else {
            showMaxToast()
            return
        }
        if !didApplyMinPax && adultstepperValue == 0 && minPaxRequired > 0 {
            adultstepperValue = minPaxRequired
            didApplyMinPax = true
        } else {
            adultstepperValue += 1
        }
        updateTotal()
    }
    
    @IBAction func _childrenMinusEvent(_ sender: Any) {
        Utils.performHapticFeedback()
        if childrenstepperValue > childrenstepperMinValue {
            childrenstepperValue -= 1
        }
        if (adultstepperValue + childrenstepperValue + infantstepperValue) == 0 {
            didApplyMinPax = false
        }
        updateTotal()
    }
    
    @IBAction func _childrenPlusEvent(_ sender: Any) {
        Utils.performHapticFeedback()
        guard canIncreasePax() else {
            showRatioToastIfNeeded()
            return
        }

        guard !isMaxPax() else {
            showMaxToast()
            return
        }
        if !didApplyMinPax && childrenstepperValue == 0 && minPaxRequired > 0 {
            childrenstepperValue = minPaxRequired
            didApplyMinPax = true
        } else {
            childrenstepperValue += 1
        }
        updateTotal()
    }
    
    @IBAction func _infantsMinusEvent(_ sender: Any) {
        Utils.performHapticFeedback()
        if infantstepperValue > infantstepperMinValue {
            infantstepperValue -= 1
            updateTotal()
        }
        if (adultstepperValue + childrenstepperValue + infantstepperValue) == 0 {
            didApplyMinPax = false
        }
    }
    
    @IBAction func _infantsPlusEvent(_ sender: Any){
        Utils.performHapticFeedback()
        guard canIncreasePax() else {
            showRatioToastIfNeeded()
            return
        }

        guard !isMaxPax() else {
            showMaxToast()
            return
        }
        let maxInfantsAllowed = Int(ceil(Double(adultstepperValue) / 4.0))
        guard infantstepperValue < maxInfantsAllowed else { return }
        if !didApplyMinPax && infantstepperValue == 0 && minPaxRequired > 0 && infantstepperValue < maxInfantsAllowed {
            infantstepperValue = minPaxRequired
            didApplyMinPax = true
        } else if infantstepperValue < maxInfantsAllowed {
            infantstepperValue += 1
        }
        updateTotal()
    }
    
    private func showRatioToastIfNeeded() {
        guard let limit = maxRatioPax else { return }
        parentBaseController?.showToast(
            "You can select maximum \(limit) passenger(s) for this add-on"
        )
    }

    
}
