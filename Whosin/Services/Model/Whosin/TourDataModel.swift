import Foundation
import ObjectMapper
import RealmSwift

class TourDataModel: Object, Mappable, ModelProtocol {
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var reviewCount: String = kEmptyString
    @objc dynamic var rating: String = kEmptyString
    @objc dynamic var isSlot: Bool = false
    @objc dynamic var onlyChild: Bool = false
    @objc dynamic var recommended: Bool = false
    @objc dynamic var isPrivate: Bool = false
    @objc dynamic var status: Bool = false
    @objc dynamic var tourId: String = kEmptyString
    @objc dynamic var countryId: String = kEmptyString
    @objc dynamic var countryName: String = kEmptyString
    @objc dynamic var cityId: String = kEmptyString
    @objc dynamic var cityName: String = kEmptyString
    @objc dynamic var tourName: String = kEmptyString
    @objc dynamic var duration: String = kEmptyString
    @objc dynamic var imagePath: String = kEmptyString
    @objc dynamic var imageCaptionName: String = kEmptyString
    @objc dynamic var cityTourTypeId: String = kEmptyString
    @objc dynamic var cityTourType: String = kEmptyString
    @objc dynamic var tourDescription: String = kEmptyString
    @objc dynamic var tourInclusion: String = kEmptyString
    @objc dynamic var tourShortDescription: String = kEmptyString
    @objc dynamic var raynaToursAdvantage: String = kEmptyString
    @objc dynamic var whatsInThisTour: String = kEmptyString
    @objc dynamic var importantInformation: String = kEmptyString
    @objc dynamic var itenararyDescription: String = kEmptyString
    @objc dynamic var usefulInformation: String = kEmptyString
    @objc dynamic var faqDetails: String = kEmptyString
    @objc dynamic var termsAndConditions: String = kEmptyString
    @objc dynamic var cancellationPolicyName: String = kEmptyString
    @objc dynamic var cancellationPolicyDescription: String = kEmptyString
    @objc dynamic var childCancellationPolicyName: String = kEmptyString
    @objc dynamic var childCancellationPolicyDescription: String = kEmptyString
    @objc dynamic var childAge: String = kEmptyString
    @objc dynamic var infantAge: String = kEmptyString
    @objc dynamic var infantCount: Int = 0
    @objc dynamic var isSeat: Bool = false
    @objc dynamic var contractId: String = kEmptyString
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var startTime: String = kEmptyString
    @objc dynamic var meal: String = kEmptyString
    @objc dynamic var videoUrl: String = kEmptyString
    @objc dynamic var googleMapUrl: String = kEmptyString
    @objc dynamic var tourExclusion: String = kEmptyString
    @objc dynamic var howToRedeem: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    dynamic var tourOptionData = List<TourOptionDataModel>()
    dynamic var tourImages = List<TourImagesModel>()
    dynamic var tourReview = List<TourReviewModel>()
    @objc dynamic var questions: String = kEmptyString
    @objc dynamic var exclusion: String = kEmptyString
    @objc dynamic var inclusion: String = kEmptyString
    @objc dynamic var customData: TicketModel?

    override class func primaryKey() -> String? {
        return "_id"
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        _id <- map["_id"]
        reviewCount <- map["reviewCount"]
        rating <- map["rating"]
        isSlot <- map["isSlot"]
        onlyChild <- map["onlyChild"]
        recommended <- map["recommended"]
        isPrivate <- map["isPrivate"]
        status <- map["status"]
        tourId <- map["tourId"]
        countryId <- map["countryId"]
        countryName <- map["countryName"]
        cityId <- map["cityId"]
        cityName <- map["cityName"]
        tourName <- map["tourName"]
        duration <- map["duration"]
        imagePath <- map["imagePath"]
        imageCaptionName <- map["imageCaptionName"]
        cityTourTypeId <- map["cityTourTypeId"]
        cityTourType <- map["cityTourType"]
        tourDescription <- map["tourDescription"]
        tourInclusion <- map["tourInclusion"]
        tourShortDescription <- map["tourShortDescription"]
        raynaToursAdvantage <- map["raynaToursAdvantage"]
        whatsInThisTour <- map["whatsInThisTour"]
        importantInformation <- map["importantInformation"]
        itenararyDescription <- map["itenararyDescription"]
        usefulInformation <- map["usefulInformation"]
        faqDetails <- map["faqDetails"]
        termsAndConditions <- map["termsAndConditions"]
        cancellationPolicyName <- map["cancellationPolicyName"]
        cancellationPolicyDescription <- map["cancellationPolicyDescription"]
        childCancellationPolicyName <- map["childCancellationPolicyName"]
        childCancellationPolicyDescription <- map["childCancellationPolicyDescription"]
        childAge <- map["childAge"]
        infantAge <- map["infantAge"]
        infantCount <- map["infantCount"]
        isSeat <- map["isSeat"]
        contractId <- map["contractId"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        startTime <- map["startTime"]
        meal <- map["meal"]
        videoUrl <- map["videoUrl"]
        googleMapUrl <- map["googleMapUrl"]
        tourExclusion <- map["tourExclusion"]
        howToRedeem <- map["howToRedeem"]
        name <- map["name"]
        tourOptionData <- (map["tourOptionData"], ListTransform<TourOptionDataModel>())
        tourImages <- (map["tourImages"], ListTransform<TourImagesModel>())
        tourReview <- (map["tourReview"], ListTransform<TourReviewModel>())
        questions <- map["questions"]
        exclusion <- map["exclusion"]
        inclusion <- map["inclusion"]
        customData <- map["customData"]
    }

    func isValid() -> Bool {
        return true
    }
}


class TourOptionDataModel: Object, Mappable {
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var xmlcode: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var xmloptioncode: String = kEmptyString
    @objc dynamic var minPax: String = "0"
    @objc dynamic var maxPax: String = "0"
    @objc dynamic var isWithoutAdult: Bool = false
    @objc dynamic var isTourGuide: String = kEmptyString
    @objc dynamic var compulsoryOptions: Bool = false
    @objc dynamic var isHideRateBreakup: Bool = false
    @objc dynamic var isHourly: Bool = false
    @objc dynamic var tourId: String = kEmptyString
    @objc dynamic var tourOptionId: String = kEmptyString
    @objc dynamic var optionName: String = kEmptyString
    @objc dynamic var childAge: String = kEmptyString
    @objc dynamic var adultPaxAge: String = kEmptyString
    @objc dynamic var infantAge: String = kEmptyString
    @objc dynamic var optionDescription: String = kEmptyString
    @objc dynamic var cancellationPolicy: String = kEmptyString
    @objc dynamic var cancellationPolicyDescription: String = kEmptyString
    @objc dynamic var childPolicyDescription: String = kEmptyString
    @objc dynamic var countryId: String = kEmptyString
    @objc dynamic var cityId: String = kEmptyString
    @objc dynamic var duration: String = kEmptyString
    @objc dynamic var timeZone: String = kEmptyString
    @objc dynamic var transferId: Int = 0
    @objc dynamic var transferName: String = kEmptyString
    @objc dynamic var adultPrice: Double = 0.0
    @objc dynamic var childPrice: Double = 0.0
    @objc dynamic var infantPrice: Double = 0.0
    @objc dynamic var withoutDiscountAmount: Double = 0.0
    @objc dynamic var finalAmount: Double = 0.0
    @objc dynamic var startTime: String = kEmptyString
    @objc dynamic var departureTime: String = kEmptyString
    @objc dynamic var disableChild: Bool = false
    @objc dynamic var disableInfant: Bool = false
    @objc dynamic var allowTodaysBooking: Bool = false
    @objc dynamic var cutOff: Int = 0
    @objc dynamic var isSlot: Bool = false
    @objc dynamic var isSeat: Bool = false
    @objc dynamic var isDefaultTransfer: Int = 0
    @objc dynamic var rateKey: String? = nil
    @objc dynamic var inventoryId: String? = nil
    @objc dynamic var finalSellingPrice: Double = 0.0
    @objc dynamic var vatbuying: Double = 0.0
    @objc dynamic var vatselling: Double = 0.0
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
    @objc dynamic var minimumPax: Int = 0
    @objc dynamic var pointRemark: String = kEmptyString
    @objc dynamic var adultRetailPrice: Double = 0.0
    @objc dynamic var childRetailPrice: Double = 0.0
    @objc dynamic var withoutDiscountAdultPrice: Double = 0.0
    @objc dynamic var withoutDiscountChildPrice: Double = 0.0
    @objc dynamic var withoutDiscountInfantPrice: Double = 0.0
    @objc dynamic var operationdays: OperationDaysModel?
    @objc dynamic var address: String = kEmptyString
    @objc dynamic var exclusion: String = kEmptyString
    @objc dynamic var inclusion: String = kEmptyString
    @objc dynamic var termsAndConditions: String = kEmptyString
    dynamic var bookingDates = List<BookingDatesModel>()
    
    dynamic var images: List<String> = List<String>()

    override class func primaryKey() -> String? {
        return "_id"
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        _id <- map["_id"]
        xmlcode <- map["xmlcode"]
        title <- map["title"]
        xmloptioncode <- map["xmloptioncode"]
        minPax <- map["minPax"]
        maxPax <- map["maxPax"]
        isWithoutAdult <- map["isWithoutAdult"]
        isTourGuide <- map["isTourGuide"]
        compulsoryOptions <- map["compulsoryOptions"]
        isHideRateBreakup <- map["isHideRateBreakup"]
        isHourly <- map["isHourly"]
        tourId <- map["tourId"]
        tourOptionId <- map["tourOptionId"]
        optionName <- map["optionName"]
        childAge <- map["childAge"]
        infantAge <- map["infantAge"]
        adultPaxAge <- map["adultAge"]
        optionDescription <- map["optionDescription"]
        descriptions <- map["description"]
        cancellationPolicy <- map["cancellationPolicy"]
        cancellationPolicyDescription <- map["cancellationPolicyDescription"]
        childPolicyDescription <- map["childPolicyDescription"]
        countryId <- map["countryId"]
        cityId <- map["cityId"]
        duration <- map["duration"]
        timeZone <- map["timeZone"]
        transferId <- map["transferId"]
        transferName <- map["transferName"]
        adultPrice <- map["adultPrice"]
        childPrice <- map["childPrice"]
        infantPrice <- map["infantPrice"]
        withoutDiscountAmount <- map["withoutDiscountAmount"]
        finalAmount <- map["finalAmount"]
        startTime <- map["startTime"]
        departureTime <- map["departureTime"]
        disableChild <- map["disableChild"]
        disableInfant <- map["disableInfant"]
        allowTodaysBooking <- map["allowTodaysBooking"]
        cutOff <- map["cutOff"]
        isSlot <- map["isSlot"]
        isSeat <- map["isSeat"]
        isDefaultTransfer <- map["isDefaultTransfer"]
        rateKey <- map["rateKey"]
        inventoryId <- map["inventoryId"]
        finalSellingPrice <- map["finalSellingPrice"]
        vatbuying <- map["vatbuying"]
        vatselling <- map["vatselling"]
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
        pointRemark <- map["pointRemark"]
        adultRetailPrice <- map["adultRetailPrice"]
        childRetailPrice <- map["childRetailPrice"]
        withoutDiscountAdultPrice <- map["withoutDiscountAdultPrice"]
        withoutDiscountChildPrice <- map["withoutDiscountChildPrice"]
        withoutDiscountInfantPrice <- map["withoutDiscountInfantPrice"]
        images <- (map["images"], StringListTransform())
        operationdays <- map["operationdays"]
        address <- map["address"]
        exclusion <- map["exclusion"]
        inclusion <- map["inclusion"]
        termsAndConditions <- map["termsAndConditions"]
        bookingDates <- (map["bookingDates"], ListTransform<BookingDatesModel>())
    }
    
    var adultAge: String {
        if !Utils.stringIsNullOrEmpty(adultPaxAge) {
            if adultPaxAge.lowercased().contains("yrs") {
                return adultPaxAge
            } else {
                return "\(adultPaxAge)+ yrs"
            }
        }

        let numbers = childAge.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
        if let maxChildAge = numbers.max() {
            guard maxChildAge > 0 else { return kEmptyString }
            return "\(maxChildAge)+ yrs"
        }
        return kEmptyString
    }

    var hasDiscount: Bool {
        return withoutDiscountAmount > finalAmount
    }
    
    var isRefundable: Bool {
        return cancellationPolicy.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != "non refundable".trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    func isValid() -> Bool {
        return true
    }
}
class TourTimeSlotModel: Object, Mappable {
    
    @objc dynamic var tourOptionId: Int = 0
    @objc dynamic var timeSlotId: String = kEmptyString
    @objc dynamic var slotId: String = kEmptyString
    @objc dynamic var id: String = "0"
    @objc dynamic var timeSlot: String = kEmptyString
    @objc dynamic var availabilityTime: String = kEmptyString
    @objc dynamic var available: Int = 0
    @objc dynamic var totalSeats: Int = 0
    @objc dynamic var adultPrice: Int = 0
    @objc dynamic var childPrice: Int = 0
    @objc dynamic var isDynamicPrice: Bool = false

    override class func primaryKey() -> String? {
        return "tourOptionId"
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        tourOptionId <- map["tourOptionId"]
        timeSlot <- map["timeSlot"]
        slotId <- map["slotId"]
        timeSlotId <- map["timeSlotId"]
        id <- map["_id"]
        availabilityTime <- map["availabilityTime"]
        available <- map["available"]
        totalSeats <- map["totalSeats"]
        adultPrice <- map["adultPrice"]
        childPrice <- map["childPrice"]
        isDynamicPrice <- map["isDynamicPrice"]
    }
    
    func isValid() -> Bool {
        return true
    }

}

class OperationDaysModel: Object, Mappable {
    
    @objc dynamic var tourId: Int = 0
    @objc dynamic var tourOptionId: Int = 0
    @objc dynamic var monday: Int = 1
    @objc dynamic var tuesday: Int = 1
    @objc dynamic var wednesday: Int = 1
    @objc dynamic var thursday: Int = 1
    @objc dynamic var friday: Int = 1
    @objc dynamic var saturday: Int = 1
    @objc dynamic var sunday: Int = 1
  

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        tourId <- map["tourId"]
        tourOptionId <- map["tourOptionId"]
        monday <- map["monday"]
        tuesday <- map["tuesday"]
        wednesday <- map["wednesday"]
        thursday <- map["thursday"]
        friday <- map["friday"]
        saturday <- map["saturday"]
        sunday <- map["sunday"]
    }
    
    func isValid() -> Bool {
        return true
    }

}
