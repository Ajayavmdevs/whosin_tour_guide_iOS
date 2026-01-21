import Foundation
import ObjectMapper
import RealmSwift

class BusinessModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var address: String = kEmptyString
    @objc dynamic var logo: String = kEmptyString
    @objc dynamic var cover: String = kEmptyString
    @objc dynamic var phone: String = kEmptyString
    @objc dynamic var email: String = kEmptyString
    @objc dynamic var website: String = kEmptyString

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
        name <- map["name"]
        address <- map["address"]
        logo <- map["logo"]
        cover <- map["cover"]
        phone <- map["phone"]
        email <- map["email"]
        website <- map["website"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
