import Foundation
import ObjectMapper
import RealmSwift

class RatingListModel: Object, Mappable, ModelProtocol {
    
    dynamic var review = List<RatingModel>()
    dynamic var user = List<UserModel>()
    @objc dynamic var currentUserReview: RatingModel?
    dynamic var avgRating: Int = 0
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        review <- (map["reviews"],ListTransform<RatingModel>())
        user <- (map["users"],ListTransform<UserModel>())
        currentUserReview <- map["currentUserReview"]
        avgRating <- map["avgRating"]

    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
