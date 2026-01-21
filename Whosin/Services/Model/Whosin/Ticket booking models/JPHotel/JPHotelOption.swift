import Foundation
import RealmSwift
import ObjectMapper

class JPHotelOptionModel: Object, Mappable, ModelProtocol {
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var intCode: String = kEmptyString
    @objc dynamic var address: String = kEmptyString
    @objc dynamic var category: String = kEmptyString
    @objc dynamic var checkIn: String = kEmptyString
    @objc dynamic var checkOut: String = kEmptyString
    @objc dynamic var city: String = kEmptyString
    @objc dynamic var contact: JPHotelContactModel?
    @objc dynamic var descriptionText: String = kEmptyString // maps from "description"
    dynamic var images: List<JPHotelImageModel> = List<JPHotelImageModel>()
    dynamic var isFavorite: List<String> = List<String>()
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var roomCount: Int = 0
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var zipCode: String = kEmptyString
    @objc dynamic var hotelRoomsCount: Int = 0
    @objc dynamic var coverImage: String = kEmptyString
    @objc dynamic var thumbImage: String = kEmptyString

    // MARK: - Realm
    override class func primaryKey() -> String? { "_id" }

    // MARK: - ObjectMapper
    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        _id              <- map["_id"]
        intCode          <- map["intCode"]
        address          <- map["address"]
        category         <- map["category"]
        checkIn          <- map["checkIn"]
        checkOut         <- map["checkOut"]
        city             <- map["city"]
        contact          <- map["contact"]
        descriptionText  <- map["description"]
        images           <- (map["images"], ListTransform<JPHotelImageModel>())
        isFavorite       <- (map["isFavorite"], StringListTransform())
        name             <- map["name"]
        roomCount        <- map["roomCount"]
        type             <- map["type"]
        zipCode          <- map["zipCode"]
        hotelRoomsCount  <- map["hotelRoomsCount"]
        coverImage       <- map["coverImage"]
        thumbImage       <- map["thumbImage"]
    }

    func isValid() -> Bool { true }
}

class JPHotelContactModel: Object, Mappable, ModelProtocol {
    @objc dynamic var phone: String = kEmptyString
    @objc dynamic var fax: String = kEmptyString
    @objc dynamic var email: String = kEmptyString

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        phone <- map["phone"]
        fax   <- map["fax"]
        email <- map["email"]
    }

    func isValid() -> Bool { true }
}

class JPHotelImageModel: Object, Mappable, ModelProtocol {
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var image: String = kEmptyString

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        type  <- map["type"]
        image <- map["image"]
    }

    func isValid() -> Bool { true }
}
