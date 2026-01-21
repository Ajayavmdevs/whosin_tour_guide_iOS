import Foundation
import ObjectMapper
import RealmSwift

class RatingModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var ratingId: String = kEmptyString
    @objc dynamic var itemId: String = kEmptyString
    @objc dynamic var activityId: String = kEmptyString
    @objc dynamic var eventOrgId: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var review: String = kEmptyString
    @objc dynamic var stars: Double = 0
    @objc dynamic var createdAt: Date?
    @objc dynamic var user: UserModel?
    @objc dynamic var reply: RatingReplyModel?
    @objc dynamic var replyString: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kFormatDateStandard)

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    override class func primaryKey() -> String? {
        "ratingId"
    }
    
    class func ratingIdPredicate(_ ratingId: String) -> NSPredicate {
        NSPredicate(format: "ratingId == %@", ratingId)
    }
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        ratingId <- map["_id"]
        itemId <- map["itemId"]
        activityId <- map["activityId"]
        eventOrgId <- map["eventOrgId"]
        userId <- map["userId"]
        review <- map["review"]
        stars <- map["stars"]
        reply <- map["reply"]
        createdAt <- (map["createdAt"], DateFormatterTransform(dateFormatter: _dateFormatter))
        replyString <- map["reply"]
        user <- map["user"]
        title <- map["title"]
        image <- map["image"]
        type <- map["type"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}


class RatingReplyModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var ratingReplyId: String = kEmptyString
    @objc dynamic var reply: String = kEmptyString
    @objc dynamic var createdAt: Date?
    
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kFormatDateStandard)

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    override class func primaryKey() -> String? {
        "ratingReplyId"
    }
    
    class func ratingReplyIdPredicate(_ ratingReplyId: String) -> NSPredicate {
        NSPredicate(format: "ratingReplyId == %@", ratingReplyId)
    }
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        ratingReplyId <- map["_id"]
        reply <- map["reply"]
        createdAt <- (map["createdAt"], DateFormatterTransform(dateFormatter: _dateFormatter))
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
