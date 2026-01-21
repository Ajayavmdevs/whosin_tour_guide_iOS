import Foundation
import RealmSwift
import ObjectMapper

class ServiceTypeModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var code: Int = 0
    
    override class func primaryKey() -> String? {
        return "code"
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        code <- map["Code"]
    }
    
    func isValid() -> Bool {
        true
    }
}
