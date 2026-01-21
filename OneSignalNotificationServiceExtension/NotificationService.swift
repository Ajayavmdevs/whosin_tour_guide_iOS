import UserNotifications
import OneSignalExtension


class NotificationService: UNNotificationServiceExtension {

//    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let defaults = UserDefaults(suiteName: "group.com.whosin.me.onesignal")
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
//            bestAttemptContent.title = "\(bestAttemptContent.title)"
//            handleBadgeCountIncrement(for: bestAttemptContent)
//            contentHandler(bestAttemptContent)
//            OneSignalExtension.didReceiveNotificationExtensionRequest(request, with: bestAttemptContent, withContentHandler: contentHandler)
            OneSignalExtension.didReceiveNotificationExtensionRequest(self.receivedRequest, with: bestAttemptContent, withContentHandler: self.contentHandler)

//            OneSignalExtension.serviceExtensionTimeWillExpireRequest(request, with: bestAttemptContent)
        }
    }
    
    private func handleBadgeCountIncrement(for content: UNMutableNotificationContent) {
        let currentBadgeCount = defaults?.integer(forKey: "badgeCount") ?? 0
        let newBadgeCount = currentBadgeCount + 1
        content.badge = NSNumber(value: newBadgeCount)
        defaults?.set(newBadgeCount, forKey: "badgeCount")
        defaults?.synchronize()
    }

    
//    override func serviceExtensionTimeWillExpire() {
//        // Called just before the extension will be terminated by the system.
//        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
//        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
//            contentHandler(bestAttemptContent)
//        }
//    }
    
    override func serviceExtensionTimeWillExpire() {
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignalExtension.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }

}
