import Foundation
import ObjectMapper
import RealmSwift

class BucketDetailModel: Object, Mappable, ModelProtocol {
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    dynamic var galleries: [String] = []
    @objc dynamic var coverImage: String = kEmptyString
    dynamic var sharedWith = List<UserDetailModel>()
    @objc dynamic var status: Bool = false
    dynamic var items = List<ItemModel>()
    dynamic var offersModel = List<OffersModel>()
    dynamic var eventsModel = List<EventModel>()
    dynamic var activitiesModel = List<ActivitiesModel>()
    dynamic var sharedUser: List<String> = List<String>()
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var owner: UserDetailModel?
    
    public var lastMsg: MessageModel?
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    class func idPredicate(_ id: String) -> NSPredicate {
        NSPredicate(format: "id == %@", id)
    }

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        userId <- map["userId"]
        name <- map["name"]
        coverImage <- map["coverImage"]
        offersModel <- (map["offers"], ListTransform<OffersModel>())
        sharedWith <- (map["shared_with"], ListTransform<UserDetailModel>())
        eventsModel <- (map["events"], ListTransform<EventModel>())
        activitiesModel <- (map["activities"], ListTransform<ActivitiesModel>())
        galleries <- map["galleries"]
        status <- map["status"]
        items <- (map["items"], ListTransform<ItemModel>())
        sharedUser <- (map["shared_with"] , StringListTransform())
        createdAt <- map["createdAt"]
        owner <- map["user"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
    var differenceIdentifier: String {
        return id
    }
    
    func isContentEqual(to source: BucketDetailModel) -> Bool {
        return self.id == source.id && self.name == source.name && self.coverImage == source.coverImage && self.lastMsg == source.lastMsg
    }
    
}


class ItemModel: Object, Mappable, ModelProtocol {
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "id"
    }

    required convenience init?(map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        id <- map["_id"]
        _id <- map["id"]
        type <- map["type"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}
