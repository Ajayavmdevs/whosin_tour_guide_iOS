import Foundation
import ObjectMapper
import RealmSwift

class NearByModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kAppName
    dynamic var users = List<InvitedGuestsModel>()
    dynamic var venues = List<VenueDetailModel>()
    
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
        users <- (map["users"], ListTransform<InvitedGuestsModel>())
        venues <- (map["venues"], ListTransform<VenueDetailModel>())
    }
        
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}
