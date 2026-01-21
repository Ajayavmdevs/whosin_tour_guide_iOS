import Foundation
import ObjectMapper
import RealmSwift

class OrganizaitionDetailModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var logo: String = kEmptyString
    @objc dynamic var cover: String = kEmptyString
    @objc dynamic var phone: String = kEmptyString
    @objc dynamic var email: String = kEmptyString
    @objc dynamic var website: String = kEmptyString
    @objc dynamic var desc: String = kEmptyString
    dynamic var galleries = List<GalaryModel>()
    dynamic var reviews = List<RatingModel>()
    dynamic var eventModel = List<EventModel>()
    @objc dynamic var currentUserReview: RatingModel?
    @objc dynamic var avgRating: Double = 0.0
    @objc dynamic var isFollowing: Bool = false
    dynamic var users = List<UserModel>()
    
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
        name <- map["name"]
        logo <- map["logo"]
        cover <- map["cover"]
        phone <- map["phone"]
        email <- map["email"]
        website <- map["website"]
        desc <- map["description"]
        galleries <- (map["galleries"], ListTransform<GalaryModel>())
        reviews <- (map["reviews"], ListTransform<RatingModel>())
        eventModel <- (map["events"], ListTransform<EventModel>())
        currentUserReview <- map["currentUserReview"]
        avgRating <- map["avg_ratings"]
        isFollowing <- map["isFollowing"]
        users <- (map["users"],ListTransform<UserModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}




