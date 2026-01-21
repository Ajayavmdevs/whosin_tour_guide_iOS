import Foundation
import ObjectMapper
import RealmSwift

class ColorModel: Object, Mappable, ModelProtocol {

    @objc dynamic var startColor: String = kAppName
    @objc dynamic var endColor: String = kAppName

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        startColor <- map["startColor"]
        endColor <- map["endColor"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
