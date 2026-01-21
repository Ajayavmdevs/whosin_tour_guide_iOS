import Foundation
import ObjectMapper

class ContainerModel<T: Mappable>: BaseModel {

	var data: T?

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
		return super.isValid() && data != nil
	}
}

class ContainerIntModel: BaseModel {

    var status:  Int = 0
    var messsage: String = kEmptyString
    var data: Int = 0

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        status <- map["status"]
        messsage <- map["messsage"]
        data <- map["data"]
    }

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    override func isValid() -> Bool {
        return super.isValid()
    }
}
