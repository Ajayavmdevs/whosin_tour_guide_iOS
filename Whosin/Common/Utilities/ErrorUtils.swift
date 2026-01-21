import UIKit

@objc
enum ErrorCode: Int {
	case invalidUrl = 900
	case invalidResponse = 1000
	case objectParsing = 1001
	case invalidObject = 1002
    case sessionExpired = 401
}

let kGeneralErrorDomain: String = "songtien"
let kErrorCodeKey: String = "errorcode"
let kErrorMessage: String = "errormessage"
let kErrorDomainKey: String = "errordomain"

class ErrorUtils: NSObject {
	class func error(_ code: ErrorCode) -> NSError {
		return error(code, message: getErrorMessage(code), shouldLog: true)
	}

	class func error(_ code: ErrorCode, message: String?) -> NSError {
		return error(code, message: message, shouldLog: true)
	}

	class func error(_ code: ErrorCode, message: String?, shouldLog: Bool) -> NSError {
		let result: [String: Any] = [
			kErrorCodeKey: code,
			kErrorMessage: message ?? getErrorMessage(code),
			kErrorDomainKey: kGeneralErrorDomain
		]
		return error(result, shouldLog: shouldLog)
	}

	class func error(_ result: [String: String]) -> NSError {
		return error(result, shouldLog: true)
	}

	class func error(_ result: [String: Any], shouldLog: Bool) -> NSError {
		let code: ErrorCode = (result[kErrorCodeKey] as? ErrorCode)!
		let message: String? = result[kErrorMessage] as? String
		if shouldLog {
			Log.debug(String(format: "error message=%@ code=%ld", message ?? kEmptyString, code.rawValue))
		}
		var userInfo: [String: String] = [:]
		if !Utils.stringIsNullOrEmpty(message) {
			userInfo[NSLocalizedDescriptionKey] = message
		}
		let errorDomain: String = result[kGeneralErrorDomain] as? String ?? kGeneralErrorDomain
		return NSError(domain: errorDomain, code: code.rawValue, userInfo: userInfo)
	}

	class func error(_ customCode: Int, message: String?) -> NSError {
		Log.debug(String(format: "error message=%@ code=%ld", message ?? kEmptyString, customCode))
		var userInfo: [String: String] = [:]
		if !Utils.stringIsNullOrEmpty(message) {
			userInfo[NSLocalizedDescriptionKey] = message
		}
		return NSError(domain: kGeneralErrorDomain, code: customCode, userInfo: userInfo)
	}

	class func getErrorMessage(_ errorCode: ErrorCode) -> String {
		switch errorCode {
			case .invalidUrl: return "The url is invalid"
			case .invalidResponse: return "Error in response. Please try again later"
			case .objectParsing: return "Response object parsing error"
			case .invalidObject: return "Object is invalid"
            case .sessionExpired: return "Session is expired"
		}
	}
}
