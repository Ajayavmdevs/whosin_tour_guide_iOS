import Foundation
import DifferenceKit
import ObjectMapper
import RealmSwift

class ChatModel: Object, Mappable, ModelProtocol, Differentiable, Identifiable {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var chatId: String = kEmptyString
    @objc dynamic var chatType: String = kEmptyString
    dynamic var members: List<String> = List<String>()
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var lastMsg: MessageModel?
    
    public var title: String = kEmptyString
    public var image: String = kEmptyString
    
    public var user: UserDetailModel?
    
    public var diffId : String {
        chatId+""+(lastMsg?.id ?? "")
    }
    
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {}
    
    init(msg: MessageModel) {
        super.init()
        title = msg.authorName
        image = msg.authorImage
        chatId = msg.chatId
        chatType = msg.chatType
        members = msg.members
        createdAt = msg.date
    }
    
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "chatId"
    }
    
    class func chatIdPredicate(_ chatId: String) -> NSPredicate {
        NSPredicate(format: "chatId == %@", chatId)
    }
    
    class func chatTypePredicate(_ chatType: String) -> NSPredicate {
        NSPredicate(format: "chatType == %@", chatType)
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        chatId <- map["chatId"]
        chatType <- map["chatType"]
        members <- (map["members"] , StringListTransform())
        createdAt <- map["createdAt"]
        lastMsg <- map["last_msg"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    var differenceIdentifier: String {
        return chatId+""+(lastMsg?.id ?? "")
    }
    
    func isContentEqual(to source: ChatModel) -> Bool {
        return self.chatId == source.chatId && self.lastMsg?.id == source.lastMsg?.id
    }
    
    func isValid() -> Bool {
        return true
    }
}

class ChatVenueModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var logo: String = kEmptyString
    @objc dynamic var cover: String = kEmptyString
    @objc dynamic var address: String = kEmptyString
    dynamic var story = List<StoryModel>()
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {}
    
    init(model: VenueDetailModel, storyId: String = kEmptyString) {
        super.init()
        id = model.id
        name = model.name
        logo = model.slogo
        cover = model.venueCover
        address = model.address
        if let str = model.storie.first(where: { $0.id == storyId}) {
            story.append(str)
        }
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        name <- map["name"]
        logo <- map["logo"]
        cover <- map["cover"]
        address <- map["address"]
        story <- map["stories"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

class ChatTicketModel: Object, Mappable, ModelProtocol {

    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var city: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var startingAmount: Double = 0
    @objc dynamic var discount: Int = 0
    dynamic var images = List<String>()
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {}
    
    init(model: TicketModel) {
        super.init()
        _id = model._id
        title = model.title
        descriptions = model.descriptions
        city = model.city
        startingAmount = model.startingAmount
        images = model.images
        discount = model.discount
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "_id"
    }
    
    func mapping(map: Map) {
        _id <- map["_id"]
        title <- map["title"]
        descriptions <- map["description"]
        city <- map["city"]
        startingAmount <- map["startingAmount"]
        discount <- map["discount"]
        images <- (map["images"], StringListTransform())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

