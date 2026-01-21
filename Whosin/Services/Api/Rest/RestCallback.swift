import UIKit

class RestCallback: NSObject {
	typealias RestResponseBlock = (RestResponse) -> Void
	var result: RestResponseBlock?

	// --------------------------------------
	// MARK: - Class
	// --------------------------------------

	class func callbackWithResult(_ result: RestResponseBlock?) -> RestCallback {
		let restCallback: RestCallback = RestCallback()
		restCallback.result = result
		return restCallback
	}

	// --------------------------------------
	// MARK: - Life Cycle
	// --------------------------------------

	override init() {
		super.init()
	}
}
