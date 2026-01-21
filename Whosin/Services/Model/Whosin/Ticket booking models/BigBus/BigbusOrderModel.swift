//
//  BigbusOrderModel.swift
//  Whosin
//
//  Created by Samir Makadia on 13/08/2025.
//

import ObjectMapper
import RealmSwift

class OctoDetailsModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var uuid: String = kEmptyString
    @objc dynamic var testMode: String = kEmptyString
    @objc dynamic var alias: String = kEmptyString
    @objc dynamic var resellerReference: String = kEmptyString
    @objc dynamic var supplierReference: String = kEmptyString
    @objc dynamic var utcRebookedAt: String = kEmptyString
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var utcCreatedAt: String = kEmptyString
    @objc dynamic var utcUpdatedAt: String = kEmptyString
    @objc dynamic var rebookingUuid: String = kEmptyString
    @objc dynamic var utcConfirmedAt: String = kEmptyString
    @objc dynamic var originalRebookingUuid: String = kEmptyString
    @objc dynamic var productId: String = kEmptyString
    @objc dynamic var optionId: String = kEmptyString
    @objc dynamic var cancellable: Bool = false
    @objc dynamic var updatable: String = kEmptyString
    @objc dynamic var freesale: String = kEmptyString
    @objc dynamic var availabilityId: String = kEmptyString
    @objc dynamic var localDateTimeStart: String = kEmptyString
    @objc dynamic var localDateTimeEnd: String = kEmptyString
    @objc dynamic var product: ProductModel?
    @objc dynamic var option: BigBusOptionsModel?
    @objc dynamic var contact: ContactModel?
    var deliveryMethods = List<String>()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id                   <- map["id"]
        uuid                 <- map["uuid"]
        testMode             <- map["testMode"]
        alias                <- map["alias"]
        rebookingUuid                <- map["rebookingUuid"]
        utcRebookedAt                <- map["utcRebookedAt"]
        originalRebookingUuid                <- map["originalRebookingUuid"]
        resellerReference    <- map["resellerReference"]
        supplierReference    <- map["supplierReference"]
        status               <- map["status"]
        utcCreatedAt         <- map["utcCreatedAt"]
        utcUpdatedAt         <- map["utcUpdatedAt"]
        utcConfirmedAt       <- map["utcConfirmedAt"]
        productId            <- map["productId"]
        optionId             <- map["optionId"]
        cancellable          <- map["cancellable"]
        updatable            <- map["updatable"]
        freesale             <- map["freesale"]
        availabilityId       <- map["availabilityId"]
        localDateTimeStart   <- map["localDateTimeStart"]
        localDateTimeEnd     <- map["localDateTimeEnd"]
        product              <- map["product"]
        option               <- map["option"]
        contact              <- map["contact"]
    }
    
    func isValid() -> Bool {
        return true
    }
}

class ProductModel: Object, Mappable, ModelProtocol {
    @objc dynamic var id: String = ""
    @objc dynamic var internalName: String = ""
    var reference = List<String>()
    var tags = List<String>()
    @objc dynamic var locale: String = ""
    @objc dynamic var timeZone: String = ""
    @objc dynamic var allowFreesale: Bool = false
    var freesaleDurationAmount = RealmOptional<Int>()
    @objc dynamic var freesaleDurationUnit: String = ""
    @objc dynamic var instantConfirmation: Bool = false
    @objc dynamic var instantDelivery: Bool = false
    @objc dynamic var availabilityRequired: Bool = false
    @objc dynamic var availabilityType: String = ""
    var deliveryFormats = List<String>()
    var deliveryMethods = List<String>()
    var settlementMethods = List<String>()
    @objc dynamic var redemptionMethod: String = ""
    var options = List<BigBusOptionsModel>()
    @objc dynamic var title: String = ""
    @objc dynamic var country: String = ""
    @objc dynamic var location: String = ""
    @objc dynamic var address: String = ""
    @objc dynamic var googlePlaceId: String = ""
    @objc dynamic var subtitle: String? = nil
    @objc dynamic var tagline: String? = nil
    var keywords = List<String>()
    @objc dynamic var pointToPoint: Bool = false
    @objc dynamic var shortDescription: String = ""
    @objc dynamic var desc: String = "" // mapped from "description"
    var highlights = List<String>()
    var inclusions = List<String>()
    var exclusions = List<String>()
    @objc dynamic var bookingTerms: String = ""
    @objc dynamic var privacyTerms: String? = nil
    @objc dynamic var redemptionInstructions: String = ""
    @objc dynamic var cancellationPolicy: String? = nil
    @objc dynamic var coverImageUrl: String = ""
    @objc dynamic var bannerImageUrl: String? = nil
    @objc dynamic var videoUrl: String? = nil
    @objc dynamic var brand: BrandModel? = nil
    @objc dynamic var destination: DestinationModel? = nil
    @objc dynamic var defaultCurrency: String = ""
    var availableCurrencies = List<String>()
    @objc dynamic var includeTax: Bool = false
    @objc dynamic var pricingPer: String = ""

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        id <- map["id"]
        internalName <- map["internalName"]
        reference <- (map["reference"], StringListTransform())
        tags <- (map["tags"], StringListTransform())
        locale <- map["locale"]
        timeZone <- map["timeZone"]
        allowFreesale <- map["allowFreesale"]
        freesaleDurationAmount.value <- map["freesaleDurationAmount"]
        freesaleDurationUnit <- map["freesaleDurationUnit"]
        instantConfirmation <- map["instantConfirmation"]
        instantDelivery <- map["instantDelivery"]
        availabilityRequired <- map["availabilityRequired"]
        availabilityType <- map["availabilityType"]
        deliveryFormats <- (map["deliveryFormats"], StringListTransform())
        deliveryMethods <- (map["deliveryMethods"],  StringListTransform())
        settlementMethods <- (map["settlementMethods"],  StringListTransform())
        redemptionMethod <- map["redemptionMethod"]
        options <- (map["options"], ListTransform<BigBusOptionsModel>())
        title <- map["title"]
        country <- map["country"]
        location <- map["location"]
        address <- map["address"]
        googlePlaceId <- map["googlePlaceId"]
        subtitle <- map["subtitle"]
        tagline <- map["tagline"]
        pointToPoint <- map["pointToPoint"]
        shortDescription <- map["shortDescription"]
        desc <- map["description"]
        highlights <- (map["highlights"], StringListTransform())
        inclusions <- (map["inclusions"], StringListTransform())
        exclusions <- (map["exclusions"], StringListTransform())
        bookingTerms <- map["bookingTerms"]
        privacyTerms <- map["privacyTerms"]
        redemptionInstructions <- map["redemptionInstructions"]
        cancellationPolicy <- map["cancellationPolicy"]
        coverImageUrl <- map["coverImageUrl"]
        bannerImageUrl <- map["bannerImageUrl"]
        videoUrl <- map["videoUrl"]
        brand <- map["brand"]
        destination <- map["destination"]
        defaultCurrency <- map["defaultCurrency"]
        includeTax <- map["includeTax"]
        pricingPer <- map["pricingPer"]
    }

    func isValid() -> Bool { return !id.isEmpty }
}
