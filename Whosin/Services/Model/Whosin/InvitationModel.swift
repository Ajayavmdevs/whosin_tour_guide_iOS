import UIKit
import ObjectMapper
import DialCountries
import RealmSwift

class InvitationModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var eventId: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var extraGuest: Int = 0
    @objc dynamic var invitedBy: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var inviteType: String = kEmptyString
    dynamic var withMe = List<UserDetailModel>()
    @objc dynamic var venue: VenueDetailModel?
    @objc dynamic var user: UserDetailModel?
    @objc dynamic var inviteStatus: String = kEmptyString
    @objc dynamic var msg: String = kEmptyString
    @objc dynamic var createdAt: String = kEmptyString

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    class func idPredicate(_ id: String) -> NSPredicate {
        NSPredicate(format: "id == %@", id)
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
        eventId <- map["eventId"]
        extraGuest <- map["extraGuest"]
        invitedBy <- map["invitedBy"]
        title <- map["title"]
        inviteType <- map["inviteType"]
        withMe <- (map["withMe"], ListTransform<UserDetailModel>())
        venue <- map["venue"]
        inviteStatus <- map["inviteStatus"]
        createdAt <- map["createdAt"]
        user <- map["user"]
        msg <- map["msg"]
    }
    
    public var statusImage: UIImage? {
        if inviteStatus == "pending" {
            return UIImage(named: "icon_invitePending")
        } else if inviteStatus == "out" {
            return UIImage(named: "icon_inviteOut")
        } else if inviteStatus == "in" {
            return UIImage(named: "icon_inviteIn")
        } else {
            return nil
        }
    }

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}
