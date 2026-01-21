import Foundation
import ObjectMapper
import RealmSwift

class CurrentUserRatingModel : Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var stars: Double = 0.0
    @objc dynamic var review: String = kEmptyString
    @objc dynamic var createdAt: String = kEmptyString
    
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
        userId <- map["userId"]
        stars <- map["stars"]
        review <- map["review"]
        createdAt <- map["createdAt"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

