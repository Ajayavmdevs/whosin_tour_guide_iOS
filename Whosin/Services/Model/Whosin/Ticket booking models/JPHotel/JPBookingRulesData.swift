import UIKit
import Foundation
import ObjectMapper
import RealmSwift

class JPBookingRulesData: Object, Mappable, ModelProtocol {
    @objc dynamic var status: String = ""
    @objc dynamic var bookingCode: String = ""
    @objc dynamic var expirationDate: String = ""
    @objc dynamic var hotelBookingRequiredFields: JPHotelBookingRequiredFields?
    @objc dynamic var cancellationPolicy: JPCancellationPolicyWrapper?
    var priceInformation = List<JPPriceInformation>()

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        status                   <- map["status"]
        bookingCode              <- map["BookingCode"]
        expirationDate           <- map["ExpirationDate"]
        hotelBookingRequiredFields <- map["hotelBookingRequiredFields"]
        cancellationPolicy       <- map["cancellationPolicy"]
        priceInformation         <- (map["priceInformation"], ListTransform<JPPriceInformation>())
    }
    
    func isValid() -> Bool { return true }

}

class JPHotelBookingRequiredFields: Object, Mappable, ModelProtocol {
    
    @objc dynamic var bookingCode: String = ""
    @objc dynamic var hotelCode: String = ""
    @objc dynamic var startDate: String = ""
    @objc dynamic var endDate: String = ""
    @objc dynamic var priceRange: JPPriceRangeModel?
    var paxes = List<JPPassengerModel>()
    var relPaxesDist = List<JPRelPaxesDistModel>()

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        bookingCode   <- map["bookingCode"]
        hotelCode     <- map["hotelCode"]
        startDate     <- map["startDate"]
        endDate       <- map["endDate"]
        priceRange    <- map["priceRange"]
        paxes         <- (map["paxes"], ListTransform<JPPassengerModel>())
        relPaxesDist  <- (map["relPaxesDist"], ListTransform<JPRelPaxesDistModel>())
    }
    
    func isValid() -> Bool { return true }

}

class JPPaxModel: Object, Mappable, ModelProtocol {
    @objc dynamic var id: String = ""
    @objc dynamic var age: String = ""

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        id  <- map["id"]
        age <- map["age"]
    }
    
    func isValid() -> Bool { return true }

}

class JPCancellationPolicyWrapper: Object, Mappable, ModelProtocol {
    @objc dynamic var Description: String = ""
    var PolicyRules = List<JPCancellationPolicyModel>()   // ✅ reused

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        Description <- map["Description"]
        PolicyRules <- (map["PolicyRules"], ListTransform<JPCancellationPolicyModel>())
    }
    
    func isValid() -> Bool { return true }
}


class JPPriceInformation: Object, Mappable, ModelProtocol {
    @objc dynamic var board: JPBoardModel?
    @objc dynamic var price: JPPriceModel?
    var hotelRooms = List<JPHotelRoomModel>()
    var hotelSupplements = List<JPSupplementModel>()

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        board            <- map["board"]
        price            <- map["price"]
        hotelRooms       <- (map["hotelRooms"], ListTransform<JPHotelRoomModel>())
        hotelSupplements <- (map["hotelSupplements"], ListTransform<JPSupplementModel>())
    }
    
    func isValid() -> Bool { return true }

}
