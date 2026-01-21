import Foundation
import RealmSwift
import ObjectMapper

class WhosinOptionModel: Object, Mappable, ModelProtocol {

    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var customTicketId: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var optionDescription: String = kEmptyString
    dynamic var images: List<String> = List<String>()
    dynamic var days: OperationDaysModel?
    @objc dynamic var startDate: Date?
    @objc dynamic var endDate: Date?
    @objc dynamic var availabilityType: String = kEmptyString
    @objc dynamic var availabilityTime: String = kEmptyString
    @objc dynamic var totalSeats: Int = 0
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var amountForChild: Double = 0.0
    @objc dynamic var amountForInfant: Double = 0.0
    @objc dynamic var createdAt: Date?
    @objc dynamic var updatedAt: Date?
    @objc dynamic var availableSeats: Int = 0
    dynamic var availabilityTimeSlot = List<TourTimeSlotModel>()

    @objc dynamic var adultAge: String = kEmptyString
    @objc dynamic var childAge: String = kEmptyString
    @objc dynamic var infantAge: String = kEmptyString
    @objc dynamic var disableChild: Bool = false
    @objc dynamic var disableInfant: Bool = false
    @objc dynamic var withoutDiscountAdultPrice: Double = 0.0
    @objc dynamic var withoutDiscountChildPrice: Double = 0.0
    @objc dynamic var withoutDiscountInfantPrice: Double = 0.0
    @objc dynamic var withoutDiscountAmount: Double = 0.0
    @objc dynamic var finalAmount: Double = 0.0
    @objc dynamic var cancellationPolicy: String = kEmptyString
    @objc dynamic var cutOff: Int = 0
    @objc dynamic var minimumPax: String = kEmptyString
    @objc dynamic var maximumPax: String = kEmptyString

    // MARK: - Date Formatter
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kStanderdDate)
    private let _fallbackFormatter = DATEFORMATTER.dateFormatterWith(format: kStanderdDate)

    override class func primaryKey() -> String? {
        return "_id"
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        _id <- map["_id"]
        customTicketId <- map["customTicketId"]
        title <- map["title"]
        optionDescription <- map["description"]
        images <- (map["images"], StringListTransform())
        days <- map["days"]
        
        var startDateString: String?
        var endDateString: String?
        var createdAtString: String?
        var updatedAtString: String?

        startDateString <- map["startDate"]
        endDateString <- map["endDate"]
        createdAtString <- map["createdAt"]
        updatedAtString <- map["updatedAt"]

        if let value = startDateString {
            startDate = _dateFormatter.date(from: value) ?? _fallbackFormatter.date(from: value)
        }

        if let value = endDateString {
            endDate = _dateFormatter.date(from: value) ?? _fallbackFormatter.date(from: value)
        }

        if let value = createdAtString {
            createdAt = _dateFormatter.date(from: value) ?? _fallbackFormatter.date(from: value)
        }

        if let value = updatedAtString {
            updatedAt = _dateFormatter.date(from: value) ?? _fallbackFormatter.date(from: value)
        }

        availabilityType <- map["availabilityType"]
        availabilityTime <- map["availabilityTime"]
        totalSeats <- map["totalSeats"]
        amount <- map["amount"]
        amountForChild <- map["amountForChild"]
        amountForInfant <- map["amountForInfant"]
        availableSeats <- map["availableSeats"]
        availabilityTimeSlot <- (map["availabilityTimeSlot"], ListTransform<TourTimeSlotModel>())

        adultAge <- map["adultAge"]
        childAge <- map["childAge"]
        infantAge <- map["infantAge"]
        disableChild <- map["disableChild"]
        disableInfant <- map["disableInfant"]
        withoutDiscountAdultPrice <- map["withoutDiscountAdultPrice"]
        withoutDiscountChildPrice <- map["withoutDiscountChildPrice"]
        withoutDiscountInfantPrice <- map["withoutDiscountInfantPrice"]
        withoutDiscountAmount <- map["withoutDiscountAmount"]
        finalAmount <- map["finalAmount"]
        cancellationPolicy <- map["cancellationPolicy"]
        cutOff <- map["cutOff"]
        minimumPax <- map["minimumPax"]
        maximumPax <- map["maximumPax"]
    }

    func isValid() -> Bool {
        return !_id.isEmpty
    }
}

class TimeAvailabilityModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var totalSeats: Int = 0
    @objc dynamic var availabilityTime: String = kEmptyString
    @objc dynamic var availableSeats: Int = 0

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["_id"]
        totalSeats <- map["totalSeats"]
        availabilityTime <- map["availabilityTime"]
        availableSeats <- map["availableSeats"]
    }
    
    func isValid() -> Bool {
        return true
    }
}
