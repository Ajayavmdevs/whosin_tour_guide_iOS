import Foundation
import ObjectMapper
import RealmSwift

class UserFeedModel: Mappable, ModelProtocol {
    
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var venue: VenueDetailModel?
    @objc dynamic var offer: OffersModel?
    @objc dynamic var event: EventModel?
    @objc dynamic var user: UserDetailModel?
    @objc dynamic var activity: ActivitiesModel?
    @objc dynamic var createdAt: String = kEmptyString
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        type <- map["type"]
        venue <- map["venue"]
        offer <- map["offer"]
        event <- map["event"]
        user <- map["user"]
        activity  <- map["activity"]
        createdAt <- map["createdAt"]
        
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}
