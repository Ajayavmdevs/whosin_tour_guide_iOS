import Foundation
import DifferenceKit
import ObjectMapper
import RealmSwift

class VenueDetailModel: Object, Mappable, ModelProtocol,Differentiable, Identifiable {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var businessId: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var slogo: String = kEmptyString
    @objc dynamic var about: String = kEmptyString
    @objc dynamic var address: String = kEmptyString
    @objc dynamic var venueCover: String = kEmptyString
    @objc dynamic var location: LocationModel?
    @objc dynamic var phone: String = kEmptyString
    @objc dynamic var email: String = kEmptyString
    @objc dynamic var website: String = kEmptyString
    @objc dynamic var bookingUrl: String = kEmptyString
    @objc dynamic var menuUrl: String = kEmptyString
    @objc dynamic var business: BusinessModel?
    dynamic var galleries: [String] = []
    @objc dynamic var dressCode: String = kEmptyString
    @objc dynamic var distance: Double = 0.0
    dynamic var timing = List<TimingModel>()
    dynamic var reviews = List<RatingModel>()
    dynamic var theme: List<String> = List<String>()
    dynamic var music: List<String> = List<String>()
    dynamic var feature: List<String> = List<String>()
    dynamic var cuisine: List<String> = List<String>()
    @objc dynamic var isFollowing: Bool = false
    @objc dynamic var isAllowReview: Bool = false
    @objc dynamic var isAllowRatting: Bool = false
    @objc dynamic var avgRatings: Double = 0.0
    dynamic var currentUserRating: CurrentUserRatingModel?
    dynamic var specialOffers = List<SpecialOffersModel>()
    dynamic var deals = List<DealsModel>()
//    dynamic var story: StoryModel?
    dynamic var storie = List<StoryModel>()
    dynamic var users = List<UserModel>()
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    dynamic var checkIns = List<UserDetailModel>()
    @objc dynamic var isOpen: Bool = false
    @objc dynamic var isRecommendation: Bool = false
    @objc dynamic var discountText: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var frequencyOfVisitForCm: Int = 0


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
        businessId <- map["business_id"]
        name <- map["name"]
        slogo <- map["logo"]
        venueCover <- map["cover"]
        about <- map["about"]
        descriptions <- map["description"]
        phone <- map["phone"]
        email <- map["email"]
        website <- map["website"]
        bookingUrl <- map["booking_url"]
        menuUrl <- map["menu_url"]
        business <- map["business"]
        galleries <- map["galleries"]
        dressCode <- map["dress_code"]
        address <- map["address"]
        location <- map["location"]
        timing <- (map["timings"], ListTransform<TimingModel>())
        reviews <- (map["reviews"], ListTransform<RatingModel>())
        theme <- (map["themes"], StringListTransform())
        music <- (map["music"], StringListTransform())
        feature <- (map["features"], StringListTransform())
        cuisine <- (map["cuisines"], StringListTransform())
        distance <- map["distance"]
        avgRatings <- map["avg_ratings"]
        isFollowing <- map["isFollowing"]
        isAllowReview <- map["isAllowReview"]
        isAllowRatting <- map["isAllowRatting"]
        specialOffers <- (map["specialOffers"],ListTransform<SpecialOffersModel>())
        deals <- (map["deals"], ListTransform<DealsModel>())
        currentUserRating <- map["currentUserReview"]
//        story <- map["story"]
        storie <- (map["stories"], ListTransform<StoryModel>())
        users <- (map["users"], ListTransform<UserModel>())
        lat <- map["lat"]
        lng <- map["lng"]
        checkIns <- (map["checkins"], ListTransform<UserDetailModel>())
        isOpen <- map["isOpen"]
        isRecommendation <- map["isRecommendation"]
        discountText <- map["discountText"]
        image <- map["image"]
        frequencyOfVisitForCm <- map["frequencyOfVisitForCm"]
        type <- map["type"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
    func getVideoUrls() -> [URL] {
        let storiesList = storie.toArray(ofType: StoryModel.self)
        let urls = storiesList.filter({ !$0.isImage && URL(string: $0.mediaUrl) != nil }).map({URL(string: $0.mediaUrl)!})
        return urls
    }
    
    var logo: String {
        return Utils.addResolutionToURL(urlString: slogo, resolution: "150")
    }
    
    var cover: String {
        return Utils.addResolutionToURL(urlString: venueCover, resolution: "600")
    }

    func hasStories() -> Bool {
        if storie.isEmpty {
            if let storyModel = HomeRepository.getStoryByVenueId(id) {
                return true
            }
            return false
        } else {
            return true
        }
    }
    
    var differenceIdentifier: String {
        return id
    }
    
    func isContentEqual(to source: VenueDetailModel) -> Bool {
        return self.id == source.id && self.image == source.image && self.name == source.name
    }
    
}




