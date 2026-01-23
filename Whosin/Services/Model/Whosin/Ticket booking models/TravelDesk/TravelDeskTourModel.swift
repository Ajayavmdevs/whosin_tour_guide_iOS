import Foundation
import RealmSwift
import ObjectMapper

class TravelDeskTourModel: Object, Mappable, ModelProtocol {

    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var id: Int = 0
    dynamic var cancellationPolicy = List<TourPolicyModel>()
    dynamic var categories = List<TourCategoryModel>()
    @objc dynamic var heroImage: TourHeroImageModel?
    @objc dynamic var isExternal: Bool = false
    @objc dynamic var language: String = kEmptyString
    @objc dynamic var languageId: Int = 0
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var notesToAgent: String? = nil
    @objc dynamic var salesDescription: String = kEmptyString
    @objc dynamic var termsAndConditions: String = kEmptyString
    dynamic var optionData = List<TourOptionModel>()

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        _id <- map["_id"]
        id <- map["id"]
        cancellationPolicy <- (map["cancellationPolicy"], ListTransform<TourPolicyModel>())
        categories <- (map["categories"], ListTransform<TourCategoryModel>())
        heroImage <- map["heroImage"]
        isExternal <- map["isExternal"]
        language <- map["language"]
        languageId <- map["languageId"]
        name <- map["name"]
        notesToAgent <- map["notesToAgent"]
        salesDescription <- map["salesDescription"]
        termsAndConditions <- map["termsAndConditions"]
        optionData <- (map["optionData"], ListTransform<TourOptionModel>())
    }

    func isValid() -> Bool {
        return true
    }
}

class TourCategoryModel: Object, Mappable, ModelProtocol {
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var url: String = kEmptyString
    @objc dynamic var heroImageId: Int = 0
    @objc dynamic var heroImage: String = kEmptyString
    @objc dynamic var id: Int = 0

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        name <- map["name"]
        url <- map["url"]
        heroImageId <- (map["heroImageId"])
        heroImage <- map["heroImage"]
        id <- map["id"]
    }

    func isValid() -> Bool { true }
}

class TourHeroImageModel: Object, Mappable, ModelProtocol {
    @objc dynamic var caption: String = kEmptyString
    @objc dynamic var relatedId: Int = 0
    @objc dynamic var isSharedStorage: Bool = false
    dynamic var srcSet = List<TourImageSrcSetModel>()
    @objc dynamic var id: Int = 0

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        caption <- map["caption"]
        relatedId <- (map["relatedId"])
        isSharedStorage <- map["isSharedStorage"]
        srcSet <- (map["srcSet"], ListTransform<TourImageSrcSetModel>())
        id <- map["id"]
    }

    func isValid() -> Bool { true }
}

class TourImageSrcSetModel: Object, Mappable, ModelProtocol {
    @objc dynamic var type: String = kEmptyString
    dynamic var sizes = List<TourImageSizeModel>()

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        type <- map["type"]
        sizes <- (map["sizes"], ListTransform<TourImageSizeModel>())
    }

    func isValid() -> Bool { true }
}

class TourImageSizeModel: Object, Mappable, ModelProtocol {
    @objc dynamic var src: String = kEmptyString
    @objc dynamic var width: Int = 0
    @objc dynamic var height: Int = 0

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        src <- map["src"]
        width <- map["width"]
        height <- map["height"]
    }

    func isValid() -> Bool { true }
}

class TourOptionModel: Object, Mappable, ModelProtocol {
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var id: Int = 0
    @objc dynamic var bookingType: Int = 0
    @objc dynamic var adultAge: Int = 0
    @objc dynamic var childAge: Int = 0
    @objc dynamic var childrenAllowed: Bool = false
    @objc dynamic var code: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var shortDescription: String = kEmptyString
    @objc dynamic var daysOffered: Int = 0
    @objc dynamic var descriptionText: String = kEmptyString
    dynamic var heroImage = List<TourHeroImageModel>()
    @objc dynamic var infantAge: Int = 0
    @objc dynamic var infantsAllowed: Bool = false
    @objc dynamic var isAppendTransactionFeeB2b: Bool = false
    @objc dynamic var isDirectCollection: Bool = false
    @objc dynamic var isDirectReporting: Bool = false
    @objc dynamic var isExternal: Bool = false
    @objc dynamic var maxNumOfPeople: Int = 0
    @objc dynamic var minNumOfPeople: Int = 0
    @objc dynamic var discount: Int = 0
    @objc dynamic var minimumAdvancedPayment: Int = 0
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var discountType: String = kEmptyString
    @objc dynamic var notes: String = kEmptyString
    @objc dynamic var unit: String = ""
    @objc dynamic var numberOfHours: Int = 0
    dynamic var pricingPeriods = List<TourPricingPeriodModel>()
    @objc dynamic var privateType: Int = 0
    @objc dynamic var tourId: Int = 0
    @objc dynamic var adultTitle: String = kEmptyString
    @objc dynamic var childTitle: String = kEmptyString
    @objc dynamic var infantTitle: String = kEmptyString
    @objc dynamic var adultDesc: String = kEmptyString
    @objc dynamic var childDesc: String = kEmptyString
    @objc dynamic var infantDesc: String = kEmptyString

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        _id <- map["_id"]
        id <- map["id"]
        bookingType <- map["bookingType"]
        childAge <- map["childAge"]
        adultAge <- map["adultAge"]
        childrenAllowed <- map["childrenAllowed"]
        code <- map["code"]
        daysOffered <- map["daysOffered"]
        descriptionText <- map["description"]
        title <- map["title"]
        notes <- map["notes"]
        unit <- map["unit"]
        discountType <- map["discountType"]
        shortDescription <- map["shortDescription"]
        heroImage <- (map["heroImage"], ListTransform<TourHeroImageModel>())
        infantAge <- map["infantAge"]
        discount <- map["discount"]
        infantsAllowed <- map["infantsAllowed"]
        isAppendTransactionFeeB2b <- map["isAppendTransactionFeeB2b"]
        isDirectCollection <- map["isDirectCollection"]
        isDirectReporting <- map["isDirectReporting"]
        isExternal <- map["isExternal"]
        maxNumOfPeople <- map["maxNumOfPeople"]
        minNumOfPeople <- map["minNumOfPeople"]
        minimumAdvancedPayment <- map["minimumAdvancedPayment"]
        name <- map["name"]
        numberOfHours <- map["numberOfHours"]
        pricingPeriods <- (map["pricingPeriods"], ListTransform<TourPricingPeriodModel>())
        privateType <- map["privateType"]
        tourId <- map["tourId"]
        adultTitle <- map["adult_title"]
        childTitle <- map["child_title"]
        infantTitle <- map["infant_title"]
        adultDesc <- map["adult_description"]
             childDesc <- map["child_description"]
             infantDesc <- map["infant_description"]
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

    func isValid() -> Bool { true }
}

class TourPricingPeriodModel: Object, Mappable, ModelProtocol {
    @objc dynamic var id: Int = 0
    @objc dynamic var dateStart: String = kEmptyString
    @objc dynamic var date: String = kEmptyString
    @objc dynamic var dateEnd: String = kEmptyString
    @objc dynamic var offerId: Int = 0
    @objc dynamic var currency: String = kEmptyString
    @objc dynamic var recPricePerAdult: Double = 0
    @objc dynamic var recPricePerAdultUsd: Double = 0
    @objc dynamic var recPricePerChild: Double = 0
    @objc dynamic var recPricePerChildUsd: Double = 0
    @objc dynamic var recPricePerTrip: Double = 0
    @objc dynamic var recPricePerTripUsd: Double = 0
    @objc dynamic var pricePerAdult: Double = 0
    @objc dynamic var pricePerChild: Double = 0
    @objc dynamic var pricePerInfant: Double = 0
    @objc dynamic var pricePerTrip: Double = 0
    @objc dynamic var pricePerAdultUsd: Double = 0
    @objc dynamic var pricePerChildUsd: Double = 0
    @objc dynamic var pricePerTripUsd: Double = 0
    @objc dynamic var discountPercent: Double = 0
    @objc dynamic var pricePerAdultBeforeDiscountUsd: Double = 0
    @objc dynamic var pricePerChildBeforeDiscountUsd: Double = 0
    @objc dynamic var pricePerTripBeforeDiscountUsd: Double = 0
    @objc dynamic var pricePerAdultBeforeDiscount: Double = 0
    @objc dynamic var pricePerChildBeforeDiscount: Double = 0
    @objc dynamic var pricePerInfantBeforeDiscount: Double = 0
    @objc dynamic var pricePerTripBeforeDiscount: Double = 0
    @objc dynamic var pricePerAdultTravelDesk: Double = 0
    @objc dynamic var pricePerChildTravelDesk: Double = 0
    @objc dynamic var pricePerTripTravelDesk: Double = 0

    @objc dynamic var isBookable: Bool = false

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        id <- map["id"]
        dateStart <- map["dateStart"]
        date <- map["date"]
        dateEnd <- map["dateEnd"]
        offerId <- map["offerId"]
        currency <- map["currency"]
        recPricePerAdult <- map["recPricePerAdult"]
        recPricePerAdultUsd <- map["recPricePerAdultUsd"]
        recPricePerChild <- map["recPricePerChild"]
        recPricePerChildUsd <- map["recPricePerChildUsd"]
        recPricePerTrip <- map["recPricePerTrip"]
        recPricePerTripUsd <- map["recPricePerTripUsd"]
        pricePerAdult <- map["pricePerAdult"]
        pricePerChild <- map["pricePerChild"]
        pricePerTrip <- map["pricePerTrip"]
        pricePerInfant <- map["pricePerInfant"]
        pricePerAdultUsd <- map["pricePerAdultUsd"]
        pricePerChildUsd <- map["pricePerChildUsd"]
        pricePerTripUsd <- map["pricePerTripUsd"]
        discountPercent <- map["discountPercent"]
        pricePerAdultBeforeDiscountUsd <- map["pricePerAdultBeforeDiscountUsd"]
        pricePerChildBeforeDiscountUsd <- map["pricePerChildBeforeDiscountUsd"]
        pricePerTripBeforeDiscountUsd <- map["pricePerTripBeforeDiscountUsd"]
        pricePerAdultBeforeDiscount <- map["pricePerAdultBeforeDiscount"]
        pricePerChildBeforeDiscount <- map["pricePerChildBeforeDiscount"]
        pricePerInfantBeforeDiscount <- map["pricePerInfantBeforeDiscount"]
        pricePerTripBeforeDiscount <- map["pricePerTripBeforeDiscount"]
        isBookable <- map["isBookable"]
        pricePerAdultTravelDesk <- map["pricePerAdultTravelDesk"]
        pricePerChildTravelDesk <- map["pricePerChildTravelDesk"]
        pricePerTripTravelDesk <- map["pricePerTripTravelDesk"]
    }
    
    var hasDiscount: Bool {
        return pricePerAdultBeforeDiscount > pricePerAdult
    }


    func isValid() -> Bool { true }
}

class TravelDeskAvailibilityModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var availability: TravelDeskAvailibility?
    @objc dynamic var price: TourPricingPeriodModel?

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        availability <- map["availability"]
        price <- map["price"]
    }
    
    func isValid() -> Bool {
        return true
    }
}

class TravelDeskAvailibility: Object, Mappable, ModelProtocol {
    @objc dynamic var date: String = kEmptyString
    @objc dynamic var startTime: Int = 0
    @objc dynamic var endTime: Int = 0
    @objc dynamic var timeSlotId: Int = 0
    @objc dynamic var left: Int = 0
    @objc dynamic var id: Int = 0

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        date <- map["date"]
        startTime <- map["startTime"]
        endTime <- (map["endTime"])
        timeSlotId <- map["timeSlotId"]
        left <- map["left"]
        id <- map["id"]
    }
    
    var slotText: String {
        return "\(convertMinutesToTime(startTime)) - \(convertMinutesToTime(endTime))"
    }

    /// Converts minutes to "HH:mm" format
    private func convertMinutesToTime(_ minutes: Int) -> String {
        let hrs = minutes / 60
        let mins = minutes % 60
        return String(format: "%02d:%02d", hrs, mins)
    }

    func isValid() -> Bool { true }
}

class PickupListModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var pickupId: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var directions: String = kEmptyString
    @objc dynamic var regionId: Int = 0
    @objc dynamic var regionName: String = kEmptyString
    @objc dynamic var cityId: Int = 0
    @objc dynamic var cityName: String = kEmptyString
    @objc dynamic var address: String = kEmptyString
    @objc dynamic var googlePlaceId: String = kEmptyString
    @objc dynamic var street: String = kEmptyString
    @objc dynamic var postalCode: String = kEmptyString
    @objc dynamic var locality: String = kEmptyString
    @objc dynamic var region: String = kEmptyString
    @objc dynamic var state: String = kEmptyString
    @objc dynamic var country: String = kEmptyString
    @objc dynamic var id: Int = 0
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0

    required convenience init?(map: Map) { self.init() }

    convenience init(name: String, id: Int) {
        self.init()
        self.name = name
        self.id = id
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        regionId <- map["regionId"]
        directions <- map["directions"]
        regionName <- (map["regionName"])
        cityId <- map["cityId"]
        cityName <- map["cityName"]
        address <- map["address"]
        id <- map["id"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        googlePlaceId <- map["googlePlaceId"]
        locality <- map["locality"]
        street <- map["street"]
        postalCode <- map["postalCode"]
        state <- map["state"]
        region <- map["region"]
        country <- map["country"]
        if map.mappingType == .fromJSON {
            var rawTourId: Any?
            rawTourId <- map["id"]
            if let idInt = rawTourId as? Int {
                id = idInt
                pickupId = ""
            } else if let idStr = rawTourId as? String {
                pickupId = idStr
                id = Int(idStr) ?? 0
            }
        } else {
            if !pickupId.isEmpty {
                pickupId <- map["id"]
            } else {
                id <- map["id"]
            }
        }

    }

    func isValid() -> Bool { true }
}
