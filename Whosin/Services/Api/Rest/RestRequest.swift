import UIKit
import Alamofire

class RestRequest: NSObject {
	var filePath: String?
	var url: String!
	var method: String!
	var parameters: [String: Any]?
	var arrayParameters: [[String: Any]]?
    var headers: [String: String] = [:]

	// --------------------------------------
	// MARK: - Class
	// --------------------------------------

	class func build(_ url: String, method: String, parameters: [String: Any]?) -> RestRequest {
		let restRequest: RestRequest = RestRequest()
		restRequest.url = url
		restRequest.method = method
		restRequest.parameters = parameters
		return restRequest
	}

	class func build(_ url: String, method: String, arrayParameters: [[String: Any]]?) -> RestRequest {
		let restRequest: RestRequest = RestRequest()
		restRequest.url = url
		restRequest.method = method
		restRequest.arrayParameters = arrayParameters
		return restRequest
	}

	class func build(_ url: String, filePath: String?, method: String, parameters: [String: Any]?) -> RestRequest {
		let restRequest: RestRequest = RestRequest()
		restRequest.url = url
		restRequest.filePath = filePath
		restRequest.method = method
		restRequest.parameters = parameters
		return restRequest
	}

	class func build(_ url: String, method: String, parameters: [String: Any]?, customHeaders: [String: String]?) -> RestRequest {
		let restRequest: RestRequest = RestRequest.build(url, method: method, parameters: parameters)
        for (key, value) in customHeaders ?? [:] {
            restRequest.headers[key] = value
        }
		return restRequest
	}

	class func build(_ url: String, method: String, arrayParameters: [[String: Any]]?, customHeaders: [String: String]?) -> RestRequest {
		let restRequest: RestRequest = RestRequest.build(url, method: method, arrayParameters: arrayParameters)
        for (key, value) in customHeaders ?? [:] {
            restRequest.headers[key] = value
        }
		return restRequest
	}

	class func build(_ url: String, filePath: String?, method: String, parameters: [String: Any]?, customHeaders: [String: String]?) -> RestRequest {
		let restRequest: RestRequest = RestRequest.build(url, filePath: filePath, method: method, parameters: parameters)
        for (key, value) in customHeaders ?? [:] {
            restRequest.headers[key] = value
        }
		return restRequest
	}

	// --------------------------------------
	// MARK: - Life Cycle
	// --------------------------------------

	override init() {
		super.init()
	}
    
}
