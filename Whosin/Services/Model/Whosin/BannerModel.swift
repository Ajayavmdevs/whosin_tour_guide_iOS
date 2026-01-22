import Foundation
import ObjectMapper
import RealmSwift

class BannerModel : Object, Mappable, ModelProtocol {

    @objc dynamic var id:String = kEmptyString
    @objc dynamic var title:String = kEmptyString
    @objc dynamic var descriptions:String = kEmptyString
    @objc dynamic var image:String = kEmptyString
    @objc dynamic var type:String = kEmptyString
    @objc dynamic var typeId:String = kEmptyString
    @objc dynamic var buttonText:String = kEmptyString
    @objc dynamic var link:String = kEmptyString
    @objc dynamic var activityId: String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var offerId: String = kEmptyString
    @objc dynamic var ticketId: String = kEmptyString
    @objc dynamic var buttonTint: String = kEmptyString
    dynamic var mediaUrls: [String] = []

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
        title <- map["title"]
        descriptions <- map["description"]
        buttonText <- map["buttonText"]
        image <- map["image"]
        type <- map["type"]
        typeId <- map["typeId"]
        link <- map["link"]
        activityId <- map["activityId"]
        venueId <- map["venueId"]
        offerId <- map["offerId"]
        ticketId <- map["ticketId"]
        mediaUrls <- map["mediaUrls"]
        buttonTint <- map["buttonTint"]

    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
