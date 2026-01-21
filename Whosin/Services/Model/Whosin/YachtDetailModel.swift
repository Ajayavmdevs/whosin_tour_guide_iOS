import Foundation
import ObjectMapper
import RealmSwift

class YachtDetailModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var yachtClubId: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var about: String = kEmptyString
    dynamic var images = List<String>()
    @objc dynamic var year: String = kEmptyString
    @objc dynamic var people: String = kEmptyString
    @objc dynamic var cabins: String = kEmptyString
    @objc dynamic var size: String = kEmptyString
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var yachtClub: YachtClubModel?
    dynamic var specifications = List<SpecificationsModel>()
    dynamic var packages = List<YachtPackgeModel>()
    dynamic var features = List<CommonSettingsModel>()
    @objc dynamic var location: LocationModel?

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["_id"]
        yachtClubId <- map["yachtClubId"]
        name <- map["name"]
        about <- map["about"]
        images <- (map["images"], StringListTransform())
        year  <- map["year"]
        people <- map["people"]
        cabins <- map["cabins"]
        size <- map["size"]
        createdAt <- map["createdAt"]
        yachtClub <- map["yachtClub"]
        location <- map["location"]
        specifications <- (map["specifications"], ListTransform<SpecificationsModel>())
        packages <- (map["packages"], ListTransform<YachtPackgeModel>())
        features <- (map["features"], ListTransform<CommonSettingsModel>())

    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}


class YachtClubModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var address: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var about: String = kEmptyString
    @objc dynamic var logo: String = kEmptyString
    @objc dynamic var location: LocationModel?
    @objc dynamic var cover: String = kEmptyString
    @objc dynamic var phone: String = kEmptyString
    @objc dynamic var email: String = kEmptyString
    @objc dynamic var website: String = kEmptyString
    @objc dynamic var bookingUrl: String = kEmptyString
    @objc dynamic var isAllowReview: Bool = false
    @objc dynamic var isAllowRating: Bool = false
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var isOpen: Bool = false
    dynamic var features = List<String>()
    dynamic var timings = List<TimingModel>()
    dynamic var galleries = List<String>()
    dynamic var timing = List<TimingModel>()
    dynamic var reviews = List<RatingModel>()
    dynamic var yachts = List<YachtDetailModel>()
    dynamic var offers = List<YachtOfferDetailModel>()
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["_id"]
        address <- map["address"]
        name <- map["name"]
        about <- map["about"]
        logo <- map["logo"]
        location  <- map["location"]
        cover <- map["cover"]
        phone <- map["phone"]
        email <- map["email"]
        website <- map["website"]
        bookingUrl <- map["booking_url"]
        isAllowReview <- map["isAllowReview"]
        isAllowRating <- map["isAllowRating"]
        createdAt <- map["createdAt"]
        isOpen <- map["isOpen"]
        features <- (map["features"], StringArrayTransform())
        timings <- (map["timings"], ListTransform<TimingModel>())
        galleries <- (map["galleries"], StringArrayTransform())
        timing <- (map["timings"], ListTransform<TimingModel>())
        reviews <- (map["reviews"], ListTransform<RatingModel>())
        yachts <- (map["yachts"], ListTransform<YachtDetailModel>())
        offers <- (map["offers"], ListTransform<YachtOfferDetailModel>())



    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}

class YachtPackgeModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var offerId: String =  kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var yachtId: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var amount: Int = 0
    @objc dynamic var discount: Int = 0
    dynamic var slots = List<String>()
    @objc dynamic var minimumHour: Int = 0
    @objc dynamic var maximumHour: Int = 0
    @objc dynamic var pricePerHour: Int = 0
    dynamic var addOn = List<String>()
    dynamic var whatsInclude = List<String>()
    @objc dynamic var createdAt: String = kEmptyString
    
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
        yachtId <- map["yachtId"]
        offerId <- map["offerId"]
        title <- map["title"]
        descriptions <- map["description"]
        amount <- map["amount"]
        discount <- map["discount"]
        minimumHour <- map["minimumHour"]
        maximumHour <- map["maximumHour"]
        pricePerHour <- map["pricePerHour"]
        addOn <- (map["addOn"], StringListTransform())
        whatsInclude <- (map["whatsInclude"], StringListTransform())
        slots <- (map["slots"], StringListTransform())
        createdAt <- map["createdAt"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

class SpecificationsModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var showTitle: Bool = false
    @objc dynamic var value: String = kEmptyString
    
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
        showTitle <- map["showTitle"]
        title <- map["title"]
        value <- map["value"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    var attributedString: NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: FontBrand.SFregularFont(size: 12)
        ]
        
        if showTitle {
            // If showTitle is true, set bold font for title
            attributes[.font] = FontBrand.SFboldFont(size: 12)
        }
        
        let attributedString = NSMutableAttributedString(string: showTitle ? "\(title): \(value)" : "\(value)", attributes: attributes)
        
        if showTitle {
            // Set bold font for title
            attributedString.addAttribute(.font, value: FontBrand.SFboldFont(size: 12), range: NSRange(location: 0, length: title.count))
            
            // Set regular font for value
            attributedString.addAttribute(.font, value: FontBrand.SFregularFont(size: 12), range: NSRange(location: title.count + 2, length: value.count))
        }
        
        return attributedString
    }


    func isValid() -> Bool {
        return true
    }
}
