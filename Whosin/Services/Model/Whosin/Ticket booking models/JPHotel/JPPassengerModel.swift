import UIKit
import Foundation
import ObjectMapper
import RealmSwift

class JPPassengerModel: Object, Mappable, ModelProtocol {
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var serviceType: String = "Hotel"
    @objc dynamic var prefix: String = kEmptyString
    @objc dynamic var firstName: String = kEmptyString
    @objc dynamic var lastName: String = kEmptyString
    @objc dynamic var age: String = kEmptyString {
        didSet { updatePaxType() }
    }
    @objc dynamic var email: String = kEmptyString
    @objc dynamic var mobile: String = kEmptyString
    @objc dynamic var nationality: String = kEmptyString
    @objc dynamic var countryCode: String = kEmptyString
    @objc dynamic var leadPassenger: Int = 0
    @objc dynamic var paxType: String = kEmptyString

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        id            <- map["id"]
        serviceType   <- map["serviceType"]
        prefix        <- map["prefix"]
        firstName     <- map["firstName"]
        lastName      <- map["lastName"]
        age           <- map["age"]
        email         <- map["email"]
        mobile        <- map["mobile"]
        nationality   <- map["nationality"]
        countryCode   <- map["countryCode"]
        leadPassenger <- map["leadPassenger"]
        paxType       <- map["paxType"]
        updatePaxType()
    }

    private func updatePaxType() {
        guard paxType.isEmpty else { return }

        if let intAge = Int(age), intAge < 18 {
            paxType = "child"
        } else {
            paxType = "adult"
        }
    }

    func isValid() -> Bool { return true }
}


// MARK: - Rel Paxes Dist
class JPRelPaxesDistModel: Object, Mappable, ModelProtocol {
    var relPaxes = List<JPRelPaxModel>()

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        relPaxes <- (map["relPaxes"], ListTransform<JPRelPaxModel>())
    }

    func isValid() -> Bool { return true }
}

class JPRelPaxModel: Object, Mappable, ModelProtocol {
    @objc dynamic var id: String = kEmptyString

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        id <- map["id"]
    }

    func isValid() -> Bool { return true }
}
