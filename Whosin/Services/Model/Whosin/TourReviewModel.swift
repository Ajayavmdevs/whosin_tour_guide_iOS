 import Foundation
import RealmSwift
import ObjectMapper

class TourReviewModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: Int = 0
    @objc dynamic var tourId: Int = 0
    @objc dynamic var reviewId: Int = 0
    @objc dynamic var reviewTitle: String = kEmptyString
    @objc dynamic var reviewContent: String = kEmptyString
    @objc dynamic var visitMonth: String = kEmptyString
    @objc dynamic var rating: String = kEmptyString
    @objc dynamic var imagePath: String = kEmptyString
    @objc dynamic var guestName: String = kEmptyString

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["id"]
        tourId <- map["tourId"]
        reviewId <- map["reviewId"]
        reviewTitle <- map["reviewTitle"]
        reviewContent <- map["reviewContent"]
        visitMonth <- map["visitMonth"]
        rating <- map["rating"]
        imagePath <- map["imagePath"]
        guestName <- map["guestName"]
    }
    
    func isValid() -> Bool {
        return true
    }
}
