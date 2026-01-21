import Foundation
import ObjectMapper
import RealmSwift

class ActivitiesModel: Object, Mappable, ModelProtocol, Identifiable {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    dynamic var galleries = List<String>()
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var providerId: String = kEmptyString
    @objc dynamic var typeId: String = kEmptyString
    @objc dynamic var price: Int = 0
    @objc dynamic var discount: Int = 0
    dynamic var totalSeats: Int = 0
    @objc dynamic var startDate: Date?
    @objc dynamic var endDate: Date?
    @objc dynamic var reservationStart: Date?
    @objc dynamic var reservationEnd: Date?
    dynamic var days = List<String>()
    @objc dynamic var time: TimingModel?
    dynamic var avilableFeatures = List<AvilableFeaturesModel>()
    dynamic var createdAt: Date?
    @objc dynamic var provider: ProviderModel?
    @objc dynamic var type: ActivityTypeModel?
    dynamic var activityRating = List<RatingModel>()
    @objc dynamic var currentUserRating: RatingModel?
    @objc dynamic var avgRating: Double = 0.0
    @objc dynamic var myRating: String = kEmptyString
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var uniqueCode: String = kEmptyString
    dynamic var user = List<UserModel>()
    @objc dynamic var coverImage: String = kEmptyString
    @objc dynamic var isRecommendation: Bool = false
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kFormatDateStandard)
    @objc dynamic var disclaimerDescription: String = kEmptyString
    @objc dynamic var disclaimerTitle: String = kEmptyString

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
        if let galleriesArray = map["galleries"].currentValue as? [String] {
                galleries.removeAll()
                galleries.append(objectsIn: galleriesArray)
        }
        descriptions <- map["description"]
        providerId <- map["providerId"]
        typeId <- map["typeId"]
        price <- map["price"]
        discount <- map["discount"]
        totalSeats <- map["totalSeats"]
        startDate <- (map["startDate"], DateFormatterTransform(dateFormatter: _dateFormatter))
        endDate <- (map["endDate"], DateFormatterTransform(dateFormatter: _dateFormatter))
        reservationStart <- (map["reservationStart"], DateFormatterTransform(dateFormatter: _dateFormatter))
        reservationEnd <- (map["reservationEnd"], DateFormatterTransform(dateFormatter: _dateFormatter))
        if let avilableDays = map["avilableDays"].currentValue as? [String] {
            days.removeAll()
            days.append(objectsIn: avilableDays)
        }
        time <- map["activityTime"]
        avilableFeatures <- (map["avilableFeatures"],ListTransform<AvilableFeaturesModel>())
        createdAt <- map["createdAt"]
        provider <- map["provider"]
        type <- map["activityType"]
        activityRating <- (map["reviews"],ListTransform<RatingModel>())
        currentUserRating <- map["currentUserReview"]
        avgRating <- map["avg_ratings"]
        myRating <- map["myRating"]
        status <- map["status"]
        uniqueCode <- map["uniqueCode"]
        user <- (map["users"],ListTransform<UserModel>())
        coverImage <- map["coverImage"]
        isRecommendation <- map["isRecommendation"]
        disclaimerDescription <- map["disclaimerDescription"]
        disclaimerTitle <- map["disclaimerTitle"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    public var  _startDate: String {
        return startDate?.display ?? ""
    }
    
    public var  _endDate: String {
        return endDate?.display ?? ""
    }
    
    public var _disocuntedPrice: String {
        return Utils.calculateDiscountValue(originalPrice: price, discountPercentage: discount)
    }
    
    public var isFutureOrCurrentDate: Bool {
        if let endDate = endDate {
            return endDate >= Date()
        } else {
            return false
        }
    }
    
    public var _isNoDiscount: Bool {
        return Int(_disocuntedPrice) == price || price == 0
    }
    
    public var isPriceZero: Bool {
        return price == 0
    }
    
    public var isReservationEnd: Bool {
        let lastDate = Utils.dateToString(reservationEnd, format: kStanderdDate)
        return Utils.isDateExpired(dateString: lastDate, format: kStanderdDate)
    }
    
    public var isActivityExpired: Bool {
        let lastDate = Utils.dateToString(endDate, format: kStanderdDate)
        return Utils.isDateExpired(dateString: lastDate, format: kStanderdDate)
    }
    
    public var availableDays: String {
        let daysArray = days.toArray(ofType: String.self)
        if daysArray.count >= 7 {
            return "All days"
        } else if daysArray.count == 2 && daysArray.contains("sat") && daysArray.contains("sun") {
            return "Weekend"
        } else if daysArray.count == 5 && !daysArray.contains("sat") && !daysArray.contains("sun"){
            return "Week days"
        } else {
            return days.joined(separator: ",")
        }
    }
    
    public var cover: String {
        return Utils.addResolutionToURL(urlString: galleries.first ?? coverImage, resolution: "600")
    }

    func isValid() -> Bool {
        return true
    }
    
}

class ProviderModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var slogo: String = kEmptyString
    @objc dynamic var address: String = kEmptyString
    @objc dynamic var loacation: LocationModel?
    @objc dynamic var email: String = kEmptyString
    @objc dynamic var phone: String = kEmptyString
    
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
        slogo <- map["logo"]
        address <- map["address"]
        loacation <- map["location"]
        email <- map["email"]
        phone <- map["phone"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    var logo: String {
        return Utils.addResolutionToURL(urlString: slogo, resolution: "150")
    }
    
    func isValid() -> Bool {
        return true
    }
}

class AvilableFeaturesModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var icon: String = kEmptyString
    @objc dynamic var feature: String = kEmptyString
    
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
        icon <- map["icon"]
        feature <- map["feature"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}


class AvilableDateTimeModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var date: Date?
    @objc dynamic var seat: Int = 0
    @objc dynamic var time: String = kEmptyString
    @objc dynamic var remainingSeat: Int = 0
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kFormatDate)
    
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
        date <- (map["date"], DateFormatterTransform(dateFormatter: _dateFormatter))
        seat <- map["seat"]
        time <- map["time"]
        remainingSeat <- map["remainingSeat"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}
