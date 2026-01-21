import Foundation
import ObjectMapper

class ExploreModel: Mappable, ModelProtocol {
    
    
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var offers: OffersModel?
    @objc dynamic var events: EventModel?
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
        offers <- map["offer"]
        events <- map["event"]
        activity <- map["activity"]
        createdAt <- map["createdAt"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}

