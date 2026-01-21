import Foundation
import ObjectMapper
import RealmSwift

class MoreInfoModel: Object, Mappable, ModelProtocol {

    @objc dynamic var tourOptionId: String = kEmptyString
    dynamic var info = List<InfoModel>()
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {}
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "tourOptionId"
    }
    
    func mapping(map: Map) {
        tourOptionId <- map["tourOptionId"]
        info <- (map["info"], ListTransform<InfoModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}


class InfoModel: Object, Mappable, ModelProtocol {

    @objc dynamic var key: String = kEmptyString
    @objc dynamic var value: String = kEmptyString
    var valueArray = List<String>()
    dynamic var days: OperationDaysModel?
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {}
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "key"
    }
    
    func mapping(map: Map) {
        key <- map["key"]
        var tempValue: Any?
        tempValue <- map["value"]
        
        if let str = tempValue as? String {
            value = str
        } else if let arr = tempValue as? [String] {
            value = arr.joined(separator: ",\n")
        }
        days <- map["value"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}
