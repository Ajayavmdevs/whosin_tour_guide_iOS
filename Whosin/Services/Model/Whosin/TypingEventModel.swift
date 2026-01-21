import Foundation
import ObjectMapper

class TypingEventModel: Mappable, ModelProtocol {
    
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var chatId: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var userName: String = kEmptyString
    @objc dynamic var isForStartTyping : Bool = false
    @objc dynamic var sender: UserModel?
    
    dynamic var receivers: [String] = []
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required init?(map: Map) {}
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    
    func isSent() -> Bool {
        guard let userDetail = APPSESSION.userDetail else { return false }
        return sender?.id == userDetail.id
    }
    
    class func chatIdPredicate(_ chatId: String) -> NSPredicate {
        NSPredicate(format: "chatId == %@", chatId)
    }
    
    func mapping(map: Map) {
        type <- map["type"]
        chatId <- map["chatId"]
        userId <- map["userId"]
        sender <- map["sender"]
        isForStartTyping <- map["isForStartTyping"]
        receivers <- map["receivers"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

