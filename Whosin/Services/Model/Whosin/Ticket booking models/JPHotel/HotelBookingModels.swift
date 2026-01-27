import UIKit
import Foundation
import ObjectMapper
import RealmSwift

// MARK: - Root Model
class JPHotelBookingModel: Object, Mappable, ModelProtocol {
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var totalAmount: Double = 0.0
    @objc dynamic var currency: String = kEmptyString
    @objc dynamic var customTicketId: String = kEmptyString
    @objc dynamic var comment: String = kEmptyString
    @objc dynamic var bookingCode: String = kEmptyString
    @objc dynamic var sourcePlatform: String = kEmptyString
    @objc dynamic var paymentMethod: String = kEmptyString
    @objc dynamic var bookingType: String = "juniper-hotel"
    @objc dynamic var promoCode: String = "juniper-hotel"

    var tourDetails = List<JPTourDetailModel>()
    var passengers = List<JPPassengerModel>()
    @objc dynamic var priceRange: JPPriceRangeModel?
    var relPaxesDist = List<JPRelPaxesDistModel>()
    var cancellationPolicy = List<JPCancellationPolicyModel>()

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        amount              <- map["amount"]
        totalAmount         <- map["totalAmount"]
        currency            <- map["currency"]
        customTicketId      <- map["customTicketId"]
        comment             <- map["comment"]
        sourcePlatform      <- map["sourcePlatform"]
        bookingCode         <- map["bookingCode"]
        paymentMethod       <- map["paymentMethod"]
        bookingType         <- map["bookingType"]
        promoCode           <- map["promoCode"]
        tourDetails         <- (map["TourDetails"], ListTransform<JPTourDetailModel>())
        passengers          <- (map["passengers"], ListTransform<JPPassengerModel>())
        priceRange          <- map["priceRange"]
        relPaxesDist        <- (map["relPaxesDist"], ListTransform<JPRelPaxesDistModel>())
        cancellationPolicy  <- (map["cancellationPolicy"], ListTransform<JPCancellationPolicyModel>())
    }

    func isValid() -> Bool { return true }
}

// MARK: - Tour Detail
class JPTourDetailModel: Object, Mappable, ModelProtocol {
    @objc dynamic var tourId: String = kEmptyString
    @objc dynamic var optionId: String?
    @objc dynamic var adult: Int = 0
    @objc dynamic var child: Int = 0
    @objc dynamic var infant: Int = 0
    @objc dynamic var startDate: String = kEmptyString
    @objc dynamic var endDate: String = kEmptyString
    @objc dynamic var startTime: String = kEmptyString
    @objc dynamic var serviceTotal: String = kEmptyString
    @objc dynamic var whosinTotal: String = kEmptyString

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        tourId       <- map["tourId"]
        optionId     <- map["optionId"]
        adult        <- map["adult"]
        child        <- map["child"]
        infant       <- map["infant"]
        startDate    <- map["startDate"]
        endDate      <- map["endDate"]
        startTime    <- map["startTime"]
        serviceTotal <- map["serviceTotal"]
        whosinTotal  <- map["whosinTotal"]
    }

    func isValid() -> Bool { return true }
}

// MARK: - Price Range
class JPPriceRangeModel: Object, Mappable, ModelProtocol {
    @objc dynamic var minimum: String = kEmptyString
    @objc dynamic var maximum: String = kEmptyString
    @objc dynamic var currency: String = kEmptyString

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        minimum  <- map["Minimum"]
        maximum  <- map["Maximum"]
        currency <- map["Currency"]
    }

    func isValid() -> Bool { return true }
}

