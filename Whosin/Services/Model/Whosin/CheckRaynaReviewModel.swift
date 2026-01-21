import Foundation
import ObjectMapper

class CheckRaynaReviewModel: Mappable, ModelProtocol {
    
    @objc dynamic var id: String = ""
    @objc dynamic var userId: String = ""
    @objc dynamic var customTicketId: String = ""
    @objc dynamic var createdAt: String = ""
    @objc dynamic var reviewStatus: String = ""
    @objc dynamic var ticketName: String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        userId <- map["userId"]
        customTicketId <- map["customTicketId"]
        createdAt <- map["createdAt"]
        reviewStatus <- map["reviewStatus"]
        ticketName <- map["ticketName"]
    }
    
    
    
    func isValid() -> Bool {
        return true
    }
}
