import Foundation
import RealmSwift
import ObjectMapper

class ZoneModel: Object, Mappable, ModelProtocol {
    
    
    @objc dynamic var code: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var zoneCode: Int = 0
    
    override class func primaryKey() -> String? {
        return "code"
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        code        <- map["code"]
        name        <- map["name"]
        zoneCode    <- map["ZoneCode"]
    }
    
    func isValid() -> Bool {
        true
    }
}
