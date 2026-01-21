import Foundation
import ObjectMapper
import RealmSwift

class OffersModel: Object, Mappable, ModelProtocol, Identifiable {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var categoryId: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var offerImage: String = kEmptyString
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
    @objc dynamic var venue: VenueDetailModel?
    dynamic var venuesModel = List<VenueDetailModel>()
    @objc dynamic var venueId: String = kEmptyString
    dynamic var packages = List<PackageModel>()
    @objc dynamic var packageModel: PackageModel?
    @objc dynamic var allowWhosIn: Bool = false
    @objc dynamic var color: ColorModel?
    @objc dynamic var isRecommendation: Bool = false
    @objc dynamic var disclaimerDescription: String = kEmptyString
    @objc dynamic var disclaimerTitle: String = kEmptyString
    @objc dynamic var specialOffer: SpecialOffersModel?
    var width: Int = 0
    var height: Int = 0
    @objc dynamic var dimension: String = "" {
        didSet {
            let sizeArray = dimension.components(separatedBy: "x")
            if sizeArray.count == 2, let w = Int(sizeArray[0]), let h = Int(sizeArray[1]) {
                width = w
                height = h
            }
        }
    }
    @objc dynamic var discountTag: String = kEmptyString
    
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
        categoryId <- map["categoryId"]
        title <- map["title"]
        descriptions <- map["description"]
        offerImage <- map["image"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        _days <- map["days"]
        packages <- (map["packages"], ListTransform<PackageModel>())
        packageModel <- map["package"]
        dimension <- map["dimension"]
        allowWhosIn <- map["allowWhosIn"]
        venue <- map["venue"]
        venuesModel <- (map["venue"], ListTransform<VenueDetailModel>())
        venueId <- map["venueId"]
        color <- map["color"]
        isRecommendation <- map["isRecommendation"]
        disclaimerDescription <- map["disclaimerDescription"]
        disclaimerTitle <- map["disclaimerTitle"]
        specialOffer <- map["specialOffer"]
        discountTag <- map["discountTag"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    var startDate: Date? {
        return Utils.stringToDate(startTime, format: kStanderdDate)
    }

    var endDate: Date? {
        return Utils.stringToDate(endTime, format: kStanderdDate)
    }
    
    var timeSloat: String {
        "\(Utils.dateToString(startDate, format: kFormatDateTimeUS)) - \(Utils.dateToString(endDate, format: kFormatDateTimeUS))"
    }
    
    public var _isExpired: Bool {
        if endTime.isEmpty {
            return false
        }
        let isExpired = Utils.isDateExpired(dateString: endTime, format: kStanderdDate)
        if isExpired {
            return true
        } else {
            let daysArray = _days.split(separator: ",")
            let arrayOfStrings: [String] = daysArray.map { String($0) }
            return Utils.isExpiredDate(start: startTime, end: endTime, daysArray: arrayOfStrings, formater: kStanderdDate)
        }
    }
    

    public func getEventTime(venueModel: VenueDetailModel?) -> String {
        let eventTimes = evnetTimeSlotForNoDate(venueModel: venueModel)
        let today = Utils.currentShourtDayOnly()
        if let todayDay = eventTimes.first(where: {$0.day == today}) {
            return Utils.convertNoDateOfferTime(todayDay.openingTime, todayDay.closingTime)
        }
        return Utils.convertNoDateOfferTime(eventTimes.first?.openingTime ?? kEmptyString, eventTimes.first?.closingTime ?? kEmptyString)
    }

    public func evnetTimeSlotForNoDate(venueModel: VenueDetailModel?) -> [TimingModel] {
        let daysArray = _days.split(separator: ",")
        let daysArrayString: [String] = daysArray.map { String($0) }
        let venueTimes = venueModel?.timing.toArrayDetached(ofType: TimingModel.self)
        if let eventTimes = venueTimes?.filter({ daysArrayString.contains($0.day) }) {
            return eventTimes
        }
        return []
    }

    public func getEventTime(timingModel: [TimingModel]?) -> String {
        let eventTimes = evnetTimeSlotForNoDate(timingModel: timingModel)
        let today = Utils.currentShourtDayOnly()
        if let todayDay = eventTimes.first(where: {$0.day == today}) {
            return Utils.convertNoDateOfferTime(todayDay.openingTime, todayDay.closingTime)
        }
        return Utils.convertNoDateOfferTime(eventTimes.first?.openingTime ?? kEmptyString, eventTimes.first?.closingTime ?? kEmptyString)
    }

    public func evnetTimeSlotForNoDate(timingModel: [TimingModel]?) -> [TimingModel] {
        let daysArray = _days.split(separator: ",")
        let daysArrayString: [String] = daysArray.map { String($0) }
        let venueTimes = timingModel
        if let eventTimes = venueTimes?.filter({ daysArrayString.contains($0.day) }) {
            return eventTimes
        }
        return []
    }

    public var _venue: VenueDetailModel {
        return venuesModel.first ?? VenueDetailModel()
    }
    
    public var isPackagewithzeroPrice: Bool {
        return packages.count == 1 ? packages.contains { $0.actualPrice == 0 && $0._flootdiscountedPrice == 0 } : false
    }
    
    
    
    public var isHideBuyButton: Bool {
        return packages.allSatisfy({ $0.isAllowSale == false }) ? true : packages.allSatisfy({ $0.remainingQty <= 0 })
    }

    public var isAllowedClaim: Bool {
        return packages.allSatisfy({ $0.isAllowClaim == false })
    }
    
    public var isShowClaim: Bool {
        return specialOffer != nil
    }
    
    public var image: String {
        return Utils.addResolutionToURL(urlString: offerImage, resolution: "300")
    }

    func isValid() -> Bool {
        return true
    }

    func isContaionToday(day: String) -> Bool {
        let daysArray = _days.split(separator: ",")
        let daysArrayString: [String] = daysArray.map { String($0) }
        return daysArrayString.contains(day)
    }

    public var isPassEndtimeForClaim: Bool {
        if endTime.isEmpty {
            return false
        }
        return Utils.isDateExpiredClaimTime(dateString: endTime, format: kStanderdDate)
    }
}

