import Foundation
import RealmSwift
import ObjectMapper

struct TourPriceSummary {
    let totalAmount: Double
    let priceToPay: Double
    let discountPrice: Double
    let priceWithPromo: Double
    let pricePerTrip: Double
    let totalAddOnAmout: Double
}


class BookingModel:Object, Mappable, ModelProtocol {
    
    var passengers: [PassengersModel] = []
    var tourDetails : [TourOptionDetailModel] = []
    @objc dynamic var currency: String = ""
    @objc dynamic var customTicketId: String = ""
    @objc dynamic var discount: Double = 0.0
    @objc dynamic var promoCode: String = ""
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var totalAmount: Double = 0.0
    @objc dynamic var paymentMethod: String = ""
    @objc dynamic var sourcePlatform: String = "iOS"
    @objc dynamic var bookingType: String = "rayna"
    @objc dynamic var cartId: String = ""
    @objc dynamic var _id: String = ""
    @objc dynamic var createdAt: Date? = nil
    var cancellationPolicy: [TourPolicyModel] = []
    
    // MARK: - Date Formatter
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kStanderdDate)
    private let _fallbackFormatter = DATEFORMATTER.dateFormatterWith(format: kStanderdDate)

    
    required convenience init?(map: Map) {
        self.init()
    }
    

    
    func mapping(map: Map) {
        cartId <- map["cartId"]
        passengers <- map["passengers"]
        _id <- map["_id"]
        tourDetails <- map["TourDetails"]
        currency <- map["currency"]
        customTicketId <- map["customTicketId"]
        sourcePlatform <- map["sourcePlatform"]
        discount <- map["discount"]
        promoCode <- map["promoCode"]
        amount <- map["amount"]
        totalAmount <- map["totalAmount"]
        paymentMethod <- map["paymentMethod"]
        bookingType <- map["bookingType"]
        cancellationPolicy <- map["cancellationPolicy"]
        var createdAtString: String?
        createdAtString <- map["createdAt"]
        if let value = createdAtString {
            createdAt = _dateFormatter.date(from: value) ?? _fallbackFormatter.date(from: value)
        }
    }
    
    
    
    func isValid() -> Bool {
        return true
    }
}

class PassengerModel: Mappable, ModelProtocol {
    
    @objc dynamic var mobile: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var serviceType: String = ""
    @objc dynamic var pickup: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var nationality: String = ""
    @objc dynamic var leadPassenger: Int = 0
    @objc dynamic var paxType: String = ""
    @objc dynamic var prefix: String = ""
    @objc dynamic var firstName: String = ""

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        mobile <- map["mobile"]
        email <- map["email"]
        serviceType <- map["serviceType"]
        pickup <- map["pickup"]
        lastName <- map["lastName"]
        nationality <- map["nationality"]
        leadPassenger <- map["leadPassenger"]
        paxType <- map["paxType"]
        prefix <- map["prefix"]
        firstName <- map["firstName"]
    }
    
    func isValid() -> Bool {
        return true
    }
    
}


class TourOptionDetailModel: Mappable, ModelProtocol {
    
    @objc dynamic var tourId: String = ""
    @objc dynamic var pickup: String = ""
    @objc dynamic var pickupLong: String = ""
    @objc dynamic var pickupLat: String = ""
    @objc dynamic var startTime: String = ""
    @objc dynamic var endTime: String = ""
    @objc dynamic var optionId: String = ""
    @objc dynamic var message: String = ""
    @objc dynamic var hotelId: Int = 0
    @objc dynamic var infant: Int = 0
    @objc dynamic var tourDate: String = ""
    @objc dynamic var adultRate: Double = 0.0
    @objc dynamic var child: Int = 0
    @objc dynamic var childRate: Double = 0.0
    @objc dynamic var adult: Int = 0
    @objc dynamic var timeSlotId: String = ""
    @objc dynamic var transferId: Int = 0
    @objc dynamic var transferIdString: String = kEmptyString
    @objc dynamic var serviceTotal: Double = 0.0
    @objc dynamic var departureTime: String = ""
    @objc dynamic var adultId: String = ""
    @objc dynamic var childId: String = ""
    @objc dynamic var infantId: String = ""
    @objc dynamic var whosinTotal: Double = 0.0
    @objc dynamic var timeSlot: String = kEmptyString
    @objc dynamic var adultTitle: String = kEmptyString
    @objc dynamic var childTitle: String = kEmptyString
    @objc dynamic var infantTitle: String = kEmptyString
    @objc dynamic var adultDesc: String = kEmptyString
    @objc dynamic var childDesc: String = kEmptyString
    @objc dynamic var infantDesc: String = kEmptyString
    @objc dynamic var addOnTitle: String = kEmptyString
    @objc dynamic var addOndesc: String = kEmptyString
    @objc dynamic var addOnImage: String = kEmptyString
    var tempTransferId: Any?
    var Addons: [TourOptionDetailModel] = []
    

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        tourId <- map["tourId"]
        pickup <- map["pickup"]
        pickupLat <- map["pickupLat"]
        pickupLong <- map["pickupLong"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        optionId <- map["optionId"]
        hotelId <- map["hotelId"]
        message <- map["message"]
        infant <- map["infant"]
        tourDate <- map["tourDate"]
        adultRate <- map["adultRate"]
        child <- map["child"]
        childRate <- map["childRate"]
        adult <- map["adult"]
        adultId <- map["adultId"]
        childId <- map["childId"]
        infantId <- map["infantId"]
        timeSlotId <- map["timeSlotId"]
        Addons <- map["Addons"]
        if map.mappingType == .fromJSON {
            if let intVal = map.JSON["transferId"] as? Int {
                transferId = intVal
                transferIdString = "\(intVal)"
            } else if let strVal = map.JSON["transferId"] as? String {
                if let intFromStr = Int(strVal) {
                    transferId = intFromStr
                    transferIdString = strVal
                } else {
                    transferId = 0
                    transferIdString = strVal
                }
            }
        } else {
            tempTransferId = transferIdString.isEmpty ? transferId : transferIdString
            tempTransferId <- map["transferId"]
        }
        serviceTotal <- map["serviceTotal"]
        departureTime <- map["departureTime"]
        whosinTotal <- map["whosinTotal"]
        timeSlot <- map["timeSlot"]
        adultTitle <- map["adult_title"]
        childTitle <- map["child_title"]
        infantTitle <- map["infant_title"]
        adultDesc <- map["adult_description"]
        childDesc <- map["child_description"]
        infantDesc <- map["infant_description"]
        addOnTitle <- map["addOnTitle"]
        addOndesc <- map["addOndesc"]
        addOnImage <- map["addOnImage"]
    }
    
    func isValid() -> Bool {
        return true
    }

}

