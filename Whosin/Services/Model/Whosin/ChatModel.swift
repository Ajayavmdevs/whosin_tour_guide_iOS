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
    
    init(_event: EventModel) {
        super.init()
        chatId = _event.id
        chatType = "event"
        title = _event.chatName
        image = _event.image
        var userIds: [String] = _event.invitedGuest.map { $0.userId }
        userIds.append(contentsOf: _event.admins)
        if let userDetail = APPSESSION.userDetail {
            if !userIds.contains(where: { $0 == userDetail.id }) {
                userIds.append(userDetail.id)
            }
        }

        members.append(objectsIn: userIds)
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

class ChatUserModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var firstName: String = kEmptyString
    @objc dynamic var lastName: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var follow: String = kEmptyString

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {}
    
     init(model: UserDetailModel) {
        super.init()
        id = model.id
        firstName = model.firstName
        lastName = model.lastName
        image = model.image
        follow = model.follow
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        image <- map["image"]
        follow <- map["follow"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public var fullName : String {
        "\(firstName) \(lastName)"
    }

    
    func isValid() -> Bool {
        return true
    }
}

class ChatOfferModel: Object, Mappable, ModelProtocol, Identifiable {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var days: String = kEmptyString
    @objc dynamic var startTime: String = kEmptyString
    @objc dynamic var endTime: String = kEmptyString
    @objc dynamic var venue: ChatVenueModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    override class func primaryKey() -> String? {
        "id"
    }

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    override init() {
        super.init()
    }
    
    required init?(map: Map) {}
    
    init(model: OffersModel, venueModel: ChatVenueModel) {
        super.init()
        id = model.id
        title = model.title
        descriptions = model.descriptions
        image = model.offerImage
        startTime = model.startTime
        endTime = model.endTime
        days = model._days
        venue = venueModel
    }

    func mapping(map: Map) {
        id <- map["_id"]
        title <- map["title"]
        descriptions <- map["description"]
        image <- map["image"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        days <- map["days"]
        venue <- map["venue"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    var startDate: Date? {
        return Utils.stringToDate(startTime, format: kStanderdDate)
    }

    var endDate: Date? {
        return Utils.stringToDate(endTime, format: kStanderdDate)
    }
    
    var timeSloat: String {
        "\(Utils.dateToString(startDate, format: kFormatDateTimeUS)) - \(Utils.dateToString(endDate, format: kFormatDateTimeUS))"
    }
    
    func isValid() -> Bool {
        return true
    }

}

class ChatYachtModel: Object, Mappable, ModelProtocol, Identifiable {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var yachtClubId: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var about: String = kEmptyString
    dynamic var features = List<CommonSettingsModel>()
    @objc dynamic var yachtClub: YachtClubModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    override class func primaryKey() -> String? {
        "id"
    }

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    override init() {
        super.init()
    }
    
    required init?(map: Map) {}
    
    init(_ model: YachtDetailModel) {
        super.init()
        id = model.id
        yachtClubId = model.yachtClubId
        name = model.name
        about = model.about
        features = model.features
        yachtClub = model.yachtClub
    }

    func mapping(map: Map) {
        id <- map["_id"]
        yachtClubId <- map["yachtClubId"]
        name <- map["name"]
        about <- map["about"]
        yachtClub <- map["yachtClub"]
        features <- (map["features"], ListTransform<CommonSettingsModel>())
    }

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
        
    func isValid() -> Bool {
        return true
    }

}

class ChatYachtOfferModel: Object, Mappable, ModelProtocol, Identifiable {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var yachtId: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var startDate: String = kEmptyString
    @objc dynamic var endDate: String = kEmptyString
    @objc dynamic var isExpired: String = kEmptyString
    @objc dynamic var startingAmount: Int = 0
    @objc dynamic var discount: Int = 0
    @objc dynamic var yacht: ChatYachtModel?
    dynamic var images = List<String>()

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    override class func primaryKey() -> String? {
        "id"
    }

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    override init() {
        super.init()
    }
    
    required init?(map: Map) {}
    
    init(model: YachtOfferDetailModel, yatchModel: ChatYachtModel) {
        super.init()
        id = model.id
        yachtId = model.yachtId
        title = model.title
        descriptions = model.descriptions
        startDate = model.startDate
        endDate = model.endDate
        isExpired = model.isExpired
        startingAmount = model.startingAmount
        discount = model.discount
        yacht = yatchModel
        images = model.images
    }

    func mapping(map: Map) {
        id <- map["_id"]
        yachtId <- map["yachtId"]
        title <- map["title"]
        descriptions <- map["description"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        isExpired <- map["isExpired"]
        startingAmount <- map["startingAmount"]
        discount <- map["discount"]
        yacht <- map["yacht"]
        images <- (map["images"], StringListTransform())
    }

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
        
    func isValid() -> Bool {
        return true
    }

}
