import Foundation
import ObjectMapper
import RealmSwift

class SpecialOffersModel : Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var discount: Int = 0
    @objc dynamic var claimCode: String = kEmptyString
    dynamic var brunchIds = List<String>()
    @objc dynamic var maxPersonAllowed: Int = 0
    @objc dynamic var maxBrunchAllowed: Int = 0
    dynamic var branches = List<BrunchModel>()
    dynamic var brunch = List<BrunchModel>()
    @objc dynamic var pricePerPerson: Int = 0
    dynamic var offers: OffersModel?
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    override class func primaryKey() -> String? {
        "id"
    }

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        venueId <- map["venueId"]
        title <- map["title"]
        descriptions <- map["description"]
        type <- map["type"]
        discount <- map["discount"]
        claimCode <- map["claimCode"]
        maxPersonAllowed <- map["maxPersonAllowed"]
        maxBrunchAllowed <- map["maxBrunchAllowed"]
        branches <- (map["branches"], ListTransform<BrunchModel>())
        brunch <- (map["brunch"], ListTransform<BrunchModel>())
        pricePerPerson <- map["pricePerPerson"]
        brunchIds <- (map["brunchIds"], StringListTransform())
        offers <- map["offers"]

    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
