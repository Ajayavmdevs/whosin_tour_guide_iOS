import Foundation
import ObjectMapper

class SearchResultModel: Mappable, ModelProtocol {
    
    
    @objc dynamic var type: String = kEmptyString
    dynamic var tickets: [TicketModel]?
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        type <- map["type"]
        tickets <- map["ticket"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}

