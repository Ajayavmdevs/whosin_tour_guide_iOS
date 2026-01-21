import Foundation
import ObjectMapper
import RealmSwift

class ShoutoutListModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var caption: String = kEmptyString
    @objc dynamic var user: UserDetailModel?
    dynamic var withMe = List<UserDetailModel>()
    @objc dynamic var venue: VenueDetailModel?
    
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
        type <- map["type"]
        caption <- map["caption"]
        user <- map["user"]
        withMe <- (map["withMe"],ListTransform<UserDetailModel>())
        venue <- map["venue"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
