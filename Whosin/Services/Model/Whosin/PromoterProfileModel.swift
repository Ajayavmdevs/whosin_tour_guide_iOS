import Foundation
import RealmSwift
import ObjectMapper

class PromoterProfileModel: Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var profile: UserDetailModel?
    dynamic var rings: CommanPromoterRingModel?
    dynamic var circles = List<UserDetailModel>()
    dynamic var review: RatingListModel?
    dynamic var venues: CommanPromoterVenueModel?
    dynamic var score: ProfileScoreModel?
    dynamic var inEvents = List<PromoterEventsModel>()
    dynamic var wishlistEvents = List<PromoterEventsModel>()
    dynamic var speciallyForMe = List<PromoterEventsModel>()
    dynamic var ImInterested = List<PromoterEventsModel>()
    dynamic var events = List<PromoterEventsModel>()
    @objc dynamic var counterModel: CountersModel?
    @objc dynamic var isAdminPromoter: Bool = false
    dynamic var logs = List<LogsModel>()
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        profile <- map["profile"]
        rings <- map["rings"]
        circles <- (map["circles"], ListTransform<UserDetailModel>())
        review <- map["review"]
        venues <- map["venues"]
        score <- map["score"]
        inEvents <- (map["inEvents"], ListTransform<PromoterEventsModel>())
        wishlistEvents <- (map["wishlistEvents"], ListTransform<PromoterEventsModel>())
        speciallyForMe <- (map["speciallyForMeEvents"], ListTransform<PromoterEventsModel>())
        ImInterested <- (map["interestedEvents"], ListTransform<PromoterEventsModel>())
        events <- (map["events"], ListTransform<PromoterEventsModel>())
        counterModel <- map["counter"]
        isAdminPromoter <- map["isAdminPromoter"]
        logs <- (map["logs"], ListTransform<LogsModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}

class CommanPromoterRingModel:Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var count: Int = 0
    @objc dynamic var maleCount: Int = 0
    @objc dynamic var femaleCount: Int = 0
    @objc dynamic var preferNotToSay: Int = 0
    dynamic var ringList = List<UserDetailModel>()
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        count <- map["count"]
        maleCount <- map["maleCount"]
        femaleCount <- map["femaleCount"]
        preferNotToSay <- map["preferNotToSay"]
        ringList <- (map["list"], ListTransform<UserDetailModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}

class CommanPromoterVenueModel:Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var count: Int = 0
    dynamic var venueList = List<VenueDetailModel>()
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        count <- map["count"]
        venueList <- (map["list"], ListTransform<VenueDetailModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}


class ProfileScoreModel: Mappable, ModelProtocol {
    
    @objc dynamic var punctuality: Double = 0.0
    @objc dynamic var activity: Double = 0.0
    @objc dynamic var value: Double = 0.0
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        punctuality <- map["punctuality"]
        activity <- map["activity"]
        value <- map["value"]

    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}

class CountersModel:Object, Mappable, ModelProtocol {
    
    @objc dynamic var eventsImIn: Int = 0
    @objc dynamic var speciallyForMe: Int = 0
    @objc dynamic var imInterested: Int = 0
    @objc dynamic var myList: Int = 0
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        eventsImIn <- map["eventsImIn"]
        speciallyForMe <- map["speciallyForMe"]
        imInterested <- map["imInterested"]
        myList <- map["myList"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}
