import ObjectMapper
import Alamofire
import PINCache
import AVFoundation
typealias ObjectResult<T: Mappable> = (T?, NSError?) -> Void
typealias ObjectArrayResult<T: Mappable> = ([T]?, NSError?) -> Void
typealias BooleanResult = (Bool, NSError?) -> Void
typealias StringResult = (String?, NSError?) -> Void
typealias JsonResult = ([String: Any]?, NSError? ) -> Void
typealias JsonAndObjectResult<T: Mappable> = ([String: Any]?, T?, NSError? ) -> Void
typealias JsonArrayResult<T: Mappable> = ([[String: Any]]?, T?, NSError? ) -> Void

class BaseApiService: NSObject {

    static let shared = BaseApiService()
    let _restClient = RestClient()
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var pendingRequests: [RestRequest] = []
    
    // --------------------------------------
    // MARK: Public Methods to Handle App State Changes
    // --------------------------------------

    func handleAppDidEnterBackground() {
        startBackgroundTask() // Keep the task running
    }

    func handleAppWillEnterForeground() {
        retryPendingRequests() // Retry all pending requests
        endBackgroundTask() // End the background task if active
    }

    // --------------------------------------
    // MARK: Private Methods to Handle Background Task
    // --------------------------------------

    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "PendingAPIRequest") {
            self.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    // Retry all pending requests when app returns to the foreground
    private func retryPendingRequests() {
        for request in pendingRequests {
            retryRequest(request)
        }
        pendingRequests.removeAll()
    }

    private func retryRequest(_ restRequest: RestRequest) {
        _restClient.invoke(restRequest, callback: RestCallback.callbackWithResult({ response in
            if response.isSuccess {
                print("Retry successful for: \(restRequest.url ?? "")")
            } else {
                print("Retry failed for: \(restRequest.url ?? "")")
            }
        }))
    }


    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var headers: [String: String] {
        [httpRequestHeaderNameAccept: httpRequestContentJson, httpRequestHeaderNameContentType: httpRequestContentJson]
    }

    class var customHeaders: [String: String] {
        [httpRequestHeaderNameAccept: httpRequestContentJson, httpRequestHeaderNameContentType: httpRequestContentJson]
    }
    
    class var customHeadersNonAuth: [String: String] {
        [httpRequestHeaderNameAccept: httpRequestContentJson, httpRequestHeaderNameContentType: httpRequestContentJson]
    }
    
    class var customHeadersForUploadFile: [String: String] {
        let boundary = Utils.generateBoundaryString()
        return [httpRequestHeaderNameAccept: httpRequestContentJson, httpRequestHeaderNameContentType: "multipart/form-data; boundary=\(boundary)"]
    }

    class func GET(_ url: String) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodGet, parameters: nil, customHeaders: headers)
    }

    class func GET(_ url: String, _ parameters: [String: Any]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodGet, parameters: parameters, customHeaders: headers)
    }

    class func POST(_ url: String, parameters: [String: Any]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPost, parameters: parameters, customHeaders: headers)
    }
    
    class func POST_UPLOAD_FILE(_ url: String, parameters: [String: Any]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPost, parameters: parameters, customHeaders: customHeadersForUploadFile)
    }
    
    class func POST_UPLOAD_FILES(_ url: String, parameters: [[String : Any]]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPost, arrayParameters: parameters, customHeaders: customHeadersForUploadFile)
    }

    class func POST(_ url: String, arrayParameters: [[String: Any]]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPost, arrayParameters: arrayParameters, customHeaders: headers)
    }

    class func POST(_ url: String, _ parameters: [String: Any]? = nil, _ filePath: String?) -> RestRequest {
        RestRequest.build(url, filePath: filePath, method: httpRequestMethodPost, parameters: parameters, customHeaders: headers)
    }

    class func PUT(_ url: String, _ parameters: [String: Any]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodPut, parameters: parameters, customHeaders: headers)
    }

    class func DELETE(_ url: String, _ parameters: [String: Any]? = nil) -> RestRequest {
        RestRequest.build(url, method: httpRequestMethodDelete, parameters: parameters, customHeaders: headers)
    }

    class func PATCH(_ url: String, _ filePath: String?) -> RestRequest {
        RestRequest.build(url, filePath: filePath, method: httpRequestMethodPatch, parameters: nil, customHeaders: customHeaders)
    }

    class func BUILDURL(_ url: String, params: [String]?) -> String {
        var resultUrl = url
        for param in params ?? [] {
            resultUrl += param
        }
        return resultUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    private func _loadDataFromCache(_ request: RestRequest) -> RestResponse? {
        // kCategoryDetailEndPoint
        if request.url.contains(kFollowingListEndPoint) || request.url.contains(kFollowerListEndPoint){
            if let userId = request.parameters?["id"] as? String {
                if PINCache.shared.containsObject(forKey: "\(request.url!) \(userId)") {
                    let cachedResult = PINCache.shared.object(forKey: "\(request.url!) \(userId)")
                    return RestResponse.build(cachedResult, allHeaderFields: request.headers)
                }
            }
            return nil
        } else if request.url.contains(kCategoryDetailEndPoint) || request.url.contains(kVenueOffersEndPoint) {
            if let userId = request.parameters?["categoryId"] as? String {
                if request.url.contains(kCategoryDetailEndPoint) || (request.url.contains(kVenueOffersEndPoint) && request.parameters?["page"] as? Int == 1 && request.parameters?["day"] as? String == "all") {
                    if PINCache.shared.containsObject(forKey: "\(request.url!) \(userId)") {
                        let cachedResult = PINCache.shared.object(forKey: "\(request.url!) \(userId)")
                        return RestResponse.build(cachedResult, allHeaderFields: request.headers)
                    }
                }
            }
            return nil
        } else {
            if PINCache.shared.containsObject(forKey: request.url) {
                Log.debug("CACHE RESPONSE load cached object for url=\(request.url!)")
                let cachedResult = PINCache.shared.object(forKey: request.url)
                return RestResponse.build(cachedResult, allHeaderFields: request.headers)
            }
        }
        return nil
    }

    private func _saveDataToCache(_ request: RestRequest, _ response: RestResponse) {
        if response.isSuccess && response.result != nil {
            Log.debug("CACHE SAVE save object for url=\(request.url!)")
            DISPATCH_ASYNC_BG {
                if request.url.contains(kFollowingListEndPoint) || request.url.contains(kFollowerListEndPoint){
                    if let userId = request.parameters?["id"] as? String {
                        PINCache.shared.setObject(response.result, forKey: "\(request.url!) \(userId)")
                    } else {
                        PINCache.shared.setObject(response.result, forKey: request.url!)
                    }
                } else if request.url.contains(kCategoryDetailEndPoint) || (request.url.contains(kVenueOffersEndPoint) && request.parameters?["page"] as? Int == 1 && request.parameters?["day"] as? String == "all") {
                    if let userId = request.parameters?["categoryId"] as? String {
                        PINCache.shared.setObject(response.result, forKey: "\(request.url!) \(userId)")
                    } else {
                        PINCache.shared.setObject(response.result, forKey: request.url!)
                    }
                } else {
                    PINCache.shared.setObject(response.result, forKey: request.url!)
                }
            }
        }
    }

    private func _parse<T: Mappable>(response: RestResponse, model: T.Type) -> (Mappable?, NSError?) {

        // Check to see if response is success
        if !response.isSuccess {
            if response.statusMessage == "cancelled" || response.statusMessage == "The network connection was lost." {
                return (nil, nil)
            }
            return (nil, ErrorUtils.error(response.headerStatusCode, message: response.statusMessage))
        }

        // Check to see if object is parsed and conform to protocols
        let object = Mapper<T>().map(JSONObject: response.result)
        if object == nil || !(object is ModelProtocol) {
            return (nil, ErrorUtils.error(ErrorCode.objectParsing))
        }

        // Check to see if model is valid
        let model = object as! ModelProtocol
        if !model.isValid() {
            if model.statusMessage != nil {
                let code: ErrorCode = response.statusMessage == "unauthorized" ? .sessionExpired : .invalidResponse
                return (nil, ErrorUtils.error(code, message: model.statusMessage!))
            }
            return (nil, ErrorUtils.error(ErrorCode.invalidObject))
        }

        // Return valid object
        return (object, nil)
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func request<T: Mappable>(_ restRequest: RestRequest, model: T.Type, shouldRefresh: Bool = true, shouldCache: Bool = true, callback: ObjectResult<T>? = nil) -> DataRequest {

//        print(restRequest.url)
        pendingRequests.append(restRequest)
        // If the data is not refreshed, load from cache (if any)
        if !shouldRefresh {
            let cachedResponse = _loadDataFromCache(restRequest)
            if cachedResponse != nil {
                let (object, error) = _parse(response: cachedResponse!, model: model)
                if let index = self.pendingRequests.firstIndex(where: { $0.url == restRequest.url }) {
                    self.pendingRequests.remove(at: index)
                }
                if object != nil {
                    callback?(object as? T, error)
                }
            }
        }

        return _restClient.invoke(restRequest, callback: RestCallback.callbackWithResult({ restResponse in
            let (object, error) = self._parse(response: restResponse, model: model)
            if let index = self.pendingRequests.firstIndex(where: { $0.url == restRequest.url }) {
                self.pendingRequests.remove(at: index)
            }
            if object != nil && shouldCache {
                self._saveDataToCache(restRequest, restResponse)
            }
            callback?(object as? T, error)
        }))
        
    }

    func request(_ restRequest: RestRequest, callback: BooleanResult?) {
        pendingRequests.append(restRequest)
        _ = _restClient.invoke(restRequest, callback: RestCallback.callbackWithResult({ response in
            if !response.isSuccess {
                callback?(false, ErrorUtils.error(response.headerStatusCode, message: response.statusMessage))
            } else {
                callback?(true, nil)
            }
        }))
    }

    func uploadRequest(_ restRequest: RestRequest, callback: BooleanResult?) {
        pendingRequests.append(restRequest)
        _restClient.uploadInvoke(restRequest, callback: RestCallback.callbackWithResult({ response in
            if !response.isSuccess {
                callback?(false, ErrorUtils.error(response.headerStatusCode, message: response.statusMessage))
            } else {
                callback?(true, nil)
            }
        }))
    }
    
    func multipartRequest<T: Mappable>(_ restRequest: RestRequest, model: T.Type, callback: ObjectResult<T>? = nil){
        pendingRequests.append(restRequest)
        _restClient.multiPartInvoke(restRequest, callback: RestCallback.callbackWithResult({ response in
            let (object, error) = self._parse(response: response, model: model)
            if let index = self.pendingRequests.firstIndex(where: { $0.url == restRequest.url }) {
                self.pendingRequests.remove(at: index)
            }
            if object != nil {
                self._saveDataToCache(restRequest, response)
            }
            callback?(object as? T, error)
        }))
    }

    func genericRequest<T: Mappable>(_ restRequest: RestRequest, model: T.Type, shouldRefresh: Bool = true, shouldCache: Bool = true, callback: ObjectResult<T>? = nil) {
        pendingRequests.append(restRequest)
        
        // If the data is not refreshed, load from cache (if any)
        if !shouldRefresh {
            let cachedResponse = _loadDataFromCache(restRequest)
            if cachedResponse != nil {
                if let index = self.pendingRequests.firstIndex(where: { $0.url == restRequest.url }) {
                    self.pendingRequests.remove(at: index)
                }
                let (object, error) = _parse(response: cachedResponse!, model: model)
                if object != nil {
                    callback?(object as? T, error)
                }
            }
        }

        _restClient.genericInvoke(restRequest, callback: RestCallback.callbackWithResult({ restResponse in
            let (object, error) = self._parse(response: restResponse, model: model)
            if let index = self.pendingRequests.firstIndex(where: { $0.url == restRequest.url }) {
                self.pendingRequests.remove(at: index)
            }
            if object != nil && shouldCache {
                self._saveDataToCache(restRequest, restResponse)
            }
            callback?(object as? T, error)
        }))
    }
    
    func requestArrayInvoke<T: Mappable>(_ restRequest: RestRequest, model: T.Type, shouldRefresh: Bool = true, shouldCache: Bool = true, callback: ObjectResult<T>? = nil) {
        // If the data is not refreshed, load from cache (if any)
        pendingRequests.append(restRequest)

        if !shouldRefresh {
            let cachedResponse = _loadDataFromCache(restRequest)
            if cachedResponse != nil {
                if let index = self.pendingRequests.firstIndex(where: { $0.url == restRequest.url }) {
                    self.pendingRequests.remove(at: index)
                }
                let (object, error) = _parse(response: cachedResponse!, model: model)
                if object != nil {
                    callback?(object as? T, error)
                }
            }
        }
        
        _restClient.invokeArray(restRequest, callback: RestCallback.callbackWithResult { restResponse in
            let (object, error) = self._parse(response: restResponse, model: model)
            if let index = self.pendingRequests.firstIndex(where: { $0.url == restRequest.url }) {
                self.pendingRequests.remove(at: index)
            }
            if object != nil && shouldCache {
                self._saveDataToCache(restRequest, restResponse)
            }
            callback?(object as? T, error)
        })
    }
}
