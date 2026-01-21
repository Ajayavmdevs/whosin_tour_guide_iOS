import Foundation
import ObjectMapper
import RealmSwift

class PackageModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var packageKey: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var subTitle: String = kEmptyString
    @objc dynamic var discountedPrice: String = kEmptyString
    @objc dynamic var discount: String = kEmptyString
    @objc dynamic var packageData: PackageDataModel?
    @objc dynamic var discountValue: String = kEmptyString
    @objc dynamic var actualPrice: Int = 0
    @objc dynamic var offerId: String = kEmptyString
    @objc dynamic var eventId: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var discounts: Int = 0
    @objc dynamic var amount: Int = 0
    @objc dynamic var qty: Int = 0
    @objc dynamic var remainingQty: Int = 0 {
        didSet {
            if remainingQty < 0 {
                remainingQty = 0
            }
        }
    }
    @objc dynamic var pricePerBrunch: Int = 0
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var isAllowSale: Bool = true
    @objc dynamic var isAllowClaim: Bool = true
    @objc dynamic var leftQtyAlert: Int = 0
    @objc dynamic var isFeatured: Bool = false
    
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
        packageKey <- map["package_key"]
        title <- map["title"]
        subTitle <- map["subTitle"]
        discountedPrice <- map["discountedPrice"]
        discount <- map["discount"]
        packageData <- map["packageData"]
        discountValue <- map["discountValue"]
        actualPrice <- map["actualPrice"]
        actualPrice <- map["amount"]
        eventId <- map["eventId"]
        offerId <- map["offerId"]
        descriptions <- map["description"]
        amount <- map["amount"]
        qty <- map["qty"]
        remainingQty <- map["remainingQty"]
        discounts <- map["discount"]
        pricePerBrunch <- map["pricePerBrunch"]
        createdAt <- map["createdAt"]
        isAllowSale <- map["isAllowSale"]
        isAllowClaim <- map["isAllowClaim"]
        leftQtyAlert <- map["leftQtyAlert"]
        isFeatured <- map["isfeatured"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
//    public var _discountedPrice: Int {
//        if !Utils.stringIsNullOrEmpty(discount) {
//            return Utils.calculateDiscountValueInt(originalPrice: actualPrice, discountPercentage: Int(discount))
//        } else {
//            return Utils.calculateDiscountValueInt(originalPrice: actualPrice, discountPercentage: discounts)
//        }
//    }

    public var _flootdiscountedPrice: Float {
        if !Utils.stringIsNullOrEmpty(discount) {
            return Utils.calculateDiscountValueFloat(originalPrice: actualPrice, discountPercentage: Int(discount))
        } else {
            return Utils.calculateDiscountValueFloat(originalPrice: actualPrice, discountPercentage: discounts)
        }
    }

    public var _discount: String {
        if discount.hasSuffix("%") {
            return "\(discount)"
        } else {
            return "\(discount)%"
        }

    }
    
    public var _discounts: String {
        let discount = "\(discounts)"
        if discount.hasSuffix("%") {
            return "\(discount)"
        } else {
            return "\(discount)%"
        }
    }
    
    public var _isNoDiscount: Bool {
        return actualPrice == 0 || Float(actualPrice) == _flootdiscountedPrice
    }

    public var _createdAt: Date {
        return Utils.stringToDate(createdAt, format: kStanderdDate) ?? Date()
    }

    func isValid() -> Bool {
        return true
    }

    public var isShowLeftQtyAlert: Bool {
        if remainingQty == 0 {
            return false
        }
        return remainingQty <= leftQtyAlert
    }
}

class PackageDataModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var subTitle: String = kEmptyString
    @objc dynamic var time: String = kEmptyString
    @objc dynamic var discountText: String = kEmptyString
    @objc dynamic var actualPrice: String = kEmptyString
    @objc dynamic var feature: String = kEmptyString
    @objc dynamic var backgroundImage: String = kEmptyString
    @objc dynamic var discountedPrice: String = kEmptyString
    @objc dynamic var discount: String = kEmptyString
    @objc dynamic var packageKey: String = kEmptyString
    
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
        subTitle <- map["subTitle"]
        time <- map["time"]
        discountText <- map["discountText"]
        actualPrice <- map["actualPrice"]
        feature <- map["feature"]
        backgroundImage <- map["backgroundImage"]
        discountedPrice <- map["discountedPrice"]
        discount <- map["discount"]
        packageKey <- map["package_key"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
