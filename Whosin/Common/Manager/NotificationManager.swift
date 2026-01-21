import Foundation
import ObjectMapper
//import FirebaseMessaging
import SwiftyJSON
import FAPanels

let NOTIFICATION = NotificationManager.shared

class NotificationManager: NSObject {
    
    private var _unreadCount: Int = 0
    private var _inCount: Int = 0
    private var _myEventCount: Int = 0
    
    // -------------------------------------
    // MARK: Singleton
    // --------------------------------------

    class var shared: NotificationManager {
        struct Static {
            static let instance = NotificationManager()
        }
        return Static.instance
    }

    override init() {
        super.init()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _getFcmToken(completion: @escaping (_ token: String) -> Void) {
//        Log.debug("PUSHNOTIFICATION >> CURRENT FCM_TOKEN=\(Messaging.messaging().fcmToken ?? kEmptyString)")
//        guard let fcmToken = Messaging.messaging().fcmToken else {
//            Messaging.messaging().token { (token, error) in
//                if let error = error {
//                    Log.error("PUSHNOTIFICATION >> Error fetching FCM_TOKEN error=\(error)")
//                    completion(kEmptyString)
//                } else {
//                    Log.debug("PUSHNOTIFICATION >> NEW FCM_TOKEN=\(token ?? kEmptyString)")
//                    completion(token ?? kEmptyString)
//                }
//            }
//            return
//        }
//        completion(fcmToken)
    }
    
    private func _requestNotificationBadge() {
    }
    
    private func _requestWhoIsInBadge() {
    }
    
    // --------------------------------------
    // MARK: Acccesors
    // --------------------------------------
    
    var isWhoIsInBadge: Bool {
        _inCount != .zero || _myEventCount != .zero
    }
    
    var unreadCount: Int { _unreadCount }
    
    var inCount: Int { _inCount }
    
    var myEventCount: Int { _myEventCount }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func configure() {
//        Messaging.messaging().delegate = self
    }
    
    func sync() {
        _requestNotificationBadge()
        _requestWhoIsInBadge()
//        _getFcmToken { token in WhosinServices.registerFCM(token: token) }
        
//        Messaging.messaging().subscribe(toTopic: "sendtoall") { error in
//            print("Notification error : ", error ?? "")
//        }
//
//        Messaging.messaging().subscribe(toTopic: "sendtoios") { error in
//            print("Notification error : ", error ?? "")
//        }
    }
    
    func refreshBadge(isNotifcation: Bool = true) {
        guard isNotifcation else {
            _requestWhoIsInBadge()
            return
        }
        _requestNotificationBadge()
    }
    
    func resetWhoIsInBadge(isMyEvent: Bool) {
        if isMyEvent { _myEventCount = .zero }
        else { _inCount = .zero }
        _ = isMyEvent ? "my_event" : "in_out"
        NotificationCenter.default.post(name: .updateWhoIsInBadge, object: nil)
    }
    
    func getUnreadCount() {
        WhosinServices.getUnreadCount { [weak self]container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            DispatchQueue.main.async {
                self._unreadCount = data.count
                NotificationCenter.default.post(name: Notification.Name("unReadCount"), object: nil, userInfo: nil)
            }
        }
    }
    
    func getChatId(_ userInfo: [AnyHashable : Any]) -> String {
        let data = JSON(userInfo)
        guard let dictionary = data.dictionaryObject else { return kEmptyString }
        if dictionary.keys.contains("msg") {
            guard let msgJsonString = dictionary["msg"] as? String else { return kEmptyString }
            guard let chatMessage = Mapper<MessageModel>().map(JSONString: msgJsonString)  else { return kEmptyString
            }
            ChatRepository().addMessageIfNotExist(messageData: chatMessage, callback: nil)
            return chatMessage.chatId
        }
        return kEmptyString
    }
    
    func handleFcmEvent(_ userInfo: [AnyHashable: Any]) {
        Preferences.chatNotificationData = [:]
        let data = JSON(userInfo)
        guard let dictionary = data.dictionaryObject else { return }
        print("🔔 Notification Dictionary: \(dictionary)")

        if let custom = dictionary["custom"] as? [String: Any],
           let a = custom["a"] as? [String: Any],
           let type = a["type"] as? String,
           let id = a["id"] as? String {

            print("🔍 Notification type: \(type), id: \(id)")
            if let msg = a["message"] as? [String: Any]  {
                self.openChatView(msg.toJSONString)
                return
            }

            switch type {
            case "bucket":
                openBucketDetails(id)

            case "outing":
                openOutingDetails(id)

            case "event":
                openEventDetails(id)

            case "activity":
                openActivityDetails(id)

            case "offer":
                openOfferDetails(id)

            case "category":
                openCategoryDetails(id)

            case "venue":
                openVenueDetails(id)

            case "follow":
                openUserDetails(id)

            case "invite":
                NotificationCenter.default.post(name: .reloadEventNotification, object: nil)
                openPromoterEventDetails(id, isCM: APPSESSION.userDetail?.isRingMember == true)

            case "promoter-event":
                openPromoterEventDetails(id, isCM: APPSESSION.userDetail?.isRingMember == true)

            case "invite_rejected":
                openPromoterEventDetails(id, isCM: APPSESSION.userDetail?.isRingMember == true)

            case "add-to-ring":
                openNotificationVC()

            case "join-my-ring":
                openPromoterDetails(id)

            case "add-to-plusone":
                openNotificationVC()

            case "plusone-accepted", "promoter-event-invite":
                openCurrentUserProfile()

            case "ticket":
                openTicketDetails(id)

            case "review-ticket":
                NotificationCenter.default.post(name: .openTicketReview, object: nil, userInfo: ["ticketId": id])
                
            case "cancel-booking":
                openWallet(1)
                
            case "ticket-booking":
                openWallet()
                
            default:
                break
            }
        }
    }

    
    func handleDynamicLinkEvent(_ link: URL) {
        Preferences.deepLink = kEmptyString
        let components = link.pathComponents
        let urlString = link.absoluteString
        if components.count >= 2 {
            let secondLastComponent = components[components.count - 2]
            if secondLastComponent == "v" {
                let venueId = components[components.count - 1]
                openVenueDetails(venueId)
            } else if secondLastComponent == "u" {
                let userId = components[components.count - 1]
                if APPSESSION.userId == userId {
                    openCurrentUserProfile()
                } else {
                    openUserDetails(userId)
                }
            } else if secondLastComponent == "o" {
                let offerId = components[components.count - 1]
                openOfferDetails(offerId)
            } else if secondLastComponent == "p" {
                let eventId = components[components.count - 1]
                if APPSESSION.userDetail?.isRingMember == true {
                    openPromoterEventDetails(eventId, isCM: true)
                } else if APPSESSION.userDetail?.isPromoter == true {
                    openPromoterEventDetails(eventId, isCM: false)
                }
            } else if urlString.contains("invoice") {
                _ = link.absoluteString
                guard let window = APP.window, APPSESSION.didLogin  else { return }
                if let navController = window.rootViewController as? UINavigationController,
                   let tabBarController = navController.viewControllers.first as? MainTabBarVC,
                   tabBarController.selectedIndex == 4 {
                    return
                }
                let controller = INIT_CONTROLLER_XIB(MainTabBarVC.self)
                controller.selectedIndex = 4
                let navController = NavigationController(rootViewController: controller)
                navController.setNavigationBarHidden(true, animated: false)
                window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
            } else if secondLastComponent == "t" {
                let ticketId = components[components.count - 1]
                openTicketDetails(ticketId)
            }
        }
    }
    
    func openInvoiceDetails(_ url: String) {
            let vc = INIT_CONTROLLER_XIB(ViewRaynaTicketVC.self)
            vc.modalPresentationStyle = .overFullScreen
        let model = TicketBookingModel()
            model.downloadTicket = url
            vc.ticketBooking = model
            vc.hidesBottomBarWhenPushed = true
            Utils.openViewController(vc)
        }
    
    func openVenueDetails(_ venueId: String) {
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        Log.debug(currentController.description)
        if let visibleVc = Utils.getVisibleViewController(from: currentController) {
            if let vc = visibleVc as? VenueDetailsVC {
                if vc.venueId == venueId {
                    return
                }
            }
        }
        let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        vc.venueId = venueId
        vc.venueDetailModel = Utils.getModelFromId(model: APPSETTING.venueModel, id: venueId)
        Utils.pushViewController(vc)
    }
    
    func openTicketDetails(_ ticketId: String) {
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        Log.debug(currentController.description)
        if let visibleVc = Utils.getVisibleViewController(from: currentController) {
            if let vc = visibleVc as? CustomTicketDetailVC {
                if vc.ticketID == ticketId {
                    return
                }
            }
        }
        let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
        vc.hidesBottomBarWhenPushed = true
        vc.ticketID = ticketId
        Utils.pushViewController(vc)
    }
    
    func openActivityDetails(_ activityId: String) {
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        Log.debug(currentController.description)
        let vc = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
        vc.activityId = activityId
        vc.modalPresentationStyle = .overFullScreen
        Utils.openViewController(vc)
    }
    
    func openEventDetails(_ eventId: String) {
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        Log.debug(currentController.description)
        let vc = INIT_CONTROLLER_XIB(EventDetailVC.self)
        vc.eventId = eventId
        Utils.pushViewController(vc)
    }
    
    func openOfferDetails(_ offerId: String) {
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        Log.debug(currentController.description)
        let controller = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
        controller.offerId = offerId
        controller.vanueOpenCallBack = { venueId, venueModel in
            let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            vc.venueId = venueId
            vc.venueDetailModel = venueModel
            Utils.getCurrentVC()?.navigationController?.pushViewController(vc, animated: true)
        }
        controller.buyNowOpenCallBack = { offer, venue, timing in
            let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
            vc.isFromActivity = false
            vc.type = "offers"
            vc.timingModel = timing
            vc.offerModel = offer
            vc.venue = venue
            vc.setCallback {
                let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
                controller.modalPresentationStyle = .overFullScreen
                Utils.getCurrentVC()?.navigationController?.pushViewController(controller, animated: true)
            }
            Utils.getCurrentVC()?.navigationController?.pushViewController(vc, animated: true)
        }
        Utils.getCurrentVC()?.presentAsPanModal(controller: controller)
    }
    
    func openOutingDetails(_ outingId: String) {
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        Log.debug(currentController.description)
        let vc = INIT_CONTROLLER_XIB(OutingDetailVC.self)
        vc.outingId = outingId
        vc.modalPresentationStyle = .overFullScreen
        Utils.openViewController(vc)
    }
    
    func openCategoryDetails(_ categoryId: String) {
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        Log.debug(currentController.description)
        let vc = INIT_CONTROLLER_XIB(CategoryDetailVC.self)
        vc.categoryId = categoryId
        vc.modalPresentationStyle = .overFullScreen
        Utils.openViewController(vc)
    }
    
    func openBucketDetails(_ bucketId: String) {
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        Log.debug(currentController.description)
        let vc = INIT_CONTROLLER_XIB(BucketDetailVC.self)
        vc.bucketId = bucketId
        vc.modalPresentationStyle = .overFullScreen
        Utils.openViewController(vc)
    }
    
    func openNotificationVC() {
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        if let visibleVc = Utils.getVisibleViewController(from: currentController) {
            if visibleVc is NotificationVC {
                    return
            }
        }
        Log.debug(currentController.description)
        let vc = INIT_CONTROLLER_XIB(NotificationVC.self)
        Utils.openViewController(vc)
    }

    func openUserDetails(_ userId: String) {
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        if let visibleVc = Utils.getVisibleViewController(from: currentController) {
            if let vc = visibleVc as? UsersProfileVC {
                if vc.contactId == userId {
                    return
                }
            }
        }
        Log.debug(currentController.description)
        let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
        vc.contactId = userId
        Utils.openViewController(vc)
    }
    
    func openCMDetails(_ userId: String) {
        if APPSESSION.userDetail?.isRingMember == true {
            guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
            if let visibleVc = Utils.getVisibleViewController(from: currentController) {
                if visibleVc is ComplementaryProfileVC {
                    return
                }
            }
            Log.debug(currentController.description)
            let vc = INIT_CONTROLLER_XIB(ComplementaryProfileVC.self)
            vc._selectedIndex = 3
            vc.hidesBottomBarWhenPushed = true
            Utils.openViewController(vc)
        } else {
            guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
            if let visibleVc = Utils.getVisibleViewController(from: currentController) {
                if visibleVc is PromoterApplicationVC {
                    return
                }
            }
            Log.debug(currentController.description)
            let vc = INIT_CONTROLLER_XIB(PromoterApplicationVC.self)
            vc.isComlementry = true
            vc.referredById = userId
            vc.hidesBottomBarWhenPushed = true
            Utils.openViewController(vc)
        }
    }
    
    func openPromoterDetails(_ userId: String) {
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        if let visibleVc = Utils.getVisibleViewController(from: currentController) {
            if visibleVc is PromoterProfileVC {
                    return
            }
        }
        Log.debug(currentController.description)
        let vc = INIT_CONTROLLER_XIB(PromoterProfileVC.self)
        vc._selectedIndex = 4
        vc.hidesBottomBarWhenPushed = true
        Utils.openViewController(vc)
    }
    
    func openPromoterEventDetails(_ eventId: String, isCM: Bool = false) {
        NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        if let visibleVc = Utils.getVisibleViewController(from: currentController) {
            if let vc = visibleVc as? PromoterEventDetailVC {
                if vc.id == eventId {
                    return
                }
            }
        }
        Log.debug(currentController.description)
        let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
        vc.id = eventId
        vc.isComplementary = isCM
        vc.hidesBottomBarWhenPushed = true
        vc.modalPresentationStyle = .overFullScreen
        Utils.pushViewController(vc)
    }
    
    func openCurrentUserProfile() {
//        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
//        if let visibleVc = Utils.getVisibleViewController(from: currentController) {
//            if visibleVc is ProfileVC {
//               return
//            }
//        }
//        let controller = NavigationController(rootViewController: INIT_CONTROLLER_XIB(CommanProfileVC.self))
//        controller.modalPresentationStyle = .fullScreen
//        Utils.presentViewController(controller)
        
        guard let window = APP.window, APPSESSION.didLogin  else { return }
        if let navController = window.rootViewController as? UINavigationController,
           let tabBarController = navController.viewControllers.first as? MainTabBarVC,
           tabBarController.selectedIndex == 2 {
            return
        }
        let controller = INIT_CONTROLLER_XIB(MainTabBarVC.self)
        controller.selectedIndex = 2
        let navController = NavigationController(rootViewController: controller)
        navController.setNavigationBarHidden(true, animated: false)
        window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))

    }
    
    func openWallet(_ index: Int = 0) {
        TabLaunchConfig.walletDefaultPageIndex = index
        guard let window = APP.window, APPSESSION.didLogin  else { return }
        if let navController = window.rootViewController as? UINavigationController,
           let tabBarController = navController.viewControllers.first as? MainTabBarVC,
           tabBarController.selectedIndex == 4 {
            return
        }
        let controller = INIT_CONTROLLER_XIB(MainTabBarVC.self)
        controller.selectedIndex = 4
        let navController = NavigationController(rootViewController: controller)
        navController.setNavigationBarHidden(true, animated: false)
        window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))

    }

    func openChatView(_ message: String) {
        
        guard let currentController = APP.window?.rootViewController, APPSESSION.didLogin else { return }
        
        guard let chatMessage = Mapper<MessageModel>().map(JSONString: message)  else {
            return
        }
        var openChatScreen = true
        if let visibleVc = Utils.getVisibleViewController(from: currentController) {
            if let vc = visibleVc as? ChatDetailVC {
                if(vc.chatModel?.chatId == chatMessage.chatId) {
                    openChatScreen = false
                }else {
                    if vc.isPresented {
                        vc.dismiss(animated: false)
                    } else {
                        vc.navigationController?.popViewController(animated: false)
                    }
                }
            }
        }
        
        let chatRepo = ChatRepository()
        chatRepo.addChatMessage(messageData: chatMessage) { _tmpChat in
            if openChatScreen {
                DISPATCH_ASYNC_MAIN {
                    guard let _tmpChat = _tmpChat else { return }
                    chatRepo.getChatModel(_tmpChat) { model, chatType in
                        let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
                        vc.modalPresentationStyle =  .overFullScreen
                        vc.hidesBottomBarWhenPushed = true
                        if model.title.isEmpty {
                            model.title = _tmpChat.authorName
                            model.image = _tmpChat.authorImage
                        }
                        if chatType.rawValue == ChatType.promoterEvent.rawValue {
                            vc.isPromoter = false
                            vc.isComplementry = true
                        }
                        vc.chatModel = model
                        vc.chatType = chatType
                        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
                            Utils.openViewController(vc)
                        }
                    }
                }
            }
        }
    
    }
}

//extension NotificationManager : MessagingDelegate {
//    
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        Log.debug(String(format: "PUSHNOTIFICATION REFRESH FCM_TOKEN=%@", fcmToken ?? kEmptyString))
//        guard let token = fcmToken else { return }
//        WhosinServices.registerFCM(token: token) { model , error in
//            print(error ?? "")
//        }
//    }
//}
