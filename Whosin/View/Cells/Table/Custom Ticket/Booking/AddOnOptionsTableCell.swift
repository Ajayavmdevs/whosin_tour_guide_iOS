import UIKit
import PanModal
import ExpandableLabel
import DropDown

class AddOnOptionsTableCell: UITableViewCell {

    @IBOutlet weak var _noteText: CustomLabel!
    @IBOutlet weak var _tourImage: UIImageView!
    @IBOutlet private weak var _tourTitle: CustomLabel!
    @IBOutlet weak var _tourDesc: ExpandableLabel!
    @IBOutlet weak var _timeView: UIView!
    @IBOutlet private weak var _selectedTransferType: CustomLabel!
    @IBOutlet private weak var _selectedDate: UILabel!
    @IBOutlet weak var _selectedDateView: UILabel!
    @IBOutlet private weak var _selectedTime: UILabel!
    @IBOutlet private weak var _optionsView: UIView!
    @IBOutlet weak var _mainView: UIView!
    @IBOutlet private weak var _customAdultView: CustomAdultsView!
    @IBOutlet weak var _cancellationPolicy: CustomButton!
    @IBOutlet weak var _depatureTime: CustomLabel!
    @IBOutlet weak var _departureTimeView: UIView!
    @IBOutlet weak var _dateView: UIView!
    @IBOutlet weak var _SelectDateStackView: UIStackView!
    @IBOutlet weak var _transferView: UIStackView!
    @IBOutlet weak var _pickupPointView: UIStackView!
    @IBOutlet weak var _pickupText: CustomLabel!
    @IBOutlet weak var _pickupBtn: CustomButton!
    
    private var _optionsGroup: [TourOptionsModel] = []
    private var adult: Int = 0
    private var child: Int = 0
    private var infant: Int = 0
    private var selectedTransferId: String = kEmptyString
    private var _selectedTourOptionModel: TourOptionsModel?
    private var _selectedTravekDeskOptionModel: TourOptionModel?
    private var _selectedBigBusOptionModel: BigBusOptionsModel?
    private var _selectedSlot: TourTimeSlotModel?
    private var _selectedTravel: TravelDeskAvailibilityModel?
    private var _selectedBigbus: OctoAvailibilityModel?
    private var _selectedPickup: PickupListModel? = nil
    private var _tourOptionImage: String = kEmptyString
    private var _type: String = kEmptyString
    private var isRefundable: Bool = false
    private var isAddon: Bool = false
    private var parentOptionId: String = kEmptyString
    
    public var callback: (() -> Void)?
    
    let dropDown = DropDown()


    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _setup()
    }
    
    private func _setup() {
        _tourTitle.numberOfLines = 0
        _tourTitle.lineBreakMode = .byWordWrapping
        _customAdultView.callback = { [weak self] adult, child, infant in
            guard let self = self else { return }
            self.adult = adult
            self.child = child
            self.infant = infant
            if BOOKINGMANAGER.ticketModel?.bookingType == "rayna" {
                if adult == 0, child == 0, infant == 0 {
                    self._SelectDateStackView.isHidden = false
                    self._timeView.isHidden = true
                    if self.isAddon, let option = self._selectedTourOptionModel {
                        BOOKINGMANAGER.addOrUpdateAddon(parentOptionId: self.parentOptionId, addonModel: option, adult: 0, child: 0, infant: 0, timeSlot: self._selectedSlot)
                    } else {
                        BOOKINGMANAGER.removeOption(_selectedTourOptionModel ?? TourOptionsModel())
                        BOOKINGMANAGER.removeOption(_selectedTravekDeskOptionModel ?? TourOptionModel())
                    }
                } else {
                    let date = self._selectedDate.text == "date_time_placeHolder".localized() ? "" : self._selectedDate.text ?? ""
                    if self._selectedDate.text == "date_time_placeHolder".localized() {
                        self._SelectDateStackView.isHidden = false
                        self._timeView.isHidden = true
                    } else {
                        if _selectedTourOptionModel?.isSlot == false {
                            let slot = TourTimeSlotModel()
                            slot.timeSlot = self._selectedSlot?.timeSlot ?? _selectedTourOptionModel?.slotText ?? ""
                            slot.timeSlotId = self._selectedSlot?.timeSlotId ?? ("0")
                            self._selectedSlot = slot
                        }
                        self._selectedDateView.text = date
                        self._selectedTime.text = self._selectedSlot?.timeSlot ?? ""
                        self._SelectDateStackView.isHidden = true
                        self._timeView.isHidden = false
                    }
                    if let option = _selectedTourOptionModel {
                        if self.isAddon {
                            BOOKINGMANAGER.addOrUpdateAddon(parentOptionId: self.parentOptionId, addonModel: option, adult: adult, child: child, infant: infant, timeSlot: self._selectedSlot)
                        } else {
                            BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: date, timeSlot: self._selectedSlot)
                        }
                    }
                }
                callback?()
            }
            else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin" {
                if adult == 0, child == 0, infant == 0 {
                    self._SelectDateStackView.isHidden = false
                    self._timeView.isHidden = true
                    if self.isAddon, let option = self._selectedTourOptionModel {
                        BOOKINGMANAGER.addOrUpdateAddon(parentOptionId: self.parentOptionId, addonModel: option, adult: 0, child: 0, infant: 0, timeSlot: self._selectedSlot)
                    } else {
                        BOOKINGMANAGER.removeOption(_selectedTourOptionModel ?? TourOptionsModel())
                    }
                } else {
                    let date = self._selectedDate.text == "date_time_placeHolder".localized() ? "" : self._selectedDate.text ?? ""
                    if self._selectedDate.text == "date_time_placeHolder".localized() {
                        self._SelectDateStackView.isHidden = false
                        self._timeView.isHidden = true
                    } else {
                        if _selectedTourOptionModel?.availabilityType == "regular" {
                            let slot = TourTimeSlotModel()
                            slot.timeSlot = self._selectedTourOptionModel?.availabilityTime ?? ""
                            slot.timeSlotId = self._selectedTourOptionModel?.availabilityTime ?? ""
                            slot.availabilityTime = self._selectedTourOptionModel?.availabilityTime ?? ""
                            self._selectedSlot = slot
                        }
                        self._selectedDateView.text = date
                        self._selectedTime.text = self._selectedSlot?.availabilityTime ?? ""
                        self._SelectDateStackView.isHidden = true
                        self._timeView.isHidden = false
                    }
                    if let option = _selectedTourOptionModel {
                        if self.isAddon {
                            BOOKINGMANAGER.addOrUpdateAddon(parentOptionId: self.parentOptionId, addonModel: option, adult: adult, child: child, infant: infant, timeSlot: self._selectedSlot)
                        } else {
                            BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: date, timeSlot: self._selectedSlot)
                        }
                    }
                }
                callback?()
            }
            else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin-ticket" {
                if adult == 0, child == 0, infant == 0 {
                    self._SelectDateStackView.isHidden = false
                    self._timeView.isHidden = true
                    if self.isAddon, let option = self._selectedTourOptionModel {
                        BOOKINGMANAGER.addOrUpdateAddon(parentOptionId: self.parentOptionId, addonModel: option, adult: 0, child: 0, infant: 0, timeSlot: self._selectedSlot)
                    } else {
                        BOOKINGMANAGER.removeOption(_selectedTourOptionModel ?? TourOptionsModel())
                    }
                } else {
                    let date = self._selectedDate.text == "date_time_placeHolder".localized() ? "" : self._selectedDate.text ?? ""
                    if self._selectedDate.text == "date_time_placeHolder".localized() {
                        self._SelectDateStackView.isHidden = false
                        self._timeView.isHidden = true
                    } else {
                        if _selectedTourOptionModel?.isSlot == false {
                            let slot = TourTimeSlotModel()
                            slot.timeSlot = self._selectedTourOptionModel?.slotText ?? ""
                            slot.timeSlotId = self._selectedTourOptionModel?.tourIdString ?? ""
                            slot.availabilityTime = self._selectedTourOptionModel?.slotText ?? ""
                            self._selectedSlot = slot
                        }
                        self._selectedDateView.text = date
                        self._selectedTime.text = self._selectedSlot?.timeSlot ?? ""
                        self._SelectDateStackView.isHidden = true
                        self._timeView.isHidden = false
                    }
                    if let option = _selectedTourOptionModel {
                        if self.isAddon {
                            BOOKINGMANAGER.addOrUpdateAddon(parentOptionId: self.parentOptionId, addonModel: option, adult: adult, child: child, infant: infant, timeSlot: self._selectedSlot)
                        } else {
                            BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: date, timeSlot: self._selectedSlot)
                        }
                    }
                }
                callback?()
            }
            else if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
                if adult == 0, child == 0, infant == 0 {
                    self._SelectDateStackView.isHidden = false
                    self._timeView.isHidden = true
                    BOOKINGMANAGER.removeOption(_selectedTravekDeskOptionModel ?? TravelDeskTourModel())
                } else {
                    let date = self._selectedDate.text == "date_time_placeHolder".localized() ? "" : self._selectedDate.text ?? ""
                    if self._selectedDate.text == "date_time_placeHolder".localized() {
                        self._SelectDateStackView.isHidden = false
                        self._timeView.isHidden = true
                    } else {
                        self._selectedDateView.text = date
                        self._selectedDate.text = date
                        self._selectedTime.text = self._selectedTravel?.availability?.slotText ?? ""
                        self._SelectDateStackView.isHidden = true
                        self._timeView.isHidden = false
                    }
                    if let option = _selectedTravekDeskOptionModel {
                        BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: date, timeSlot: self._selectedTravel, optionDetail: BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(option.id)" }))
                    }
                }
                callback?()
            }
            else if BOOKINGMANAGER.ticketModel?.bookingType == "big-bus" || BOOKINGMANAGER.ticketModel?.bookingType == "hero-balloon" {
                if adult == 0, child == 0, infant == 0 {
                    self._SelectDateStackView.isHidden = false
                    self._timeView.isHidden = true
                    BOOKINGMANAGER.removeOption(_selectedBigBusOptionModel ?? BigBusOptionsModel())
                } else {
                    let date = self._selectedDate.text == "date_time_placeHolder".localized() ? "" : self._selectedDate.text ?? ""
                    if self._selectedDate.text == "date_time_placeHolder".localized() {
                        self._SelectDateStackView.isHidden = false
                        self._timeView.isHidden = true
                    } else {
                        let slot = "\(self._selectedBigbus?.openingHours.first?.from ?? "") - \(self._selectedBigbus?.openingHours.first?.to ?? "")"
                        self._selectedDateView.text = date
                        self._selectedDate.text = date
                        self._selectedTime.text = slot
                        self._SelectDateStackView.isHidden = true
                        self._timeView.isHidden = false
                    }
                    if let option = _selectedBigBusOptionModel {
                        BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: date, timeSlot: self._selectedBigbus, optionDetail: BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == option.id }), pickup: _selectedPickup)
                    }
                }
                callback?()
            }
        }
        _tourImage.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePreview))
        _tourImage.addGestureRecognizer(imageTap)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        _tourDesc.isUserInteractionEnabled = true
        _tourDesc.addGestureRecognizer(tapGesture)
        _tourDesc.delegate = self
        _tourDesc.shouldCollapse = false
        _tourDesc.shouldExpand = false
        _tourDesc.numberOfLines = 0
        _tourDesc.lineBreakMode = .byWordWrapping
        _tourDesc.ellipsis = NSAttributedString(string: "....")
        _tourDesc.collapsedAttributedLink = NSAttributedString(string: "more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
        _tourDesc.setLessLinkWith(lessLink: "see_less".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink], position: .left)
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    private func _requestTimeSlot(completion: @escaping ([TourTimeSlotModel]) -> Void) {
        let contractId = Utils.stringIsNullOrEmpty(BOOKINGMANAGER.ticketModel?.contractId) ? BOOKINGMANAGER.ticketModel?.tourData?.contractId ?? kEmptyString : BOOKINGMANAGER.ticketModel?.contractId ?? kEmptyString
        
        let params: [String: Any] = [
            "tourId": _selectedTourOptionModel?.tourId ?? 0,
            "tourOptionId": _selectedTourOptionModel?.tourOptionId ?? kEmptyString,
            "contractId": contractId,
            "date": _selectedDate.text ?? "",
            "transferId": _selectedTourOptionModel?.transferId ?? 0,
            "noOfAdult": adult,
            "noOfChild": child,
            "noOfInfant": infant
        ]
        WhosinServices.raynaTourTimeSlots(params: params) { [weak self] container, error in
            guard self != nil else {
                completion([])
                return
            }
            guard let data = container?.data else {
                completion([])
                return
            }
            let filteredData = data.filter { $0.available != 0 }
            completion(filteredData)
        }
    }
    
    private func updateNoteText(min: Int, max: Int, noteTxt: String) {
        if !Utils.stringIsNullOrEmpty(noteTxt) {
            _noteText.isHidden = false
            _noteText.text = LANGMANAGER.localizedString(forKey: "note_text", arguments: ["value": noteTxt])
            return
        }
        _noteText.isHidden = true
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ options: [TourOptionsModel], isSelected: Bool, discount: Int = 0, isCart: Bool = false) {
        _type = "rayna"
        guard let data = options.first else { return }
        _optionsView.isHidden = false
        _optionsGroup = options
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(data.tourOptionId)" }) {
            _selectedTourOptionModel = options.first(where: {$0.transferId == model.transferId && $0.optionId == data.optionId })
            adult = model.adult
            child = model.child
            infant = model.infant
            _selectedTime.text = model.timeSlot
            let slot = TourTimeSlotModel()
            slot.tourOptionId = Int(model.optionId) ?? 0
            slot.id = model.optionId
            slot.timeSlot = model.timeSlot
            slot.timeSlotId = model.timeSlotId
            _selectedSlot = slot
            if let option = _selectedTourOptionModel {
                BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: model.tourDate, timeSlot: self._selectedSlot)
            }
        } else {
            adult = 0
            child = 0
            infant = 0
            _selectedTourOptionModel = nil
        }
        
        if _selectedTourOptionModel == nil {
            _selectedTourOptionModel = options.first
        }
        let tourImage = data.optionDetail?.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) } ).first ?? kEmptyString
        
        if Utils.stringIsNullOrEmpty(tourImage) {
            _tourImage.loadWebImage(BOOKINGMANAGER.ticketModel?.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) } ).first ?? kEmptyString)
            _tourOptionImage = BOOKINGMANAGER.ticketModel?.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) } ).first ?? kEmptyString
        }
        else {
            _tourImage.loadWebImage(tourImage)
            _tourOptionImage = tourImage
        }

        
        _tourTitle.text = _selectedTourOptionModel!.optionDetail?.optionName
        _tourDesc.text = _selectedTourOptionModel!.optionDetail?.optionDescription
        _customAdultView.setupData(BOOKINGMANAGER.ticketModel, _selectedTourOptionModel)
        
        let originalPrice: Double = _selectedTourOptionModel?.withoutDiscountAmount.formatted() ?? 0.0
        let discountPrice: Double = _selectedTourOptionModel?.finalAmount.formatted() ?? 0.0

        _mainView.layer.borderWidth = isSelected ? 1 : 0.5
        _mainView.layer.borderColor = isSelected ? ColorBrand.tabSelectColor.cgColor : ColorBrand.brandGray.cgColor
        
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(_selectedTourOptionModel?.tourOptionId ?? 0)" }) {
            if Utils.stringIsNullOrEmpty(model.tourDate) {
                _selectedDate.text = "date_time_placeHolder".localized()
                _SelectDateStackView.isHidden = false
                _timeView.isHidden = true
                _dateView.borderColor = ColorBrand.brandGray
            } else {
                if !Utils.stringIsNullOrEmpty(model.timeSlot) {
                    _timeView.isHidden = false
                    _SelectDateStackView.isHidden = true
                    _selectedTime.text = model.timeSlot
                } else {
                    _timeView.isHidden = true
                    _SelectDateStackView.isHidden = false
                }
                let date = Utils.stringToDate(model.tourDate, format: kStanderdDate)
                if date != nil {
                    _selectedDate.text = Utils.dateToString(date, format: kFormatDate)
                    _selectedDateView.text = Utils.dateToString(date, format: kFormatDate)
                } else {
                    _selectedDate.text = "\(model.tourDate)"
                    _selectedDateView.text = "\(model.tourDate)"
                }
                _dateView.borderColor = UIColor(hexString: "#2BA735")
                if isCart, let model = _selectedTourOptionModel {
                    BOOKINGMANAGER.addOption(model, adult: adult, child: child, infant: infant, date: _selectedDate.text ?? "", timeSlot: self._selectedSlot)
                }
            }
        } else {
            _selectedDate.text = "date_time_placeHolder".localized()
            _SelectDateStackView.isHidden = false
            _timeView.isHidden = true
            _dateView.borderColor = ColorBrand.brandGray
        }

        _selectedTransferType.text = _selectedTourOptionModel?.transferName
        
        self.isRefundable = data.optionDetail?.isRefundable == true
        _cancellationPolicy.setTitle(data.optionDetail?.isRefundable == true ? "cancellation_policy".localized() : "non_refundable".localized())
        _cancellationPolicy.backgroundColor = data.optionDetail?.isRefundable == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
        updateNoteText(min: BOOKINGMANAGER.ticketModel?.minPax ?? 0, max: BOOKINGMANAGER.ticketModel?.maxPax ?? 1000, noteTxt: _selectedTourOptionModel?.notes ?? "")
        _transferView.isHidden = options.count <= 1
    }
    
    public func setupData(_ options: TourOptionsModel, isSelected: Bool, discount: Int = 0, isCart: Bool = false) {
        _optionsView.isHidden = false
        _type = "whosin"
        _selectedTourOptionModel = options
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == options._id }) {
            _selectedTourOptionModel = options
            adult = model.adult
            child = model.child
            infant = model.infant
            _selectedTime.text = Utils.stringIsNullOrEmpty(model.timeSlot) ? model.startTime : model.timeSlot
            if let option = _selectedTourOptionModel {
                BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: model.tourDate, timeSlot: self._selectedSlot)
            }
        } else {
            adult = 0
            child = 0
            infant = 0
            _selectedTourOptionModel = nil
        }
        
        if _selectedTourOptionModel == nil {
            _selectedTourOptionModel = options
        }
        let tourImage = options.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) } ).first ?? kEmptyString
        
        if Utils.stringIsNullOrEmpty(tourImage) {
            _tourImage.loadWebImage(BOOKINGMANAGER.ticketModel?.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) } ).first ?? kEmptyString)
            _tourOptionImage = BOOKINGMANAGER.ticketModel?.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) } ).first ?? kEmptyString
        }
        else {
            _tourImage.loadWebImage(tourImage)
            _tourOptionImage = tourImage
        }

        
        _tourTitle.text = options.title
        _tourDesc.text = options.descriptions
        _customAdultView.setupData(BOOKINGMANAGER.ticketModel, _selectedTourOptionModel)

        let originalPrice: Double = options.finalAmount
        let discountPrice: Double = options.withoutDiscountAmount
        
        _mainView.layer.borderWidth = isSelected ? 1 : 0.5
        _mainView.layer.borderColor = isSelected ? ColorBrand.tabSelectColor.cgColor : ColorBrand.brandGray.cgColor
        
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == options._id }) {
            if Utils.stringIsNullOrEmpty(model.tourDate) {
                _selectedDate.text = "date_time_placeHolder".localized()
                _SelectDateStackView.isHidden = false
                _timeView.isHidden = true
                _dateView.borderColor = ColorBrand.brandGray
            } else {
                if options.availabilityType == "regular" {
                    if !Utils.stringIsNullOrEmpty(model.startTime) {
                        _timeView.isHidden = false
                        _SelectDateStackView.isHidden = true
                        _selectedTime.text = model.startTime
                    } else {
                        _timeView.isHidden = true
                        _SelectDateStackView.isHidden = false
                    }
                } else {
                    if !Utils.stringIsNullOrEmpty(model.timeSlot) {
                        _timeView.isHidden = false
                        _SelectDateStackView.isHidden = true
                        _selectedTime.text = model.timeSlot
                    } else {
                        _timeView.isHidden = true
                        _SelectDateStackView.isHidden = false
                    }
                }
                let date = Utils.stringToDate(model.tourDate, format: kStanderdDate)
                if date != nil {
                    _selectedDate.text = Utils.dateToString(date, format: kFormatDate)
                    _selectedDateView.text = Utils.dateToString(date, format: kFormatDate)
                } else {
                    _selectedDate.text = "\(model.tourDate)"
                    _selectedDateView.text = "\(model.tourDate)"
                }
                if isCart, let model = _selectedTourOptionModel {
                    BOOKINGMANAGER.addOption(model, adult: adult, child: child, infant: infant, date: _selectedDate.text ?? "", timeSlot: self._selectedSlot)
                }
                _dateView.borderColor = UIColor(hexString: "#2BA735")
            }
        } else {
            _selectedDate.text = "date_time_placeHolder".localized()
            _SelectDateStackView.isHidden = false
            _timeView.isHidden = true
            _dateView.borderColor = ColorBrand.brandGray
        }
        
        self.isRefundable = options.isRefundable == true

        _cancellationPolicy.setTitle(options.isRefundable == true ? "cancellation_policy".localized() : "non_refundable".localized())
        _cancellationPolicy.backgroundColor = options.isRefundable == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
        updateNoteText(min: Int(options.minmumPaxString) ?? 0, max: options.totalSeats, noteTxt: _selectedTourOptionModel?.notes ?? "")
        _transferView.isHidden = true
    }
    
    public func setupAddonData(_ addon: TourOptionsModel, parentOptionId: String, isSelected: Bool, discount: Int = 0) {
        isAddon = true
        self.parentOptionId = parentOptionId
        _optionsView.isHidden = false
        _type = BOOKINGMANAGER.ticketModel?.bookingType ?? ""
        _selectedTourOptionModel = addon
        
        let tourImage = addon.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) }).first ?? kEmptyString
        if Utils.stringIsNullOrEmpty(tourImage) {
            _tourImage.loadWebImage(BOOKINGMANAGER.ticketModel?.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) }).first ?? kEmptyString)
            _tourOptionImage = BOOKINGMANAGER.ticketModel?.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) }).first ?? kEmptyString
        } else {
            _tourImage.loadWebImage(tourImage)
            _tourOptionImage = tourImage
        }
        
        if BOOKINGMANAGER.ticketModel?.bookingType == "whosin-ticket" {
            _tourTitle.text = addon.displayName
            _tourDesc.text = addon.optionDescription
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin" {
            _tourTitle.text = addon.title
            _tourDesc.text = addon.descriptions
        } else {
            _tourTitle.text = addon.optionDetail?.optionName
            _tourDesc.text = addon.optionDetail?.optionDescription
        }
        
        _customAdultView.setupData(BOOKINGMANAGER.ticketModel, _selectedTourOptionModel)
        
        if let parent = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == parentOptionId }) {
            let existingAddon: TourOptionDetailModel? = {
                if BOOKINGMANAGER.ticketModel?.bookingType == "rayna" {
                    return parent.Addons.first(where: { $0.optionId == "\(addon.tourOptionId)" })
                } else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin" {
                    return parent.Addons.first(where: { $0.optionId == addon._id })
                } else {
                    return parent.Addons.first(where: { $0.optionId == addon.optionId })
                }
            }()
            if let existingAddon = existingAddon {
                adult = existingAddon.adult
                child = existingAddon.child
                infant = existingAddon.infant
                _selectedTime.text = existingAddon.timeSlot.isEmpty ? existingAddon.startTime : existingAddon.timeSlot
                if BOOKINGMANAGER.ticketModel?.bookingType == "whosin" || BOOKINGMANAGER.ticketModel?.bookingType == "whosin-ticket" {
                    let slot = TourTimeSlotModel()
                    slot.id = existingAddon.timeSlotId
                    slot.timeSlot = existingAddon.timeSlot
                    slot.availabilityTime = existingAddon.timeSlot
                    _selectedSlot = slot
                } else {
                    let slot = TourTimeSlotModel()
                    slot.timeSlotId = existingAddon.timeSlotId
                    slot.timeSlot = existingAddon.timeSlot
                    _selectedSlot = slot
                }
                let date = Utils.stringToDate(parent.tourDate, format: kStanderdDate)
                if date != nil {
                    _selectedDate.text = Utils.dateToString(date, format: kFormatDate)
                    _selectedDateView.text = Utils.dateToString(date, format: kFormatDate)
                } else {
                    _selectedDate.text = "\(parent.tourDate)"
                    _selectedDateView.text = "\(parent.tourDate)"
                }
                _timeView.isHidden = _selectedTime.text?.isEmpty == true
                _SelectDateStackView.isHidden = !(_timeView.isHidden)
            } else {
                adult = 0
                child = 0
                infant = 0
                _selectedTime.text = ""
                _SelectDateStackView.isHidden = false
                _timeView.isHidden = true
            }
        }
        
        _mainView.layer.borderWidth = isSelected ? 1 : 0.5
        _mainView.layer.borderColor = isSelected ? ColorBrand.tabSelectColor.cgColor : ColorBrand.brandGray.cgColor
        _transferView.isHidden = true
    }
    
    public func setupData(_ options: TourOptionModel, isSelected: Bool, discount: Int = 0, isCart: Bool = false) {
        _optionsView.isHidden = false
        _type = "travel-desk"
        _selectedTravekDeskOptionModel = options
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(options.id)" }) {
            _selectedTravekDeskOptionModel = options
            adult = model.adult
            child = model.child
            infant = model.infant
            _selectedTime.text = model.timeSlot
            let slot = TravelDeskAvailibility()
            slot.startTime = Int(model.startTime) ?? 0
            slot.endTime = Int(model.endTime) ?? 0
            slot.timeSlotId = Int(model.timeSlotId) ?? 0
            _selectedTravel?.availability = slot
            if let option = _selectedTravekDeskOptionModel {
                BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: model.tourDate, timeSlot: self._selectedTravel, optionDetail: BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(option.id)" }))
            }
        }
        else {
            adult = 0
            child = 0
            infant = 0
            _selectedTravekDeskOptionModel = nil
        }
        
        if _selectedTravekDeskOptionModel == nil {
            _selectedTravekDeskOptionModel = options
        }
        
        var images: [String] = options.heroImage.compactMap { image in
            image.srcSet.compactMap { $0.sizes.first?.src }
        }.flatMap { $0 }

        if images.isEmpty {
            images = BOOKINGMANAGER.ticketModel?.travelDeskTourData.compactMap { model in
                model.heroImage?.srcSet.compactMap { $0.sizes.first?.src }
            }.flatMap { $0 } ?? []
        }

        if images.isEmpty {
            images = BOOKINGMANAGER.ticketModel?.images.toArray(ofType: String.self) ?? []
        }

        _tourImage.loadWebImage(images.first ?? "")
        _tourOptionImage = images.first ?? ""

        _tourTitle.text = options.name
        _tourDesc.text = Utils.convertHTMLToPlainText(from: options.descriptionText)
        _customAdultView.setupData(BOOKINGMANAGER.ticketModel, options)

        let originalPrice: Double = options.pricingPeriods.first?.pricePerAdult ?? 0
        let discountPrice: Double = options.pricingPeriods.first?.pricePerAdultBeforeDiscount ?? 0
        
        _mainView.layer.borderWidth = isSelected ? 1 : 0.5
        _mainView.layer.borderColor = isSelected ? (ColorBrand.tabSelectColor).cgColor : (ColorBrand.brandGray).cgColor
        
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(options.id)" }) {
            if Utils.stringIsNullOrEmpty(model.tourDate) {
                _selectedDate.text = "date_time_placeHolder".localized()
                _SelectDateStackView.isHidden = false
                _timeView.isHidden = true
                _dateView.borderColor = ColorBrand.brandGray
            } else {
                if !Utils.stringIsNullOrEmpty(model.timeSlot) {
                    _timeView.isHidden = false
                    _SelectDateStackView.isHidden = true
                    _selectedTime.text = model.timeSlot
                } else {
                    _timeView.isHidden = true
                    _SelectDateStackView.isHidden = false
                }
                let date = Utils.stringToDate(model.tourDate, format: kStanderdDate)
                if date != nil {
                    _selectedDate.text = Utils.dateToString(date, format: kFormatDate)
                    _selectedDateView.text = Utils.dateToString(date, format: kFormatDate)
                } else {
                    _selectedDate.text = "\(model.tourDate)"
                    _selectedDateView.text = "\(model.tourDate)"
                }
                if isCart, let selected = _selectedTravekDeskOptionModel {
                    BOOKINGMANAGER.addOption(selected, adult: adult, child: child, infant: infant, date: _selectedDate.text ?? "", timeSlot: self._selectedTravel, optionDetail: BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(selected.id)" }))
                }
                _dateView.borderColor = UIColor(hexString: "#2BA735")
            }
        }
        else {
            _selectedDate.text = "date_time_placeHolder".localized()
            _SelectDateStackView.isHidden = false
            _timeView.isHidden = true
            _dateView.borderColor = ColorBrand.brandGray
        }

        self.isRefundable = BOOKINGMANAGER.ticketModel?.isFreeCancellation == true
        _cancellationPolicy.setTitle(BOOKINGMANAGER.ticketModel?.isFreeCancellation == true ? "cancellation_policy".localized() : "non_refundable".localized())
        _cancellationPolicy.backgroundColor = BOOKINGMANAGER.ticketModel?.isFreeCancellation == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
        updateNoteText(min: options.minNumOfPeople, max: options.maxNumOfPeople, noteTxt: _selectedTravekDeskOptionModel?.notes ?? "")
        _transferView.isHidden = true
    }

    public func setWhosinModule(_ options: TourOptionsModel, isSelected: Bool, discount: Int = 0, isCart: Bool = false) {
        _optionsView.isHidden = false
        _type = "whosin-ticket"
        _selectedTourOptionModel = options
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == options.optionId }) {
            _selectedTourOptionModel = options
            adult = model.adult
            child = model.child
            infant = model.infant
            let slot = TourTimeSlotModel()
            slot.tourOptionId = Int(model.optionId) ?? 0
            slot.id = model.optionId
            slot.timeSlot = model.timeSlot
            slot.slotId = model.timeSlotId
            slot.timeSlotId = model.timeSlotId
            _selectedSlot = slot
            _selectedTime.text = Utils.stringIsNullOrEmpty(model.timeSlot) ? model.startTime : model.timeSlot
            if let option = _selectedTourOptionModel {
                BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: model.tourDate, timeSlot: self._selectedSlot)
            }
        }
        else {
            adult = 0
            child = 0
            infant = 0
            _selectedTourOptionModel = nil
        }
        
        if _selectedTourOptionModel == nil {
            _selectedTourOptionModel = options
        }
        let tourImage = options.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) } ).first ?? kEmptyString
        
        if Utils.stringIsNullOrEmpty(tourImage) {
            _tourImage.loadWebImage(BOOKINGMANAGER.ticketModel?.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) } ).first ?? kEmptyString)
            _tourOptionImage = BOOKINGMANAGER.ticketModel?.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) } ).first ?? kEmptyString
        }
        else {
            _tourImage.loadWebImage(tourImage)
            _tourOptionImage = tourImage
        }

        
        _tourTitle.text = options.displayName
        _tourDesc.text = options.optionDescription
        _customAdultView.setupData(BOOKINGMANAGER.ticketModel, _selectedTourOptionModel)

        let originalPrice: Double = options.adultPrice
        let discountPrice: Double = options.adultPrice

        _mainView.layer.borderWidth = isSelected ? 1 : 0.5
        _mainView.layer.borderColor = isSelected ? ColorBrand.tabSelectColor.cgColor : ColorBrand.brandGray.cgColor
        
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == options.optionId }) {
            if Utils.stringIsNullOrEmpty(model.tourDate) {
                _selectedDate.text = "date_time_placeHolder".localized()
                _SelectDateStackView.isHidden = false
                _timeView.isHidden = true
                _dateView.borderColor = ColorBrand.brandGray
            } else {
                if options.availabilityType == "regular" {
                    if !Utils.stringIsNullOrEmpty(model.startTime) {
                        _timeView.isHidden = false
                        _SelectDateStackView.isHidden = true
                        _selectedTime.text = model.startTime
                    } else {
                        _timeView.isHidden = true
                        _SelectDateStackView.isHidden = false
                    }
                } else {
                    if !Utils.stringIsNullOrEmpty(model.timeSlot) {
                        _timeView.isHidden = false
                        _SelectDateStackView.isHidden = true
                        _selectedTime.text = model.timeSlot
                    } else {
                        _timeView.isHidden = true
                        _SelectDateStackView.isHidden = false
                    }
                }
                let date = Utils.stringToDate(model.tourDate, format: kStanderdDate)
                if date != nil {
                    _selectedDate.text = Utils.dateToString(date, format: kFormatDate)
                    _selectedDateView.text = Utils.dateToString(date, format: kFormatDate)
                } else {
                    _selectedDate.text = "\(model.tourDate)"
                    _selectedDateView.text = "\(model.tourDate)"
                }
                if isCart, let model = _selectedTourOptionModel {
                    BOOKINGMANAGER.addOption(model, adult: adult, child: child, infant: infant, date: _selectedDate.text ?? "", timeSlot: self._selectedSlot)
                }
                _dateView.borderColor = UIColor(hexString: "#2BA735")
            }
        }
        else {
            _selectedDate.text = "date_time_placeHolder".localized()
            _SelectDateStackView.isHidden = false
            _timeView.isHidden = true
            _dateView.borderColor = ColorBrand.brandGray
        }

        self.isRefundable = options.isRefundable == true

        _cancellationPolicy.setTitle(options.isRefundable == true ? "cancellation_policy".localized() : "non_refundable".localized())
        _cancellationPolicy.backgroundColor = options.isRefundable == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
        updateNoteText(min: Int(options.minPaxString) ?? 0, max: Int(options.maxPaxString) ?? 1000, noteTxt: _selectedTourOptionModel?.notes ?? "")
        _transferView.isHidden = true
    }
    
    public func setupData(_ options: BigBusOptionsModel, isSelected: Bool, discount: Int = 0, isCart: Bool = false, slotModel: OctoAvailibilityModel? = nil) {
        _optionsView.isHidden = false
        _type = BOOKINGMANAGER.ticketModel?.bookingType ?? "big-bus"
        _selectedBigBusOptionModel = options
        self._selectedBigbus = slotModel
        if let model = slotModel {
            BOOKINGMANAGER.octoAvailibility = model
        }
        _pickupPointView.isHidden = !options.pickupRequired && !options.pickupAvailable
        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(options.id)" }) {
            _selectedBigBusOptionModel = options
            adult = model.adult
            child = model.child
            infant = model.infant
            _selectedTime.text = model.timeSlot
            let slot = TravelDeskAvailibility()
            slot.startTime = Int(model.startTime) ?? 0
            slot.endTime = Int(model.endTime) ?? 0
            slot.timeSlotId = Int(model.timeSlotId) ?? 0
            _pickupText.text = model.pickup
            _selectedPickup = options.pickupPoints.first(where: { $0.name == model.pickup })
            _selectedTravel?.availability = slot
            if Utils.stringIsNullOrEmpty(model.tourDate) {
                _selectedDate.text = "date_time_placeHolder".localized()
                _SelectDateStackView.isHidden = false
                _timeView.isHidden = true
                _dateView.borderColor = ColorBrand.brandGray
            } else {
                if !Utils.stringIsNullOrEmpty(model.timeSlot) {
                    _timeView.isHidden = false
                    _SelectDateStackView.isHidden = true
                    _selectedTime.text = model.timeSlot
                } else {
                    _timeView.isHidden = true
                    _SelectDateStackView.isHidden = false
                }
                let date = Utils.stringToDate(model.tourDate, format: kStanderdDate)
                if date != nil {
                    _selectedDate.text = Utils.dateToString(date, format: kFormatDate)
                    _selectedDateView.text = Utils.dateToString(date, format: kFormatDate)
                } else {
                    _selectedDate.text = "\(model.tourDate)"
                    _selectedDateView.text = "\(model.tourDate)"
                }
                if let selected = _selectedBigBusOptionModel {
                    BOOKINGMANAGER.addOption(selected, adult: adult, child: child, infant: infant, date: _selectedDate.text ?? "", timeSlot: self._selectedBigbus, optionDetail: BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(selected.id)" }))
                }
                _dateView.borderColor = UIColor(hexString: "#2BA735")
            }
        } else {
            _selectedDate.text = "date_time_placeHolder".localized()
            _SelectDateStackView.isHidden = false
            _timeView.isHidden = true
            _dateView.borderColor = ColorBrand.brandGray
        }
//        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(options.id)" }) {
//            _selectedBigBusOptionModel = options
//            adult = model.adult
//            child = model.child
//            infant = model.infant
//            _selectedTime.text = model.timeSlot
//            let slot = TravelDeskAvailibility()
//            slot.startTime = Int(model.startTime) ?? 0
//            slot.endTime = Int(model.endTime) ?? 0
//            slot.timeSlotId = Int(model.timeSlotId) ?? 0
//            _pickupText.text = model.pickup
//            _selectedPickup = options.pickupPoints.first(where: { $0.name == model.pickup })
//            _selectedTravel?.availability = slot
//            if let option = _selectedBigBusOptionModel {
//                BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: model.tourDate, timeSlot: self._selectedBigbus, optionDetail: BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == option.id }), pickup: _selectedPickup)
//            }
//        }
//        else {
//            adult = 0
//            child = 0
//            infant = 0
//            _selectedTravekDeskOptionModel = nil
//        }
        
        if _selectedTravekDeskOptionModel == nil {
            _selectedBigBusOptionModel = options
        }
        
        var images: String = options.coverImageUrl

        if images.isEmpty {
            images = BOOKINGMANAGER.ticketModel?.bigBusTourData.first?.galleryImages.first?.url ?? ""
        }

        if images.isEmpty {
            images = BOOKINGMANAGER.ticketModel?.bigBusTourData.first?.bannerImageUrl ?? ""
        }
        
        if images.isEmpty {
            images = BOOKINGMANAGER.ticketModel?.bigBusTourData.first?.bannerImages.first?.url ?? ""
        }
        
        if images.isEmpty {
            images = BOOKINGMANAGER.ticketModel?.images.first ?? ""
        }

        _tourImage.loadWebImage(images)
        _tourOptionImage = images

        _tourTitle.text = options.title
        _tourDesc.text = options.shortDescription
        _customAdultView.setupData(BOOKINGMANAGER.ticketModel, options, slot: self._selectedBigbus)

        let originalPrice: Int = options.units.first?.pricingFrom.first?.original ?? 0
        let discountPrice: Int = options.units.first?.pricingFrom.first?.net ?? 0

        _mainView.layer.borderWidth = isSelected ? 1 : 0.5
        _mainView.layer.borderColor = isSelected ? (ColorBrand.tabSelectColor).cgColor : (ColorBrand.brandGray).cgColor
        
        self.isRefundable = BOOKINGMANAGER.ticketModel?.isFreeCancellation == true
        _cancellationPolicy.setTitle(BOOKINGMANAGER.ticketModel?.isFreeCancellation == true ? "cancellation_policy" : "non_refundable".localized())
        _cancellationPolicy.backgroundColor = BOOKINGMANAGER.ticketModel?.isFreeCancellation == true ? ColorBrand.amberColor.withAlphaComponent(0.8) : UIColor(hexString: "#E32A62")
        let min = (options.restrictions?.minPaxCount == 0 ? 0 : options.restrictions?.minPaxCount ?? 0)
        let max = (options.restrictions?.maxPaxCount == 0 ? 1000 : options.restrictions?.maxPaxCount ?? 1000)
        updateNoteText(min: min, max: max, noteTxt: _selectedBigBusOptionModel?.notes ?? "")
        _transferView.isHidden = true
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func _handleDateSelectEvent(_ sender: UIButton) {
        guard (adult + child + infant) > 0 else {
            var unit = Utils.stringIsNullOrEmpty(_selectedTourOptionModel?.unit) ? Utils.stringIsNullOrEmpty(_selectedBigBusOptionModel?.unit) ? _selectedTravekDeskOptionModel?.unit : _selectedBigBusOptionModel?.unit : _selectedTourOptionModel?.unit
            let msg = LANGMANAGER.localizedString(forKey: "min_pax_required_alert", arguments:
                                                        ["value": "\(unit ?? "passenger")"])

            parentBaseController?.alert(message: msg)
            return
        }
        if _selectedBigBusOptionModel?.pickupRequired == true && _selectedBigBusOptionModel?.pickupAvailable == true && _selectedPickup == nil {
            parentBaseController?.alert(message: "pickup_alert".localized())
            return
        }
        let controller = INIT_CONTROLLER_XIB(NewDateTimePickerVC.self)
        controller.allowTodaysBooking = _selectedTourOptionModel?.allowTodaysBooking ?? true
        controller._selectedTourOptionModel = self._selectedTourOptionModel
        controller._selectedTravelOptionModel = self._selectedTravekDeskOptionModel
        controller._selectedBigBusOptionModel = self._selectedBigBusOptionModel
        controller._selectedPickup = self._selectedPickup
        controller.isSlots = self._selectedTourOptionModel?.isSlot == true
        controller.contactCallback = { [weak self] in
            guard let self else { return }
            let vc = INIT_CONTROLLER_XIB(ContactOptionSheet.self)
            vc.openWhosinAdmin = {
                self.openWhosinAdminChat()
            }
            vc.openWhatsappContact = {
                self.openWhatsAppChat()
            }
            DISPATCH_ASYNC_MAIN_AFTER(0.2, closure: {
                if vc is PanModalPresentable {
                    self.parentBaseController?.presentPanModal(vc)
                } else {
                    self.parentBaseController?.presentAsPanModal(controller: vc)
                }
            }) 
        }
        controller.didUpdateCallback = { [weak self] date, time in
            guard let self = self else { return }
            let selected = Utils.dateToStringWithTimezone(date, format: kFormatDateLocal)
            NotificationCenter.default.post(name: .reloadOptions, object: nil, userInfo: ["date": date])
                if let selectedSlot = time as? TourTimeSlotModel {
                    if _selectedTourOptionModel?.isSlot == true {
                        self._timeView.isHidden = false
                        self._SelectDateStackView.isHidden = true
                        self._selectedTime.text = (BOOKINGMANAGER.ticketModel?.bookingType == "whosin" && _selectedTourOptionModel?.availabilityType == "slot") ? selectedSlot.availabilityTime : selectedSlot.timeSlot
                        self._selectedSlot = selectedSlot
                    } else {
                        self._timeView.isHidden = false
                        self._SelectDateStackView.isHidden = true
                        self._selectedTime.text = (BOOKINGMANAGER.ticketModel?.bookingType == "whosin" && _selectedTourOptionModel?.availabilityType == "slot") ? selectedSlot.availabilityTime : selectedSlot.timeSlot
                        self._selectedSlot = selectedSlot
                    }
                    self._selectedDateView.text = "\(Utils.dateToString(Utils.stringToDate(selected, format: kFormatDateLocal), format: kFormatDate)) "
                    self._selectedDate.text = "\(Utils.dateToString(Utils.stringToDate(selected, format: kFormatDateLocal), format: kFormatDate)) "
                    if let option = _selectedTourOptionModel {
                        if self.isAddon {
                            BOOKINGMANAGER.addOrUpdateAddon(parentOptionId: self.parentOptionId, addonModel: option, adult: adult, child: child, infant: infant, timeSlot: selectedSlot)
                        } else {
                            BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: Utils.dateToString(Utils.stringToDate(selected, format: kFormatDateLocal), format: kFormatDate), timeSlot: selectedSlot, pickup: _selectedPickup)
                        }
                        callback?()
                    }
                } else if let model = time as? TravelDeskAvailibilityModel, let selectedSlot = model.availability {
                    self._timeView.isHidden = false
                    self._SelectDateStackView.isHidden = true
                    self._selectedTime.text =  selectedSlot.slotText
                    self._selectedTravel = model
                self._selectedDateView.text = "\(Utils.dateToString(Utils.stringToDate(selected, format: kFormatDateLocal), format: kFormatDate)) "
                self._selectedDate.text = "\(Utils.dateToString(Utils.stringToDate(selected, format: kFormatDateLocal), format: kFormatDate)) "
                if let option = _selectedTravekDeskOptionModel {
                    BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: Utils.dateToString(Utils.stringToDate(selected, format: kFormatDateLocal), format: kFormatDate), timeSlot: self._selectedTravel, optionDetail: BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(option.id)" }))
                    callback?()
                }
            } else if let model = time as? OctoAvailibilityModel {
                self._timeView.isHidden = false
                self._SelectDateStackView.isHidden = true
                self._selectedTime.text =  "\(model.openingHours.first?.from ?? "") - \(model.openingHours.first?.to ?? "")"
                self._selectedBigbus = model
                self._selectedDateView.text = "\(Utils.dateToString(Utils.stringToDate(selected, format: kFormatDateLocal), format: kFormatDate)) "
                self._selectedDate.text = "\(Utils.dateToString(Utils.stringToDate(selected, format: kFormatDateLocal), format: kFormatDate)) "
                if let option = _selectedBigBusOptionModel {
                    BOOKINGMANAGER.octoAvailibility = model
                    _customAdultView.setupData(BOOKINGMANAGER.ticketModel, option, slot: model)
                    BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: Utils.dateToString(Utils.stringToDate(selected, format: kFormatDateLocal), format: kFormatDate), timeSlot: model, optionDetail: BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(option.id)" }), pickup: _selectedPickup, clearAddons: true)
                    callback?()
                }
            }
        }
        parentBaseController?.presentAsPanModal(controller: controller)
    }
    
    @IBAction private func _handleTransferTypeEvent(_ sender: CustomButton) {
        dropDown.dataSource = _optionsGroup.map({ $0.transferName })
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
        dropDown.direction = .bottom
        dropDown.backgroundColor = ColorBrand.cardBgColor
        dropDown.textColor = ColorBrand.white
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            _selectedTourOptionModel = _optionsGroup.first(where: { $0.transferName == item })
            guard (adult + child + infant) > 0 else {
                parentBaseController?.alert(message: "Please select at least one passenger before choosing transfer type.")
                return
            }
            if _selectedTourOptionModel?.isSlot == true {
                _requestTimeSlot { [weak self] timeSlots in
                    guard let self = self else { return }
                    if let option = _selectedTourOptionModel {
                        var originalPrice: Double = 0
                        var discountPrice: Double = 0
                        
                        if adult > 0 {
                            originalPrice += option.withoutDiscountAdultPrice.formatted() * Double(adult)
                            discountPrice += option.adultPrice.formatted() * Double(adult)
                        }
                        
                        if child > 0 {
                            originalPrice += option.withoutDiscountChildPrice.formatted() * Double(child)
                            discountPrice += option.childPrice.formatted() * Double(child)
                        }
                        
                        if infant > 0 {
                            originalPrice += option.withoutDiscountInfantPrice.formatted() * Double(infant)
                            discountPrice += option.infantPrice.formatted() * Double(infant)
                        }
                        
                        let date = self._selectedDate.text == "date_time_placeHolder".localized() ? "" : self._selectedDate.text ?? ""

                        if let model = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(self._selectedTourOptionModel?.tourOptionId ?? 0)" }) {
                            let timeSlot = timeSlots.first(where: { $0.timeSlotId == model.timeSlotId })
                            self._selectedDate.text = self._selectedDate.text
                            self._selectedTime.text = timeSlot?.timeSlot
                            self._selectedDateView.text = model.tourDate
                            self._timeView.isHidden = false
                            self._SelectDateStackView.isHidden = true
                            self._selectedSlot = timeSlot
                            if let option = _selectedTourOptionModel {
                                BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: date, timeSlot: self._selectedSlot)
                            }
                        }
                        else {
                            self._selectedDate.text = "date_time_placeHolder".localized()
                            self._timeView.isHidden = false
                            self._SelectDateStackView.isHidden = true
                            self._selectedSlot = nil
                            if let option = _selectedTourOptionModel {
                                BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: date, timeSlot: self._selectedSlot)
                            }
                        }
                        
                        callback?()
                    }
                }
            } else {
                if let option = _selectedTourOptionModel {
                    var originalPrice: Double = 0
                    var discountPrice: Double = 0
                    
                    if adult > 0 {
                        originalPrice += option.withoutDiscountAdultPrice.formatted() * Double(adult)
                        discountPrice += option.adultPrice.formatted() * Double(adult)
                    }
                    
                    if child > 0 {
                        originalPrice += option.withoutDiscountChildPrice.formatted() * Double(child)
                        discountPrice += option.childPrice.formatted() * Double(child)
                    }
                    
                    if infant > 0 {
                        originalPrice += option.withoutDiscountInfantPrice.formatted() * Double(infant)
                        discountPrice += option.infantPrice.formatted() * Double(infant)
                    }
                    
                    self._timeView.isHidden = false
                    self._SelectDateStackView.isHidden = true
                    let date = self._selectedDate.text == "date_time_placeHolder".localized() ? "" : self._selectedDate.text ?? ""
                    if Utils.stringIsNullOrEmpty(_selectedSlot?.timeSlot) {
                        BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: date, timeSlot: nil)
                    } else {
                        BOOKINGMANAGER.addOption(option, adult: adult, child: child, infant: infant, date: date, timeSlot: _selectedSlot)
                    }
                    callback?()
                }
            }
            self._selectedTransferType.text = item
        }
    }
    
    @IBAction private func _handleMoreInfoSheet(_ sender: CustomButton) {
        let vc = INIT_CONTROLLER_XIB(MoreInfoBottomSheet.self)
        vc.ticketId = BOOKINGMANAGER.ticketModel?._id ?? ""
        vc.optionID = {
            if let tourOptionId = _selectedTourOptionModel?.tourOptionId, tourOptionId != 0 {
                return "\(tourOptionId)"
            } else if let optionId = _selectedTourOptionModel?._id, !Utils.stringIsNullOrEmpty(optionId), BOOKINGMANAGER.ticketModel?.bookingType != "whosin-ticket" {
                return optionId
            } else if let oID = _selectedTourOptionModel?.optionId, !Utils.stringIsNullOrEmpty(oID) {
                return oID
            } else if let opId = _selectedBigBusOptionModel?.id, !Utils.stringIsNullOrEmpty(opId) {
                return opId
            } else {
                return "\(_selectedTravekDeskOptionModel?.id ?? 0)"
            }
        }()
        vc.tourId = BOOKINGMANAGER.ticketModel?.code ?? ""
        vc.travelOptionModel = _selectedTravekDeskOptionModel
        vc.tourOptionModel = _selectedTourOptionModel
        vc.isRefundable = isRefundable
        self.parentBaseController?.presentAsPanModal(controller: vc)
    }
        
    @IBAction func _handlePickupEvent(_ sender: CustomButton) {
        guard let pickupList = _selectedBigBusOptionModel?.pickupPoints.toArray(ofType: PickupListModel.self) else { return }
        let vc = INIT_CONTROLLER_XIB(PickupListVC.self)
        vc.modalPresentationStyle = .pageSheet
        vc.isOctoType = true
        vc.originalPickupList = pickupList
        vc.callback = { [weak self] model in
            guard let self = self else { return }
            self._selectedPickup = model
            self._pickupText.text = model.name
        }
        parentBaseController?.navigationController?.present(vc, animated: true)

    }
    
    @IBAction private func _handleCancellationPolicy(_ sender: Any) {
        if BOOKINGMANAGER.ticketModel?.isFreeCancellation == false { return }
        let vc = INIT_CONTROLLER_XIB(CancellationPolicyBottomSheet.self)
        vc.travelOptionModel = _selectedTravekDeskOptionModel
        vc.tourOptionModel = _selectedTourOptionModel
        parentViewController?.present(vc, animated: true)
    }
    
    @objc func openImagePreview() {
        let vc = INIT_CONTROLLER_XIB(EventGalleryPreviewVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.eventGallery = [_tourOptionImage]
        vc.selectedImage = _tourOptionImage
        parentViewController?.present(vc, animated: true)
    }
    
    @objc private func labelTapped() {
        let vc = INIT_CONTROLLER_XIB(DeclaimerBottomSheet.self)
        vc.disclaimerTitle = "description".localized()
        if _type == "rayna" {
            vc.disclaimerdescriptions = _selectedTourOptionModel?.optionDetail?.optionDescription ?? kEmptyString
        } else if _type == "whosin" {
            vc.disclaimerdescriptions = _selectedTourOptionModel?.descriptions ?? ""
        } else if _type == "travel-desk" {
            vc.disclaimerdescriptions = _selectedTravekDeskOptionModel?.descriptionText ?? ""
        } else if _type == "big-bus" || _type == "hero-balloon" {
            vc.disclaimerdescriptions = _selectedBigBusOptionModel?.shortDescription ?? ""
        }
        parentBaseController?.presentAsPanModal(controller: vc)
    }
    
    private func openWhosinAdminChat() {
            guard let parentVC = parentBaseController else { return }
            guard let userDetail = APPSESSION.userDetail else { return }
            let chatModel = ChatModel()
            chatModel.image = "https://whosin-bucket.nyc3.digitaloceanspaces.com/file/1721896083557_image-1721896083557.jpg"
            chatModel.title = "Whosin Admin"
            chatModel.members.append(kLiveAdminId)
            chatModel.members.append(userDetail.id)
            let chatIds = [kLiveAdminId, userDetail.id].sorted()
            chatModel.chatId = chatIds.joined(separator: ",")
            chatModel.chatType = "friend"
            DISPATCH_ASYNC_MAIN_AFTER(0.01) {
                let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
                vc.chatModel = chatModel
                vc.hidesBottomBarWhenPushed = true
    //            Utils.openViewController(vc)
                parentVC.navigationController?.pushViewController(vc, animated: true)
            }
        }
    
    private func openWhatsAppChat() {
            let phoneNumber = "971554373163"
            let message = "Hello, I need a customized itinerary!"
            let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

            if let appURL = URL(string: "whatsapp://send?phone=\(phoneNumber)&text=\(encodedMessage)"),
               UIApplication.shared.canOpenURL(appURL) {
                UIApplication.shared.open(appURL, options: [:])
                return
            }

            if let webURL = URL(string: "https://wa.me/\(phoneNumber)?text=\(encodedMessage)") {
                UIApplication.shared.open(webURL, options: [:])
            }
        }
}

extension AddOnOptionsTableCell: ExpandableLabelDelegate {
    
    func willExpandLabel(_ label: ExpandableLabel) {
        labelTapped()
        label.collapsed = false
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
    }
}
