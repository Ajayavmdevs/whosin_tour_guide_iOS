import Foundation
import ObjectMapper
import RealmSwift

class OctoAvailibilityModel: Object, Mappable {
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var localDateTimeStart: String = kEmptyString
    @objc dynamic var localDateTimeEnd: String = kEmptyString
    @objc dynamic var allDay: Bool = false
    @objc dynamic var available: Bool = false
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var vacancies: String = kEmptyString
    @objc dynamic var capacity: String = kEmptyString
    @objc dynamic var limitCapacity: String = kEmptyString
    @objc dynamic var totalCapacity: String = kEmptyString
    @objc dynamic var paxCount: Int = 0
    @objc dynamic var limitPaxCount: Int = 0
    @objc dynamic var totalPaxCount: Int = 0
    @objc dynamic var noShows: Int = 0
    @objc dynamic var totalNoShows: Int = 0
    @objc dynamic var maxUnits: Int = 0
    @objc dynamic var maxPaxCount: Int = 0
    @objc dynamic var utcCutoffAt: String = kEmptyString
    
    var openingHours = List<OpeningHoursModel>()
    
    @objc dynamic var meetingPoint: String = kEmptyString
    @objc dynamic var meetingPointCoordinates: String = kEmptyString
    @objc dynamic var meetingPointDirections: String = kEmptyString
    @objc dynamic var meetingPointLatitude: Double = 0.0
    @objc dynamic var meetingPointLongitude: Double = 0.0
    @objc dynamic var  meetingLocalDateTime: String = kEmptyString
    var unitPricing = List<PricingModel>()
    @objc dynamic var pricing: PricingModel?
    
    @objc dynamic var pickupAvailable: Bool = false
    @objc dynamic var pickupRequired: Bool = false
    var pickupPoints = List<String>()

    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id <- map["id"]
        localDateTimeStart <- map["localDateTimeStart"]
        localDateTimeEnd <- map["localDateTimeEnd"]
        allDay <- map["allDay"]
        available <- map["available"]
        status <- map["status"]
        vacancies <- map["vacancies"]
        capacity <- map["capacity"]
        limitCapacity <- map["limitCapacity"]
        totalCapacity <- map["totalCapacity"]
        paxCount <- map["paxCount"]
        limitPaxCount <- map["limitPaxCount"]
        totalPaxCount <- map["totalPaxCount"]
        noShows <- map["noShows"]
        totalNoShows <- map["totalNoShows"]
        maxUnits <- map["maxUnits"]
        maxPaxCount <- map["maxPaxCount"]
        utcCutoffAt <- map["utcCutoffAt"]
        openingHours <- (map["openingHours"], ListTransform<OpeningHoursModel>())
        meetingPointDirections <- map["meetingPointDirections"]
        unitPricing <- (map["unitPricing"], ListTransform<PricingModel>())
        pricing <- map["pricing"]
        pickupAvailable <- map["pickupAvailable"]
        pickupRequired <- map["pickupRequired"]
        pickupPoints <- (map["pickupPoints"], StringListTransform())
    }
    
    func isValid() -> Bool {
        return true
    }
}

class OpeningHoursModel: Object, Mappable {
    @objc dynamic var from: String = kEmptyString
    @objc dynamic var to:  String = kEmptyString
    @objc dynamic var frequency: Int = 0
    @objc dynamic var frequencyAmount: Int = 0
    @objc dynamic var frequencyUnit:  String = kEmptyString
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        from <- map["from"]
        to <- map["to"]
        frequency <- map["frequency"]
        frequencyAmount <- map["frequencyAmount"]
        frequencyUnit <- map["frequencyUnit"]
    }
    
    func isValid() -> Bool {
        return true
    }
}
