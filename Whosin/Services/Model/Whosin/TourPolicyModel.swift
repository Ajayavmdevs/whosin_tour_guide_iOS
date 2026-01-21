import Foundation
import RealmSwift
import ObjectMapper

import ObjectMapper
import RealmSwift

class TourPolicyModel: Object, Mappable, ModelProtocol {

    @objc dynamic var tourId: Int = 0
    @objc dynamic var tourIdString: String = kEmptyString
    @objc dynamic var ticketId: String = kEmptyString
    @objc dynamic var optionId: String = kEmptyString
    @objc dynamic var fromDate: String = kEmptyString
    @objc dynamic var toDate: String = kEmptyString
    @objc dynamic var percentage: Int = 0
    @objc dynamic var hours: Int = 0
    @objc dynamic var percents: Int = 0

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        if map.mappingType == .fromJSON {
            var rawTourId: Any?
            rawTourId <- map["tourId"]
            if let idInt = rawTourId as? Int {
                tourId = idInt
                tourIdString = ""
            } else if let idStr = rawTourId as? String {
                tourIdString = idStr
                tourId = Int(idStr) ?? 0
            }
        } else {
            if !tourIdString.isEmpty {
                tourIdString <- map["tourId"]
            } else {
                tourId <- map["tourId"]
            }
        }
        ticketId   <- map["ticketId"]
        optionId   <- (map["optionId"], StringTransform())
        fromDate   <- map["fromDate"]
        toDate     <- map["toDate"]
        percentage <- map["percentage"]
        hours      <- map["hours"]
        percents   <- map["percents"]
    }

    func isValid() -> Bool {
        return true
    }

    public var refundPercentage: Int {
        return 100 - percentage
    }

    var optionIdIntValue: Int? {
        return Int(optionId)
    }
}


class availibityWhosinTicket: Object, Mappable, ModelProtocol {

    @objc dynamic var available: Bool = false

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        available     <- map["available"]
    }

    func isValid() -> Bool {
        return true
    }

}
