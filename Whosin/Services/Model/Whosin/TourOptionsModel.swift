import Foundation
import ObjectMapper
import RealmSwift

class TourOptionsModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var tourId: Int = 0
    @objc dynamic var tourIdString: String = kEmptyString
    @objc dynamic var tourOptionId: Int = 0
    @objc dynamic var optionId: String = kEmptyString
    @objc dynamic var timeSlotId: String = kEmptyString
    @objc dynamic var transferId: Int = 0
    @objc dynamic var transferName: String = kEmptyString
    @objc dynamic var optionName: String = kEmptyString
    @objc dynamic var customTicketId: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var optionDescription: String = kEmptyString
    @objc dynamic var sortDescription: String = kEmptyString
    @objc dynamic var longDescription: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var availabilityTime: String = kEmptyString
    @objc dynamic var availabilityType: String = kEmptyString
    @objc dynamic var discountType: String = kEmptyString
    @objc dynamic var adultPrice: Double = 0.0
    @objc dynamic var withoutDiscountAdultPrice: Double = 0.0
    @objc dynamic var adultPriceRayna: Double = 0.0
    @objc dynamic var childPrice: Double = 0.0
    @objc dynamic var childPriceRayna: Double = 0.0
    @objc dynamic var withoutDiscountChildPrice: Double = 0.0
    @objc dynamic var infantPrice: Double = 0.0
    @objc dynamic var infantPriceRayna: Double = 0.0
    @objc dynamic var withoutDiscountInfantPrice: Double = 0.0
    @objc dynamic var withoutDiscountAmount: Double = 0.0
    @objc dynamic var finalAmount: Double = 0.0
    @objc dynamic var startTime: String = kEmptyString
    @objc dynamic var departureTime: String = kEmptyString
    @objc dynamic var disableChild: Bool = false
    @objc dynamic var disableInfant: Bool = false
    @objc dynamic var allowTodaysBooking: Bool = true
    @objc dynamic var cutOff: Int = 0
    @objc dynamic var totalSeats: Int = 0
    @objc dynamic var ratioPerPax: Int = 0
    @objc dynamic var isSlot: Bool = false
    @objc dynamic var isSeat: Bool = false
    @objc dynamic var isPickup: Bool = false
    @objc dynamic var isTourGuide: Bool = false
    @objc dynamic var isHourly: Bool = false
    @objc dynamic var isDefaultTransfer: Int = 0
    @objc dynamic var rateKey: String = kEmptyString
    @objc dynamic var inventoryId: String = kEmptyString
    @objc dynamic var adultBuyingPrice: Double = 0.0
    @objc dynamic var childBuyingPrice: Double = 0.0
    @objc dynamic var infantBuyingPrice: Double = 0.0
    @objc dynamic var adultSellingPrice: Double = 0.0
    @objc dynamic var childSellingPrice: Double = 0.0
    @objc dynamic var infantSellingPrice: Double = 0.0
    @objc dynamic var companyBuyingPrice: Double = 0.0
    @objc dynamic var companySellingPrice: Double = 0.0
    @objc dynamic var agentBuyingPrice: Double = 0.0
    @objc dynamic var agentSellingPrice: Double = 0.0
    @objc dynamic var subAgentBuyingPrice: Double = 0.0
    @objc dynamic var subAgentSellingPrice: Double = 0.0
    @objc dynamic var finalSellingPrice: Double = 0.0
    @objc dynamic var vatBuying: Double = 0.0
    @objc dynamic var vatSelling: Double = 0.0
    @objc dynamic var currencyFactor: Double = 0.0
    @objc dynamic var agentPercentage: Double = 0.0
    @objc dynamic var transferBuyingPrice: Double = 0.0
    @objc dynamic var transferSellingPrice: Double = 0.0
    @objc dynamic var serviceBuyingPrice: Double = 0.0
    @objc dynamic var serviceSellingPrice: Double = 0.0
    @objc dynamic var rewardPoints: Int = 0
    @objc dynamic var tourChildAge: Int = 0
    @objc dynamic var maxChildAge: Int = 0
    @objc dynamic var maxInfantAge: Int = 0
    @objc dynamic var cutOffhrs: Int = 0
    @objc dynamic var minimumPax: Int = 0
    @objc dynamic var order: Int = 0
    @objc dynamic var discount: Int = 0
    @objc dynamic var pointRemark: String = kEmptyString
    @objc dynamic var address: String = kEmptyString
    @objc dynamic var adultAge: String = kEmptyString
    @objc dynamic var infantAge: String = kEmptyString
    @objc dynamic var childAge: String = kEmptyString
    @objc dynamic var transferOptions: String = kEmptyString
    @objc dynamic var cancellationPolicy: String = kEmptyString
    @objc dynamic var cancellationPolicyDescription: String = kEmptyString
    @objc dynamic var adultRetailPrice: Double = 0.0
    @objc dynamic var childRetailPrice: Double = 0.0
    @objc dynamic var maximumPax: String = "0"
    @objc dynamic var minimumPaxString: String = "0"
    @objc dynamic var minPaxString: String = "0"
    @objc dynamic var minmumPaxString: String = "0"
    @objc dynamic var maxPaxString: String = "0"
    @objc dynamic var displayName: String = ""
    @objc dynamic var childPolicy: String = ""
    @objc dynamic var inclusion: String = ""
    @objc dynamic var exclusion: String = ""
    @objc dynamic var tourExclusion: String = ""
    @objc dynamic var countryId: String = ""
    @objc dynamic var cityId: String = ""
    @objc dynamic var duration: String = ""
    @objc dynamic var termsAndConditions: String = ""
    @objc dynamic var unit: String = "" {
        didSet {
            let lower = unit.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if lower == "hour" || lower == "hours" || lower == "hrs" || lower == "hr" {
                unit = "hrs"
            }
        }
    }
    @objc dynamic var notes: String = ""
    @objc dynamic var childPolicyDescription: String = ""
    dynamic var operationdays: OperationDaysModel?
    @objc dynamic var slotText: String = ""
    dynamic var images: List<String> = List<String>()
    dynamic var moreInfo: List<String> = List<String>()
    @objc dynamic var optionDetail: TourOptionDataModel?
    dynamic var availabilityTimeSlot = List<TourTimeSlotModel>()
    dynamic var bookingDates = List<BookingDatesModel>()
    @objc dynamic var startDate: Date?
    @objc dynamic var endDate: Date?
    @objc dynamic var adultTitle: String = kEmptyString
    @objc dynamic var childTitle: String = kEmptyString
    @objc dynamic var infantTitle: String = kEmptyString
    @objc dynamic var adultDesc: String = kEmptyString
    @objc dynamic var childDesc: String = kEmptyString
    @objc dynamic var infantDesc: String = kEmptyString
    @objc dynamic var isAddon: Bool = false
    @objc dynamic var isRestricted: Bool = false
    dynamic var addonOptionIds: List<String> = List<String>()
    dynamic var addonOptions = List<TourOptionsModel>()

    

    // MARK: - Date Formatter
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kStanderdDate)
    private let _fallbackFormatter = DATEFORMATTER.dateFormatterWith(format: kStanderdDate)


    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        tourId <- map["tourId"]
        tourIdString <- map["tourId"]
        optionId <- map["tourOptionId"]
        tourOptionId <- map["tourOptionId"]
        timeSlotId <- map["timeSlotId"]
        _id <- map["_id"]
        title <- map["title"]
        unit <- map["unit"]
        notes <- map["notes"]
        discountType <- map["discountType"]
        descriptions <- map["description"]
        optionDescription <- map["optionDescription"]
        sortDescription <- map["sortDescription"]
        longDescription <- map["longDescription"]
        optionName <- map["optionName"]
        availabilityTime <- map["availabilityTime"]
        availabilityType <- map["availabilityType"]
        customTicketId <- map["customTicketId"]
        transferId <- map["transferId"]
        transferName <- map["transferName"]
        adultPrice <- map["adultPrice"]
        childPrice <- map["childPrice"]
        infantPrice <- map["infantPrice"]
        transferOptions <- map["transferOptions"]
        isHourly <- map["isHourly"]
        discount <- map["discount"]
        withoutDiscountAdultPrice <- map["withoutDiscountAdultPrice"]
        withoutDiscountChildPrice <- map["withoutDiscountChildPrice"]
        withoutDiscountInfantPrice <- map["withoutDiscountInfantPrice"]
        adultPriceRayna <- map["adultPriceRayna"]
        childPriceRayna <- map["childPriceRayna"]
        infantPriceRayna <- map["infantPriceRayna"]
        address <- map["address"]
        duration <- map["duration"]
        order <- map["order"]
        withoutDiscountAmount <- map["withoutDiscountAmount"]
        finalAmount <- map["finalAmount"]
        startTime <- map["startTime"]
        departureTime <- map["departureTime"]
        disableChild <- map["disableChild"]
        disableInfant <- map["disableInfant"]
        allowTodaysBooking <- map["allowTodaysBooking"]
        cutOff <- map["cutOff"]
        totalSeats <- map["totalSeats"]
        ratioPerPax <- map["ratioPerPax"]
        isSlot <- map["isSlot"]
        isSeat <- map["isSeat"]
        isTourGuide <- map["isTourGuide"]
        isPickup <- map["isPickup"]
        isDefaultTransfer <- map["isDefaultTransfer"]
        rateKey <- map["rateKey"]
        cityId <- map["cityId"]
        inventoryId <- map["inventoryId"]
        adultBuyingPrice <- map["adultBuyingPrice"]
        childBuyingPrice <- map["childBuyingPrice"]
        infantBuyingPrice <- map["infantBuyingPrice"]
        adultSellingPrice <- map["adultSellingPrice"]
        childSellingPrice <- map["childSellingPrice"]
        infantSellingPrice <- map["infantSellingPrice"]
        companyBuyingPrice <- map["companyBuyingPrice"]
        companySellingPrice <- map["companySellingPrice"]
        agentBuyingPrice <- map["agentBuyingPrice"]
        agentSellingPrice <- map["agentSellingPrice"]
        subAgentBuyingPrice <- map["subAgentBuyingPrice"]
        subAgentSellingPrice <- map["subAgentSellingPrice"]
        finalSellingPrice <- map["finalSellingPrice"]
        vatBuying <- map["vatbuying"]
        vatSelling <- map["vatselling"]
        currencyFactor <- map["currencyFactor"]
        agentPercentage <- map["agentPercentage"]
        transferBuyingPrice <- map["transferBuyingPrice"]
        transferSellingPrice <- map["transferSellingPrice"]
        serviceBuyingPrice <- map["serviceBuyingPrice"]
        serviceSellingPrice <- map["serviceSellingPrice"]
        rewardPoints <- map["rewardPoints"]
        tourChildAge <- map["tourChildAge"]
        maxChildAge <- map["maxChildAge"]
        maxInfantAge <- map["maxInfantAge"]
        minimumPax <- map["minimumPax"]
        minmumPaxString <- map["minimumPax"]
        minPaxString <- map["minPax"]
        maxPaxString <- map["maxPax"]
        cutOffhrs <- map["cutOffhrs"]
        pointRemark <- map["pointRemark"]
        adultRetailPrice <- map["adultRetailPrice"]
        childRetailPrice <- map["childRetailPrice"]
        slotText <- map["slotText"]
        optionDetail <- map["optionDetail"]
        adultAge <- map["adultAge"]
        infantAge <- map["infantAge"]
        childAge <- map["childAge"]
        exclusion <- map["exclusion"]
        tourExclusion <- map["tourExclusion"]
        countryId <- map["countryId"]
        childPolicyDescription <- map["childPolicyDescription"]
        cancellationPolicy <- map["cancellationPolicy"]
        termsAndConditions <- map["termsAndConditions"]
        inclusion <- map["inclusion"]
        cancellationPolicyDescription <- map["cancellationPolicyDescription"]
        operationdays <- map["operationdays"]
        displayName <- map["displayName"]
        childPolicy <- map["childPolicy"]
        images <- (map["images"], StringListTransform())
        moreInfo <- (map["moreInfo"], StringListTransform())
        availabilityTimeSlot <- (map["availabilityTimeSlot"], ListTransform<TourTimeSlotModel>())
        bookingDates <- (map["bookingDates"], ListTransform<BookingDatesModel>())
        adultTitle <- map["adult_title"]
        childTitle <- map["child_title"]
        infantTitle <- map["infant_title"]
        adultDesc <- map["adult_description"]
        childDesc <- map["child_description"]
        infantDesc <- map["infant_description"]
        isAddon <- map["isAddon"]
        isRestricted <- map["isRestricted"]
        addonOptionIds <- (map["addonOptionIds"], StringListTransform())
        addonOptions <- (map["Addons"], ListTransform<TourOptionsModel>())
        var startDateString: String?
        var endDateString: String?
        startDateString <- map["startDate"]
        endDateString <- map["endDate"]
        
        if let value = startDateString {
            startDate = _dateFormatter.date(from: value) ?? _fallbackFormatter.date(from: value)
        }

        if let value = endDateString {
            endDate = _dateFormatter.date(from: value) ?? _fallbackFormatter.date(from: value)
        }


    }
    
    var discountText: NSAttributedString {
        guard discount > 0 else { return NSAttributedString(string: "") }

        if discountType.lowercased() == "flat" {
            return "\(Utils.getCurrentCurrencySymbol())\(discount) OFF".withCurrencyFont(18, true)
        } else {
            return NSAttributedString(
                string: "\(discount)% OFF"
            )
        }
    }

    
    var hasDiscount: Bool {
        return withoutDiscountAmount > finalAmount
    }
    
    var isRefundable: Bool {
        return cancellationPolicy.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != "non refundable".trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    var inititalDate: String {
        allowTodaysBooking ? Utils.dateToString(Date(), format: kFormatDate)
        :  Utils.dateToString(Calendar.current.date(byAdding: .day, value: 1, to: Date()), format: kFormatDate)
    }
    
    var maxPax: Int {
        return maximumPax == "NA" ? 1000 : Int(maximumPax) ?? 1000
    }
    
    var minPax: Int {
        return minimumPaxString == "NA" ? 0 : Int(minimumPaxString) ?? 0
    }

    
    func isValid() -> Bool {
        return true
    }

}

class PassengersModel: Mappable, ModelProtocol {
    @objc dynamic var paxType: String = kEmptyString
    @objc dynamic var prefix: String = kEmptyString
    @objc dynamic var firstName: String = kEmptyString
    @objc dynamic var lastName: String = kEmptyString
    @objc dynamic var countryCode: String = kEmptyString
    @objc dynamic var nationality: String = kEmptyString
    @objc dynamic var mobile: String = kEmptyString
    @objc dynamic var email: String = kEmptyString
    @objc dynamic var leadPassenger: Int = 0
    @objc dynamic var serviceType: String = "Tour"
    @objc dynamic var message: String = kEmptyString
    @objc dynamic var pickup: String = kEmptyString
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        paxType <- map["paxType"]
        prefix <- map["prefix"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        countryCode <- map["countryCode"]
        nationality <- map["nationality"]
        mobile <- map["mobile"]
        email <- map["email"]
        leadPassenger <- map["leadPassenger"]
        serviceType <- map["serviceType"]
        message <- map["message"]
        pickup <- map["pickup"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}
