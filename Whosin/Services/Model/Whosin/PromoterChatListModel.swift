import Foundation
import RealmSwift
import ObjectMapper

class PromoterChatListModel: Object,Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var venueName: String = kEmptyString
    @objc dynamic var venueImage: String = kEmptyString
    @objc dynamic var date: String = kEmptyString
    @objc dynamic var startTime: String = kEmptyString
    @objc dynamic var endTime: String = kEmptyString
    @objc dynamic var lastMessage: MessageModel?
    @objc dynamic var totalMessages: Int = 0
    @objc dynamic var maxInvitee: Int = 0
    @objc dynamic var owner: UserDetailModel?
    dynamic var users = List<UserDetailModel>()
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    class func idPredicate(_ chatId: String) -> NSPredicate {
        NSPredicate(format: "id == %@", chatId)
    }


    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        userId <- map["userId"]
        descriptions <- map["description"]
        venueName <- map["venueName"]
        venueImage <- map["venueImage"]
        date <- map["date"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        lastMessage <- map["lastMessage"]
        totalMessages <- map["totalMessages"]
        owner <- map["owner"]
        maxInvitee <- map["maxInvitee"]
        users <- (map["users"], ListTransform<UserDetailModel>())
    }
    
    public var isExpired: Bool {
        return  Utils.stringDateLocal("\(date) \(endTime)", format: "yyyy-MM-dd HH:mm")?.isExpired() ?? false
    }
    
    public var isExpiredGroupChat: Bool {
        let fifteenMinutes: TimeInterval = 15 * 60
        if let endDate = Utils.stringDateLocal("\(date) \(endTime)", format: "yyyy-MM-dd HH:mm") {
            return endDate.isExpiredAfter15(after: fifteenMinutes)
        }
        return false
    }
    
    public var isExpiredAllChat: Bool {
        let afterMinutes: TimeInterval = 120 * 60
        if let endDate = Utils.stringDateLocal("\(date) \(endTime)", format: "yyyy-MM-dd HH:mm") {
            return endDate.isExpiredAfter15(after: afterMinutes)
        }
        return false
    }
    
    public var inUsers: [UserDetailModel] {
        return users.toArrayDetached(ofType: UserDetailModel.self).filter({ $0.inviteStatus == "in" && $0.promoterStatus != "rejected" && $0.promoterStatus == "accepted"})
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}

class PromoterChatMessagesModel: Mappable, ModelProtocol {
    
    dynamic var users = List<UserDetailModel>()
    dynamic var members = List<String>()
    dynamic var messages = List<MessageModel>()
    @objc dynamic var channelClosed: Bool = false
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        users <- (map["users"], ListTransform<UserDetailModel>())
        members <- (map["members"], StringListTransform())
        messages <- (map["messages"], ListTransform<MessageModel>())
        channelClosed <- map["channelClosed"]
    }


    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}
