
import Foundation
import ObjectMapper
import RealmSwift

class CustomComponentModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var badge: String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var offerId: String = kEmptyString
    @objc dynamic var ticketId: String = kEmptyString

    //--------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        title <- map["title"]
        descriptions <- map["description"]
        image <- map["image"]
        type <- map["type"]
        badge <- map["badge"]
        venueId <- map["venueId"]
        offerId <- map["offerId"]
        ticketId <- map["ticketId"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
