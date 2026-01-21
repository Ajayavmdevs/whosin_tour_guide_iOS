import Foundation
import ObjectMapper

class CommanModel<T: Mappable, U: Mappable>: BaseModel {

    var data: [T]?
    var users: [U]?

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
        users <- map["users"]
    }

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    override func isValid() -> Bool {
        return super.isValid()
    }
}
