import Foundation
import RealmSwift
import ObjectMapper

class ServiceModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var code: String = kEmptyString
    @objc dynamic var intCode: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var serviceTypeCode: String = kEmptyString
    
    @objc dynamic var zoneModel: ZoneModel?
    dynamic var serviceZones: List<ZoneModel> = List<ZoneModel>()
    dynamic var serviceType: List<ServiceTypeModel> = List<ServiceTypeModel>()
    @objc dynamic var serviceContentInfo: ServiceContentInfoModel?
    dynamic var serviceOptions: List<ServiceOptionModel> = List<ServiceOptionModel>()
    dynamic var serviceCodes: List<String> = List<String>()
    
    override class func primaryKey() -> String? {
        return "_id"
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        _id                 <- map["_id"]
        code                <- map["code"]
        intCode             <- map["intCode"]
        name                <- map["name"]
        serviceTypeCode     <- map["serviceTypeCode"]
        zoneModel                <- map["zone"]
        serviceZones        <- (map["serviceZones"], ListTransform<ZoneModel>())
        serviceType         <- (map["serviceType"], ListTransform<ServiceTypeModel>())
        serviceContentInfo  <- map["serviceContentInfo"]
        serviceOptions      <- (map["serviceOptions"], ListTransform<ServiceOptionModel>())
        serviceCodes        <- (map["serviceCodes"], StringListTransform())
    }
    
    func isValid() -> Bool {
        true
    }
}

