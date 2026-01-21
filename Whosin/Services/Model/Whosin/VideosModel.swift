import Foundation
import ObjectMapper
import RealmSwift

class VideosModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var videoUrl: String = kEmptyString
    @objc dynamic var thumb: String = kEmptyString
    @objc dynamic var duration: Int = 0
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var ticketId: String = kEmptyString
    var venueModel: VenueDetailModel?
    var ticketModel: TicketModel?
    
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
        descriptions <- map["descriptions"]
        videoUrl <- map["videoUrl"]
        thumb <- map["thumb"]
        duration <- map["duration"]
        venueId <- map["venueId"]
        ticketId <- map["ticketId"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
