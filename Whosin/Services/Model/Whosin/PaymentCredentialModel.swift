import Foundation
import ObjectMapper
import RealmSwift
import NISdk

class PaymentCredentialModel: Mappable, ModelProtocol {

    // Stripe / Tabby
    @objc dynamic var clientSecret: String = ""
    @objc dynamic var secretKey: String = ""
    @objc dynamic var publishableKey: String = ""
    dynamic var tabby: TabbyModel?

    // Generic Payment Info
    @objc dynamic var type: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var action: String = ""
    @objc dynamic var language: String = ""
    @objc dynamic var emailAddress: String = ""
    @objc dynamic var reference: String = ""
    @objc dynamic var outletId: String = ""
    @objc dynamic var createDateTime: String = ""
    @objc dynamic var referrer: String = ""
    @objc dynamic var merchantOrderReference: String = ""
    @objc dynamic var formattedAmount: String = ""
    @objc dynamic var isSaudiPaymentEnabled: Bool = false
    dynamic var amount: NIAmount?
    dynamic var merchantAttributes: NIMerchantAttributes?
    dynamic var billingAddress: BillingAddress?
    dynamic var paymentMethods: PaymentMethods?
    dynamic var orderSummary: OrderSummary?
    dynamic var formattedOrderSummary: FormattedOrderSummary?
    dynamic var links: NIPaymentLinks?
    dynamic var embedded: NIEmbedded?
    dynamic var savedCard: SavedCard?
    

    // --------------------------------------
    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        amount <- map["amount"]
        clientSecret <- map["client_secret"]
        secretKey <- map["secret_key"]
        publishableKey <- map["publishable_key"]
        tabby <- map["tabby"]
        type <- map["type"]
        id <- map["_id"]
        action <- map["action"]
        language <- map["language"]
        emailAddress <- map["emailAddress"]
        reference <- map["reference"]
        outletId <- map["outletId"]
        createDateTime <- map["createDateTime"]
        referrer <- map["referrer"]
        merchantOrderReference <- map["merchantOrderReference"]
        formattedAmount <- map["formattedAmount"]
        orderSummary <- map["orderSummary"]
        formattedOrderSummary <- map["formattedOrderSummary"]
        isSaudiPaymentEnabled <- map["isSaudiPaymentEnabled"]

        merchantAttributes <- map["merchantAttributes"]
        billingAddress <- map["billingAddress"]
        paymentMethods <- map["paymentMethods"]
        savedCard <- map["savedCard"]
        links <- map["_links"]
        embedded <- map["_embedded"]


    }

    func isValid() -> Bool { return true }
}


class TabbyModel : Mappable, ModelProtocol {

    @objc dynamic var id:String = kEmptyString
    @objc dynamic var webUrl:String = kEmptyString

    

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        webUrl <- map["web_url"]
        
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

class NIMerchantAttributes: Mappable {

    var selectedId: String = ""
    var webhookUrl: String = ""
    var customerNote: String = ""

    required init?(map: Map) {}
    func mapping(map: Map) {
        selectedId <- map["selectedId"]
        webhookUrl <- map["webhookUrl"]
        customerNote <- map["customerNote"]
    }
}

class NIPaymentLinks: Mappable {

    var cancel: NIHref?
    var paymentLink: NIHref?
    var paymentAuthorization: NIHref?
    var selfKey: NIHref?
    var payment: NIHref?
    var merchantBrand: NIHref?
    var tenantBrand: NIHref?

    required init?(map: Map) {}
    func mapping(map: Map) {
        cancel <- map["cancel"]
        paymentLink <- map["cnp:payment-link"]
        paymentAuthorization <- map["payment-authorization"]
        selfKey <- map["self"]
        payment <- map["payment"]
        merchantBrand <- map["merchant-brand"]
        tenantBrand <- map["tenant-brand"]
    }
}

class NIHref: Mappable {
    var href: String = ""

    required init?(map: Map) {}
    func mapping(map: Map) {
        href <- map["href"]
    }
}

class NIEmbedded: Mappable {

    var payment: [NIPaymentItem] = []

    required init?(map: Map) {}
    func mapping(map: Map) {
        payment <- map["payment"]
    }
}

class NIPaymentItem: Mappable {

    var id: String = ""
    var reference: String = ""
    var state: String = ""
    var amount: NIPaymentAmount?
    var updateDateTime: String = ""
    var outletId: String = ""
    var orderReference: String = ""
    var merchantOrderReference: String = ""
    var links: NIPaymentItemLinks?

    required init?(map: Map) {}
    func mapping(map: Map) {

        id <- map["_id"]
        reference <- map["reference"]
        state <- map["state"]
        amount <- map["amount"]
        updateDateTime <- map["updateDateTime"]
        outletId <- map["outletId"]
        orderReference <- map["orderReference"]
        merchantOrderReference <- map["merchantOrderReference"]
        links <- map["_links"]
    }
}

class NIPaymentAmount: Mappable {
    var currencyCode: String = ""
    var value: Int = 0

    required init?(map: Map) {}
    func mapping(map: Map) {
        currencyCode <- map["currencyCode"]
        value <- map["value"]
    }
}

class NIPaymentItemLinks: Mappable {

    var selfLink: NIHref?
    var card: NIHref?
    var samsungPay: NIHref?
    var applePay: NIHref?
    var webValidateApple: NIHref?

    required init?(map: Map) {}
    func mapping(map: Map) {
        selfLink <- map["self"]
        card <- map["payment:card"]
        samsungPay <- map["payment:samsung_pay"]
        applePay <- map["payment:apple_pay"]
        webValidateApple <- map["cnp:apple_pay_web_validate_session"]
    }
}

class NIAmount: Mappable {

    var currencyCode: String?
    var value: Double?

    required init?(map: Map) {}
    func mapping(map: Map) {
        currencyCode <- map["currencyCode"]
        value <- map["value"]
    }
}
