import FirebaseAnalytics

let LOGMANAGER = LogManager.shared

enum LogEventType {
    case viewTicket
    case viewCart
    case removeCart
    case getTicket
    case addToCart
    case checkout
    case purchase
    case addToWishlist
    case paymentInitiated
    case addUserInfo
    case paymentFailed
    case paymentCancelled
}

class LogManager {
    
    class var shared: LogManager {
        struct Static {
            static let instance = LogManager()
        }
        return Static.instance
    }
    
    private var userId: String? {
        return APPSESSION.userDetail?.id ?? APPSESSION.userDetail?.userId ?? "Guest"
    }

    
    func logTicketEvent(_ type: LogEventType,id: String, name: String, price: Double? = nil, transactionId: String? = nil, currency: String = "AED") {
        Analytics.setUserID(userId)
        
        var parameters: [String: Any] = [
            AnalyticsParameterItemID: id,
            AnalyticsParameterItemName: name,
        ]
        
        if let userId {
            parameters["user_id"] = userId
        }
        
        if let price {
            parameters[AnalyticsParameterPrice] = price
            parameters[AnalyticsParameterValue] = price
            parameters[AnalyticsParameterCurrency] = currency
        }
        
        if let transactionId {
            parameters[AnalyticsParameterTransactionID] = transactionId
        }
        
        let eventName: String
        
        switch type {
        case .viewTicket:
            eventName = "view_ticket"
        case .getTicket:
            eventName = "get_ticket"
        case .addToCart:
            eventName = AnalyticsEventAddToCart
        case .viewCart:
            eventName = AnalyticsEventViewCart
        case .removeCart:
            eventName = AnalyticsEventRemoveFromCart
        case .checkout:
            eventName = AnalyticsEventBeginCheckout
        case .purchase:
            eventName = AnalyticsEventPurchase
        case .addToWishlist:
            eventName = AnalyticsEventAddToWishlist
        case .paymentInitiated:
            eventName = "payment_initiated"
        case .addUserInfo:
            eventName = "add_guest_detail"
        case .paymentFailed:
            eventName = "payment_failed"
        case .paymentCancelled:
            eventName = "payment_cancelled"
        }
        
        Analytics.logEvent(eventName, parameters: parameters)
    }
}
