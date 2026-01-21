import Foundation
import ObjectMapper
import RealmSwift

class VenuesOffersModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var page: String = kEmptyString
    dynamic var offers = List<OffersModel>()
    @objc dynamic var totalOffers: String = kEmptyString
    
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
        page <- map["page"]
        totalOffers <- map["total_offers"]
        offers <- (map["offers"],ListTransform<OffersModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
