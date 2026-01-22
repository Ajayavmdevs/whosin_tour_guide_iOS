import Foundation
import ObjectMapper
import RealmSwift

class StoryModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id : String = kEmptyString
    @objc dynamic var mediaType : String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var offerId: String = kEmptyString
    @objc dynamic var ticketId: String = kEmptyString
    @objc dynamic var contentType : String = kEmptyString
    @objc dynamic var mediaUrl : String = kEmptyString
    @objc dynamic var thumbnail : String = kEmptyString
    @objc dynamic var duration: String = kEmptyString
    @objc dynamic var buttonText : String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var expiryDate:String = kEmptyString
    dynamic var ticketModel: TicketModel?

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
        mediaType <- map["mediaType"]
        venueId <- map["venueId"]
        offerId <- map["offerId"]
        ticketId <- map["ticketId"]
        contentType <- map["contentType"]
        mediaUrl <- map["mediaUrl"]
        thumbnail <- map["thumbnail"]
        buttonText <- map["buttonText"]
        duration <- map["duration"]
        userId <- map["userId"]
        expiryDate <- map["expiryDate"]
        createdAt <- map["createdAt"]
    }
    
    var isImage: Bool {
        mediaType == "photo"
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}
