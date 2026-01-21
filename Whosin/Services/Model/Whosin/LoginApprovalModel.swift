import Foundation
import ObjectMapper

class LoginApprovalModel: Mappable, ModelProtocol {
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var reqId: String = kEmptyString
    dynamic var metadata: MetaDataModel?
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        userId <- map["userId"]
        status <- map["status"]
        createdAt <- map["createdAt"]
        type <- map["type"]
        reqId <- map["reqId"]
        metadata <- map["metadata"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}


class MetaDataModel: Mappable, ModelProtocol {
    
    @objc dynamic var deviceName: String = kEmptyString
    @objc dynamic var deviceId: String = kEmptyString
    @objc dynamic var deviceModel: String = kEmptyString
    @objc dynamic var deviceLocation: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var token: String = kEmptyString
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        deviceName <- map["device_name"]
        deviceId <- map["device_id"]
        deviceModel <- map["device_model"]
        deviceLocation <- map["device_location"]
        userId <- map["userId"]
        status <- map["status"]
        token <- map["token"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
