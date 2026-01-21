import UIKit
import Foundation
import ObjectMapper
import RealmSwift

class JPCancellationPolicyModel: Object, Mappable, ModelProtocol {
    @objc dynamic var from: String = kEmptyString
    @objc dynamic var to: String = kEmptyString
    @objc dynamic var dateFrom: String = kEmptyString
    @objc dynamic var DateTo: String = kEmptyString
    @objc dynamic var dateFromHour: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var fixedPrice: String = kEmptyString
    @objc dynamic var percentPrice: String = kEmptyString
    @objc dynamic var nights: String = kEmptyString
    @objc dynamic var applicationTypeNights: String = kEmptyString

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        from                 <- map["From"]
        to                 <- map["To"]
        dateFrom             <- map["DateFrom"]
        DateTo             <- map["DateTo"]
        dateFromHour         <- map["DateFromHour"]
        type                 <- map["Type"]
        fixedPrice           <- map["FixedPrice"]
        percentPrice         <- map["PercentPrice"]
        nights               <- map["Nights"]
        applicationTypeNights <- map["ApplicationTypeNights"]
    }

    func isValid() -> Bool { return true }
}
