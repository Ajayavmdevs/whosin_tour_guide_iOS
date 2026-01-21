import Foundation
import ObjectMapper
import RealmSwift

class BigBusTourModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var internalName: String = kEmptyString
    @objc dynamic var country: String = kEmptyString
    @objc dynamic var location: String = kEmptyString
    @objc dynamic var subtitle: String = kEmptyString
    @objc dynamic var tagline: String = kEmptyString
    @objc dynamic var reference: String = kEmptyString
    var tags = List<String>()
    @objc dynamic var locale: String = kEmptyString
    @objc dynamic var timeZone: String = kEmptyString
    @objc dynamic var allowFreesale: Bool = false
    @objc dynamic var freesaleDurationAmount: Int = 0
    @objc dynamic var freesaleDurationUnit: String = kEmptyString
    @objc dynamic var instantConfirmation: Bool = false
    @objc dynamic var instantDelivery: Bool = false
    @objc dynamic var availabilityRequired: Bool = false
    @objc dynamic var availabilityType: String = kEmptyString
    var deliveryFormats = List<String>()
    var deliveryMethods = List<String>()
    var settlementMethods = List<String>()
    @objc dynamic var redemptionMethod: String = kEmptyString
    var options = List<BigBusOptionsModel>()
    var keywords = List<String>()
    @objc dynamic var pointToPoint: Bool = false
    @objc dynamic var shortDescription: String = kEmptyString
    @objc dynamic var descriptionText: String = kEmptyString
    var highlights = List<String>()
    @objc dynamic var alert: String = kEmptyString
    var inclusions = List<String>()
    var exclusions = List<String>()
    @objc dynamic var bookingTerms: String = kEmptyString
    @objc dynamic var privacyTerms: String = kEmptyString
    @objc dynamic var redemptionInstructions: String = kEmptyString
    @objc dynamic var cancellationPolicy: String = kEmptyString
    var faqs = List<FAQModel>()
    @objc dynamic var coverImageUrl: String = kEmptyString
    @objc dynamic var bannerImageUrl: String = kEmptyString
    @objc dynamic var videoUrl: String = kEmptyString
    var galleryImages = List<ImageInfoModel>()
    var bannerImages = List<ImageInfoModel>()
    @objc dynamic var defaultCurrency: String = kEmptyString
    var availableCurrencies = List<String>()
    @objc dynamic var includeTax: Bool = false
    @objc dynamic var pricingPer: String = kEmptyString
    @objc dynamic var status: Bool = false
    @objc dynamic var supplier: String = kEmptyString
    @objc dynamic var destination: DestinationModel? = nil
    var categories = List<BigBusCategoryModel>()
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        internalName <- map["internalName"]
        country <- map["country"]
        location <- map["location"]
        subtitle <- map["subtitle"]
        tagline <- map["tagline"]
        reference <- map["reference"]
        tags <- (map["tags"], StringListTransform())
        locale <- map["locale"]
        timeZone <- map["timeZone"]
        allowFreesale <- map["allowFreesale"]
        freesaleDurationAmount <- map["freesaleDurationAmount"]
        freesaleDurationUnit <- map["freesaleDurationUnit"]
        instantConfirmation <- map["instantConfirmation"]
        instantDelivery <- map["instantDelivery"]
        availabilityRequired <- map["availabilityRequired"]
        availabilityType <- map["availabilityType"]
        deliveryFormats <- (map["deliveryFormats"], StringListTransform())
        deliveryMethods <- (map["deliveryMethods"], StringListTransform())
        settlementMethods <- (map["settlementMethods"], StringListTransform())
        redemptionMethod <- map["redemptionMethod"]
        options <- (map["options"], ListTransform<BigBusOptionsModel>())
        keywords <- (map["keywords"], StringListTransform())
        pointToPoint <- map["pointToPoint"]
        shortDescription <- map["shortDescription"]
        descriptionText <- map["description"]
        highlights <- (map["highlights"], StringListTransform())
        alert <- map["alert"]
        inclusions <- (map["inclusions"], StringListTransform())
        exclusions <- (map["exclusions"], StringListTransform())
        bookingTerms <- map["bookingTerms"]
        privacyTerms <- map["privacyTerms"]
        redemptionInstructions <- map["redemptionInstructions"]
        cancellationPolicy <- map["cancellationPolicy"]
        faqs <- (map["faqs"], ListTransform<FAQModel>())
        coverImageUrl <- map["coverImageUrl"]
        bannerImageUrl <- map["bannerImageUrl"]
        videoUrl <- map["videoUrl"]
        galleryImages <- (map["galleryImages"], ListTransform<ImageInfoModel>())
        bannerImages <- (map["bannerImages"], ListTransform<ImageInfoModel>())
        defaultCurrency <- map["defaultCurrency"]
        availableCurrencies <- (map["availableCurrencies"], StringListTransform())
        includeTax <- map["includeTax"]
        pricingPer <- map["pricingPer"]
        status <- map["status"]
        supplier <- map["supplier"]
        destination <- map["destination"]
        categories <- (map["categories"], ListTransform<BigBusCategoryModel>())
    }
    
    func isValid() -> Bool {
        return true
    }}

class BigBusCategoryModel: Object, Mappable, ModelProtocol {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var defaults: Bool = false
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var shortDescription: String = kEmptyString
    @objc dynamic var coverImageUrl: String = kEmptyString
    @objc dynamic var bannerImageUrl: String = kEmptyString

    required convenience init?(map: Map) { self.init() }
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        defaults <- map["default"]
        title <- map["title"]
        shortDescription <- map["shortDescription"]
        coverImageUrl <- map["coverImageUrl"]
        bannerImageUrl <- map["bannerImageUrl"]
    }
    
    func isValid() -> Bool {
        return true
    }
}

class ImageInfoModel: Object, Mappable, ModelProtocol {
    @objc dynamic var url: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var caption: String = kEmptyString

    required convenience init?(map: Map) { self.init() }
    func mapping(map: Map) {
        url <- map["url"]
        title <- map["title"]
        caption <- map["caption"]
    }
    
    func isValid() -> Bool {
        return true
    }
}

class FAQModel: Object, Mappable, ModelProtocol {
    @objc dynamic var question: String = kEmptyString
    @objc dynamic var answer: String = kEmptyString

    required convenience init?(map: Map) { self.init() }
    func mapping(map: Map) {
        question <- map["question"]
        answer <- map["answer"]
    }
    
    func isValid() -> Bool {
        return true
    }
}

class BigBusOptionsModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = ""
    @objc dynamic var defaultOption: Bool = false
    @objc dynamic var internalName: String = ""
    @objc dynamic var reference: String = kEmptyString
    var tags = List<String>()
    var availabilityLocalStartTimes = List<String>()
    @objc dynamic var availabilityLocalDateStart: String = kEmptyString
    @objc dynamic var availabilityLocalDateEnd: String = kEmptyString
    @objc dynamic var cancellationCutoff: String = kEmptyString
    @objc dynamic var cancellationCutoffAmount: Int = 0
    @objc dynamic var cancellationCutoffUnit: String = kEmptyString
    @objc dynamic var availabilityCutoff: String = kEmptyString
    @objc dynamic var availabilityCutoffAmount: Int = 0
    @objc dynamic var availabilityCutoffUnit: String = kEmptyString
    var visibleContactFields = List<String>()
    var requiredContactFields = List<String>()
    @objc dynamic var restrictions: OptionRestrictionsModel? = nil
    var units = List<BigBusUnitModel>()
    @objc dynamic var title: String = ""
    @objc dynamic var subtitle: String = kEmptyString
    @objc dynamic var language: String = kEmptyString
    @objc dynamic var shortDescription: String = kEmptyString
    @objc dynamic var duration: String = kEmptyString
    @objc dynamic var unit: String = ""
    @objc dynamic var notes: String = kEmptyString
    @objc dynamic var durationAmount: Int = 0
    @objc dynamic var durationUnit: String = kEmptyString
    @objc dynamic var coverImageUrl: String = kEmptyString
    var itinerary = List<ItineraryModel>()
    @objc dynamic var fromPoint: String = kEmptyString
    @objc dynamic var toPoint: String = kEmptyString
    @objc dynamic var pickupAvailable: Bool = false
    @objc dynamic var pickupRequired: Bool = false
    @objc dynamic var adultTitle: String = kEmptyString
    @objc dynamic var childTitle: String = kEmptyString
    @objc dynamic var infantTitle: String = kEmptyString
    @objc dynamic var adultDesc: String = kEmptyString
    @objc dynamic var childDesc: String = kEmptyString
    @objc dynamic var infantDesc: String = kEmptyString
    var pickupPoints = List<PickupListModel>() // adjust if complex object
    
    // MARK: Init
    required convenience init?(map: Map) { self.init() }
    
    // MARK: Mapping
    func mapping(map: Map) {
        id <- map["id"]
        defaultOption <- map["default"]
        internalName <- map["internalName"]
        reference <- map["reference"]
        tags <- (map["tags"], StringListTransform())
        availabilityLocalStartTimes <- (map["availabilityLocalStartTimes"], StringListTransform())
        availabilityLocalDateStart <- map["availabilityLocalDateStart"]
        availabilityLocalDateEnd <- map["availabilityLocalDateEnd"]
        cancellationCutoff <- map["cancellationCutoff"]
        cancellationCutoffAmount <- map["cancellationCutoffAmount"]
        cancellationCutoffUnit <- map["cancellationCutoffUnit"]
        availabilityCutoff <- map["availabilityCutoff"]
        availabilityCutoffAmount <- map["availabilityCutoffAmount"]
        availabilityCutoffUnit <- map["availabilityCutoffUnit"]
        visibleContactFields <- (map["visibleContactFields"], StringListTransform())
        requiredContactFields <- (map["requiredContactFields"], StringListTransform())
        restrictions <- map["restrictions"]
        units <- (map["units"], ListTransform<BigBusUnitModel>())
        title <- map["title"]
        subtitle <- map["subtitle"]
        unit <- map["unit"]
        notes <- map["notes"]
        language <- map["language"]
        shortDescription <- map["shortDescription"]
        duration <- map["duration"]
        durationAmount <- map["durationAmount"]
        durationUnit <- map["durationUnit"]
        coverImageUrl <- map["coverImageUrl"]
        itinerary <- (map["itinerary"], ListTransform<ItineraryModel>())
        fromPoint <- map["fromPoint"]
        toPoint <- map["toPoint"]
        pickupAvailable <- map["pickupAvailable"]
        pickupRequired <- map["pickupRequired"]
        pickupPoints <- (map["pickupPoints"], ListTransform<PickupListModel>())
        adultTitle <- map["adult_title"]
        childTitle <- map["child_title"]
        infantTitle <- map["infant_title"]
        adultDesc <- map["adult_description"]
        childDesc <- map["child_description"]
        infantDesc <- map["infant_description"]
    }
    
    func isValid() -> Bool {
        return true
    }
}

class OptionRestrictionsModel: Object, Mappable, ModelProtocol {
    @objc dynamic var minUnits: Int = 0
    @objc dynamic var maxUnits: Int = 1000
    @objc dynamic var minPaxCount: Int = 0
    @objc dynamic var maxPaxCount: Int = 1000
    
    required convenience init?(map: Map) { self.init() }
    func mapping(map: Map) {
        minUnits <- map["minUnits"]
        maxUnits <- map["maxUnits"]
        minPaxCount <- map["minPaxCount"]
        maxPaxCount <- map["maxPaxCount"]
    }
    
    func isValid() -> Bool {
        return true
    }
}

class BigBusUnitModel: Object, Mappable, ModelProtocol {
    @objc dynamic var id: String = ""
    @objc dynamic var internalName: String = ""
    @objc dynamic var reference: String = kEmptyString
    var tags = List<String>()
    @objc dynamic var type: String = ""
    var visibleContactFields = List<String>()
    var requiredContactFields = List<String>()
    @objc dynamic var restrictions: UnitRestrictionsModel? = nil
    @objc dynamic var title: String = ""
    @objc dynamic var titlePlural: String = ""
    @objc dynamic var subtitle: String = kEmptyString
    var pricingFrom = List<PricingModel>()
    
    required convenience init?(map: Map) { self.init() }
    func mapping(map: Map) {
        id <- map["id"]
        internalName <- map["internalName"]
        reference <- map["reference"]
        tags <- (map["tags"], StringListTransform())
        type <- map["type"]
        visibleContactFields <- (map["visibleContactFields"], StringListTransform())
        requiredContactFields <- (map["requiredContactFields"], StringListTransform())
        restrictions <- map["restrictions"]
        title <- map["title"]
        titlePlural <- map["titlePlural"]
        subtitle <- map["subtitle"]
        pricingFrom <- (map["pricingFrom"], ListTransform<PricingModel>())
    }
    
    func isValid() -> Bool {
        return true
    }
}

class UnitRestrictionsModel: Object, Mappable, ModelProtocol {
    @objc dynamic var requiredBool: Bool = false
    @objc dynamic var minAge: Int = 0
    @objc dynamic var maxAge: Int = 0
    @objc dynamic var idRequired: Bool = false
    @objc dynamic var minQuantity: Int = 0
    @objc dynamic var maxQuantity: Int = 0
    @objc dynamic var paxCount: Int = 0
    var accompaniedBy = List<String>()
    @objc dynamic var accompaniedByRatio: String = kEmptyString
    
    required convenience init?(map: Map) { self.init() }
    func mapping(map: Map) {
        requiredBool <- map["required"]
        minAge <- map["minAge"]
        maxAge <- map["maxAge"]
        idRequired <- map["idRequired"]
        minQuantity <- map["minQuantity"]
        maxQuantity <- map["maxQuantity"]
        paxCount <- map["paxCount"]
        accompaniedBy <- (map["accompaniedBy"], StringListTransform())
        accompaniedByRatio <- map["accompaniedByRatio"]
    }
    
    func isValid() -> Bool {
        return true
    }
}

class PricingModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var unitId: String = kEmptyString
    @objc dynamic var unitType: String = kEmptyString
    @objc dynamic var original: Int = 0
    @objc dynamic var retail: Int = 0
    @objc dynamic var net: Int = 0
    @objc dynamic var currency: String = kEmptyString
    @objc dynamic var currencyPrecision: Int = 0
    @objc dynamic var netOctoPrice: Int = 0
    var includedTaxes = List<TaxModel>()
    @objc dynamic var withoutDiscountNet: Int = 0
    @objc dynamic var netBeforeDiscount: Int = 0
    
    required convenience init?(map: Map) { self.init() }
    func mapping(map: Map) {
        unitId <- map["unitId"]
        unitType <- map["unitType"]
        original <- map["original"]
        retail <- map["retail"]
        net <- map["net"]
        currency <- map["currency"]
        currencyPrecision <- map["currencyPrecision"]
        includedTaxes <- (map["includedTaxes"], ListTransform<TaxModel>())
        withoutDiscountNet <- map["withoutDiscountNet"]
        netOctoPrice <- map["netOctoPrice"]
        netBeforeDiscount <- map["netBeforeDiscount"]
    }
    
    var currencyDivisor: Double {
            pow(10.0, Double(currencyPrecision))
        }

        var adjustedOriginal: Double {
            Double(original) / currencyDivisor
        }
    
        var adjustedRetail: Double {
            Double(retail) / currencyDivisor
        }
    
        var adjustedNet: Double {
            Double(net) / currencyDivisor
        }
    
        var adjustedWithoutDiscountNet: Double {
            Double(withoutDiscountNet) / currencyDivisor
        }
    
    var adjustedNetWithoutDiscount: Double {
        Double(netBeforeDiscount) / currencyDivisor
    }
    
    func isValid() -> Bool {
        return true
    }
}

class TaxModel: Object, Mappable, ModelProtocol {
    @objc dynamic var name: String = ""
    @objc dynamic var shortDescription: String = kEmptyString
    @objc dynamic var original: Int = 0
    @objc dynamic var retail: Int = 0
    @objc dynamic var net: Int = 0
    
    required convenience init?(map: Map) { self.init() }
    func mapping(map: Map) {
        name <- map["name"]
        shortDescription <- map["shortDescription"]
        original <- map["original"]
        retail <- map["retail"]
        net <- map["net"]
    }
    
    func isValid() -> Bool {
        return true
    }
}

class ItineraryModel: Object, Mappable, ModelProtocol {
    @objc dynamic var name: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var descriptionText: String = kEmptyString
    @objc dynamic var address: String = kEmptyString
    @objc dynamic var googlePlaceId: String = kEmptyString
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var travelTime: String = kEmptyString
    @objc dynamic var travelTimeAmount: Int = 0
    @objc dynamic var travelTimeUnit: String = kEmptyString
    @objc dynamic var duration: String = kEmptyString
    @objc dynamic var durationAmount: Int = 0
    @objc dynamic var durationUnit: String = kEmptyString
    
    required convenience init?(map: Map) { self.init() }
    func mapping(map: Map) {
        name <- map["name"]
        type <- map["type"]
        descriptionText <- map["description"]
        address <- map["address"]
        googlePlaceId <- map["googlePlaceId"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        travelTime <- map["travelTime"]
        travelTimeAmount <- map["travelTimeAmount"]
        travelTimeUnit <- map["travelTimeUnit"]
        duration <- map["duration"]
        durationAmount <- map["durationAmount"]
        durationUnit <- map["durationUnit"]
    }
    
    func isValid() -> Bool {
        return true
    }
}

class DestinationModel: Object, Mappable, ModelProtocol{
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var defaultFlag: Bool = false
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var shortDescription: String = kEmptyString
    @objc dynamic var featured: Bool = false
    var tags = List<String>()
    @objc dynamic var country: String = kEmptyString
    @objc dynamic var contact: ContactModel? = nil
    @objc dynamic var brand: BrandModel? = nil
    @objc dynamic var address: String = kEmptyString
    @objc dynamic var googlePlaceId: String = kEmptyString
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var coverImageUrl: String = kEmptyString
    @objc dynamic var bannerImageUrl: String = kEmptyString
    @objc dynamic var videoUrl: String = kEmptyString
    @objc dynamic var facebookUrl: String = kEmptyString
    @objc dynamic var googleUrl: String = kEmptyString
    @objc dynamic var tripadvisorUrl: String = kEmptyString
    @objc dynamic var twitterUrl: String = kEmptyString
    @objc dynamic var youtubeUrl: String = kEmptyString
    @objc dynamic var instagramUrl: String = kEmptyString
    var notices = List<String>()
    @objc dynamic var defaultCurrency: String = kEmptyString
    var availableCurrencies = List<String>()
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id <- map["id"]
        defaultFlag <- map["default"]
        name <- map["name"]
        title <- map["title"]
        shortDescription <- map["shortDescription"]
        featured <- map["featured"]
        tags <- (map["tags"], StringListTransform())
        country <- map["country"]
        contact <- map["contact"]
        brand <- map["brand"]
        address <- map["address"]
        googlePlaceId <- map["googlePlaceId"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        coverImageUrl <- map["coverImageUrl"]
        bannerImageUrl <- map["bannerImageUrl"]
        videoUrl <- map["videoUrl"]
        facebookUrl <- map["facebookUrl"]
        googleUrl <- map["googleUrl"]
        tripadvisorUrl <- map["tripadvisorUrl"]
        twitterUrl <- map["twitterUrl"]
        youtubeUrl <- map["youtubeUrl"]
        instagramUrl <- map["instagramUrl"]
        notices <- (map["notices"], StringListTransform())
        defaultCurrency <- map["defaultCurrency"]
        availableCurrencies <- (map["availableCurrencies"], StringListTransform())
    }
    
    func isValid() -> Bool {
        return true
    }
}

class ContactModel: Object, Mappable, ModelProtocol {
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var email: String = kEmptyString
    @objc dynamic var telephone: String = kEmptyString
    @objc dynamic var address: String = kEmptyString
    @objc dynamic var website: String = kEmptyString
    
    required convenience init?(map: Map) { self.init() }
    func mapping(map: Map) {
        name <- map["name"]
        email <- map["email"]
        telephone <- map["telephone"]
        address <- map["address"]
        website <- map["website"]
    }
    
    func isValid() -> Bool {
        return true
    }
}

class BrandModel: Object, Mappable, ModelProtocol {
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var backgroundColor: String = kEmptyString
    @objc dynamic var checkoutLogoUrl: String = kEmptyString
    @objc dynamic var color: String = kEmptyString
    @objc dynamic var secondaryColor: String = kEmptyString
    @objc dynamic var faviconUrl: String = kEmptyString
    @objc dynamic var logoUrl: String = kEmptyString
    @objc dynamic var logoWhiteUrl: String = kEmptyString
    @objc dynamic var accentFont: FontModel? = nil
    @objc dynamic var bodyFont: FontModel? = nil
    @objc dynamic var headerFont: FontModel? = nil
    @objc dynamic var contact: ContactModel? = nil
    
    required convenience init?(map: Map) { self.init() }
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        backgroundColor <- map["backgroundColor"]
        checkoutLogoUrl <- map["checkoutLogoUrl"]
        color <- map["color"]
        secondaryColor <- map["secondaryColor"]
        faviconUrl <- map["faviconUrl"]
        logoUrl <- map["logoUrl"]
        logoWhiteUrl <- map["logoWhiteUrl"]
        accentFont <- map["accentFont"]
        bodyFont <- map["bodyFont"]
        headerFont <- map["headerFont"]
        contact <- map["contact"]
    }
    
    func isValid() -> Bool {
        return true
    }
}

class FontModel: Object, Mappable, ModelProtocol {
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var normalTtfUrl: String = kEmptyString
    @objc dynamic var boldTtfUrl: String = kEmptyString
    @objc dynamic var italicTtfUrl: String = kEmptyString
    @objc dynamic var boldItalicTtfUrl: String = kEmptyString
    
    required convenience init?(map: Map) { self.init() }
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        normalTtfUrl <- map["normalTtfUrl"]
        boldTtfUrl <- map["boldTtfUrl"]
        italicTtfUrl <- map["italicTtfUrl"]
        boldItalicTtfUrl <- map["boldItalicTtfUrl"]
    }
    
    func isValid() -> Bool {
        return true
    }
}
