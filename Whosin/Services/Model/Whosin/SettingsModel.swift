import Foundation
import ObjectMapper
import DialCountries
import RealmSwift

class SettingsModel:  Mappable, ModelProtocol {

    var gender: [String] = []
    var countries: [String] = []
    var pages: [MembershipPackageModel] = []
    var privacy: String = kEmptyString
    var terms: String = kEmptyString
    var cuisine: [CommonSettingsModel] = []
    var cuisines: [CommonSettingsModel] = []
    var music: [CommonSettingsModel] = []
    var feature: [CommonSettingsModel] = []
    var features: [CommonSettingsModel] = []
    var themes: [CommonSettingsModel] = []
    var membershipPackage: [MembershipPackageModel] = []
    var loginRequests: [LoginApprovalModel] = []
    var categories: [CommonSettingsModel] = []
    var currencies: [CurrenciesModel] = []
    var languages: [LanguagesModel] = []
    var allowTabbyPayments: Bool = false
    var allowStripePayments: Bool = false
    var allowNgeniusPayments: Bool = false
    var forceUpdate: Bool = false
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        gender <- map["gender"]
        countries <- map["countries"]
        pages <- map["pages"]
        cuisine <- map["cuisine"]
        cuisines <- map["cuisines"]
        music <- map["music"]
        feature <- map["feature"]
        features <- map["features"]
        membershipPackage <- map["membershipPackage"]
        privacy <- map["privacy_policy"]
        terms <- map["terms_conditions"]
        themes <- map["themes"]
        loginRequests <- map["loginRequests"]
        categories <- map["categories"]
        allowTabbyPayments <- map["allowTabbyPayments"]
        allowStripePayments <- map["allowStripePayments"]
        allowNgeniusPayments <- map["allowNgeniusPayments"]
        forceUpdate <- map["forceUpdate"]
        languages <- map["languages"]
        currencies <- map["currencies"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}


class CommonSettingsModel: Object, Mappable, ModelProtocol, Identifiable {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var icon: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var feature: String = kEmptyString
    @objc dynamic var emoji: String = kEmptyString
    @objc dynamic var price: Int = 0
    @objc dynamic var endPrice: Int = 0
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        title <- map["title"]
        icon <- map["icon"]
        feature <- map["feature"]
        image <- map["image"]
        type <- map["type"]
        price <- map["price"]
        emoji <- map["emoji"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

class MembershipPackageModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var membershipPackageId: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var subTitle: String = kEmptyString
    @objc dynamic var packageKey: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var time: String = kEmptyString
    @objc dynamic var discountText: String = kEmptyString
    @objc dynamic var actualPrice: Int = 0
    @objc dynamic var discount: Int = 0
    @objc dynamic var amount: Int = 0
    @objc dynamic var discountedPrice: String = kEmptyString
    dynamic var feature = List<CommonSettingsModel>()// = kEmptyString
    @objc dynamic var backgroundImage: String = kEmptyString
    @objc dynamic var productId: String = kEmptyString
    @objc dynamic var paymentLink: String = kEmptyString
    @objc dynamic var priceId: String = kEmptyString
    @objc dynamic var status: Bool = false
    @objc dynamic var isPopular: Bool = false
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var discountType: String = kEmptyString
    @objc dynamic var termsAndCondition: String = kEmptyString
    @objc dynamic var additionalValidity: Int = 0
    @objc dynamic var currency: String = kEmptyString
    @objc dynamic var validTill: String = "lifetime"
    @objc dynamic var orderStatus: String = kEmptyString
    @objc dynamic var membershipStatus: String = kEmptyString
    @objc dynamic var paymentStatus: String = kEmptyString
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        "id"
    }

    func mapping(map: Map) {
        id <- map["_id"]
        membershipPackageId <- map["membershipPackageId"]
        userId <- map["userId"]
        title <- map["title"]
        packageKey <- map["package_key"]
        subTitle <- map["subTitle"]
        image <- map["image"]
        time <- map["time"]
        discountText <- map["discountText"]
        actualPrice <- map["actualPrice"]
        discountedPrice <- map["discountedPrice"]
        discount <- map["discount"]
        amount <- map["amount"]
        feature <- (map["features"], ListTransform<CommonSettingsModel>())
        backgroundImage <- map["backgroundImage"]
        productId <- map["productId"]
        paymentLink <- map["paymentLink"]
        priceId <- map["priceId"]
        status <- map["status"]
        isPopular <- map["isPopular"]
        descriptions <- map["description"]
        discountType <- map["discountType"]
        termsAndCondition <- map["termsAndCondition"]
        additionalValidity <- map["additionalValidity"]
        currency <- map["currency"]
        validTill <- map["validTill"]
        orderStatus <- map["orderStatus"]
        membershipStatus <- map["membershipStatus"]
        paymentStatus <- map["paymentStatus"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

class PromoCodeModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var promoCodeInfo: PromoCodeInfoModel?
    @objc dynamic var discountAmount: Int = 0
    @objc dynamic var finalAmount: Int = 0
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        "id"
    }

    func mapping(map: Map) {
        id <- map["_id"]
        promoCodeInfo <- map["promoCodeInfo"]
        discountAmount <- map["discountAmount"]
        finalAmount <- map["finalAmount"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

class PromoCodeInfoModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    dynamic var dealIds = List<String>()
    dynamic var activityIds = List<String>()
    dynamic var offerPackageIds = List<String>()
    dynamic var discountIds = List<String>()
    dynamic var membershipPackageIds = List<String>()
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var bannerImage: String = kEmptyString
    @objc dynamic var promoCode: String = kEmptyString
    @objc dynamic var discountPercentage: Int = 0
    @objc dynamic var minimumPurchaseAmount: Int = 0
    @objc dynamic var maximumDiscountAmount: Int = 0
    dynamic var targetTypes = List<String>()
    @objc dynamic var usageLimitation: Int = 0
    @objc dynamic var startDate: String = kEmptyString
    @objc dynamic var endDate: String = kEmptyString
    @objc dynamic var isActive: Bool = false

    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        "id"
    }

    func mapping(map: Map) {
        id <- map["_id"]
        dealIds <- (map["dealIds"], StringListTransform())
        activityIds <- (map["activityIds"], StringListTransform())
        offerPackageIds <- (map["offerPackageIds"], StringListTransform())
        discountIds <- (map["discountIds"], StringListTransform())
        membershipPackageIds <- (map["membershipPackageIds"], StringListTransform())
        title <- map["title"]
        descriptions <- map["description"]
        bannerImage <- map["bannerImage"]
        promoCode <- map["promoCode"]
        discountPercentage <- map["discountPercentage"]
        minimumPurchaseAmount <- map["minimumPurchaseAmount"]
        maximumDiscountAmount <- map["maximumDiscountAmount"]
        targetTypes <- (map["targetTypes"], StringListTransform())
        usageLimitation <- map["usageLimitation"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        isActive <- map["isActive"]

    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public var discountPercent: String {
        if "\(discountPercentage)".hasSuffix("%") {
            return "\(discountPercentage)"
        } else {
            return "\(discountPercentage)%"
        }

    }


    func isValid() -> Bool {
        return true
    }
}

class PromoBaseModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var totalAmount: Double = 0
    @objc dynamic var totalDiscount: Double = 0
    @objc dynamic var promoDiscount: Double = 0
    @objc dynamic var itemsDiscount: Double = 0
    @objc dynamic var amount: String = kEmptyString
    @objc dynamic var promoDiscountType: String = kEmptyString
    dynamic var metadata = List<PromoCodeApplyModel>()

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        totalAmount <- map["totalAmount"]
        totalDiscount <- map["totalDiscount"]
        promoDiscount <- map["promoDiscount"]
        itemsDiscount <- map["itemsDiscount"]
        promoDiscountType <- map["promoDiscountType"]
        amount <- map["amount"]
        metadata <- (map["metadata"], ListTransform<PromoCodeApplyModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }


}

class PromoCodeApplyModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var dealId: String = kEmptyString
    @objc dynamic var packageId: String = kEmptyString
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var finalAmount: Double = 0.0
    @objc dynamic var discount: Double = 0.0
    @objc dynamic var promoType: String = kEmptyString
    @objc dynamic var ticketId: String = kEmptyString
    @objc dynamic var finalDiscount: Int = 0
    @objc dynamic var qty: Int = 0
    @objc dynamic var isEligible: Bool = false
    @objc dynamic var finalDiscountInPercent: Double = 0.0
    @objc dynamic var promoDiscountInPercent: Double = 0.0
    

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        _id <- map["_id"]
        type <- map["type"]
        qty <- map["qty"]
        amount <- map["amount"]
        ticketId <- map["ticketId"]
        discount <- map["discount"]
        isEligible <- map["isEligible"]
        promoDiscountInPercent <- map["promoDiscountInPercent"]
        promoType <- map["promoType"]
        finalDiscount <- map["finalDiscount"]
        finalAmount <- map["finalAmount"]
        finalDiscountInPercent <- map["finalDiscountInPercent"]
        dealId <- map["dealId"]
        packageId <- map["packageId"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

class CurrenciesModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var currency: String = kEmptyString
    @objc dynamic var rate: Double = 0
    @objc dynamic var symbol: String = kEmptyString
    @objc dynamic var flag: String = ""
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        "id"
    }

    func mapping(map: Map) {
        id <- map["_id"]
        currency <- map["currency"]
        rate <- map["rate"]
        symbol <- map["symbol"]
        flag <- map["flag"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

class LanguagesModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var code: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var native_name: String = kEmptyString
    @objc dynamic var flag: String = kEmptyString
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    

    func mapping(map: Map) {
        code <- map["code"]
        name <- map["name"]
        native_name <- map["native_name"]
        flag <- map["flag"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

