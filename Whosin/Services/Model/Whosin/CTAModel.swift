import Foundation
import ObjectMapper
import RealmSwift

class CTAModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var text: String = kEmptyString
    @objc dynamic var actionType: String = kEmptyString
    @objc dynamic var link: String = kEmptyString
    @objc dynamic var backgroundColor: String = kEmptyString
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        text <- map["text"]
        actionType <- map["actionType"]
        link <- map["link"]
        backgroundColor <- map["backgroundColor"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

