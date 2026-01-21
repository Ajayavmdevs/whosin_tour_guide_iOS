import Foundation
import RealmSwift
import ObjectMapper

class ServiceOptionModel: Object, Mappable, ModelProtocol {

    
    @objc dynamic var order: Int = 0
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var numberOfDays: Int = 0
    @objc dynamic var startTime: String = kEmptyString
    @objc dynamic var minimumPax: Int = 1
    @objc dynamic var name: String?
    dynamic var descriptions: List<DescriptionModel> = List<DescriptionModel>()
    dynamic var zones: List<ZoneModel> = List<ZoneModel>()
    
    override class func primaryKey() -> String? {
        return "id"
    }

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        order           <- map["Order"]
        id           <- map["_id"]
        numberOfDays    <- map["NumberOfDays"]
        startTime       <- map["StartTime"]
        minimumPax      <- map["MinimumPax"]
        name            <- map["Name"]
        descriptions    <- (map["Descriptions"], ListTransform<DescriptionModel>())
        zones           <- (map["Zones"], ListTransform<ZoneModel>())
    }
    
    func isValid() -> Bool {
        true
    }
    
    var shortDescription: String {
        return Utils.convertHTMLToPlainText(from: descriptions.first(where: { $0.type == "SHT" })?.descriptions ?? kEmptyString)
    }
    
    var longDescription: String {
        return Utils.convertHTMLToPlainText(from:descriptions.first(where: { $0.type == "LNG" })?.descriptions ?? kEmptyString)
    }
}
