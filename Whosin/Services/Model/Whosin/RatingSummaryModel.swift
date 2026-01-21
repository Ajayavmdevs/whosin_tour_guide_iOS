import Foundation
import ObjectMapper
import RealmSwift

class RatingSummaryModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var totalRating: Int = 0
    @objc dynamic var avgRating: String = kEmptyString
    @objc dynamic var summary: SummaryModel?
        
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        totalRating <- map["totalRating"]
        avgRating <- map["avgRating"]
        summary <- map["summary"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

class SummaryModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var one: StarRatingModel?
    @objc dynamic var two: StarRatingModel?
    @objc dynamic var three: StarRatingModel?
    @objc dynamic var four: StarRatingModel?
    @objc dynamic var five: StarRatingModel?
 
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        one <- map["1"]
        two <- map["2"]
        three <- map["3"]
        four <- map["4"]
        five <- map["5"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

class StarRatingModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var totalRatings: Int = 0
    @objc dynamic var percentage: String = kEmptyString
        
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        totalRatings <- map["total_ratings"]
        percentage <- map["percentage"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}
