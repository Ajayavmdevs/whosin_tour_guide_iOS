import Foundation
import RealmSwift
import ObjectMapper

class JPHotelAvailibilityModel: Object, Mappable, ModelProtocol {
    @objc dynamic var hotelInfo: JPHotelInfoModel?
    var hotelOptions = List<JPHotelAvailibilityOptionModel>()

    required convenience init?(map: Map) { self.init() }

    override init() { super.init() }

    func mapping(map: Map) {
        hotelInfo   <- map["hotelInfo"]
        hotelOptions <- (map["hotelOptions"], ListTransform<JPHotelAvailibilityOptionModel>())
    }

    func isValid() -> Bool { true }
}

// MARK: - Hotel Info
class JPHotelInfoModel: Object, Mappable {
    @objc dynamic var code: String = kEmptyString
    @objc dynamic var jpCode: String = kEmptyString
    @objc dynamic var jpdCode: String = kEmptyString
    @objc dynamic var bestDeal: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var destinationZone: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var infoDescription: String = kEmptyString // mapping from "Description"
    @objc dynamic var hotelChain: String = kEmptyString
    @objc dynamic var latitude: String = kEmptyString
    @objc dynamic var longitude: String = kEmptyString
    @objc dynamic var address: String = kEmptyString
    @objc dynamic var hotelCategory: String = kEmptyString
    @objc dynamic var hotelCategoryType: String = kEmptyString
    @objc dynamic var hotelType: String = kEmptyString

    var label = List<String>()
    var images = List<String>()

    @objc dynamic var checkTime: JPCheckTimeModel?

    required convenience init?(map: Map) { self.init() }
    override init() { super.init() }

    func mapping(map: Map) {
        code              <- map["Code"]
        jpCode            <- map["JPCode"]
        jpdCode           <- map["JPDCode"]
        bestDeal          <- map["BestDeal"]
        type              <- map["Type"]
        destinationZone   <- map["DestinationZone"]
        name              <- map["Name"]
        infoDescription   <- map["Description"]
        hotelChain        <- map["HotelChain"]
        latitude          <- map["Latitude"]
        longitude         <- map["Longitude"]
        address           <- map["Address"]
        hotelCategory     <- map["HotelCategory"]
        hotelCategoryType <- map["HotelCategoryType"]
        hotelType         <- map["HotelType"]

        label  <- (map["Label"], StringListTransform())
        images <- (map["Images"], StringListTransform())

        checkTime <- map["CheckTime"]
    }
}

class JPCheckTimeModel: Object, Mappable {
    @objc dynamic var checkIn: String = kEmptyString
    @objc dynamic var checkOut: String = kEmptyString

    required convenience init?(map: Map) { self.init() }
    override init() { super.init() }

    func mapping(map: Map) {
        checkIn  <- map["CheckIn"]
        checkOut <- map["CheckOut"]
    }
}

// MARK: - Hotel Options
class JPHotelAvailibilityOptionModel: Object, Mappable {
    @objc dynamic var ratePlanCode: String = kEmptyString
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var nonRefundable: String = kEmptyString
    @objc dynamic var packageContract: String = kEmptyString

    @objc dynamic var board: JPBoardModel?
    @objc dynamic var price: JPPriceModel?

    var hotelRooms = List<JPHotelRoomModel>()
    var hotelSupplements = List<JPSupplementModel>()
    var hotelOffers = List<JPOfferModel>()

    required convenience init?(map: Map) { self.init() }
    override init() { super.init() }

    func mapping(map: Map) {
        ratePlanCode    <- map["RatePlanCode"]
        status          <- map["Status"]
        nonRefundable   <- map["NonRefundable"]
        packageContract <- map["PackageContract"]
        board <- map["board"]
        price <- map["price"]
        hotelRooms       <- (map["hotelRooms"], ListTransform<JPHotelRoomModel>())
        hotelSupplements <- (map["hotelSupplements"], ListTransform<JPSupplementModel>())
        hotelOffers      <- (map["hotelOffers"], ListTransform<JPOfferModel>())
    }
}

class JPBoardModel: Object, Mappable {
    @objc dynamic var boardName: String = kEmptyString // mapping from "Board"
    @objc dynamic var typeCode: String = kEmptyString  // mapping from "Type"

    required convenience init?(map: Map) { self.init() }
    override init() { super.init() }

    func mapping(map: Map) {
        boardName <- map["Board"]
        typeCode  <- map["Type"]
    }
}

class JPPriceModel: Object, Mappable {
    @objc dynamic var currency: String = kEmptyString
    @objc dynamic var recommended: String? = nil // can be null in JSON
    @objc dynamic var gross: String = kEmptyString
    @objc dynamic var nett: String = kEmptyString
    @objc dynamic var amount: String = kEmptyString

    @objc dynamic var serviceTaxes: JPServiceTaxesModel?

    required convenience init?(map: Map) { self.init() }
    override init() { super.init() }

    func mapping(map: Map) {
        currency     <- map["Currency"]
        recommended  <- map["Recommended"]
        gross        <- map["Gross"]
        nett         <- map["Nett"]
        amount       <- map["Amount"]
        serviceTaxes <- map["ServiceTaxes"]
    }
}

class JPServiceTaxesModel: Object, Mappable {
    @objc dynamic var included: String = kEmptyString
    @objc dynamic var amount: String = kEmptyString

    required convenience init?(map: Map) { self.init() }
    override init() { super.init() }

    func mapping(map: Map) {
        included <- map["Included"]
        amount   <- map["Amount"]
    }
}

class JPHotelRoomModel: Object, Mappable {
    @objc dynamic var source: String = kEmptyString
    @objc dynamic var units: String = kEmptyString
    @objc dynamic var availRooms: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var roomCategory: String = kEmptyString
    @objc dynamic var typeCode: String = kEmptyString 
    @objc dynamic var jrCode: String = kEmptyString
    var features = List<String>()

    @objc dynamic var roomOccupancy: JPRoomOccupancyModel?

    required convenience init?(map: Map) { self.init() }
    override init() { super.init() }

    func mapping(map: Map) {
        source       <- map["Source"]
        units        <- map["Units"]
        availRooms   <- map["AvailRooms"]
        var tmpName: String?
        tmpName <- map["Name"]
        if (tmpName?.isEmpty ?? true) {
            tmpName <- map["name"]
        }
        name = tmpName ?? ""

        var tmpCategory: String?
        tmpCategory <- map["RoomCategory"]
        if (tmpCategory?.isEmpty ?? true) {
            tmpCategory <- map["category"]
        }
        roomCategory = tmpCategory ?? ""

        var tmpType: String?
        tmpType <- map["Type"]
        if (tmpType?.isEmpty ?? true) {
            tmpType <- map["categoryType"]
        }
        typeCode = tmpType ?? ""
        roomOccupancy <- map["RoomOccupancy"]
        jrCode <- map["jrCode"]
        features <- (map["features"],StringListTransform())
    }
}

class JPRoomOccupancyModel: Object, Mappable {
    @objc dynamic var occupancy: String = kEmptyString
    @objc dynamic var maxOccupancy: String = kEmptyString
    @objc dynamic var adults: String = kEmptyString
    @objc dynamic var children: String = kEmptyString

    required convenience init?(map: Map) { self.init() }
    override init() { super.init() }

    func mapping(map: Map) {
        occupancy    <- map["Occupancy"]
        maxOccupancy <- map["MaxOccupancy"]
        adults       <- map["Adults"]
        children     <- map["Children"]
    }
}

class JPSupplementModel: Object, Mappable {
    @objc dynamic var code: String = kEmptyString
    @objc dynamic var onlyResidents: String = kEmptyString
    @objc dynamic var ratePlanCode: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var descriptionText: String = kEmptyString // mapping from "Description"
    @objc dynamic var price: JPPriceModel?


    required convenience init?(map: Map) { self.init() }
    override init() { super.init() }

    func mapping(map: Map) {
        code           <- map["Code"]
        onlyResidents  <- map["OnlyResidents"]
        ratePlanCode  <- map["RatePlanCode"]
        name           <- map["Name"]
        descriptionText <- map["Description"]
        price <- map["price"]
    }
}

class JPOfferModel: Object, Mappable {
    @objc dynamic var code: String = kEmptyString
    @objc dynamic var category: String = kEmptyString
    @objc dynamic var onlyResidents: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var descriptionText: String = kEmptyString // mapping from "Description"

    required convenience init?(map: Map) { self.init() }
    override init() { super.init() }

    func mapping(map: Map) {
        code            <- map["Code"]
        category        <- map["Category"]
        onlyResidents   <- map["OnlyResidents"]
        name            <- map["Name"]
        descriptionText <- map["Description"]
    }
}


