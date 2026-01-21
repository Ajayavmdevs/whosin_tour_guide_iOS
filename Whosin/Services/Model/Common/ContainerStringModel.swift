import Foundation
import ObjectMapper

class ContainerStringModel: BaseModel {

    var data: String = kEmptyString

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    override func isValid() -> Bool {
        return super.isValid()
    }
}

class ContainerStringListModel: BaseModel {

    var data: [String] = []

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    override func isValid() -> Bool {
        return super.isValid()
    }
}

class ContainerFloatModel: BaseModel {

    var data: Float = .zero

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    override func isValid() -> Bool {
        return super.isValid()
    }
}
