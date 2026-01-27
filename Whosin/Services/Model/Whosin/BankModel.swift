import Foundation
import RealmSwift
import ObjectMapper

class BankModel: Object, Mappable, ModelProtocol {

    @objc dynamic var bankDetails: BankDetailsModel?
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var holderName: String = kEmptyString
    @objc dynamic var holderType: String = kEmptyString
    @objc dynamic var country: String = kEmptyString
    @objc dynamic var currency: String = kEmptyString

    // MARK: - Mappable
    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        _id <- map["_id"]
        bankDetails <- map["bankDetails"]
        userId <- map["userId"]
        holderName <- map["holderName"]
        holderType <- map["holderType"]
        country <- map["country"]
        currency <- map["currency"]
    }
    
    // MARK: - ModelProtocol
    func isValid() -> Bool {
        return true
    }
}

class BankDetailsModel: Object, Mappable, ModelProtocol {

    @objc dynamic var bankName: String = kEmptyString
    @objc dynamic var accountNumber: String = kEmptyString
    @objc dynamic var iban: String = kEmptyString
    @objc dynamic var ifsc: String = kEmptyString
    @objc dynamic var routingNumber: String = kEmptyString
    @objc dynamic var sortCode: String = kEmptyString
    @objc dynamic var swiftCode: String = kEmptyString
    @objc dynamic var bsb: String = kEmptyString

    // MARK: - Mappable
    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        bankName <- map["bankName"]
        accountNumber <- map["accountNumber"]
        iban <- map["iban"]
        ifsc <- map["ifsc"]
        routingNumber <- map["routingNumber"]
        sortCode <- map["sortCode"]
        swiftCode <- map["swiftCode"]
        bsb <- map["bsb"]
    }
    
    // MARK: - ModelProtocol
    func isValid() -> Bool {
        return true
    }
}
