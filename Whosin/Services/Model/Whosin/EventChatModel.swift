import Foundation
import ObjectMapper
import RealmSwift


class EventChatModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    dynamic var members: List<String> = List<String>()
    
    public var lastMsg: MessageModel?

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {}
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    class func idPredicate(_ chatId: String) -> NSPredicate {
        NSPredicate(format: "id == %@", chatId)
    }
    
    
    func mapping(map: Map) {
        id <- map["_id"]
        title <- map["title"]
        image <- map["image"]
        members <- (map["members"] , StringListTransform())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

