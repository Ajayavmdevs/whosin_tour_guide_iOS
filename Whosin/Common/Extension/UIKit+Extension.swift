import Foundation
import AVFoundation
import UIKit
import MediaPlayer

extension UIImage {
    
    func resized(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
}

extension Date {
    
    func isBetween(_ date1: Date, and date2: Date, isDateOnly: Bool = true) -> Bool {
        var dateF = date1
        var dateL = date2
        if isDateOnly {
            dateF = Utils.dateOnly(date1) ?? date1
            dateL = Utils.dateOnly(date2) ?? date2
        }
        return (min(dateF, dateL) ... max(dateF, dateL)).contains(self)
    }
    
    var timeAgoSince: String {
        let calendar = Calendar.current
        let now = Utils.localTimeZoneDate()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: now)
        
        if let years = components.year, years > 0 {
            return "\(years)" + "time_ago_years".localized()
        } else if let months = components.month, months > 0 {
            return "\(months)" + "time_ago_months".localized()
        } else if let days = components.day, days >= 7 {
            return "\(days / 7)" + "time_ago_weeks".localized()
        } else if let days = components.day, days > 0 {
            return LANGMANAGER.localizedString(forKey: "d_ago", arguments: ["value": "\(days)"])
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)" + "time_ago_hours".localized()
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)" + "m ago"
        } else {
            return "time_ago_just_now".localized()
        }
    }
    
    func days(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    func hours(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }

    func minutes(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    
    var remainTime: String {
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: self)

        return "\(components.day ?? 0)d \(components.hour ?? 0)h \(components.minute ?? 0)m \(components.second ?? 0)s Left"
    }
    
    var currentUTCTimeZoneHour: String {
         let formatter = DateFormatter()
         formatter.timeZone = TimeZone(identifier: "UTC")
         formatter.amSymbol = "AM"
         formatter.pmSymbol = "PM"
         formatter.dateFormat = "HH"

         return formatter.string(from: self)
     }
    
    var currentUTCTimeZoneMinute: String {
         let formatter = DateFormatter()
         formatter.timeZone = TimeZone(identifier: "UTC")
         formatter.amSymbol = "AM"
         formatter.pmSymbol = "PM"
         formatter.dateFormat = "mm"

        return formatter.string(from: self)
     }
    
    var timeOnly: String {
        return Utils.timeOnly24Hours(self)
    }
    
    var timeOnly12Hour: String {
        return Utils.timeOnly(self)
    }
    
    var time12HourWithAMPM: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = kFormatDateHourMinuteAM
        timeFormatter.timeZone = TimeZone.current
        let dateOnly = timeFormatter.string(from: self)
        return dateOnly
    }
    
    var display: String {
        return Utils.dateToString(self, format: kFormatEventDate)
    }

    var displayWithoutDay: String {
        return Utils.dateToString(self, format: kFormatDateReview)
    }

    var day: String {
        return Utils.dateToString(self, format: "EE")
    }
    
    var isToday: Bool {
        let calendar = Calendar.current
        let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let dateToCheckComponents = calendar.dateComponents([.year, .month, .day], from: self)
        return currentDateComponents == dateToCheckComponents
    }

    func isExpired() -> Bool {
        return self < Utils.localTimeZoneDate()
    }
    
    func isExpiredAfter15(after interval: TimeInterval) -> Bool {
        return self.addingTimeInterval(interval) < Date()
    }


}

extension String {
    
    var trim: String {
        return trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    var isValidURL: Bool {
        if let url = URL(string: self) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    var encode: String? {
        if let data = data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    var decode: String? {
        if let data = Data(base64Encoded: self) {
            return String(decoding: data, as: UTF8.self)
        }
        return nil
    }
    
    var toURL: URL? {
        return URL(string: self)
    }
    
    var numbersOnly: String {
        
        let numbers = self.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression,
            range:nil)
        return numbers
    }
    
    func isValidEmail() -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: self)
    }
    
    func containsHTML() -> Bool {
        return self.range(of: "<[^>]+>", options: .regularExpression) != nil
    }
    
    func htmlToAttributedString() -> NSAttributedString? {
        let styledHTML = "<style>body { color: white; }</style>\(self)"
        
        guard let data = styledHTML.data(using: .utf8) else { return nil }
        
        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )

            return attributedString
        } catch {
            print("Error converting HTML to NSAttributedString: \(error)")
            return nil
        }
    }

    func withCurrencyFont(_ fontSize: CGFloat = 14, _ isBold: Bool = true, color: UIColor = UIColor.white) -> NSAttributedString {
        let currency = Utils.getCurrentCurrencySymbol()
        let isAED = currency == "D"
        
        // Default base font (you can adjust global defaults here)
        let defaultFont = isBold ? FontBrand.SFmediumFont(size: fontSize) : FontBrand.SFmediumFont(size: fontSize)
        let dirhamFont = FontBrand.dirhamText(size: fontSize)
        
        let attributed = NSMutableAttributedString(
            string: self,
            attributes: [
                .font: defaultFont,
                .foregroundColor: color
            ]
        )
        
        if isAED, let range = self.range(of: currency) {
            let nsRange = NSRange(range, in: self)
            attributed.addAttribute(.font, value: dirhamFont, range: nsRange)
        }
        
        return attributed
    }

}

extension NSAttributedString {
    func withCurrencyFont(_ fontSize: CGFloat) -> NSAttributedString {
        // Get currency symbol and AED status
        let currency = Utils.getCurrentCurrencySymbol()
        let isAED = APPSESSION.userDetail?.currency.uppercased() == "AED" || currency == "D"
        
        let defaultFont = FontBrand.SFmediumFont(size: fontSize)
        let dirhamFont = FontBrand.dirhamText(size: fontSize)
        let color = UIColor.white
        
        // Convert self (NSAttributedString) to mutable copy
        let attributed = NSMutableAttributedString(attributedString: self)
        let wholeRange = NSRange(location: 0, length: attributed.length)
        
        // Apply default font and color to whole string
        attributed.addAttributes([
            NSAttributedString.Key.font: defaultFont,
            NSAttributedString.Key.foregroundColor: color
        ], range: wholeRange)
        
        // If AED, change font for currency symbol
        if isAED {
            let string = self.string
            if let range = string.range(of: currency) {
                let nsRange = NSRange(range, in: string)
                attributed.addAttribute(.font, value: dirhamFont, range: nsRange)
            }
        }
        
        return attributed
    }
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }

    func toDictionary() -> [String: Any]? {
        guard let jsonData = self.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

    }

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: attributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont, constrainedToWidth width: CGFloat) -> CGFloat {
         let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
         let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
         return ceil(boundingBox.height)
     }

    func createAttributedString() -> NSAttributedString {
        let separatedArray = self.components(separatedBy: "-")

        let fullString = NSMutableAttributedString()

        // Create attributed string for the first part with a specific font and color
        let firstAttributedString = NSAttributedString(string: "\(separatedArray.first ?? "") - ", attributes: [NSAttributedString.Key.font: FontBrand.SFboldFont(size: 15), NSAttributedString.Key.foregroundColor: ColorBrand.white])
        fullString.append(firstAttributedString)

        // Create attributed string for the second part with a different font and color
        let secondAttributedString = NSAttributedString(string: separatedArray.last ?? "", attributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 12, isItalic: true), NSAttributedString.Key.foregroundColor: ColorBrand.white.withAlphaComponent(0.7)])
        fullString.append(secondAttributedString)
        return fullString
    }
}

extension URL {
    
    var toString: String {
        return absoluteString
    }
    
    var lastPathName: String {
        return lastPathComponent
    }
    
    var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

extension UIView {
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                if let homeVC = viewController as? HomeVC {
                    homeVC.pauseVideoWhenDisappear()
                }
                return viewController
            }
        }
        return nil
    }
    
    var parentBaseController: BaseViewController? { parentViewController as? BaseViewController }
    
    var isInternetAvailable: Bool { parentBaseController?.isInternetAvailable ?? true }
    
    func addBottomLine(_ color: UIColor, _ width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lineView)

        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))

        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
    }
    
    func addTopLine(_ color: UIColor, _ width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lineView)

        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))

        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
    }
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        layer.add(animation, forKey: nil)
    }
    
    func borders(for edges: [UIRectEdge], width: CGFloat = 1, color: UIColor = .black) {
        if edges.contains(.all) {
            layer.borderWidth = width
            layer.borderColor = color.cgColor
        } else {
            let allSpecificBorders: [UIRectEdge] = [.top, .bottom, .left, .right]

            for edge in allSpecificBorders {
                if let view = viewWithTag(Int(edge.rawValue)) {
                    view.removeFromSuperview()
                }

                if edges.contains(edge) {
                    let view = UIView()
                    view.tag = Int(edge.rawValue)
                    view.backgroundColor = color
                    view.translatesAutoresizingMaskIntoConstraints = false
                    addSubview(view)

                    var horizontalVisualFormat = "H:"
                    var verticalVisualFormat = "V:"

                    switch edge {
                        case UIRectEdge.bottom:
                            horizontalVisualFormat += "|-(0)-[v]-(0)-|"
                            verticalVisualFormat += "[v(\(width))]-(0)-|"
                        case UIRectEdge.top:
                            horizontalVisualFormat += "|-(0)-[v]-(0)-|"
                            verticalVisualFormat += "|-(0)-[v(\(width))]"
                        case UIRectEdge.left:
                            horizontalVisualFormat += "|-(0)-[v(\(width))]"
                            verticalVisualFormat += "|-(0)-[v]-(0)-|"
                        case UIRectEdge.right:
                            horizontalVisualFormat += "[v(\(width))]-(0)-|"
                            verticalVisualFormat += "|-(0)-[v]-(0)-|"
                        default:
                            break
                    }

                    addConstraints(NSLayoutConstraint.constraints(
                        withVisualFormat: horizontalVisualFormat,
                        options: .directionLeadingToTrailing,
                        metrics: nil,
                        views: ["v": view]))
                    addConstraints(NSLayoutConstraint.constraints(
                        withVisualFormat: verticalVisualFormat,
                        options: .directionLeadingToTrailing,
                        metrics: nil,
                        views: ["v": view]))
                }
            }
        }
    }
    
    func pinEdgesToSuperView() {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: superView.leftAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        rightAnchor.constraint(equalTo: superView.rightAnchor).isActive = true
    }
}

extension Notification.Name {
    static let changeReachability = Notification.Name("changeReachabilityNotification")
    static let updateNotificationBadge = Notification.Name("updateNotificationBadge")
    static let updateWhoIsInBadge = Notification.Name("updateWhoIsInBadge")
    static let updateLocationState = Notification.Name("updateLocationStatu")
    static let changeSubscriptionState = Notification.Name("changeSubscriptionState")
    static let changeUserUpdateState = Notification.Name("changeUserUpdateState")
    static let changeUserFollowState = Notification.Name("changeUserFollowState")
    static let reloadShoutouts = Notification.Name("reloadShoutouts")
    static let openClaimSuccessCard = Notification.Name("openClaimSuccessCard")
    static let openPurchaseSuccessCard = Notification.Name("openPurchaseSuccessCard")
    static let openTicketReview = Notification.Name("openTicketReview")
    static let openReportSuccessCard = Notification.Name("openReportSuccessCard")
    static let readUpdatesState = Notification.Name("readUpdatesState")
    static let changeVenueFollowState = Notification.Name("changeVenueFollowState")
    static let approvedAuthRequest = Notification.Name("approvedAuthRequest")
    static let switchToPersonalProfile = Notification.Name("switchToPersonalProfile")
    static let switchToPromoterProfile = Notification.Name("switchToPromoterProfile")
    static let switchToComplementaryProfile = Notification.Name("switchToComplementaryProfile")
    static let reloadMyEventsNotifier = Notification.Name("relodMyEventsNotifier")
    static let reloadPromoterProfileNotifier = Notification.Name("reloadPromoterProfileNotifier")
    static let reloadEventNotification = Notification.Name("reloadEventNotification")
    static let reloadUsersNotification = Notification.Name("reloadUserNotification")
    static let reloadEventDraftNotification = Notification.Name("reloadEventDraftNotification")
    static let changeUserProfileTypeUpdateState = Notification.Name("changeUserProfileTypeUpdateState")
    static let changereloadNotificationUpdateState = Notification.Name("changereloadUpdateState")
    static let commanProfilePullToRefresh = Notification.Name("commanProfilePullToRefresh")
    static let showAlertForUpgradeProfile = Notification.Name("showAlertForUpgradeProfile")
    static let openPenaltyPaymenPopup = Notification.Name("openPenaltyPaymenPopup")
    static let revokeSubAdminAccess = Notification.Name("revokeSubAdminAccess")
    static let showMiniPlayerEvent = Notification.Name("showMiniPlayerEvent")
    static let reloadOnLike = Notification.Name("reloadOnLike")
    static let reloadHistory = Notification.Name("reloadHistory")
    static let reloadOptions = Notification.Name("reloadOptions")

}

extension MPVolumeView {
    
    /// Set device volume
    /// - Parameter volume: Volume
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}
 
extension Dictionary {
    /// Merges dictionary
    /// - Parameter dict: Dictionary to be merged
    /// - Returns: Merged dictionary
    func merge(dict: [Key: Value]) -> [Key: Value] {
        var mutableCopy = self
        for (key, value) in dict {
            mutableCopy[key] = value
        }
        return mutableCopy
    }

    /// Returns json string fom dictionary.
    var toJSONString: String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? ""
        } catch { return "" }
    }
    
    var toJSONPrettyPrintString: String {
        guard JSONSerialization.isValidJSONObject(self),
              let data = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]),
              let jsonString = String(data: data, encoding: .utf8) else {
            return ""
        }
        return jsonString
    }

}

extension UILabel {
    func setPrice(_ amount: Double) {
        let currency = Utils.getCurrentCurrencySymbol()
        let isAED = (APPSESSION.userDetail?.currency.uppercased() == "AED" || currency == "D")
        let formatted = "\(currency)\(amount.formattedDecimal())"
        
        let attributed = NSMutableAttributedString(string: formatted)
        let fontSize = self.font.pointSize
        let blackColor = UIColor.black
        
        if isAED {
            attributed.addAttributes([
                .font: FontBrand.dirhamText(size: fontSize),
                .foregroundColor: blackColor
            ], range: NSRange(location: 0, length: 1))
        } else {
            attributed.addAttributes([
                .font: FontBrand.SFboldFont(size: fontSize),
                .foregroundColor: blackColor
            ], range: NSRange(location: 0, length: 1))
        }
        
        attributed.addAttributes([
            .font: FontBrand.SFboldFont(size: fontSize),
            .foregroundColor: blackColor
        ], range: NSRange(location: 1, length: formatted.count - 1))
        
        self.attributedText = attributed
    }
}


