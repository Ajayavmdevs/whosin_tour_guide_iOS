import Foundation
import ObjectMapper
import RealmSwift

class DiscountModel : Object, Mappable, ModelProtocol {

    @objc dynamic var id : String = kEmptyString
    @objc dynamic var title : String = kEmptyString
    @objc dynamic var discountTypeId : String = kEmptyString
    @objc dynamic var descriptions : String = kEmptyString
    @objc dynamic var startDate : String = kEmptyString
    @objc dynamic var expiryDate : String = kEmptyString
    @objc dynamic var discount : String = kEmptyString
    
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
        title <- map["title"]
        discountTypeId <- map["discountTypeId"]
        descriptions <- map["description"]
        startDate <- map["startDate"]
        expiryDate <- map["expiryDate"]
        discount <- map["discount"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
