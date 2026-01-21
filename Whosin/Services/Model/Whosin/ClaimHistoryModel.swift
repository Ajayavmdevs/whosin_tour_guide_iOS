import Foundation
import ObjectMapper
import RealmSwift
import StripePayments

class ClaimHistoryModel:Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var specialOfferId: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var claimCode: String = kEmptyString
    @objc dynamic var totalPerson: Int = 0
    dynamic var brunch = List<BrunchModel>()
    @objc dynamic var billAmount: Int = 0
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var venue: VenueDetailModel?
    @objc dynamic var specialOffer: SpecialOffersModel?
    @objc dynamic var amount: Int = 0
    @objc dynamic var claimId: String = kEmptyString
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var paymentStatus: String = kEmptyString

    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["_id"]
        userId <- map["userId"]
        venueId <- map["venueId"]
        specialOfferId <- map["specialOfferId"]
        type <- map["type"]
        claimCode <- map["claimCode"]
        totalPerson <- map["totalPerson"]
        brunch <- (map["brunch"], ListTransform<BrunchModel>())
        billAmount <- map["billAmount"]
        createdAt <- map["createdAt"]
        venue <- map["venue"]
        specialOffer <- map["specialOffer"]
        claimId <- map["claimId"]
        amount <- map["amount"]
        status <- map["status"]
        paymentStatus <- map["paymentStatus"]        
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    public var totalPaid: String {
        let totalAmount = brunch.reduce(0) { (result, item) in
            let qty = item.qty
            let pricePerBrunch = item.pricePerBrunch
            let itemTotal = qty * pricePerBrunch
            return result + itemTotal
        }
        return "D\(totalAmount)"
    }


    func isValid() -> Bool {
        return true
    }
    
}

class ClaimProcessModel: Mappable, ModelProtocol {
    
    @objc dynamic var response: ClaimHistoryModel? = nil
    dynamic var objToSend: PaymentCredentialModel? = nil
    dynamic var tabby: TabbyModel? = nil

    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        response <- map["response"]
        objToSend <- map["objToSend"]
        tabby <- map["tabby"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}

