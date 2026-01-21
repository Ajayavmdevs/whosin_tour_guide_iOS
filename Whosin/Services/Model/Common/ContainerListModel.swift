import Foundation
import ObjectMapper

class ContainerListModel<T: Mappable>: BaseModel {

	var data: [T]?

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
