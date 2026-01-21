import Foundation
import ObjectMapper
import RealmSwift

class RecommendedModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    dynamic var category = List<CategoryDetailModel>()
    dynamic var deals = List<DealsModel>()
    dynamic var venues = List<VenueDetailModel>()
    dynamic 
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        type <- map["type"]
        category <- (map["category"],ListTransform<CategoryDetailModel>())
        deals <- (map["deals"],ListTransform<DealsModel>())
        venues <- (map["venues"],ListTransform<VenueDetailModel>())

    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

