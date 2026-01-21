import Foundation
import ObjectMapper
import RealmSwift

class OutingListModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var offerId: String = kEmptyString
    @objc dynamic var owner: UserDetailModel?
    @objc dynamic var venue: VenueDetailModel?
    @objc dynamic var offer: OffersModel?
    @objc dynamic var date: String = kEmptyString
    @objc dynamic var startTime: String = kEmptyString
    @objc dynamic var endTime: String = kEmptyString
    @objc dynamic var extraGuest: Int = 0
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var createdAt: String = kEmptyString
    dynamic var invitedUser: List<UserDetailModel> = List<UserDetailModel>()
    public var lastMsg: MessageModel?
    dynamic var members: List<String> = List<String>()

    
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
        userId <- map["userId"]
        venueId <- map["venueId"]
        offerId <- map["offerId"]
        owner <- map["user"]
        offer <- map["offer"]
        date <- map["date"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        extraGuest <- map["extraGuest"]
        status <- map["status"]
        createdAt <- map["createdAt"]
        venue <- map["venue"]
        invitedUser <- (map["invitedUser"], ListTransform<UserDetailModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    var borderColor: UIColor {
        guard let userDetail = APPSESSION.userDetail else { return ColorBrand.brandBorderRed }
        if userId == userDetail.id && status == "upcoming" {
            return ColorBrand.brandPink
        }
        if let user = user {
            if user.inviteStatus.lowercased() == "in" {
                return ColorBrand.brandGreen
            }
            else if user.inviteStatus.lowercased() == "pending" {
                return ColorBrand.yellowColor
            }
        }
        return ColorBrand.brandBorderRed
    }
        
    var isOwner: Bool {
        guard let userDetail = APPSESSION.userDetail else { return false }
        return userId == userDetail.id
    }
    
    var user: UserDetailModel? {
        guard let userDetail = APPSESSION.userDetail else { return nil }
        return invitedUser.first(where: { $0.id == userDetail.id})
    }
    
    var _invitedUser: [UserDetailModel] {
        return invitedUser.toArrayDetached(ofType: UserDetailModel.self)
    }
    
    var invitedId: String {
        return invitedUser.first { $0.userId == APPSESSION.userDetail?.id }?.inviteId ?? kEmptyString
    }

    
    var _date: String {
        return Utils.stringToDate(date, format: kFormatDate)?.display ?? ""
    }

    var _startTime: String {
        let date = Utils.stringToDate(startTime, format: "HH:mm")
        return Utils.dateToString(date, format: "HH:mm")
    }
    
    var _endTime: String {
        let date = Utils.stringToDate(endTime, format: "HH:mm")
        return Utils.dateToString(date, format: "HH:mm")
    }
    
    var _timeSlot: String {
        return _startTime + " - " + _endTime
    }
    
    var createdDate: String {
        return "Created date: " + (Utils.stringToDate(createdAt, format: kStanderdDate)?.display ?? "")
    }

    var chatName: String {
        let name = venue?.name ?? kEmptyString
        return name + " - \(owner?.fullName ?? kEmptyString)"
    }

    var chatHomeEventName: String {
        return venue?.name ?? kEmptyString
    }

    var chatHomeOrgName: String {
        return owner?.fullName ?? kEmptyString
    }

    func isValid() -> Bool {
        return true
    }
    
    var differenceIdentifier: String {
        return id
    }
    
    func isContentEqual(to source: EventModel) -> Bool {
        return self.id == source.id && self.chatHomeOrgName == source.chatHomeOrgName && self.chatHomeEventName == source.chatHomeEventName && self.lastMsg == source.lastMsg
    }
}
