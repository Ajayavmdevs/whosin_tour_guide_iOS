import Foundation
import ObjectMapper
import RealmSwift

class EventDetailModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var event: EventModel?
    dynamic var user = List<UserDetailModel>()
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        event <- map["event"]
        user <- (map["users"],ListTransform<UserDetailModel>())

    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
