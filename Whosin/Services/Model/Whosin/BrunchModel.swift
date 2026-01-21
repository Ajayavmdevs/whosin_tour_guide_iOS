import Foundation
import ObjectMapper
import RealmSwift

class BrunchModel : Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var item: String = kEmptyString
    @objc dynamic var amount: Int = 0
    @objc dynamic var total: Int = 0
    @objc dynamic var discount: Int = 0
    @objc dynamic var itemId: String = kEmptyString
    @objc dynamic var qty: Int = 0
    @objc dynamic var pricePerBrunch:  Int = 0

    
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
        item <- map["item"]
        amount <- map["amount"]
        total <- map["amount"]
        discount <- map["discount"]
        itemId <- map["itemId"]
        qty <- map["qty"]
        pricePerBrunch <- map["pricePerBrunch"]
    }
    

    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
