import Foundation
import RealmSwift
import ObjectMapper

class DescriptionModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id:  String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    
    override class func primaryKey() -> String? {
        return "id"
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["id"]
        descriptions <- map["Description"]
        type        <- map["Type"]
    }
    
    func isValid() -> Bool {
        true
    }
}
