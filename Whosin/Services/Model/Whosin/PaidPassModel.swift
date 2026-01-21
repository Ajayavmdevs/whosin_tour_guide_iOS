import Foundation
import RealmSwift
import ObjectMapper

class PaidPassModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var frequency: Int = 0
    @objc dynamic var amount: Int = 0
    @objc dynamic var validityInDays: Int = 0

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["_id"]
        title <- map["title"]
        descriptions <- map["description"]
        type <- map["type"]
        frequency <- map["frequency"]
        amount <- map["amount"]
        validityInDays <- map["validityInDays"]
    }

    func isValid() -> Bool {
        return true
    }
}
