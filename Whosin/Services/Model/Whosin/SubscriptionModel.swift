import Foundation
import ObjectMapper
import RealmSwift

class SubscriptionModel : Object, Mappable, ModelProtocol {

    @objc dynamic var id:String = kEmptyString
    @objc dynamic var userId:String = kEmptyString
    @objc dynamic var validity: Date?
    @objc dynamic var createdAt:String = kEmptyString
    @objc dynamic var status:Bool = false
    dynamic var package: MembershipPackageModel?
    
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var subTitle: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var buttonText: String = kEmptyString
    @objc dynamic var backgroundType: String = kEmptyString
    @objc dynamic var startColor: String = kEmptyString
    @objc dynamic var endColor: String = kEmptyString
    @objc dynamic var frequency: Int = 0
    dynamic var packageId: MembershipPackageModel?
    
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kStanderdDate)

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    override class func primaryKey() -> String? {
        "id"
    }

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        userId <- map["userId"]
        validity <- (map["validity"], DateFormatterTransform(dateFormatter: _dateFormatter))
        createdAt <- map["createdAt"]
        status <- map["status"]
        package <- map["package"]
        
        title <- map["title"]
        subTitle <- map["subTitle"]
        descriptions <- map["description"]
        image <- map["image"]
        buttonText <- map["buttonText"]
        backgroundType <- map["backgroundType"]
        startColor <- map["startColor"]
        endColor <- map["endColor"]
        frequency <- map["frequency"]
        packageId <- map["packageId"]

        
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
