import UIKit

let BOOKINGMANAGER = OnboardingTicketBookingManager.shared

class OnboardingTicketBookingManager: NSObject {
    
    var ticketModel: TicketModel?
    var bookingModel = BookingModel()
    lazy var optionsList: [TourOptionsModel] = []
    var whosinOptionsList: [TourOptionsModel] = []
    var onItemChange: (() -> Void)?
    var adults: Int = 0
    var childs: Int = 0
    var infants: Int = 0
    var date: Date?
    var endDate: Date?
    var octoAvailibility: OctoAvailibilityModel?
    
    static let shared = OnboardingTicketBookingManager()
    
    public func clearManager() {
        ticketModel = nil
        octoAvailibility = nil
        bookingModel = BookingModel()
        whosinOptionsList.removeAll()
        optionsList.removeAll()
    }
    
    public func initializeGuestList() {
        
        let guestTypes = [
            (count: 1, type: "Adult"),
            (count: 0, type: "Child"),
            (count: 0, type: "Infant")
        ]
        
        bookingModel.passengers.removeAll()
        var passengerIndex = 0
        
        guestTypes.forEach { guest in
            (0..<guest.count).forEach { _ in
                let passenger = PassengersModel()
                passenger.leadPassenger = passengerIndex == 0 ? 1 : 0
                passenger.paxType = guest.type
                bookingModel.passengers.append(passenger)
                passengerIndex += 1
            }
        }
    }
    
    public func validateMembers() -> String? {
        
        if bookingModel.passengers.contains(where: { $0.paxType.isEmpty }) {
            return "pax_type_required".localized()
        }
        
        guard let primaryHolder = bookingModel.passengers.first else {
            return "primary_member_not_found".localized()
        }
        
        if Utils.stringIsNullOrEmpty(primaryHolder.firstName) {
            return "enter_primary_guest_first_name".localized()
        }
        
        if Utils.stringIsNullOrEmpty(primaryHolder.lastName) {
            return "enter_primary_guest_last_name".localized()
        }
        
        if !Utils.isEmail(emailString: primaryHolder.email) {
            return "enter_primary_guest_email".localized()
        }
        
        if primaryHolder.mobile.isEmpty {
            return "enter_primary_guest_phone".localized()
        }
        
        if primaryHolder.countryCode.isEmpty {
            return "select_primary_guest_country_code".localized()
        }
        
        if !Utils.isValidNumber(primaryHolder.mobile, Utils.getCountryCode(for: primaryHolder.countryCode) ?? "AE") {
            return "invalid_phone".localized()
        }
        
        if primaryHolder.nationality.isEmpty {
            return "please_select_nationality".localized()
        }
        
        if primaryHolder.paxType.isEmpty {
            return "please_select_primary_member_pax_type".localized()
        }
        
        for option in bookingModel.tourDetails {
            
            let transfer = optionsList.first { matchesOption($0, optionId: option.optionId, transferId: option.transferId) }
            if transfer?.transferName == "Private Transfers" || transfer?.transferName == "Sharing Transfers" {
                if option.pickup.isEmpty {
                    return LANGMANAGER.localizedString(forKey: "please_enter_pickup_address", arguments: ["value": transfer?.optionDetail?.optionName ?? ""])
                }
            }
            if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
                let travelModel = BOOKINGMANAGER.ticketModel?.travelDeskTourData.first?.optionData.first(where: { "\($0.id)" == option.optionId})
                if option.pickup.isEmpty, travelModel?.isDirectReporting == false {
                    return "please_select_pickup_location".localized()
                }
            }
            if transfer?.optionDetail?.isWithoutAdult == false {
                if primaryHolder.paxType != "Adult" {
                    return "primary_guest_should_be_adult".localized()
                }
            }
            
            if option.adult > 0  && primaryHolder.paxType != "Adult" {
                return "primary_guest_should_be_adult".localized()
            }
            
        }
        
        bookingModel.passengers.forEach { passenger in
            if passenger.email.isEmpty {
                passenger.email = primaryHolder.email
            }
            if passenger.mobile.isEmpty {
                passenger.mobile = primaryHolder.mobile
            }
            if passenger.nationality.isEmpty {
                passenger.nationality = primaryHolder.nationality
            }
        }
        return nil
    }
    
    public func matchesOption(_ item: TourOptionsModel, optionId: String, transferId: Int) -> Bool {
        String(item.tourOptionId) == optionId &&
        item.transferId == transferId
    }
    
    @discardableResult
    public func addOption(_ model: Any, adult: Int, child: Int, infant: Int, date: String, timeSlot: Any? = nil, optionDetail: TourOptionDetailModel? = nil, pickup: PickupListModel? = nil, clearAddons: Bool = false) {
        let bookingType = ticketModel?.bookingType ?? ""
        let data = TourOptionDetailModel()
        data.adult = adult
        data.child = child
        data.infant = infant
        data.tourDate = date
        
        if bookingType == "travel-desk", let travelModel = model as? TourOptionModel {
            let slotModel = timeSlot as? TravelDeskAvailibilityModel
            let optionId = "\(travelModel.id)"
            let existingAddons = clearAddons ? [] : (bookingModel.tourDetails.first(where: { $0.optionId == optionId })?.Addons ?? [])
            var pricing: TourPricingPeriodModel?
            bookingModel.tourDetails.removeAll { $0.optionId == optionId }
            if let slotModel = slotModel {
                pricing = slotModel.price
            } else {
                pricing = travelModel.pricingPeriods.first
            }
            guard let pricing = pricing else {
                return
            }
            
            if let detail = optionDetail {
                data.pickup = detail.pickup
                data.hotelId = detail.hotelId
            }
            
            let adultRate = pricing.pricePerAdult.formatted()
            let childRate = pricing.pricePerChild.formatted()
            let infantRate = pricing.pricePerInfant.formatted()
            let pricePerTrip = pricing.pricePerTrip
            let adultTravelRate = pricing.pricePerAdultTravelDesk
            let childTravelRate = pricing.pricePerChildTravelDesk
            let infantTravelRate = pricing.pricePerInfant
            let pricePerTravelTrip = pricing.pricePerTripTravelDesk
            
            let total = (adultRate * Double(adult)) +
            (childRate * Double(child)) +
            (infantRate * Double(infant))
            
            let travelTotal = (adultTravelRate * Double(adult)) +
            (childTravelRate * Double(child)) +
            (infantTravelRate * Double(infant))
            
            
            data.tourId = "\(travelModel.tourId)"
            data.optionId = optionId
            data.transferId = 0
            data.startTime = "\(slotModel?.availability?.startTime ?? 0)"
            data.endTime = "\(slotModel?.availability?.endTime ?? 0)"
            data.adultRate = adult == 0 ? 0 : pricing.pricePerAdult.formatted()
            data.childRate = child == 0 ? 0 : pricing.pricePerChild.formatted()
            data.serviceTotal = travelTotal + pricePerTravelTrip
            data.timeSlotId = "\(slotModel?.availability?.timeSlotId ?? 0)"
            data.timeSlot = slotModel?.availability?.slotText ?? ""
            data.whosinTotal = Utils.convertToAED(price: total + pricePerTrip).roundedValue()
            data.adultTitle = Utils.stringIsNullOrEmpty(travelModel.adultTitle) ? "Adult" : travelModel.adultTitle
            data.childTitle = Utils.stringIsNullOrEmpty(travelModel.childTitle) ? "Child" : travelModel.childTitle
            data.infantTitle = Utils.stringIsNullOrEmpty(travelModel.infantTitle) ? "Infant" : travelModel.infantTitle
            data.Addons = existingAddons
            
            
        }
        else if bookingType == "rayna", let raynaModel = model as? TourOptionsModel {
            let slotModel = timeSlot as? TourTimeSlotModel
            let optionId = "\(raynaModel.tourOptionId)"
            let existingAddons = clearAddons ? [] : (bookingModel.tourDetails.first(where: { $0.optionId == optionId })?.Addons ?? [])
            bookingModel.tourDetails.removeAll { $0.optionId == optionId }
            
            let adultPrice = raynaModel.adultPriceRayna * Double(adult)
            let childPrice = raynaModel.childPriceRayna * Double(child)
            let infantPrice = raynaModel.infantPrice * Double(infant)
            let total = adultPrice + childPrice + infantPrice
            
            data.tourId = "\(raynaModel.tourId)"
            data.optionId = "\(raynaModel.tourOptionId)"
            data.transferId = raynaModel.transferId
            data.startTime = raynaModel.startTime
            data.adultRate = adult == 0 ? 0 : raynaModel.adultPriceRayna.formatted()
            data.childRate = child == 0 ? 0 : raynaModel.childPriceRayna.formatted()
            data.serviceTotal = Utils.convertToAED(price:total)
            data.departureTime = raynaModel.departureTime
            data.timeSlotId = raynaModel.isSlot ? (slotModel?.timeSlotId ?? "") : "0"
            data.timeSlot = slotModel?.timeSlot ?? ""
            
            let whosinTotal = (raynaModel.adultPrice.formatted() * Double(adult)) +
            (raynaModel.childPrice.formatted() * Double(child)) +
            (raynaModel.infantPrice.formatted() * Double(infant))
            data.whosinTotal = Utils.convertToAED(price:whosinTotal).roundedValue()
            data.adultTitle = Utils.stringIsNullOrEmpty(raynaModel.adultTitle) ? "Adult" : raynaModel.adultTitle
            data.childTitle = Utils.stringIsNullOrEmpty(raynaModel.childTitle) ? "Child" : raynaModel.childTitle
            data.infantTitle = Utils.stringIsNullOrEmpty(raynaModel.infantTitle) ? "Infant" : raynaModel.infantTitle
            data.Addons = existingAddons
            
            
        }
        else if bookingType == "whosin", let whosinModel = model as? TourOptionsModel {
            let slotModel = timeSlot as? TourTimeSlotModel
            let optionId = whosinModel._id
            let existingAddons = clearAddons ? [] :bookingModel.tourDetails.first(where: { $0.optionId == optionId })?.Addons ?? []
            bookingModel.tourDetails.removeAll { $0.optionId == optionId }
            
            let adultPrice = whosinModel.withoutDiscountAdultPrice * Double(adult)
            let childPrice = whosinModel.withoutDiscountChildPrice * Double(child)
            let infantPrice = whosinModel.withoutDiscountInfantPrice * Double(infant)
            let total = adultPrice + childPrice + infantPrice
            
            let whosinTotal = (whosinModel.adultPrice.formatted() * Double(adult)) +
            (whosinModel.childPrice.formatted() * Double(child)) +
            (whosinModel.infantPrice.formatted() * Double(infant))
            
            data.tourId = whosinModel.customTicketId
            data.optionId = optionId
            data.transferId = 0
            data.startTime = whosinModel.availabilityTime
            data.adultRate = adult == 0 ? 0 : whosinModel.withoutDiscountAdultPrice.formatted()
            data.childRate = child == 0 ? 0 : whosinModel.withoutDiscountChildPrice.formatted()
            data.serviceTotal = Utils.convertToAED(price:total)
            data.timeSlotId = slotModel?.id ?? "0"
            data.timeSlot = Utils.stringIsNullOrEmpty(slotModel?.availabilityTime) ? whosinModel.availabilityTime : slotModel?.availabilityTime ?? ""
            data.whosinTotal = Utils.convertToAED(price:whosinTotal).roundedValue()
            data.adultTitle = Utils.stringIsNullOrEmpty(whosinModel.adultTitle) ? "adult".localized() : whosinModel.adultTitle
            data.childTitle = Utils.stringIsNullOrEmpty(whosinModel.childTitle) ? "childTitle".localized() : whosinModel.childTitle
            data.infantTitle = Utils.stringIsNullOrEmpty(whosinModel.infantTitle) ? "infant_title".localized() : whosinModel.infantTitle
            data.Addons = existingAddons
            
        }
        else if bookingType == "whosin-ticket", let whosinModel = model as? TourOptionsModel {
            let slotModel = timeSlot as? TourTimeSlotModel
            let optionId = whosinModel.optionId
            let existingAddons = clearAddons ? [] : bookingModel.tourDetails.first(where: { $0.optionId == optionId })?.Addons ?? []
            bookingModel.tourDetails.removeAll { $0.optionId == optionId }
            
            let adultPrice = whosinModel.withoutDiscountAdultPrice * Double(adult)
            let childPrice = whosinModel.withoutDiscountChildPrice * Double(child)
            let infantPrice = whosinModel.withoutDiscountInfantPrice * Double(infant)
            let total = adultPrice + childPrice + infantPrice
            
            let whosinTotal = (whosinModel.adultPrice.formatted() * Double(adult)) +
            (whosinModel.childPrice.formatted() * Double(child)) +
            (whosinModel.infantPrice.formatted() * Double(infant))
            
            data.tourId = whosinModel.tourIdString
            data.optionId = optionId
            data.transferId = 0
            data.startTime = slotModel?.timeSlot ?? ""
            data.adultRate = adult == 0 ? 0 : whosinModel.adultPrice.formatted()
            data.childRate = child == 0 ? 0 : whosinModel.childPrice.formatted()
            data.serviceTotal = Utils.convertToAED(price:total).formatted()
            data.timeSlotId = slotModel?.slotId ?? "0"
            data.timeSlot = slotModel?.timeSlot ?? ""
            data.whosinTotal = Utils.convertToAED(price:whosinTotal).roundedValue()
            data.adultTitle = Utils.stringIsNullOrEmpty(whosinModel.adultTitle) ? "Adult" : whosinModel.adultTitle
            data.childTitle = Utils.stringIsNullOrEmpty(whosinModel.childTitle) ? "Child" : whosinModel.childTitle
            data.infantTitle = Utils.stringIsNullOrEmpty(whosinModel.infantTitle) ? "Infant" : whosinModel.infantTitle
            data.Addons = existingAddons
            
            
        }
        else if bookingType == "big-bus" || bookingType == "hero-balloon",let bigbusOption = model as? BigBusOptionsModel {
            
            let slotModel = timeSlot as? OctoAvailibilityModel
            let optionId = bigbusOption.id
            let existingAddons = clearAddons ? [] : (bookingModel.tourDetails.first(where: { $0.optionId == optionId })?.Addons ?? [])
            var total: Double = 0
            var whosinTotal: Double = 0
            let units = bigbusOption.units.toArray(ofType: BigBusUnitModel.self)
            let adultUnit  = units.first { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "adult" }
            let childUnit  = units.first { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "child" }
            let infantUnit = units.first { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "infant" }
            bookingModel.tourDetails.removeAll { $0.optionId == optionId }
            if let slotModel = slotModel {
                let units = slotModel.unitPricing.toArrayDetached(ofType: PricingModel.self)
                let adultUnit  = units.first { $0.unitType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "adult" }
                let childUnit  = units.first { $0.unitType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "child" }
                let infantUnit = units.first { $0.unitType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "infant" }
                let adultPrice  = (adultUnit?.adjustedNetWithoutDiscount ?? 0) * Double(adult)
                let childPrice  = (childUnit?.adjustedNetWithoutDiscount ?? 0) * Double(child)
                let infantPrice = (infantUnit?.adjustedNetWithoutDiscount ?? 0) * Double(infant)
                total = adultPrice + childPrice + infantPrice
                let adultNetPrice = (adultUnit?.adjustedNet ?? 0) * Double(adult)
                let childNetPrice = (childUnit?.adjustedNet ?? 0) * Double(child)
                let infantNetPrice = (infantUnit?.adjustedNet ?? 0) * Double(infant)

                whosinTotal = adultNetPrice + childNetPrice + infantNetPrice
                data.adultRate    = adult == 0 ? 0 : Double(adultNetPrice)
                data.childRate    = child == 0 ? 0 : Double(childNetPrice)

            } else {
                let adultUnit  = units.first { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "adult" }
                let childUnit  = units.first { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "child" }
                let infantUnit = units.first { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "infant" }
                let adultPrice  = (adultUnit?.pricingFrom.first?.withoutDiscountNet ?? 0) * adult
                let childPrice  = (childUnit?.pricingFrom.first?.withoutDiscountNet ?? 0) * child
                let infantPrice = (infantUnit?.pricingFrom.first?.withoutDiscountNet ?? 0) * infant
                total = Double(adultPrice + childPrice + infantPrice)
                let adultNetPrice = (adultUnit?.pricingFrom.first?.net ?? 0) * adult
                let childNetPrice = (childUnit?.pricingFrom.first?.net ?? 0) * child
                let infantNetPrice = (infantUnit?.pricingFrom.first?.net ?? 0) * infant

                whosinTotal = Double(adultNetPrice + childNetPrice + infantNetPrice)
                data.adultRate    = adult == 0 ? 0 : Double(adultNetPrice)
                data.childRate    = child == 0 ? 0 : Double(childNetPrice)

            }
            
            let startTime = slotModel?.openingHours.first?.from ?? ""
            let slot = "\(slotModel?.openingHours.first?.from ?? "") - \(slotModel?.openingHours.first?.to ?? "")"
            let tourDate = slotModel?.id ?? ""
            
            data.tourDate = tourDate
            data.adultId = adult == 0 ? "" : adultUnit?.id ?? ""
            data.childId = child == 0 ? "" : childUnit?.id ?? ""
            data.infantId = infant == 0 ? "" :  infantUnit?.id ?? ""
            data.tourId       = BOOKINGMANAGER.ticketModel?.code ?? ""
            data.optionId     = optionId
            data.startTime    = startTime
            data.serviceTotal = Utils.convertToAED(price: Double(total))
            data.timeSlotId   = "0"
            data.timeSlot     = slot
            data.pickup = pickup?.name ?? ""
            data.whosinTotal  = Utils.convertToAED(price: Double(whosinTotal)).roundedValue()
            data.adultTitle = Utils.stringIsNullOrEmpty(bigbusOption.adultTitle) ? "Adult" : bigbusOption.adultTitle
            data.childTitle = Utils.stringIsNullOrEmpty(bigbusOption.childTitle) ? "Child" : bigbusOption.childTitle
            data.infantTitle = Utils.stringIsNullOrEmpty(bigbusOption.infantTitle) ? "Infant" : bigbusOption.infantTitle
            data.Addons = existingAddons
        }
        
        
        bookingModel.tourDetails.append(data)
        onItemChange?()
    }
    
    @discardableResult
    public func removeOption(_ model: Any) {
        guard let bookingType = ticketModel?.bookingType else { return }
        let optionIdToRemove: String
        
        switch bookingType {
        case "rayna":
            guard let raynaModel = model as? TourOptionsModel else { return }
            optionIdToRemove = String(raynaModel.tourOptionId)
            
        case "whosin":
            guard let whosinModel = model as? TourOptionsModel else { return }
            optionIdToRemove = whosinModel._id
            
        case "travel-desk":
            guard let travelModel = model as? TourOptionModel else { return }
            optionIdToRemove = "\(travelModel.id)"
            
        case "big-bus", "hero-balloon":
            guard let octoModel = model as? BigBusOptionsModel else { return }
            optionIdToRemove = "\(octoModel.id)"
        default:
            print("Unknown booking type: \(bookingType)")
            return
        }
        
        bookingModel.tourDetails.removeAll { $0.optionId == optionIdToRemove }
        onItemChange?()
    }

    public func addOrUpdateAddon(parentOptionId: String, addonModel: TourOptionsModel, adult: Int, child: Int, infant: Int, timeSlot: TourTimeSlotModel?) {
        guard let parent = bookingModel.tourDetails.first(where: { $0.optionId == parentOptionId }) else { return }
        
        let bookingType = ticketModel?.bookingType ?? "rayna"
        
        if adult == 0 && child == 0 && infant == 0 {
            let optionIdToRemove: String
            if bookingType == "rayna" {
                optionIdToRemove = "\(addonModel.tourOptionId)"
            } else if bookingType == "whosin" {
                optionIdToRemove = addonModel._id
            } else if bookingType == "whosin-ticket" {
                optionIdToRemove = addonModel.optionId
            } else {
                return
            }
            parent.Addons.removeAll { $0.optionId == optionIdToRemove }
            onItemChange?()
            return
        }

        let data = TourOptionDetailModel()
        data.optionId = addonModel._id
        
        data.adult = adult
        data.child = child
        data.infant = infant
        data.tourDate = parent.tourDate
        
        if bookingType == "rayna" {
            let tourId = parent.tourId
            let addonOptionId = String(addonModel.tourOptionId)
            parent.Addons.removeAll { $0.optionId == addonOptionId }
            
            let adultPrice = addonModel.adultPriceRayna * Double(adult)
            let childPrice = addonModel.childPriceRayna * Double(child)
            let infantPrice = addonModel.infantPrice * Double(infant)
            let total = adultPrice + childPrice + infantPrice
            
            data.addOnTitle = addonModel.title
            data.addOndesc = addonModel.sortDescription
            data.addOnImage = addonModel.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) }).first ?? kEmptyString
            data.tourId = tourId
            data.optionId = addonOptionId
            data.transferId = addonModel.transferId
            data.startTime = addonModel.startTime
            data.adultRate = adult == 0 ? 0 : addonModel.withoutDiscountAdultPrice.formatted()
            data.childRate = child == 0 ? 0 : addonModel.withoutDiscountChildPrice.formatted()
            data.serviceTotal = Utils.convertToAED(price: total)
            data.departureTime = addonModel.departureTime
            data.timeSlotId = timeSlot?.timeSlotId ?? "0"
            data.timeSlot = timeSlot?.timeSlot ?? ""
            data.startTime = timeSlot?.timeSlot ?? ""
            let whosinTotal = (addonModel.adultPrice.formatted() * Double(adult)) +
            (addonModel.childPrice.formatted() * Double(child)) +
            (addonModel.infantPrice.formatted() * Double(infant))
            data.whosinTotal = Utils.convertToAED(price: whosinTotal).roundedValue()
            data.adultTitle = Utils.stringIsNullOrEmpty(addonModel.adultTitle) ? "Adult" : addonModel.adultTitle
            data.childTitle = Utils.stringIsNullOrEmpty(addonModel.childTitle) ? "Child" : addonModel.childTitle
            data.infantTitle = Utils.stringIsNullOrEmpty(addonModel.infantTitle) ? "Infant" : addonModel.infantTitle
            
            parent.Addons.append(data)
            
        } else if bookingType == "whosin" {
            let optionId = addonModel._id
            parent.Addons.removeAll { $0.optionId == optionId }
            
            let adultPrice = addonModel.withoutDiscountAdultPrice * Double(adult)
            let childPrice = addonModel.withoutDiscountChildPrice * Double(child)
            let infantPrice = addonModel.withoutDiscountInfantPrice * Double(infant)
            let total = adultPrice + childPrice + infantPrice
            
            let whosinTotal = (addonModel.adultPrice.formatted() * Double(adult)) +
            (addonModel.childPrice.formatted() * Double(child)) +
            (addonModel.infantPrice.formatted() * Double(infant))
            data.addOnTitle = addonModel.title
            data.addOndesc = addonModel.sortDescription
            data.addOnImage = addonModel.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) }).first ?? kEmptyString
            data.tourId = parent.tourId
            data.optionId = optionId
            data.transferId = 0
            data.startTime = addonModel.availabilityTime
            data.adultRate = adult == 0 ? 0 : addonModel.withoutDiscountAdultPrice.formatted()
            data.childRate = child == 0 ? 0 : addonModel.withoutDiscountChildPrice.formatted()
            data.serviceTotal = total
            data.timeSlotId = timeSlot?.id ?? "0"
            data.timeSlot = timeSlot?.availabilityTime ?? ""
            data.startTime = timeSlot?.availabilityTime ?? ""
            data.whosinTotal = whosinTotal
            data.adultTitle = Utils.stringIsNullOrEmpty(addonModel.adultTitle) ? "adult".localized() : addonModel.adultTitle
            data.childTitle = Utils.stringIsNullOrEmpty(addonModel.childTitle) ? "childTitle".localized() : addonModel.childTitle
            data.infantTitle = Utils.stringIsNullOrEmpty(addonModel.infantTitle) ? "infant_title".localized() : addonModel.infantTitle
            
            parent.Addons.append(data)
        } else if bookingType == "whosin-ticket" {
            let optionId = addonModel.optionId
            parent.Addons.removeAll { $0.optionId == optionId }
            
            let adultPrice = addonModel.withoutDiscountAdultPrice * Double(adult)
            let childPrice = addonModel.withoutDiscountChildPrice * Double(child)
            let infantPrice = addonModel.withoutDiscountInfantPrice * Double(infant)
            let total = adultPrice + childPrice + infantPrice
            
            let whosinTotal = (addonModel.adultPrice.formatted() * Double(adult)) +
            (addonModel.childPrice.formatted() * Double(child)) +
            (addonModel.infantPrice.formatted() * Double(infant))
            data.addOnTitle = addonModel.title
            data.addOndesc = addonModel.sortDescription
            data.addOnImage = addonModel.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) }).first ?? kEmptyString
            
            data.tourId = addonModel.tourIdString
            data.optionId = optionId
            data.transferId = 0
            data.startTime = timeSlot?.timeSlot ?? ""
            data.adultRate = adult == 0 ? 0 : addonModel.adultPrice.formatted()
            data.childRate = child == 0 ? 0 : addonModel.childPrice.formatted()
            data.serviceTotal = Utils.convertToAED(price: total).formatted()
            data.timeSlotId = timeSlot?.id ?? "0"
            data.timeSlot = timeSlot?.availabilityTime ?? ""
            data.startTime = timeSlot?.availabilityTime ?? ""
            data.whosinTotal = Utils.convertToAED(price: whosinTotal).roundedValue()
            data.adultTitle = Utils.stringIsNullOrEmpty(addonModel.adultTitle) ? "Adult" : addonModel.adultTitle
            data.childTitle = Utils.stringIsNullOrEmpty(addonModel.childTitle) ? "Child" : addonModel.childTitle
            data.infantTitle = Utils.stringIsNullOrEmpty(addonModel.infantTitle) ? "Infant" : addonModel.infantTitle
            
            parent.Addons.append(data)
        }
        
        onItemChange?()
    }
    
    public func calculateTourTotals(promo: PromoBaseModel?) -> TourPriceSummary {
        var totalAdultPrice: Double = 0
        var totalChildPrice: Double = 0
        var totalInfantPrice: Double = 0
        var totalAdultAmount: Double = 0
        var totalChildAmount: Double = 0
        var totalInfantAmount: Double = 0
        var totalAmount: Double = 0
        var priceToPay: Double = 0
        var pricePerTrip: Double = 0
        var pricePerTripWithoutdiscount: Double = 0
        var totalAddonPrice: Double = 0
        var totalAddonAmount: Double = 0
        
        for data in BOOKINGMANAGER.bookingModel.tourDetails {
            if let option = BOOKINGMANAGER.optionsList.first(where: { matchesOption($0, optionId: data.optionId, transferId: data.transferId) }) {
                
                let adultPrice = option.withoutDiscountAdultPrice.formatted() * Double(data.adult)
                let childPrice = option.withoutDiscountChildPrice.formatted() * Double(data.child)
                let infantPrice = option.withoutDiscountInfantPrice.formatted() * Double(data.infant)
                
                let adultTotal = option.adultPrice.formatted() * Double(data.adult)
                let childTotal = option.childPrice.formatted() * Double(data.child)
                let infantTotal = option.infantPrice.formatted() * Double(data.infant)
                
                totalAdultPrice += adultPrice
                totalChildPrice += childPrice
                totalInfantPrice += infantPrice
                totalAdultAmount += adultTotal
                totalChildAmount += childTotal
                totalInfantAmount += infantTotal
            }
            else if let model = BOOKINGMANAGER.ticketModel?.optionData.first(where: { $0._id == data.optionId }) {
                
                let adultPrice = model.withoutDiscountAdultPrice.formatted() * Double(data.adult)
                let childPrice = model.withoutDiscountChildPrice.formatted() * Double(data.child)
                let infantPrice = model.withoutDiscountInfantPrice.formatted() * Double(data.infant)
                
                let adultTotal = model.adultPrice.formatted() * Double(data.adult)
                let childTotal = model.childPrice.formatted() * Double(data.child)
                let infantTotal = model.infantPrice.formatted() * Double(data.infant)
                
                totalAdultPrice += adultPrice
                totalChildPrice += childPrice
                totalInfantPrice += infantPrice
                totalAdultAmount += adultTotal
                totalChildAmount += childTotal
                totalInfantAmount += infantTotal
            }
            else if let model = BOOKINGMANAGER.ticketModel?.whosinModuleTourData.first?.optionData.first(where: { $0.optionId == data.optionId }) {
                
                let adultPrice = model.withoutDiscountAdultPrice.formatted() * Double(data.adult)
                let childPrice = model.withoutDiscountChildPrice.formatted() * Double(data.child)
                let infantPrice = model.withoutDiscountInfantPrice.formatted() * Double(data.infant)
                
                let adultTotal = model.adultPrice.formatted() * Double(data.adult)
                let childTotal = model.childPrice.formatted() * Double(data.child)
                let infantTotal = model.infantPrice.formatted() * Double(data.infant)
                
                totalAdultPrice += adultPrice
                totalChildPrice += childPrice
                totalInfantPrice += infantPrice
                totalAdultAmount += adultTotal
                totalChildAmount += childTotal
                totalInfantAmount += infantTotal
            }
            else if let model = BOOKINGMANAGER.ticketModel?.travelDeskTourData.first?.optionData.first(where: { "\($0.id)" == data.optionId}) {
                
                let adultPrice = (model.pricingPeriods.first?.pricePerAdultBeforeDiscount.formatted() ?? 0) * Double(data.adult)
                let childPrice = (model.pricingPeriods.first?.pricePerChildBeforeDiscount.formatted() ?? 0) * Double(data.child)
                let infantPrice = (model.pricingPeriods.first?.pricePerInfantBeforeDiscount.formatted() ?? 0) * Double(data.infant)
                
                let adultTotal = (model.pricingPeriods.first?.pricePerAdult.formatted() ?? 0) * Double(data.adult)
                let childTotal = (model.pricingPeriods.first?.pricePerChild.formatted() ?? 0) * Double(data.child)
                let infantTotal = (model.pricingPeriods.first?.pricePerInfant.formatted() ?? 0) * Double(data.infant)
                
                pricePerTrip += model.pricingPeriods.first?.pricePerTrip ?? 0
                pricePerTripWithoutdiscount += model.pricingPeriods.first?.pricePerTripBeforeDiscount ?? 0
                totalAdultPrice += adultPrice
                totalChildPrice += childPrice
                totalInfantPrice += infantPrice
                totalAdultAmount += adultTotal
                totalChildAmount += childTotal
                totalInfantAmount += infantTotal
            }
            else if let model = BOOKINGMANAGER.ticketModel?.bigBusTourData.first?.options.first(where: { $0.id == data.optionId}) {
                if let slotModel = BOOKINGMANAGER.octoAvailibility {
                    let units = slotModel.unitPricing.toArrayDetached(ofType: PricingModel.self)
                    let adultUnit  = units.first { $0.unitType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "adult" }
                    let childUnit  = units.first { $0.unitType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "child" }
                    let infantUnit = units.first { $0.unitType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "infant" }
                    
                    let adultPrice = (adultUnit?.adjustedNetWithoutDiscount ?? 0) * Double(data.adult)
                    let childPrice = (childUnit?.adjustedNetWithoutDiscount ?? 0) * Double(data.child)
                    let infantPrice = (infantUnit?.adjustedNetWithoutDiscount ?? 0) * Double(data.infant)
                    
                    let adultTotal = (adultUnit?.adjustedNet.roundedValue() ?? 0) * Double(data.adult)
                    let childTotal = (childUnit?.adjustedNet.roundedValue() ?? 0) * Double(data.child)
                    let infantTotal = (infantUnit?.adjustedNet.roundedValue() ?? 0) * Double(data.infant)
                    
                    totalAdultPrice += Double(adultPrice).roundedValue()
                    totalChildPrice += Double(childPrice).roundedValue()
                    totalInfantPrice += Double(infantPrice).roundedValue()
                    totalAdultAmount += Double(adultTotal).roundedValue()
                    totalChildAmount += Double(childTotal).roundedValue()
                    totalInfantAmount += Double(infantTotal).roundedValue()

                } else {
                    let units = model.units.toArray(ofType: BigBusUnitModel.self)
                    let adultUnit  = units.first { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "adult" }
                    let childUnit  = units.first { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "child" }
                    let infantUnit = units.first { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "infant" }
                    
                    let adultPrice  = (adultUnit?.pricingFrom.first?.withoutDiscountNet ?? 0) * data.adult
                    let childPrice  = (childUnit?.pricingFrom.first?.withoutDiscountNet ?? 0) * data.child
                    let infantPrice = (infantUnit?.pricingFrom.first?.withoutDiscountNet ?? 0) * data.infant
                    
                    let adultTotal = (adultUnit?.pricingFrom.first?.net ?? 0) * data.adult
                    let childTotal = (childUnit?.pricingFrom.first?.net ?? 0) * data.child
                    let infantTotal = (infantUnit?.pricingFrom.first?.net ?? 0) * data.infant
                    
                    totalAdultPrice += Double(adultPrice)
                    totalChildPrice += Double(childPrice)
                    totalInfantPrice += Double(infantPrice)
                    totalAdultAmount += Double(adultTotal)
                    totalChildAmount += Double(childTotal)
                    totalInfantAmount += Double(infantTotal)
                }
            }
            
            for addon in data.Addons {
                totalAddonPrice += addon.serviceTotal
                totalAddonAmount += addon.whosinTotal
            }
        }
        
        totalAmount = totalAdultPrice + totalChildPrice + totalInfantPrice + pricePerTripWithoutdiscount + totalAddonPrice
        priceToPay = totalAdultAmount + totalChildAmount + totalInfantAmount + pricePerTrip + totalAddonAmount
        
        let discountPrice: Double = {
            if let promo = promo {
                return promo.itemsDiscount.formatted()
            } else {
                return totalAmount - priceToPay
            }
        }()
        
        let priceWithPromo: Double = {
            if let promo = promo {
                return promo.metadata.first?.finalAmount.formatted() ?? priceToPay
            } else {
                return priceToPay
            }
        }()
        
        return TourPriceSummary(
            totalAmount: totalAmount,
            priceToPay: priceToPay,
            discountPrice: discountPrice < 0 ? 0 : discountPrice,
            priceWithPromo: priceWithPromo,
            pricePerTrip: pricePerTrip,
            totalAddOnAmout: totalAddonAmount
        )
    }
    
    public func getTotalAmount(for optionId: String? = nil) -> Double {
        var totalAmount = 0.0

        bookingModel.tourDetails.forEach { option in
            guard optionId == nil || option.optionId == optionId else { return }

            // Base option total
            totalAmount += option.whosinTotal

            // Add-on total
            var addonTotal = 0.0
            for addon in option.Addons {
                addonTotal += addon.serviceTotal
            }

            totalAmount += addonTotal
        }

        return Utils.convertCurrent(totalAmount).formattedWithoutDecimal()
    }

    
}
