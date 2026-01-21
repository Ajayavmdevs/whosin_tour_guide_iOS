import Foundation
import RealmSwift
import ObjectMapper

class ServiceContentInfoModel: Object, Mappable, ModelProtocol {
    
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var serviceName: String = kEmptyString
    dynamic var descriptions: List<DescriptionModel> = List<DescriptionModel>()
    dynamic var images: List<ImageModel> = List<ImageModel>()
    
    override class func primaryKey() -> String? {
        return "id"
    }

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        serviceName <- map["ServiceName"]
        descriptions <- (map["Descriptions"], ListTransform<DescriptionModel>())
        images <- (map["Images"], ListTransform<ImageModel>())
    }
    
    func isValid() -> Bool {
        true
    }

}
