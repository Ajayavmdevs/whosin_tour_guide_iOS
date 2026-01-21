import Foundation
import ObjectMapper
import RealmSwift

class DealsModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var discountValue: Int = 0
    @objc dynamic var discountValues: String = kEmptyString
    @objc dynamic var discountedPrice: Int = 0
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var categoryId: String = kEmptyString
    @objc dynamic var originalPrice: Int = 0
    @objc dynamic var startDate: String = kEmptyString
    @objc dynamic var endDate: String = kEmptyString
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var venueModel: VenueDetailModel?
    var days: String  {
        get {
            if _days.isEmpty { return kEmptyString }
            let daysArray = _days.split(separator: ",")
            if daysArray.count >= 7 {
                return "All days"
            } else if daysArray.count == 2 && daysArray.contains("sat") && daysArray.contains("sun") {
                return "Weekend"
            } else if daysArray.count == 5 && !daysArray.contains("sat") && !daysArray.contains("sun"){
                return "Week days"
            }
            let capitalizedArray = daysArray.map { $0.capitalized }
            return capitalizedArray.joined(separator: ", ")
        }
    }
    @objc dynamic var _days: String = kEmptyString
    @objc dynamic var startTime: String = kEmptyString
    @objc dynamic var endTime: String = kEmptyString
    @objc dynamic var actualPrice: Int = 0
    @objc dynamic var paxPerVoucher: Int = 0
    dynamic var features = List<CommonSettingsModel>()
    dynamic var vouchars = List<VoucharsModel>()
    
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
        title <- map["title"]
        descriptions <- map["description"]
        image <- map["image"]
        venueId <- map["venueId"]
        categoryId <- map["categoryId"]
        _days <- map["days"]
        discountValue <- map["discountValue"]
        discountValues <- map["discountValue"]
        discountedPrice <- map["discountedPrice"]
        originalPrice <- map["originalPrice"]
        startTime <- map["startTime"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        endTime <- map["endTime"]
        actualPrice <- map["actualPrice"]
        paxPerVoucher <- map["paxPerVoucher"]
        features <- (map["features"],ListTransform<CommonSettingsModel>())
        createdAt <- map["createdAt"]
        venueModel <- map["venue"]
        vouchars <- (map["vouchers"],ListTransform<VoucharsModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    public var _startDate: String {
        return Utils.stringToDate(startDate, format: kFormatDate)?.display ?? ""
    }
    
    public var _endtDate: String {
        return Utils.stringToDate(endDate, format: kFormatDate)?.display ?? ""
    }
    
    public var _timeSlot: String {
        return Utils.formatTimeRange(start: startTime, end: endTime) ?? kEmptyString
    }

    public var _isExpired: Bool {
        let isExpired = Utils.isDateExpired(dateString: "\(endDate) \(endTime)", format: "yyyy-MM-dd HH:mm")
        if isExpired {
            return true
        } else {
            let daysArray = _days.split(separator: ",")
            let arrayOfStrings: [String] = daysArray.map { String($0) }
            return Utils.isExpiredDate(start: startDate, end: endDate, daysArray: arrayOfStrings)
        }
    }
    
    public var isZeroPrice: Bool {
        return actualPrice == 0
    }

    public var _isNoDiscount: Bool {
        return actualPrice == 0 || actualPrice == discountedPrice
    }

    func isValid() -> Bool {
        return true
    }
}

class VoucharsModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var discountValue: String = kEmptyString
    @objc dynamic var discountedPrice: Int = 0
    @objc dynamic var originalPrice: Int = 0
    @objc dynamic var startDate: String = kEmptyString
    @objc dynamic var endDate: Date?
    @objc dynamic var status: Bool = false
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
        title <- map["title"]
        descriptions <- map["description"]
        discountValue <- map["discountValue"]
        discountedPrice <- map["discountedPrice"]
        originalPrice <- map["originalPrice"]
        startDate <- map["startDate"]
        endDate <- (map["endDate"],DateFormatterTransform(dateFormatter: _dateFormatter))
        status <- map["status"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
