import Foundation
import ObjectMapper

class BaseModel: Mappable, ModelProtocol {
    
	var code: Int = 0
    var statusCode: Int = 0
	var message: String = kEmptyString
    var claimId: String = kEmptyString
    var amount: Int = 0
    var currency: String = kEmptyString
    var type: String = kEmptyString
    
	// --------------------------------------
	// MARK: <Mappable>
	// --------------------------------------

	required init?(map _: Map) {}

	func mapping(map: Map) {
		code <- map["status"]
        statusCode <- map["data.status"]
		message <- map["message"]
        claimId <- map["data._id"]
        amount <- map["amount"]
        currency <- map["currency"]
        type <- map["type"]
	}

	// --------------------------------------
	// MARK: <ModelProtocol>
	// --------------------------------------

	func isValid() -> Bool {
		isSuccess
	}
    
    var statusMessage: String? {
        message
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    var isSuccess: Bool {
        code == 1 || message == "Success" || statusCode == 1 || message == "Reset password."
    }
}
