import Foundation
import ObjectMapper

class SearchHistoryModel: Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var subtitle: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var isPromoter: Bool = false
    @objc dynamic var isRingMember: Bool = false

    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        type <- map["type"]
        title <- map["title"]
        subtitle <- map["subtitle"]
        image <- map["image"]
        venueId <- map["venueId"]
        isPromoter <- map["isPromoter"]
        isRingMember <- map["isRingMember"]
        
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}


