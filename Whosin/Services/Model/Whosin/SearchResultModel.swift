import Foundation
import ObjectMapper

class SearchResultModel: Mappable, ModelProtocol {
    
    
    @objc dynamic var type: String = kEmptyString
    dynamic var venues : [VenueDetailModel]?
    dynamic var users : [UserDetailModel]?
    dynamic var offers: [OffersModel]?
    dynamic var events: [EventModel]?
    dynamic var activities: [ActivitiesModel]?
    dynamic var tickets: [TicketModel]?
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        type <- map["type"]
        venues <- map["venues"]
        users <- map["users"]
        offers <- map["offers"]
        events <- map["events"]
        activities <- map["activity"]
        tickets <- map["ticket"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}

