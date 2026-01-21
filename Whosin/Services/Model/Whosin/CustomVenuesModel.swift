import Foundation
import ObjectMapper
import RealmSwift

class CustomVenuesModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var subTitle: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var info: String = kEmptyString
    @objc dynamic var badge: String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var offerId: String = kEmptyString
    var venueModel: VenueDetailModel?
    var offerModel: OffersModel?
    
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
        title <- map["title"]
        descriptions <- map["description"]
        info <- map["info"]
        subTitle <- map["subTitle"]
        badge <- map["badge"]
        venueId <- map["venueId"]
        offerId <- map["offerId"]
    }
    
    
    public var _badge: String {
        if (badge.hasSuffix("%")) {
            return "\(badge)"
        } else {
            return "\(badge)%"
        }

    }
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
