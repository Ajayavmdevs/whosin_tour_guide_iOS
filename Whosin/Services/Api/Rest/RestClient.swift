import Alamofire

let kDefaultRetryCount: Int = 5
let kDefaultPageSize: Int = 500
let kDefaultRequestTimeOut: TimeInterval = 300.0
let kDefaultResourceRequestTimeOut: TimeInterval = 300.0

class RestClient: NSObject {

    struct SessionSecData {
        var protectionSpace: URLProtectionSpace
        var userCredential: URLCredential
    }
    
    private var _sessionManager: Session!
    private var _sessionRetrier = SessionRetrier()
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    private class func _validate(_ response: HTTPURLResponse?, object: [String: Any]?, error: NSError?) -> RestResponse {
        let allHeaderFields = response?.allHeaderFields
        var isSuccess: Bool = true
        var statusCode: Int = (response?.statusCode ?? httpStatusCodeOk)
        var statusMessage: String? = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        var result = object
        // Handle error case
        if result == nil || error != nil {
            if error != nil {
                if let message = error?.localizedDescription, let _ = message.range(of: "URLSessionTask failed with error: ", options: .caseInsensitive) {
                    statusMessage =  message.replacingOccurrences(of: "URLSessionTask failed with error: ", with: "")
                    statusCode = error!.code
                } else {
                    statusMessage = error?.localizedDescription
                    statusCode = error!.code
                }

            } else {
                statusMessage = "Something went wrong with the server. Please try after some time."
                statusCode = httpStatusCodeNoContent
            }
            isSuccess = false
            result = [:]
        }
        if statusCode > httpStatusCodeMultipleChoices {
            if error != nil {
                if statusCode == httpStatusCodeUnauthorized {
                    statusMessage = "The credential is incorrect. Try again!"
                } else {
                    statusMessage = error?.localizedDescription
                }
            } else if !(200...299).contains(statusCode) {
                statusMessage = "Server not working. Please try again after some time."
            }
            isSuccess = false
        }

        if object != nil {
            //Log.debug(String(format: "SERVICE RESPONSE result\n%@\n", object ?? kEmptyString))
        }

        return RestResponse.build(
            result,
            isSuccess: isSuccess,
            statusCode: statusCode,
            allHeaderFields: allHeaderFields,
            statusMessage: statusMessage)
    }

    private class func _validString(_ response: HTTPURLResponse?, object: String?, error: NSError?) -> RestResponse {
        let allHeaderFields = response?.allHeaderFields
        var isSuccess: Bool = true
        var statusCode: Int = (response?.statusCode ?? httpStatusCodeOk)
        var statusMessage: String? = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        let result = object

        // Handle error case
        if result == nil || error != nil {
            if error != nil {
                statusMessage = error?.localizedDescription
                statusCode = error!.code
            } else {
                statusMessage = "The content is empty"
                statusCode = httpStatusCodeNoContent
            }
            isSuccess = false
        }
        if statusCode > httpStatusCodeMultipleChoices {
            if error != nil {
                if statusCode == httpStatusCodeUnauthorized {
                    statusMessage = "The credential is incorrect. Try again!"
                } else {
                    statusMessage = error?.localizedDescription
                }
            }
            isSuccess = false
        }

        if object != nil {
            // Log.debug(String(format: "SERVICE RESPONSE result\n%@\n", object ?? kEmptyString))
        }

        return RestResponse.build(
            result,
            isSuccess: isSuccess,
            statusCode: statusCode,
            allHeaderFields: allHeaderFields,
            statusMessage: statusMessage)
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override init() {
        super.init()
        _initSessionManager()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _initSessionManager(_ host: String? = nil) {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.timeoutIntervalForRequest = kDefaultRequestTimeOut
        configuration.timeoutIntervalForResource = kDefaultResourceRequestTimeOut
        configuration.allowsCellularAccess = true
        configuration.urlCredentialStorage = nil
        configuration.httpCookieAcceptPolicy = .always
                                
        let serverTrust = ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [:])
        _sessionManager = Session(configuration: configuration, serverTrustManager: serverTrust)
    }
    
    private func _generateHeaders(headerDict: [String: String]) -> HTTPHeaders {
        var httpHeaders: HTTPHeaders = HTTPHeaders()
        headerDict.forEach { key, value in
            httpHeaders.add(HTTPHeader.init(name: key, value: value))
        }
        return httpHeaders
    }
        
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func invoke(_ request: RestRequest, retryCount: Int = kDefaultRetryCount, callback: RestCallback? = nil) -> DataRequest {
        let headers = _generateHeaders(headerDict: request.headers)
        // Logging
        print("\n-------------------- API REQUEST --------------------")
        print("URL: \(request.url ?? "")")
        print("Method: \(request.method ?? "")")
        print("Headers: \(headers.dictionary)")
        print("Params: \(request.parameters ?? [:])")
        print("----------------------------------------------------\n")

        // Request
        let dataRequest = _sessionManager.request(
            request.url,
            method: HTTPMethod(rawValue: request.method),
            parameters: request.parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        
        
        
        _sessionRetrier.addRetryInfo(request: dataRequest, retryCount: retryCount)
        
        dataRequest.response { data in
            self._sessionRetrier.deleteRetryInfo(request: dataRequest)
        }.responseData { response in
            let httpUrlResponse = response.response
            var object: [String: Any]?
            var error: NSError?
            
            switch response.result {
            case .success(let result): object = try? JSONSerialization.jsonObject(with: result) as? [String : Any]
            case .failure(let err): error = err as NSError?
            }
        
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
        return dataRequest
    }

    func invokeArray(_ request: RestRequest, retryCount: Int = kDefaultRetryCount, callback: RestCallback? = nil) {
        
        // Logging
        if request.arrayParameters == nil {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@", request.method, request.url))
        } else {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@ params=%@", request.method, request.url, request.arrayParameters ?? "nil"))
        }

        // Request
        let headers = _generateHeaders(headerDict: request.headers)
        let dataRequest = _sessionManager.request(
            request.url,
            method: HTTPMethod(rawValue: request.method),
            parameters: request.arrayParameters?.asParameters(),
            encoding: ArrayEncoding(),
            headers: headers
        )
        _sessionRetrier.addRetryInfo(request: dataRequest, retryCount: retryCount)
        dataRequest.response { data in
            self._sessionRetrier.deleteRetryInfo(request: dataRequest)
        }.responseData { response in
            let httpUrlResponse = response.response
            var object: [String: Any]?
            var error: NSError?
            
            switch response.result {
            case .success(let result): object = try? JSONSerialization.jsonObject(with: result) as? [String : Any]
            case .failure(let err): error = err as NSError?
            }
        
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }

    func genericInvoke(_ request: RestRequest, retryCount: Int = kDefaultRetryCount, callback: RestCallback? = nil) {
        
        // Logging
        if request.parameters == nil {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@", request.method, request.url))
        } else {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@ params=%@", request.method, request.url, request.parameters ?? "nil"))
        }

        // Request
        let headers = _generateHeaders(headerDict: request.headers)
        let dataRequest = _sessionManager.request(
            request.url,
            method: HTTPMethod(rawValue: request.method),
            parameters: request.parameters,
            headers: headers
        )
        _sessionRetrier.addRetryInfo(request: dataRequest, retryCount: retryCount)
        dataRequest.response { data in
            self._sessionRetrier.deleteRetryInfo(request: dataRequest)
        }.responseData { response in
            let httpUrlResponse = response.response
            var object: [String: Any]?
            var error: NSError?
            
            switch response.result {
            case .success(let result):
                object = try? JSONSerialization.jsonObject(with: result) as? [String : Any]
                if object == nil, let data = try? JSONSerialization.jsonObject(with: result) {
                    let objcDict: NSDictionary = ["data": data]
                    object = objcDict as? [String: Any]
                }
            case .failure(let err): error = err as NSError?
            }
            
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }

    func uploadInvoke(_ request: RestRequest, callback: RestCallback? = nil) {
        
        // Logging
        if request.parameters == nil {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@", request.method, request.url))
        } else {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@ params=%@", request.method, request.url, request.parameters ?? "nil"))
        }

        // Upload Request
        let headers = _generateHeaders(headerDict: request.headers)
        let uploadRequest = _sessionManager.upload(
            URL(fileURLWithPath: request.filePath!),
            to: request.url,
            method: HTTPMethod(rawValue: request.method!),
            headers: headers
        )
        uploadRequest.responseData { response in
            let httpUrlResponse = response.response
            let object = ["status": "success"]
            var error: NSError?
            
            switch response.result {
            case .success(_): break
            case .failure(let err): error = err as NSError?
            }
            
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }

    func booleanInvoke(_ request: RestRequest, encoding: String, callback: RestCallback? = nil) {
        
        // Logging
        if request.parameters == nil {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@", request.method, request.url))
        } else {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@ params=%@", request.method, request.url, request.parameters ?? "nil"))
        }
        
        // Request
        let headers = _generateHeaders(headerDict: request.headers)
        let dataRequest = _sessionManager.request(
            request.url,
            method: HTTPMethod(rawValue: request.method!),
            parameters: [:],
            encoding: encoding,
            headers: headers
        )
        dataRequest.response { response in
            let httpUrlResponse = response.response
            let object = ["status": "success"]
            let error = response.error as NSError?
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }

    func stringInvoke(_ request: RestRequest, encoding: String, retryCount: Int = kDefaultRetryCount, callback: RestCallback? = nil) {
        
        // Logging
        if request.parameters == nil {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@", request.method, request.url))
        } else {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@ params=%@", request.method, request.url, request.parameters ?? "nil"))
        }
                    
        // Request
        let headers = _generateHeaders(headerDict: request.headers)
        let dataRequest = _sessionManager.request(
            request.url,
            method: HTTPMethod(rawValue: request.method!),
            parameters: [:],
            encoding: encoding,
            headers: headers
        )
        _sessionRetrier.addRetryInfo(request: dataRequest, retryCount: retryCount)
        dataRequest.response { data in
            self._sessionRetrier.deleteRetryInfo(request: dataRequest)
        }.responseString { response in
            let httpUrlResponse = response.response
            let object = response.value
            let error = response.error as NSError?
            let restReponse = RestClient._validString(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }
    
    public func multiPartInvoke(_ request: RestRequest, callback: RestCallback? = nil) {
        // Logging
        if request.parameters == nil {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@", request.method, request.url))
        } else {
            Log.debug(String(format: "SERVICE REQUEST method=%@ url=%@ params=%@", request.method, request.url, request.parameters ?? "nil"))
        }
        let headers = _generateHeaders(headerDict: request.headers)
        let uploadRequest = _sessionManager.upload(multipartFormData: {multipartFormData in
            request.parameters?.forEach({ key, value in
                if value is URL{
                    multipartFormData.append(value as! URL, withName: key)
                } else if value is Data{
                    multipartFormData.append(value as! Data, withName: key)
                } else if value is String{
                    if let data = (value as? String)?.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                } else if value is Int{
                    if let data = String(value as! Int).data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                } else if value is [URL] {
                    let imageArray = value as? [URL]
                    imageArray?.forEach({ url in
                        multipartFormData.append(url, withName: key)
                    })
                }
                
            })
        }, to: request.url, method: HTTPMethod(rawValue: request.method), headers: headers)
        uploadRequest.uploadProgress { progress in
            let value =  Int(progress.fractionCompleted * 100)
            print("\(value) %")
        }
        uploadRequest.responseData { response in
            let httpUrlResponse = response.response
            var object: [String: Any]?
            var error: NSError?
            
            switch response.result {
            case .success(let result): object = try? JSONSerialization.jsonObject(with: result) as? [String : Any]
            case .failure(let err): error = err as NSError?
            }
        
            let restReponse = RestClient._validate(httpUrlResponse, object: object, error: error)
            callback?.result!(restReponse)
        }
    }
}

extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with _: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

private let kArrayParameters = "kArrayParameters"

extension Array {
    func asParameters() -> Parameters {
        [kArrayParameters: self]
    }
}

struct ArrayEncoding: ParameterEncoding {

    public let options: JSONSerialization.WritingOptions

    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        guard let parameters = parameters,
            let array = parameters[kArrayParameters] else {
            return urlRequest
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)

            if urlRequest.value(forHTTPHeaderField: httpRequestHeaderNameAccept) == nil {
                urlRequest.setValue(httpRequestContentJson, forHTTPHeaderField: httpRequestHeaderNameAccept)
            }
            if urlRequest.value(forHTTPHeaderField: httpRequestHeaderNameContentType) == nil {
                urlRequest.setValue(httpRequestContentJson, forHTTPHeaderField: httpRequestHeaderNameContentType)
            }
//            if APPSESSION.isAuthenticated && urlRequest.value(forHTTPHeaderField: httpRequestHeaderAuthorization) == nil {
//                urlRequest.setValue(APPSESSION.token, forHTTPHeaderField: httpRequestHeaderAuthorization)
//            }

            urlRequest.httpBody = data

        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }

        return urlRequest
    }
}


class SessionRetrier: RequestInterceptor {
    
    private var _requestsAndRetryCounts: [(Request, Int)] = []
    private var _lock = NSLock()

    private func index(request: Request) -> Int? {
        return _requestsAndRetryCounts.firstIndex(where: { $0.0 === request })
    }

    func addRetryInfo(request: Request, retryCount: Int? = nil) {
        _lock.lock() ; defer { _lock.unlock() }
        guard index(request: request) == nil else { Log.error("ERROR addRetryInfo called for already tracked request"); return }
        _requestsAndRetryCounts.append((request, retryCount ?? kDefaultRetryCount))
    }

    func deleteRetryInfo(request: Request) {
        _lock.lock() ; defer { _lock.unlock() }
        guard let index = index(request: request) else { Log.error("ERROR deleteRetryInfo called for not tracked request"); return }
        _requestsAndRetryCounts.remove(at: index)
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        _lock.lock() ; defer { _lock.unlock() }

        guard let index = index(request: request) else { completion(.doNotRetry); return }
        let (request, retryCount) = _requestsAndRetryCounts[index]

        if retryCount == 0 {
            completion(.doNotRetry)
        } else {
            Log.debug("Failed to connect to server=\(String(describing: request.request?.url)) retry=\(retryCount - 1)")
            _requestsAndRetryCounts[index] = (request, retryCount - 1)
            completion(.retryWithDelay(0.5))
        }
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: kEmptyString))
        completion(.success(urlRequest))
    }
}
