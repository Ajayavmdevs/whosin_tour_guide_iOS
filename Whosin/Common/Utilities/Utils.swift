import MediaPlayer
import Photos
import CoreLocation
import Contacts
import RealmSwift
import ObjectMapper
import UIKit
import UserNotifications
import libPhoneNumber_iOS
import MediaBrowser
import DialCountries
import AVFoundation
import SDWebImage
import Amplitude

class Utils: NSObject {
    
    // --------------------------------------
    // MARK: Notification
    // --------------------------------------
    
    class func dispatchNotification(title: String, body: String, identifier: String = UUID().uuidString, data: [String: Any] = [:]) {
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.userInfo = data
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    // --------------------------------------
    // MARK: Strings
    // --------------------------------------
    
    class func getDeviceUdid() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    class func getDeviceID() -> String {
        if let retrievedDeviceId = KeychainManager.shared.retrieve(forKey: "deviceId") {
            return retrievedDeviceId
        } else {
            KeychainManager.shared.save(getDeviceUdid(), forKey: "deviceId")
            return getDeviceUdid()
        }
    }
    
    class func getHashSha256(_ input: String, length: Int) -> String? {
        guard let data = input.data(using: .utf8) else { return nil }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.baseAddress, CC_LONG(data.count), &hash)
        }
        let hashString = hash.map { String(format: "%02x", $0) }.joined()
        return String(hashString.prefix(length))
    }
    
    class func getBooleanString(_ value: Bool) -> String {
        return value ? "true" : "false"
    }
    
    class func formatFirstname(_ firstname: String, andLastName lastname: String) -> String {
        return "\(firstname) \(lastname)"
    }
    
    class func stringIsNullOrEmpty(_ string: String?) -> Bool {
        return (string == nil || string?.trim == kEmptyString || string == "NULL" || string == "null")
    }
    
    
    
    class func isValidNumber(_ number: String, _ countryCode: String) -> Bool {
        guard let phoneUtil = NBPhoneNumberUtil.sharedInstance() else {
            return false
        }
        do {
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(number, defaultRegion: countryCode == "UAE" ? "AE" : countryCode)
            return phoneUtil.isValidNumber(phoneNumber)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return false
    }
    
    class func isValidEmail(_ email: String?) -> Bool {
        if (email == nil || email?.trim == kEmptyString || email == "NULL" || email == "null") {
            return false
        } else {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
        }
    }
    
    class func isValidTextOrHTML(_ value: String?) -> Bool {
        guard !stringIsNullOrEmpty(value) else {
            return false
        }

        let plainText = convertHTMLToPlainText(from: value ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return !Utils.stringIsNullOrEmpty(plainText)
    }
    
    class func isValidCode(_ code: String) -> Bool {
        let regex = #"^[A-Za-z]-\d{4}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: code)
    }
    
    class func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        if let formattedNumber = formatter.string(from: NSNumber(value: number)) {
            return "\(formattedNumber)"
        }
        return "0"
    }
    
    class func formatCurrency(_ amount: Float, withDecimal: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        if !withDecimal { formatter.maximumFractionDigits = 0 }
        if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
            return "\(formattedAmount)"
        }
        return "$0"
    }
    
    
    class func removeFileExtension(_ fileName: String?) -> String? {
        var components = fileName?.components(separatedBy: ".")
        if components?.count ?? 0 > 1 {
            components?.removeLast()
            return components?.joined(separator: ".")
        } else {
            return fileName
        }
    }
    
    class func attributedText(data: TicketModel, onlyPrice:Bool = false) -> NSAttributedString {
        let startingText = NSAttributedString(
            string: "starting".localized(),
            attributes: [.font: FontBrand.SFregularFont(size: 13),  // Replace with your normal font if needed
                         .foregroundColor: UIColor.white]
        )
        
        let spacing = NSAttributedString(
            string: " ", // two spaces (adjust if needed)
            attributes: [
                .font: FontBrand.SFregularFont(size: 13)
            ]
        )

        
        let discountedPriceCurrency = NSAttributedString(
            string: " \(Utils.getCurrentCurrencySymbol())",
            attributes: [.foregroundColor: UIColor.white, .font: APPSESSION.userDetail?.currency == "AED" || Utils.getCurrentCurrencySymbol() == "D" ? FontBrand.dirhamText(size: 13) : FontBrand.SFboldFont(size: 13)] // optional: make discounted price black
        )
        let discountedPrice = NSAttributedString(
            string: "\(data.startingAmount.formattedDecimal())",
            attributes: [.foregroundColor: UIColor.white, .font: FontBrand.SFboldFont(size: 13)] // optional: make discounted price black
        )

        let finalText = NSMutableAttributedString()
        if !onlyPrice {
            finalText.append(startingText)
            finalText.append(spacing) 
        }
        
        if data.hasDiscount {
            let originalPrice = NSAttributedString(
                string: "\(Utils.getCurrentCurrencySymbol())\(data.startingAmountWithoutDiscount.hideFloatingValue())",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                             .foregroundColor: UIColor.white.withAlphaComponent(0.6), .font: APPSESSION.userDetail?.currency == "AED" || Utils.getCurrentCurrencySymbol() == "D" ? FontBrand.dirhamText(size: 13) : FontBrand.SFboldFont(size: 13)] // optional: make strikethrough gray
            )
            finalText.append(originalPrice)
        }
        finalText.append(discountedPriceCurrency)
        finalText.append(discountedPrice)
        return finalText
    }
    
    // --------------------------------------
    // MARK: Date
    // --------------------------------------
    
    class func localTimeZoneDate(timeZone: TimeZone = TimeZone.current) -> Date {
        let dubaiTimeZone = TimeZone(identifier: "Asia/Dubai")!
        let currentDate = Date()
        let secondsFromGMT = dubaiTimeZone.secondsFromGMT(for: currentDate)
        let dubaiDate = Calendar.current.date(byAdding: .second, value: secondsFromGMT, to: currentDate)!
        return dubaiDate
        
        //        return Date().addingTimeInterval(Double(timeZone.secondsFromGMT()))
    }
    
    class func toUtcDate(_ date: Date) -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: date))
        return Date(timeInterval: seconds, since: date)
    }
    
    class func dateOnly(_ date: Date?) -> Date? {
        let dateStr = dateToString(date, format: kFormatDateUS)
        let dateOnly = stringToDate(dateStr, format: kFormatDateUS)
        return dateOnly
    }
    
    public class func dateOnlyWithTimeZone(_ date: Date?) -> Date? {
        let dateStr = dateToStringWithTimezone(date, format: kFormatDateUS)
        let dateOnly = stringToDate(dateStr, format: kFormatDateUS)
        return dateOnly
    }
    
    class func timeOnly(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = kFormatDateTimeUS
        timeFormatter.timeZone = TimeZone.current
        let dateOnly = timeFormatter.string(from: date)
        return dateOnly
    }
    
    class func timeOnlyDateType(_ date: String?) -> Date? {
        guard let date = date else { return Date() }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = kFormatDateTimeUS
        let dateOnly = timeFormatter.date(from: date)
        return dateOnly
    }
    
    class func timeOnly24Hours(_ date: Date?) -> String {
        guard let date = date else { return "" }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = kFormatDateTimeUS
        let dateOnly = timeFormatter.string(from: date)
        return dateOnly
    }
    
    class func timeOnlyCalender(_ date: Date?) -> Date? {
        let dateStr = dateToString(date, format: kFormatDateHourMinuteAM)
        let dateOnly = stringToDate(dateStr, format: kFormatDateHourMinuteAM)
        return dateOnly
    }
    
    class func adjustEndTime(startDate: Date, endTime: Date) -> Date? {
        let calendar = Calendar.current
        if endTime < startDate {
            if let adjustedEndTime = calendar.date(byAdding: .day, value: 1, to: endTime) {
                return adjustedEndTime
            }
        }
        return endTime
    }
    
    class func getYearDate(startDate: Date) -> Date? {
        let calendar = Calendar.current
        if let adjustedEndTime = calendar.date(byAdding: .year, value: 1, to: startDate) {
            return adjustedEndTime
        }
        return nil
    }
    
    
    class func dateToString(_ date: Date?, format: String) -> String {
        if date == nil {
            return kEmptyString
        }
        let dateFormatter = DATEFORMATTER.dateFormatterWith(format: format, locale: Locale.current)
        return dateFormatter.string(from: date!)
    }
    
    class func dateToStringWithTimezone(_ date: Date?, format: String) -> String {
        if date == nil {
            return kEmptyString
        }
        
        var convertedDate = date
        let timeZoneOffset = TimeZone.current.secondsFromGMT()
        convertedDate?.addTimeInterval(TimeInterval(timeZoneOffset))
        
        let dateFormatter = DATEFORMATTER.dateFormatterWith(format: format, locale: Locale.current)
        return dateFormatter.string(from: convertedDate!)
    }
    
    class func dateToStringEST(_ date: Date?, format: String) -> String {
        if date == nil {
            return kEmptyString
        }
        
        var convertedDate = date
        
        let timeZoneOffset = TimeZone.current.secondsFromGMT()
        convertedDate?.addTimeInterval(TimeInterval(timeZoneOffset + 5 * 3600))
        
        let dateFormatter = DATEFORMATTER.dateFormatterWith(format: format, locale: Locale.current)
        return dateFormatter.string(from: convertedDate!)
    }
    
    class func convertNoDateOfferTime(_ startTime: String, _ endTime: String) -> String {
        if let startDate = stringToDate(startTime, format: kFormatDateTimeUS), let endDate = stringToDate(endTime, format: kFormatDateTimeUS) {
            return "\(dateToString(startDate, format: kFormatDateTimeUS)) - \(dateToString(endDate, format: kFormatDateTimeUS))"
        }
        return "\(startTime) - \(endTime)"
    }
    
    class func dateToStringUTC(_ date: Date?, format: String) -> String {
        if date == nil {
            return kEmptyString
        }
        
        var convertedDate = date
        
        let timeZoneOffset = TimeZone.current.secondsFromGMT()
        convertedDate?.addTimeInterval(TimeInterval(timeZoneOffset))
        
        let dateFormatter = DATEFORMATTER.dateFormatterWith(format: format, locale: Locale.current)
        return dateFormatter.string(from: convertedDate!)
    }
    
    class func stringToDate(_ string: String?, format: String) -> Date? {
        if Utils.stringIsNullOrEmpty(string) {
            return nil
        }
        let dateFormatter = DATEFORMATTER.dateFormatterWith(format: format, locale: Locale.current)
        return dateFormatter.date(from: string!)
    }
    
    class func stringToDateLocal(_ string: String?, format: String) -> Date? {
        if Utils.stringIsNullOrEmpty(string) {
            return nil
        }
        let dateFormatter = DATEFORMATTER.dateFormatterWith(format: format, locale: Locale.current)
        let timeZoneOffset = TimeZone.current.secondsFromGMT()
        return dateFormatter.date(from: string!)?.addingTimeInterval(TimeInterval(timeZoneOffset + 5 * 3600))
    }
    
    class func stringDateLocal(_ string: String?, format: String) -> Date? {
        guard let isoDateString = string, !Utils.stringIsNullOrEmpty(isoDateString) else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: isoDateString)
    }
    
    class func currentDayOnly() -> String {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: today).lowercased()
    }
    
    class func currentShourtDayOnly() -> String {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: today).lowercased()
    }
    
    class func currentTimeOnly() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let dateString = formatter.string(from: Date())
        return formatter.date(from: dateString)!
    }
    
    class func getDay(from dateString: String) -> String? {
        _ = ISO8601DateFormatter()
        guard let date = stringToDate(dateString, format: kStanderdDate) else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        if let day = components.weekday {
            let dayName = calendar.weekdaySymbols[day - 1]
            return dayName
        } else {
            return nil
        }
    }
    
    class func isDateExpired(dateString: String?, format: String) -> Bool {
        guard let dateString = dateString, !dateString.isEmpty else {
            return true
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let expiryDate = dateFormatter.date(from: dateString) {
            return expiryDate < Date()
        }
        return true
    }
    
    class func isDateExpiredWith2Hour(dateString: String?, format: String) -> Bool {
        guard let dateString = dateString, !dateString.isEmpty else {
            return true
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let expiryDate = dateFormatter.date(from: dateString) {
            if let updateTime = Calendar.current.date(byAdding: .hour, value: 2, to: expiryDate) {
                return updateTime < Date()
            }
        }
        return true
    }
    
    
    class func isDateExpiredClaimTime(dateString: String?, format: String) -> Bool {
        guard let dateString = dateString, !dateString.isEmpty else {
            return true
        }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = format
        if let expiryDate = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "HH:mm"
            let hours = dateFormatter.string(from: expiryDate)
            dateFormatter.dateFormat = kFormatDate
            let todayDate = dateFormatter.string(from: Date())
            let dateString = "\(todayDate) \(hours)"
            dateFormatter.dateFormat = kFormatDateTimeLocal
            if let updatedate = dateFormatter.date(from: dateString) {
                if let updateTime = Calendar.current.date(byAdding: .hour, value: 2, to: updatedate) {
                    return updateTime.isExpired()
                }
            }
        }
        return true
    }
    
    class func getCurrentDate(withFormat format: String) -> Date {
        let currentDate = Date().addingTimeInterval(TimeInterval(19800))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Dubai")!
        let formattedDateString = dateFormatter.string(from: currentDate)
        if let formattedDate = dateFormatter.date(from: formattedDateString) {
            return formattedDate
        } else {
            return currentDate
        }
    }
    
    class func generateMessageId(_ userId: String) -> String {
        let timestamp = Date().timeIntervalSince1970
        let messageStr = "\(userId)_\(timestamp)"
        return messageStr
    }
    
    class func getStringInMinuteAndSecond(durationInSecond: Int) -> String {
        var timeMin = 0
        var timeSec = 0
        timeMin = durationInSecond / 60
        timeSec = durationInSecond % 60
        let timeNow = String(format: "%02d:%02d", timeMin, timeSec)
        return timeNow
    }
    
    class func getDateBefore(months: Int) -> Date? {
        let currentDate = Date()
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: -months, to: currentDate)
    }
    
    class func timeAgoString(from timeInterval: TimeInterval) -> String {
        let currentDate = Date()
        let previousDate = Date(timeIntervalSince1970: timeInterval)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        if let timeAgo = formatter.string(from: previousDate, to: currentDate) {
            return timeAgo == "0s" ? "now".localized() :"\(timeAgo)"
        } else {
            return ""
        }
    }
    
    class func formatTimeString(timeString: String) -> String {
        if let interval = TimeInterval(timeString) {
            return Utils.timeAgoString(from: interval)
        } else {
            return ""
        }
    }
    
    class func randomString(length: Int, id: String) -> String {
        let letters = id
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    class func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    class func formatTimeRange(start: String, end: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let startTime = formatter.date(from: start),
              let endTime = formatter.date(from: end) else {
            return nil
        }
        formatter.dateFormat = "hh:mm"
        let formattedStartTime = formatter.string(from: startTime)
        let formattedEndTime = formatter.string(from: endTime)
        return "\(formattedStartTime) - \(formattedEndTime)"
    }
    
    class func isExpiredDate(start: String, end: String, daysArray: [String]) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = kFormatDate
        guard let startDate = formatter.date(from: start), let endDate = formatter.date(from: end) else {
            return true
        }
        var finalDate: Date?
        var currentDate = startDate
        let calendar = Calendar.current
        while currentDate <= endDate {
            formatter.dateFormat = "E"
            let shortDayOfWeek = formatter.string(from: currentDate).lowercased()
            if daysArray.contains(shortDayOfWeek) {
                finalDate = currentDate
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        if let _finalDate = finalDate {
            return _finalDate.isExpired()
        }
        return true
    }
    
    class func isExpiredDate(start: String, end: String, daysArray: [String], formater: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = formater
        
        guard let startDate = formatter.date(from: start), let endDate = formatter.date(from: end) else {
            return false
        }
        var finalDate: Date?
        var currentDate = startDate
        let calendar = Calendar.current
        while currentDate <= endDate {
            formatter.dateFormat = "E"
            let shortDayOfWeek = formatter.string(from: currentDate).lowercased()
            if daysArray.contains(shortDayOfWeek) {
                finalDate = currentDate
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        if let _finalDate = finalDate {
            return _finalDate.isExpired()
        }
        return false
    }
    
    
    class func remainingDays(from dateString: Date) -> Int? {
        _ = ISO8601DateFormatter()
        var dateComponent = DateComponents()
        dateComponent.day = 15
        let calendar = Calendar.current
        guard let futureDate = calendar.date(byAdding: dateComponent, to: dateString) else {
            print("Failed to add days to date")
            return nil
        }
        let now = Date()
        let remainingDays = calendar.dateComponents([.day], from: now, to: futureDate).day ?? 0
        
        return remainingDays
    }
    // --------------------------------------
    // MARK: image
    // --------------------------------------
    
    class func setAtributedTitleText(title: String, subtitle: String, titleFont: UIFont, subtitleFont: UIFont) -> NSMutableAttributedString {
//        let textTitle = title
//        let textList = NSMutableAttributedString(string: subtitle)
//        let PrefixAttributedString = NSMutableAttributedString(string: textTitle)
//        let boldFont = titleFont
//        PrefixAttributedString.addAttributes([NSAttributedString.Key.font: boldFont], range: NSRange(location: 0, length: PrefixAttributedString.length))
//        let textAttributedString = NSMutableAttributedString(string: subtitle)
//        textAttributedString.addAttributes([NSAttributedString.Key.font: subtitleFont], range: NSRange(location: 0, length: textList.length))
//        let attributedText = NSMutableAttributedString()
//        attributedText.append(PrefixAttributedString)
//        attributedText.append(textAttributedString)
//        return attributedText
        
        let textTitle = title
        let textList = NSMutableAttributedString(string: subtitle)
        let prefixAttributedString = NSMutableAttributedString(string: textTitle)
        let boldFont = titleFont

        // Apply font to prefix
        prefixAttributedString.addAttributes([.font: boldFont], range: NSRange(location: 0, length: prefixAttributedString.length))

        // Apply font to subtitle
        let textAttributedString = NSMutableAttributedString(string: subtitle)
        textAttributedString.addAttributes([.font: subtitleFont], range: NSRange(location: 0, length: textList.length))

        // Combine
        let attributedText = NSMutableAttributedString()
        attributedText.append(prefixAttributedString)
        attributedText.append(textAttributedString)

        // ✅ Add line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6 // <- You can customize this value

        // Apply to the full range
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))

        return attributedText

    }
    
    class func createAttributedStringWithColors(firstText: String, firstTextColor: UIColor, secondText: String, secondTextColor: UIColor) -> NSAttributedString {
        let firstTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: firstTextColor
        ]
        let secondTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: secondTextColor
        ]
        
        let firstAttributedString = NSAttributedString(string: firstText, attributes: firstTextAttributes)
        let secondAttributedString = NSAttributedString(string: secondText, attributes: secondTextAttributes)
        
        let combinedAttributedString = NSMutableAttributedString()
        combinedAttributedString.append(firstAttributedString)
        combinedAttributedString.append(secondAttributedString)
        
        return combinedAttributedString
    }
    
    // --------------------------------------
    // MARK: Systems
    // --------------------------------------
    
    class func downloadAudioFile(from url: URL, completion: @escaping (URL?, Error?) -> Void) {
        let session = URLSession.shared
        
        let task = session.downloadTask(with: url) { (tempLocation, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let tempLocation = tempLocation else {
                completion(nil, NSError(domain: "com.example.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "No temporary file location."]))
                return
            }
            _ = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
            let destinationURL = getDocumentsUrl().appendingPathComponent(url.lastPathComponent)
            
            do {
                try FileManager.default.moveItem(at: tempLocation, to: destinationURL)
                completion(destinationURL, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    
    
    class func getAudioDuration(filePath: String, completion: @escaping (Double?) -> Void) {
        
        if let fileURL = URL(string: filePath) {
            let asset = AVURLAsset(url: fileURL)
            
            let duration = asset.duration.seconds
            if duration.isFinite && !duration.isNaN {
                completion(duration)
            } else {
                completion(nil)
            }
        }
    }
    
    class func getAudioDuration(filePath: String) -> Double {
        if let fileURL = URL(string: filePath) {
            let asset = AVURLAsset(url: fileURL)
            
            let duration = asset.duration.seconds
            if duration.isFinite && !duration.isNaN {
                return duration
            }
        }
        return 0
    }
    
    class func saveDictionaryToUserDefaults(_ dict: NSDictionary?) {
        let userDefaults: UserDefaults = UserDefaults.standard
        for key in dict?.allKeys ?? [] {
            userDefaults.set(dict![key], forKey: (key as? String)!)
        }
        userDefaults.synchronize()
    }
    
    class func saveObjectToUserDefaults(_ key: String, object: Any?) {
        let userDefaults: UserDefaults = UserDefaults.standard
        if object != nil {
            userDefaults.set(object, forKey: key)
        }
        userDefaults.synchronize()
    }
    
    class func removeObjectFromUserDefaults(_ key: String) {
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }
    
    class func getObjectFromUserDefaults(_ key: String) -> Any? {
        let userDefaults: UserDefaults = UserDefaults.standard
        return userDefaults.object(forKey: key)
    }
    
    class func getLocalDirectory(_ folderName: String?) -> URL? {
        if stringIsNullOrEmpty(folderName) {
            return nil
        }
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let folderPath = (documentDirectory as NSString).appendingPathComponent(folderName!)
        if !FileManager.default.fileExists(atPath: folderPath) {
            Log.debug("Create new folder: \(folderPath)")
            do {
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Log.debug("Error creating local directory: \(error.localizedDescription)")
                return nil
            }
        }
        return URL(string: folderPath)
    }
    
    class func fileSizeFromPath(path: String!) -> Int {
        if Utils.stringIsNullOrEmpty(path) {
            return 0
        } else {
            var fileSize: Int = 0
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: path)
                fileSize = attr[FileAttributeKey.size] as? Int ?? 0
                let dict = attr as NSDictionary
                fileSize = Int(dict.fileSize())
            } catch {
                print("Error: \(error)")
            }
            return fileSize
        }
    }
    
    class func saveFileToLocal(_ image: UIImage, fileName: String) {
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = image.wxCompress(type: .session) {
            try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
        }
    }
    
    class func saveFileToLocal(data: Data, fileName: String) {
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
    }
    
    class func savePDFFileToLocal(data: Data, fileName: String) -> URL? {
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
            return URL(fileURLWithPath: filePath)
        } catch {
            print("Error saving file: \(error.localizedDescription)")
            return nil
        }
    }
    
    class func saveFileFromURL(_ videoURL: URL, fileName: String, completion: @escaping (URL?) -> Void) {
        let destinationURL = getDocumentsUrl().appendingPathComponent(fileName)
        
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: videoURL) { tempLocalUrl, response, error in
            if let error = error {
                print("Error downloading video: \(error)")
                completion(nil)
            } else if let tempLocalUrl = tempLocalUrl {
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationURL)
                    completion(destinationURL)
                } catch {
                    print("Error saving video: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
        downloadTask.resume()
    }
    
    class func getDocumentsUrl() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    class func isFileExist(atPath filePath: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: filePath)
    }
    
    class func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
    class func getAssetImageUrl(forImageNamed name: String) -> URL? {
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("\(name).png")
        guard fileManager.fileExists(atPath: url.path) else {
            guard
                let image = UIImage(named: name),
                let data = image.pngData()
            else { return nil }
            
            fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
            return url
        }
        
        return url
    }
    
    class func getAssetImageUrlString(forImageNamed name: String) -> String? {
        return getAssetImageUrl(forImageNamed: name)?.absoluteString
    }
    
    
    // --------------------------------------
    // MARK: Get models By Id
    // --------------------------------------
    
    
    class func getUsersWithSharedIds(userModels: [UserModel], sharedWithIds: [String]) -> [UserModel] {
        return userModels.filter { sharedWithIds.contains($0.id) }
    }
    
    class func getUserFromId(userModels: [UserModel], userId: String) -> UserModel? {
        return userModels.filter { $0.id == userId }.first
    }
    
    class func getModelsFromIds<T: Identifiable>(model: [T]?, ids: [String]) -> [T]? {
        return model?.filter { ids.contains($0.id as! String) }
    }
    
    class func getModelsFromIds<T: Identifiable>(model: [T]?, ids: List<String>) -> [T]? {
        return model?.filter { ids.contains($0.id as! String) }
    }
    
    class func getModelFromId<T: Identifiable>(model: [T]?, id: String) -> T? {
        return model?.filter { $0.id as? String == id }.first
    }
    
    // --------------------------------------
    // MARK: Validator
    // --------------------------------------
    
    class func validateEmail(_ candidate: String?) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: candidate)
    }
    
    class func validatePhoneNumber(_ candidate: String?) -> Bool {
        if candidate!.count < 10 { return false }
        let regex = "(\\+[0-9]+[\\- \\.]*)?(\\([0-9]+\\)[\\- \\.]*)?([0-9][0-9\\- \\.][0-9\\- \\.]+[0-9])"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: candidate)
    }
    
    class func validateUrl(_ url: URL?) -> Bool {
        if url != nil, url?.scheme != nil, url?.host != nil,
           url?.scheme == "http" || url?.scheme == "https" || url?.scheme == "ftp" || url?.scheme == "file" {
            return true
        } else {
            return false
        }
    }
    
    class func validateInstagramProfileUrl(_ url: URL?) -> Bool {
        guard let url = url, let scheme = url.scheme, let host = url.host else {
            return false
        }
        
        let validSchemes = ["http", "https"]
        if !validSchemes.contains(scheme) {
            return false
        }
        
        let validHosts = ["www.instagram.com", "instagram.com"]
        if !validHosts.contains(host) {
            return false
        }
        
        //        let pathComponents = url.pathComponents
        //        if pathComponents.count == 2, !pathComponents[1].isEmpty {
        //            return true
        //        }
        
        return true
    }
    
    
    class func isEmail(emailString: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailString)
    }
    
    class func setVolumeStealthily(_ view: UIView, _ volume: Float) {
        
        let volumeView = MPVolumeView(frame: .zero)
        
        guard let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider else {
            assertionFailure("Unable to find the slider")
            return
        }
        
        volumeView.clipsToBounds = true
        view.addSubview(volumeView)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak slider, weak volumeView] in
            slider?.setValue(volume, animated: false)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak volumeView] in
                volumeView?.removeFromSuperview()
            }
        }
    }
    
    class func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    class func webMediaPhoto(url: String, caption: String?) -> Media? {
        guard let validUrl = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? kEmptyString) else {
            return nil
        }
        var photo = Media()
        if let _caption = caption {
            photo = Media(url: validUrl, caption: _caption)
        } else {
            photo = Media(url: validUrl)
        }
        return photo
    }
    
    class func getCountyFlag(code: String) -> String {
        return code
            .unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
    
    class func getCountryCode(for dialCode: String) -> String? {
        let countryDialCodes: [String: String] = [
            "+93": "AF",  "+355": "AL", "+213": "DZ",  "+376": "AD", "+244": "AO",
            "+54": "AR", "+374": "AM", "+297": "AW", "+61": "AU", "+43": "AT", "+994": "AZ",
            "+973": "BH", "+880": "BD",  "+375": "BY", "+32": "BE", "+501": "BZ", "+229": "BJ",
            "+975": "BT", "+591": "BO", "+387": "BA", "+267": "BW", "+55": "BR", "+246": "IO", "+673": "BN", "+359": "BG",
            "+226": "BF", "+257": "BI", "+855": "KH", "+237": "CM",  "+238": "CV",  "+236": "CF",
            "+235": "TD", "+56": "CL", "+86": "CN",   "+57": "CO", "+269": "KM", "+242": "CG",
            "+243": "CD", "+682": "CK", "+506": "CR", "+225": "CI", "+385": "HR", "+53": "CU", "+357": "CY", "+420": "CZ",
            "+45": "DK", "+253": "DJ",   "+593": "EC", "+20": "EG", "+503": "SV", "+240": "GQ",
            "+291": "ER", "+372": "EE", "+251": "ET", "+500": "FK", "+298": "FO", "+679": "FJ", "+358": "FI", "+33": "FR",
            "+594": "GF", "+689": "PF", "+241": "GA", "+220": "GM", "+995": "GE", "+49": "DE", "+233": "GH", "+350": "GI",
            "+30": "GR", "+299": "GL",    "+502": "GT",  "+224": "GN",
            "+245": "GW", "+592": "GY", "+509": "HT", "+39": "VA", "+504": "HN", "+852": "HK", "+36": "HU", "+354": "IS",
            "+91": "IN", "+62": "ID", "+98": "IR", "+964": "IQ", "+353": "IE",  "+972": "IL",
            "+81": "JP", "+44": "JE", "+962": "JO", "+7": "KZ", "+254": "KE", "+686": "KI", "+850": "KP",
            "+82": "KR", "+965": "KW", "+996": "KG", "+856": "LA", "+371": "LV", "+961": "LB", "+266": "LS", "+231": "LR",
            "+218": "LY", "+423": "LI", "+370": "LT", "+352": "LU", "+853": "MO", "+389": "MK", "+261": "MG", "+265": "MW",
            "+60": "MY", "+960": "MV", "+223": "ML", "+356": "MT", "+692": "MH", "+596": "MQ", "+222": "MR", "+230": "MU",
            "+262": "YT", "+52": "MX", "+691": "FM", "+373": "MD", "+377": "MC", "+976": "MN", "+382": "ME",
            "+212": "MA", "+258": "MZ", "+95": "MM", "+264": "NA", "+674": "NR", "+977": "NP", "+31": "NL", "+687": "NC",
            "+64": "NZ", "+505": "NI", "+227": "NE", "+234": "NG", "+683": "NU", "+672": "NF",  "+47": "NO",
            "+968": "OM", "+92": "PK", "+680": "PW", "+970": "PS", "+507": "PA", "+675": "PG", "+595": "PY", "+51": "PE",
            "+63": "PH", "+48": "PL", "+351": "PT",  "+974": "QA", "+40": "RO",  "+250": "RW",
            "+590": "BL", "+290": "SH",    "+508": "PM",
            "+685": "WS", "+378": "SM", "+239": "ST", "+966": "SA", "+221": "SN", "+381": "RS", "+248": "SC", "+232": "SL",
            "+65": "SG", "+421": "SK", "+386": "SI", "+677": "SB", "+252": "SO", "+27": "ZA", "+211": "SS", "+34": "ES",
            "+94": "LK", "+249": "SD", "+597": "SR",  "+268": "SZ", "+46": "SE", "+41": "CH", "+963": "SY",
            "+886": "TW", "+992": "TJ", "+255": "TZ", "+66": "TH", "+670": "TL", "+228": "TG", "+690": "TK", "+676": "TO",
            "+1": "TT", "+216": "TN", "+90": "TR", "+993": "TM",  "+688": "TV", "+256": "UG", "+380": "UA",
            "+971": "AE","+598": "UY", "+998": "UZ", "+678": "VU", "+58": "VE", "+84": "VN",
            "+681": "WF", "+967": "YE", "+260": "ZM", "+263": "ZW"
        ]
        if let countryName = countryDialCodes[dialCode] {
            return countryName
        }
        return nil
        
    }
    
    class func getCountryCodeByName(byCountryName countryName: String) -> String? {
        
        for localeCode in Locale.isoRegionCodes {
            let identifier = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: localeCode])
            let locale = Locale(identifier: identifier)
            if let name = locale.localizedString(forRegionCode: localeCode), name.lowercased() == countryName.lowercased() {
                return localeCode
            }
        }
        
        let cleanedCountryName = countryName.replacingOccurrences(of: "\\s*\\(.*\\)", with: "", options: .regularExpression)
        let aliasMapping: [String: String] = [
            "UK": "United Kingdom",
            "United Arab Emirates (UAE)": "United Arab Emirates",
            "UAE": "United Arab Emirates",
            "USA": "United States",
            "Russian Federation": "Russia",
            "South Korea": "Korea, Republic of"
        ]
        
        let normalizedCountryName = aliasMapping[countryName] ?? cleanedCountryName
        for localeCode in Locale.isoRegionCodes {
            let identifier = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: localeCode])
            let locale = Locale(identifier: identifier)
            if let name = locale.localizedString(forRegionCode: localeCode), name.lowercased() == normalizedCountryName.lowercased() {
                return localeCode
            }
        }
        return nil
    }
    
    class func isValidCountryCode(_ code: String) -> Bool {
        let availableCountryCodes = Locale.isoRegionCodes // All ISO country codes
        return availableCountryCodes.contains(code.uppercased())
    }
    
    class func getcurrentFlag() -> String {
        let country = Country.getCurrentCountry()
        if let countryCode = APPSESSION.userDetail?._countryCode, let code = Utils.getCountryCode(for: countryCode) {
            return  Utils.getCountyFlag(code: code)
        }
        if let code = country?.flag {
            return code
        }
        return Utils.getCountyFlag(code: "AE")
    }
    
    class func getCurrentDialCode() -> String {
        if let dialCode = APPSESSION.userDetail?._countryCode, !Utils.stringIsNullOrEmpty(dialCode) {
            return dialCode
        }
        let country = Country.getCurrentCountry()
        if let countryCode = country?.dialCode {
            return countryCode
        }
        return "+971"
    }
    
    class func getCurrentCountryName() -> String {
        let country = Country.getCurrentCountry()
        let countryCode = APPSESSION.userDetail?._countryCode ?? "+971"
        if let countryName = Locale.current.localizedString(forRegionCode: (Utils.getCountryCode(for: countryCode) ?? country?.code) ?? "AE") {
            return countryName
        }
        return "United Arab Emirates"
    }
    
    // --------------------------------------
    // MARK: Generate QR image
    // --------------------------------------
    
    class func generateQRCode(from content: String, with size: CGSize) -> UIImage? {
        if let qrCodeFilter = CIFilter(name: "CIQRCodeGenerator") {
            let data = content.data(using: String.Encoding.utf8)
            qrCodeFilter.setValue(data, forKey: "inputMessage")
            if let qrCodeCIImage = qrCodeFilter.outputImage {
                let scaleX = size.width / qrCodeCIImage.extent.size.width
                let scaleY = size.height / qrCodeCIImage.extent.size.height
                let transformedImage = qrCodeCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
                let qrCodeImage = UIImage(ciImage: transformedImage)
                return qrCodeImage
            }
        }
        return nil
    }
    
    
    // --------------------------------------
    // MARK: Story Viewed Check
    // --------------------------------------
    
    class func saveViewedStory(id: String) {
        var cellIds = UserDefaults.standard.array(forKey: "storyIds") as? [String] ?? []
        cellIds.append(id)
        UserDefaults.standard.set(cellIds, forKey: "storyIds")
    }
    
    class func getViewedStories() -> [String] {
        return UserDefaults.standard.array(forKey: "storyIds") as? [String] ?? []
    }
    
    class func discountPercent(originalPrice: Double, discountedPrice: Double) -> Int? {
        let discountPercent = ((originalPrice - discountedPrice) / originalPrice) * 100
        return  Int(discountPercent)
    }
    
    class func calculateDiscountValue(originalPrice: Int?, discountPercentage: Int?) -> String {
        guard let discountPercentage = discountPercentage else {
            guard let originalPrice = originalPrice else { return "" }
            return String(originalPrice)
        }
        guard let originalPrice = originalPrice else { return "" }
        let discount = originalPrice * discountPercentage / 100
        let discountValue = Int(discount)
        let price = originalPrice - discountValue
        return String(price)
    }
    
    class func calculateDiscountValueInt(originalPrice: Int?, discountPercentage: Int?) -> Int {
        guard let discountPercentage = discountPercentage else {
            guard let originalPrice = originalPrice else { return 0 }
            return originalPrice
        }
        guard let originalPrice = originalPrice else { return 0 }
        let discount = originalPrice * discountPercentage / 100
        let discountValue = Int(discount)
        let price = originalPrice - discountValue
        return price
    }
    
    class func calculateDiscountValueFloat(originalPrice: Int?, discountPercentage: Int?) -> Float {
        guard let discountPercentage = discountPercentage else {
            guard let originalPrice = originalPrice else { return 0 }
            return Float(originalPrice)
        }
        guard let originalPrice = originalPrice else { return 0 }
        let discount = Float(originalPrice) * Float(discountPercentage) / 100
        let discountValue = discount
        let price = Float(originalPrice) - discountValue
        return Float(price)
    }
    
    class func calculateDiscountValueDouble(originalPrice: Double?, discountPercentage: Int?) -> Double {
        guard let discountPercentage = discountPercentage else {
            return originalPrice ?? 0.0
        }
        guard let originalPrice = originalPrice else {
            return 0.0
        }
        let discount = originalPrice * Double(discountPercentage) / 100.0
        let price = originalPrice - discount
        return price
    }
    
    class func calculateRefundAmount(amount: Double, policies: [TourPolicyModel]) -> Double? {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        for policy in policies {
            if
                let fromDate = dateFormatter.date(from: policy.fromDate),
                let toDate = dateFormatter.date(from: policy.toDate) {
                
                if currentDate >= fromDate && currentDate <= toDate {
                    let refundAmount = amount * Double(policy.refundPercentage) / 100.0
                    return refundAmount
                }
            }
        }
        
        return nil
    }
    
    class func calculateRefundAmount(amount: Double, policies: [JPCancellationPolicyModel]) -> Double? {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for policy in policies {
            if
                let fromDate = dateFormatter.date(from: policy.dateFrom),
                let toDate = dateFormatter.date(from: policy.DateTo) {
                
                if (currentDate >= fromDate && currentDate <= toDate) || (fromDate > currentDate && currentDate <= toDate) {
                    let percent = 100 - Double(Int(policy.percentPrice) ?? 0)
                    let refundAmount = amount * percent / 100.0
                    return refundAmount
                }
            }
        }
        
        return nil
    }
    
    class func isNonRefundable(policies: [TourPolicyModel]) -> Bool {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        for policy in policies {
            if
                let fromDate = dateFormatter.date(from: policy.fromDate),
                let toDate = dateFormatter.date(from: policy.toDate) {
                
                if currentDate >= fromDate && currentDate <= toDate {
                    return policy.refundPercentage == 0
                }
            }
        }
        return false
    }

    class func isHotelNonRefundable(policies: [JPCancellationPolicyModel]) -> Bool {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for policy in policies {
            if let fromDate = dateFormatter.date(from: policy.dateFrom), let toDate = dateFormatter.date(from: policy.DateTo) {
                
                if currentDate >= fromDate && currentDate <= toDate {
                    if let percent = Int(policy.percentPrice) {
                        return percent == 100
                    }
                }
            }
        }
        return false
    }

    
    class func getVisibleViewController(from viewController: UIViewController?) -> UIViewController? {
        
        if let navigationController = viewController as? UINavigationController {
            // If the current view controller is a navigation controller, get its top view controller.
            return getVisibleViewController(from: navigationController.topViewController)
        } else if let tabBarController = viewController as? UITabBarController {
            // If the current view controller is a tab bar controller, get the selected view controller.
            return getVisibleViewController(from: tabBarController.selectedViewController)
        } else if let presentedViewController = viewController?.presentedViewController {
            // If the current view controller has a presented view controller, get the presented view controller.
            return getVisibleViewController(from: presentedViewController)
        } else {
            // This is the currently visible view controller.
            return viewController
        }
    }
    
    class func getRootViewController(from viewController: UIViewController?) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            // If the current view controller is a navigation controller, get its root view controller.
            return getRootViewController(from: navigationController.viewControllers.first)
        } else if let tabBarController = viewController as? UITabBarController {
            // If the current view controller is a tab bar controller, get the first view controller of its selected tab.
            return getRootViewController(from: tabBarController.selectedViewController)
        } else if let presentedViewController = viewController?.presentedViewController {
            // If the current view controller has a presented view controller, get the root of the presented view controller.
            return getRootViewController(from: presentedViewController)
        } else {
            // This is the root/base view controller.
            return viewController
        }
    }
    
    class func openViewController(_ vc: UIViewController) {
        guard let rootVc = APP.window?.rootViewController else { return }
        if let visibleVc = Utils.getVisibleViewController(from: rootVc) {
            if let nav = visibleVc.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                guard let presentedController = visibleVc.presentedViewController else {
                    visibleVc.present(vc, animated: true, completion: nil)
                    return
                }
                presentedController.present(vc, animated: true, completion: nil)
            }
        } else {
            if let nav = rootVc.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                guard let presentedController = rootVc.presentedViewController else {
                    rootVc.present(vc, animated: true, completion: nil)
                    return
                }
                presentedController.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    class func pushViewController(_ vc: UIViewController) {
        guard let rootVc = APP.window?.rootViewController else { return }
        
        func safePushOrPresent(from source: UIViewController) {
            if let nav = source.navigationController {
                nav.pushViewController(vc, animated: true)
            } else if let nav = source as? UINavigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                // Fallback: Present wrapped in NavigationController
                let navWrapper = UINavigationController(rootViewController: vc)
                navWrapper.modalPresentationStyle = .fullScreen
                
                if let baseVc = vc as? BaseViewController {
                    baseVc.isModal = true
                }
                
                source.present(navWrapper, animated: true, completion: nil)
            }
        }

        if let visibleVc = Utils.getVisibleViewController(from: rootVc) {
            safePushOrPresent(from: visibleVc)
        } else {
            safePushOrPresent(from: rootVc)
        }
    }
    
    class func presentViewController(_ vc: UIViewController) {
        guard let rootVc = APP.window?.rootViewController else { return }
        
        if let visibleVc = Utils.getVisibleViewController(from: rootVc) {
            visibleVc.present(vc, animated: true, completion: nil)
        } else {
            rootVc.present(vc, animated: true, completion: nil)
        }
    }
    
    class func getCurrentVC() -> UIViewController? {
        guard let rootVc = APP.window?.rootViewController else { return nil }
        
        if let visibleVc = Utils.getVisibleViewController(from: rootVc) {
            return visibleVc
        } else {
            return rootVc
        }
    }
    
    class func generateDynamicLinks(controller: UIViewController?, venueDetailModel: VenueDetailModel?) {
        guard let controller = controller else { return }
        guard let venueModel = venueDetailModel else { return }
        var params: [String: Any] = [:]
        params["title"] = venueModel.name
        params["description"] = venueModel.about.isEmpty ? venueModel.address : venueModel.about
        params["image"] = venueModel.cover
        params["itemId"] = venueModel.id
        params["itemType"] = "venue"
        WhosinServices.createDynamicLink(params: params) {  container, error in
            guard let data = container else { return }
            let shareMessage = "\(venueModel.name) \n\n \(venueModel.about) \n\n \(data.data)"
            let items = [shareMessage]
            let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityController.setValue(kAppName, forKey: "subject")
            activityController.popoverPresentationController?.sourceView = controller.view
            activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
            controller.present(activityController, animated: true, completion: nil)
        }
    }
    
    class func generateDynamicLinksForPromoterEvent(controller: UIViewController?, model: PromoterEventsModel?) {
        guard let controller = controller else { return }
        if let vc = controller as? BaseViewController {
            vc.showHUD()
        }
        guard let event = model else { return }
        var params: [String: Any] = [:]
        params["title"] = event.venueType == "venue" ? event.venue?.name : event.customVenue?.name
        let requirements = event.requirementsAllowed.isEmpty ? "" : "\n\nRequirements:\n • " + event.requirementsAllowed.joined(separator: "\n • ")
        let benefits = event.benefitsIncluded.isEmpty ? "" : "\n\nBenefits:\n • " + event.benefitsIncluded.joined(separator: "\n • ")
        params["description"] = event.descriptions
        params["image"] = event.venueType == "venue" ? event.venue?.cover : event.customVenue?.image
        params["itemId"] = event.id
        params["itemType"] = "promoter-event"
        WhosinServices.createDynamicLink(params: params) {  container, error in
            if let vc = controller as? BaseViewController {
                vc.hideHUD()
            }
            guard let data = container else { return }
            let shareMessage = "\(event.venueType == "venue" ? event.venue?.name ?? "" : event.customVenue?.name ?? "") \n \(event.descriptions + requirements + benefits) \n\n \(data.data)"
            let items: [Any] = [shareMessage]
            let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityController.setValue(kAppName, forKey: "subject")
            activityController.popoverPresentationController?.sourceView = controller.view
            activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
            controller.present(activityController, animated: true, completion: nil)
        }
    }
    
    class func generateDynamicLinks(venueDetailModel: VenueDetailModel?, completion: @escaping (String?, Error?) -> Void) {
        guard let venueModel = venueDetailModel else { return }
        var params: [String: Any] = [:]
        params["title"] = venueModel.name
        params["description"] = venueModel.about.isEmpty ? venueModel.address : venueModel.about
        params["image"] = venueModel.cover
        params["itemId"] = venueModel.id
        params["itemType"] = "venue"
        WhosinServices.createDynamicLink(params: params) {  container, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = container else { return }
            let shareMessage = "\(venueModel.name) \n\n \(venueModel.about) \n\n \(data.data)"
            completion(shareMessage, nil)
        }
    }
    
    class func generateDynamicLinksTicket(ticketModel: TicketModel?, completion: @escaping (String?, Error?) -> Void) {
        guard let ticket = ticketModel else { return }
        var desciption = ticket.descriptions.htmlToAttributedString()?.string ?? ""
        if desciption.count > 150 {
            desciption = String(desciption.prefix(150)) + "..."
        }
        var params: [String: Any] = [:]
        params["title"] = ticket.title
        params["description"] = desciption
        params["image"] = ticket.images.filter({ !Utils.isVideo($0) } ).first
        params["itemId"] = ticket._id
        params["itemType"] = "ticket"
        WhosinServices.createDynamicLink(params: params) {  container, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = container else { return }
            let shareMessage = "\(ticket.title) \n\n \(desciption) \n\n \(data.data)"
            completion(shareMessage, nil)
        }
    }
    
    
    class func generateDynamicLinksForUser(controller: UIViewController?, userDetail: UserDetailModel) {
        guard let controller = controller else { return }
        var params: [String: Any] = [:]
        params["title"] = userDetail.fullName
        params["description"] = userDetail.bio
        params["image"] = userDetail.image
        params["itemId"] = userDetail.id
        params["itemType"] = "user"
        WhosinServices.createDynamicLink(params: params) {  container, error in
            
            guard let data = container else { return }
            let shareMessage = "\(userDetail.fullName) \n\n \(userDetail.bio) \n\n \(data.data)"
            let items = [shareMessage]
            let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityController.setValue(kAppName, forKey: "subject")
            activityController.popoverPresentationController?.sourceView = controller.view
            activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
            controller.present(activityController, animated: true, completion: nil)
        }
    }
    
    class func generateDynamicLinksForUser(userDetail: UserDetailModel, completion: @escaping (String?, Error?) -> Void) {
        var params: [String: Any] = [:]
        params["title"] = userDetail.fullName
        params["description"] = userDetail.bio
        params["image"] = userDetail.image
        params["itemId"] = userDetail.id
        params["itemType"] = "user"
        WhosinServices.createDynamicLink(params: params) {  container, error in
            
            guard let data = container else { return }
            let shareMessage = "\(userDetail.fullName) \n\n \(userDetail.bio) \n\n \(data.data)"
            completion(shareMessage, nil)
        }
    }
    
    class func generateDynamicLinksForJoinPlusOne(params: [String: Any], completion: @escaping (String?, Error?) -> Void) {
        WhosinServices.createDynamicLink(params: params) {  container, error in
            guard let data = container else { return }
            let shareMessage = "You're Invited to Plus One! \n\n Click the link to join my Plus One group and become part of something exciting! Let’s get started! \n\n \(data.data)"
            completion(shareMessage, nil)
        }
    }
    
    class func generateDynamicLinksForOffer(offer: OffersModel, completion: @escaping (String?, Error?) -> Void) {
        var params: [String: Any] = [:]
        params["title"] = offer.title
        params["description"] = offer.descriptions
        params["image"] = offer.image
        params["itemId"] = offer.id
        params["itemType"] = "offer"
        WhosinServices.createDynamicLink(params: params) {  container, error in
            
            guard let data = container else { return }
            let shareMessage = "\(offer.title) \n\n \(offer.descriptions) \n\n \(data.data)"
            completion(shareMessage, nil)
        }
    }
    
    class func generateDynamicLinksForYachtOffer(offer: YachtOfferDetailModel, completion: @escaping (String?, Error?) -> Void) {
        var params: [String: Any] = [:]
        params["title"] = offer.title
        params["description"] = offer.descriptions
        params["image"] = offer.images.first
        params["itemId"] = offer.id
        params["itemType"] = "yacht"
        WhosinServices.createDynamicLink(params: params) {  container, error in
            
            guard let data = container else { return }
            let shareMessage = "\(offer.title) \n\n \(offer.descriptions) \n\n \(data.data)"
            completion(shareMessage, nil)
        }
    }
    
    class func generateDynamicLinksForClub(model: YachtClubModel?, completion: @escaping (String?, Error?) -> Void) {
        guard let model = model else { return }
        var params: [String: Any] = [:]
        params["title"] = model.name
        params["description"] = model.about.isEmpty ? model.address : model.about
        params["image"] = model.cover
        params["itemId"] = model.id
        params["itemType"] = "yachtClub"
        WhosinServices.createDynamicLink(params: params) {  container, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = container else { return }
            let shareMessage = "\(model.name) \n\n \(model.about) \n\n \(data.data)"
            completion(shareMessage, nil)
        }
    }
    
    class func generateDynamicLinksForPromoterEvent(model: PromoterEventsModel?, completion: @escaping (String?, Error?) -> Void) {
        guard let event = model else { return }
        var params: [String: Any] = [:]
        params["title"] = event.venueType == "venue" ? event.venue?.name : event.customVenue?.name
        let requirements = event.requirementsAllowed.isEmpty ? "" : "\n\nRequirements:\n • " + event.requirementsAllowed.joined(separator: "\n • ")
        let benefits = event.benefitsIncluded.isEmpty ? "" : "\n\nBenefits:\n • " + event.benefitsIncluded.joined(separator: "\n • ")
        params["description"] = event.descriptions
        params["image"] = event.venueType == "venue" ? event.venue?.logo : event.customVenue?.image
        params["itemId"] = event.id
        params["itemType"] = "promoter-event"
        WhosinServices.createDynamicLink(params: params) {  container, error in
            guard let data = container else { return }
            let shareMessage = "\(event.venueType == "venue" ? event.venue?.name ?? "" : event.customVenue?.name ?? "") \n \(event.descriptions + requirements + benefits) \n\n \(data.data)"
            completion(shareMessage, nil)
        }
    }
    
    class func formatDiscountValue(_ value: Float) -> String {
        return "\(Int(round(value)))"
    }
    
    class func checkIfWazeInstalled() -> Bool {
        let wazeURL = URL(string: "waze://")!
        if UIApplication.shared.canOpenURL(wazeURL) {
            return true
        } else {
            return false
        }
    }
    
    class func checkIfGoogleMapsInstalled() -> Bool {
        let googleMapsURL = URL(string: "comgooglemaps://")!
        if UIApplication.shared.canOpenURL(googleMapsURL) {
            return true
        } else {
            return false
        }
    }
    
    class func isVenueDetailEmpty(_ venueDetail: VenueDetailModel?) -> Bool {
        return venueDetail == nil
    }
    
    class func getDownloadedFileURL(fileName: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            return nil
        }
    }
    
    class func downloadVideo(_ url: URL) {
        let localUrl = Utils.getDownloadedFileURL(fileName: url.lastPathComponent)
        if (localUrl == nil) {
            URLSession.shared.downloadTask(with: url) { (location, response, error) in
                guard let location = location else {
                    if let error = error {
                        print("Failed to download video: \(error)")
                    }
                    return
                }
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
                
                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        return
                    }
                    try FileManager.default.moveItem(at: location, to: destinationURL)
                    print("Video downloaded successfully and saved at: \(destinationURL)")
                } catch {
                    print("Failed to save video: \(error)")
                }
            }.resume()
        }
    }
    
    class func isImageCached(with urlString: URL) -> Bool {
        if let cacheKey = SDWebImageManager.shared.cacheKey(for: urlString) {
            return SDImageCache.shared.diskImageDataExists(withKey: cacheKey)
        }
        return false
    }
    
    class func isNotificationPermissionGranted(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            var isAllowed = false
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                isAllowed = true
            case .denied, .notDetermined:
                isAllowed = false
            default:
                isAllowed = false
            }
            completion(isAllowed)
        }
    }
    
    class func isAllowNotification() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var isAllowed = false
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                isAllowed = true
            case .denied, .notDetermined:
                isAllowed = false
            default:
                isAllowed = false
            }
            semaphore.signal()
        }
        semaphore.wait()
        return isAllowed
    }
    
    
    class func isAllowContactAccess() -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized:
            return false
        case .denied, .notDetermined:
            return true
        default:
            return true
        }
    }
    
    class func addResolutionToURL(urlString: String, resolution: String) -> String {
        let pattern = "(\\.(jpg|jpeg|png|webp))$"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(urlString.startIndex..<urlString.endIndex, in: urlString)
            let result = regex.stringByReplacingMatches(
                in: urlString,
                options: [],
                range: range,
                withTemplate: "-\(resolution)$1"
            )
            return result
        } catch {
            print("Regex error: \(error)")
            return urlString
        }
    }


    
    @inline(never)
    class func convertHTMLToPlainText(from html: String) -> String {
        guard !html.isEmpty else { return kEmptyString }

        if !html.contains("<") {
            return html.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if !Thread.isMainThread {
            return DispatchQueue.main.sync {
                convertHTMLToPlainText(from: html)
            }
        }

        guard let data = html.data(using: .utf8, allowLossyConversion: false) else {
            return kEmptyString
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        return autoreleasepool {
            do {
                let attributedString = try NSAttributedString(
                    data: data,
                    options: options,
                    documentAttributes: nil
                )

                let text = attributedString.string
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                return text.isEmpty ? kEmptyString : text

            } catch {
                return stripHTMLUsingRegex(html)
            }
        }
    }

    private class func stripHTMLUsingRegex(_ html: String) -> String {
        let withoutTags = html.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )

        return withoutTags
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    
    static func plainTextToHTMLList(_ input: String) -> String {
        let lines = input.components(separatedBy: "\n")
        let liItems = lines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { "<li>\($0)</li>" }
            .joined()
        return "<ul>\(liItems)</ul>"
    }

    
    static func convertHTMLToAttributedString(from html: String) -> NSAttributedString? {
        guard !html.isEmpty else { return nil }

        var modifiedHTML = html

        if !html.contains("<") && html.contains("•") {
            let lines = html.components(separatedBy: .newlines)
            var bulletItems = [String]()

            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedLine.hasPrefix("•") {
                    let content = trimmedLine.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
                    bulletItems.append("<li>\(content)</li>")
                } else if !trimmedLine.isEmpty {
                    bulletItems.append("<p>\(trimmedLine)</p>")
                }
            }

            modifiedHTML = "<ul>\(bulletItems.joined())</ul>"
        }

        modifiedHTML = modifiedHTML
            .replacingOccurrences(of: "<p></p>", with: "")
            .replacingOccurrences(of: "<ul></ul>", with: "")
            .replacingOccurrences(of: "<ul><ul>", with: "<ul>")
            .replacingOccurrences(of: "</ul></ul>", with: "</ul>")
            .replacingOccurrences(of: "<br><br>", with: "<br>")

        modifiedHTML = modifiedHTML
            .replacingOccurrences(of: "<ul>", with: "")
            .replacingOccurrences(of: "</ul>", with: "")
            .replacingOccurrences(of: "<li>", with: "• ")
            .replacingOccurrences(of: "</li>", with: "<br>")
            .replacingOccurrences(of: "&nbsp;", with: " ") // clean non-breaking spaces

        guard let data = modifiedHTML.data(using: .utf8, allowLossyConversion: true) else { return nil }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        do {
            let attributedString = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)

            let font = FontBrand.SFregularFont(size: 14)
            let color = ColorBrand.white
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 5

            attributedString.addAttributes([
                .foregroundColor: color,
                .font: font,
                .paragraphStyle: paragraphStyle
            ], range: NSRange(location: 0, length: attributedString.length))

            return attributedString
        } catch {
            print("Error parsing HTML: \(error)")
            return nil
        }
    }



    
    
    
    class func calculateAge(from birthDateString: String, dateFormat: String = "yyyy-MM-dd") -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent locale
        
        guard let birthDate = dateFormatter.date(from: birthDateString) else {
            return nil // Invalid date string
        }
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
        return ageComponents.year
    }
    
    class func isValidLink(_ text: String) -> Bool {
        let urlPattern = #"((https|http)://)?(www\.)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/[\w-]*)*(\?[^\s]*)?"#
        let regex = try? NSRegularExpression(pattern: urlPattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex?.firstMatch(in: text, options: [], range: range) != nil
    }
    
    class func openURL(urlString: String) {
        var formattedURLString = urlString
        if !formattedURLString.lowercased().hasPrefix("http://") && !formattedURLString.lowercased().hasPrefix("https://") {
            formattedURLString = "https://\(formattedURLString)"
        }
        
        if let url = URL(string: formattedURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    class func calculateAge(from dateString: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let birthDate = dateFormatter.date(from: dateString) else {
            return nil
        }
        
        let currentDate = Date()
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
        
        return ageComponents.year
    }
    
    class func makePromoTitleText(
        discount: Double,
        promoCode: String,
        defaultFont: UIFont,
        dirhamFont: UIFont
    ) -> NSAttributedString {
        
        let amount = String(format: "%.2f", discount)
        let currency = Utils.getCurrentCurrencySymbol()
        let savedWith = "saved_with".localized()
        
        var formattedText: String
        
        switch LANGMANAGER.currentLanguage {
        case "hi":
            formattedText = "\(currency) \(amount) \(promoCode) \(savedWith)"
            
        case "de", "zh", "ar":
            formattedText = "\(currency) \(amount) \(savedWith) \(promoCode)"
            
        default:
            formattedText = "\(currency) \(amount) \(savedWith) \(promoCode)"
        }
        
        let attributed = NSMutableAttributedString(
            string: formattedText,
            attributes: [.font: defaultFont]
        )
        
        if APPSESSION.userDetail?.currency.uppercased() == "AED" || currency == "D" {
            if let range = formattedText.range(of: currency) {
                let nsRange = NSRange(range, in: formattedText)
                attributed.addAttribute(.font, value: dirhamFont, range: nsRange)
            }
        }
        
        return attributed
    }


    
    class func generateThumbnail(for videoURL: String) -> UIImage? {
        guard let url = URL(string: videoURL) else { return UIImage() }
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnailCGImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            let thumbnailImage = UIImage(cgImage: thumbnailCGImage)
            return thumbnailImage
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    class func getTotalPrice(_ price: Int, markup: Int, vat: Bool = false,vatPercentage: Int ) -> String {
        let markupAmount = (price * markup) / 100
        var totalPrice = price + markupAmount
        if vat {
            let vatAmount = (totalPrice * vatPercentage) / 100
            totalPrice += vatAmount
        }
        return "\(totalPrice)"
    }
    
    class func saveViewedStoryByVenue(venueId: String, storyId: String) {
        var viewedStories = UserDefaults.standard.dictionary(forKey: "viewedStories") as? [String: [String: TimeInterval]] ?? [:]
        let timestamp = Date().timeIntervalSince1970
        
        if var storiesForVenue = viewedStories[venueId] {
            storiesForVenue[storyId] = timestamp
            viewedStories[venueId] = storiesForVenue
        } else {
            viewedStories[venueId] = [storyId: timestamp]
        }
        UserDefaults.standard.set(viewedStories, forKey: "viewedStories")
    }
    
    class func getViewedStories(for venueId: String) -> [String: TimeInterval] {
        let viewedStories = UserDefaults.standard.dictionary(forKey: "viewedStories") as? [String: [String: TimeInterval]] ?? [:]
        return viewedStories[venueId] ?? [:]
    }
    
    class func isStoryViewed(venueId: String, storyId: String) -> Bool {
        let viewedStoriesForVenue = getViewedStories(for: venueId)
        return viewedStoriesForVenue[storyId] != nil
    }
    
    class func getNextUnviewedStoryIndex(venueId: String, stories: [StoryModel]) -> Int? {
        let viewedStories = getViewedStories(for: venueId)
        for (index, story) in stories.enumerated() {
            if viewedStories[story.id] == nil {
                return index
            }
        }
        return nil
    }
    
    class func setPriceLabel(
        label: CustomLabel,
        originalPrice: Double,
        discountedPrice: Double,
        isNeedSpace: Bool = false
    ) {
        let fullText = NSMutableAttributedString()
        let currency = Utils.getCurrentCurrencySymbol()
        let isAED = currency == "D"
        
        let originalFont = isAED ? FontBrand.dirhamText(size: 12) : FontBrand.SFregularFont(size: 12)
        let discountedFont = isAED ? FontBrand.dirhamText(size: 13) : FontBrand.SFregularFont(size: 13)
        
        if originalPrice > discountedPrice {
            let originalPriceStr = NSAttributedString(
                string: "\(currency)\(originalPrice.formattedDecimal())",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.white.withAlphaComponent(0.8),
                    .font: originalFont,
                    .baselineOffset: 0
                ]
            )
            fullText.append(originalPriceStr)
        }
        
        let discountedPriceStr = NSAttributedString(
            string: isNeedSpace ? " \(currency)\(discountedPrice.formattedDecimal())" : "\(currency)\(discountedPrice.formattedDecimal())",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.8),
                .font: discountedFont
            ]
        )
        
        fullText.append(discountedPriceStr)
        
        label.attributedText = fullText
    }

    
    class func convertMinutesToTime(_ minutes: String) -> String {
        let item = Int(minutes) ?? 0
        let hrs = item / 60
        let mins = item % 60
        return String(format: "%02d:%02d", hrs, mins)
    }

    class func getStaticMapURL(latitude: Double, longitude: Double) -> String {
        return "https://maps.googleapis.com/maps/api/staticmap?center=\(latitude),\(longitude)&zoom=15&size=400x400&maptype=roadmap&markers=color:red%7C\(latitude),\(longitude)&key=\(kGoogleMapKey)"
    }

    
    class func getAddressFromLatLng(lat: Double, lng: Double, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: lng)
            
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse Geocoding Error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                let address = [
                    placemark.subThoroughfare,  // Street number
                    placemark.thoroughfare,      // Street name
                    placemark.locality,          // City
                    placemark.postalCode,        // Zip code
                    placemark.country            // Country
                ].compactMap { $0 }.joined(separator: ", ")
                
                print("Address: \(address)")
                completion(address)
            } else {
                completion(nil)
                print("No address found")
            }
        }
    }
    
    class func parseRatio(_ ratio: String) -> CGFloat {
        let components = ratio.split(separator: ":").compactMap { CGFloat(Double($0) ?? 0.0) }
        if components.count == 2, components[1] != 0 {
            return components[0] / components[1]
        }
        return 1.0
    }
    
    class func isVideo(_ url: String) -> Bool {
        let videoExtensions = [".mp4", ".mov", ".avi", ".mkv"]
        return videoExtensions.contains { url.lowercased().hasSuffix($0) }
    }
    
    class func getActiveDays(from model: OperationDaysModel) -> String {
        var activeDays: [String] = []

        if model.monday == 1 { activeDays.append("Monday") }
        if model.tuesday == 1 { activeDays.append("Tuesday") }
        if model.wednesday == 1 { activeDays.append("Wednesday") }
        if model.thursday == 1 { activeDays.append("Thursday") }
        if model.friday == 1 { activeDays.append("Friday") }
        if model.saturday == 1 { activeDays.append("Saturday") }
        if model.sunday == 1 { activeDays.append("Sunday") }

//        if activeDays.isEmpty || activeDays.count == 0 {
//            return "All days"
//        }

        return activeDays.joined(separator: ", ")
    }

    class func getTransferName(_ id:Int) -> String{
        if id == 41865 {
            return "without_transfer".localized()
        } else if id == 41843 {
            return "sharing_transfer".localized()
        } else if id == 41844 {
            return "private_transfer".localized()
        } else if id == 43129 {
            return "private_boat_without_transfers".localized()
        } else if id == 43110 {
            return "pvt_yach_without_transfer".localized()
        } else if id == 271864 {
            return "quantity".localized()
        }
        return ""
    }
    
    class func checkMediaPermissionsAndPrompt(from viewController: BaseViewController,
                                         completion: @escaping (_ camera: Bool, _ photoLibrary: Bool, _ microphone: Bool) -> Void) {
        var cameraGranted = false
        var photoGranted = false
        var micGranted = false
        
        let group = DispatchGroup()

        // Camera
        group.enter()
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraGranted = true
            group.leave()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                cameraGranted = granted
                group.leave()
            }
        default:
            cameraGranted = false
            group.leave()
        }

        // Photo Library
        group.enter()
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            photoGranted = true
            group.leave()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if #available(iOS 14, *) {
                    photoGranted = (status == .authorized || status == .limited)
                } else {
                    photoGranted = (status == .authorized)
                }
                group.leave()
            }
        default:
            photoGranted = false
            group.leave()
        }

        // Microphone
        group.enter()
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            micGranted = true
            group.leave()
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                micGranted = granted
                group.leave()
            }
        default:
            micGranted = false
            group.leave()
        }

        // Handle result after all permissions checked
        group.notify(queue: .main) {
            if !cameraGranted {
                viewController.alert(
                    message: "camera_access_permission".localized(),
                    okActionTitle: "open_settings".localized(),
                    okHandler: { _ in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                )
            }

            if !photoGranted {
                viewController.alert(
                    message: "photo_library_access_permission".localized(),
                    okActionTitle: "open_settings".localized(),
                    okHandler: { _ in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                )
            }

            if !micGranted {
                viewController.alert(
                    message: "microphone_access_permission".localized(),
                    okActionTitle: "open_settings".localized(),
                    okHandler: { _ in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                )
            }

            completion(cameraGranted, photoGranted, micGranted)
        }
    }
    
    class func performHapticFeedback() {
        if #available(iOS 10.0, *), UIDevice.current.hasHapticSupport {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01 ) {
                AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate)
            }
        }
    }
    
    class func makeDirhamStyledText(text: String, dirhamFontSize: CGFloat = 14, labelFont: UIFont) -> NSAttributedString {
        let result = NSMutableAttributedString(
            string: " \(Utils.getCurrentCurrencySymbol())",
            attributes: [.font: APPSESSION.userDetail?.currency == "AED" || APPSESSION.userDetail?.currency == "D" ? FontBrand.dirhamText(size: dirhamFontSize) : FontBrand.SFboldFont(size: dirhamFontSize)]
        )
        
        let normalText = NSAttributedString(
            string: text,
            attributes: [.font: labelFont]
        )
        
        result.append(normalText)
        return result
    }

    class func addLog(screen: String, object: AdListModel) {
        Amplitude.instance().logEvent(screen, withEventProperties: object.toJSON())
    }
    
    class func getCurrentCurrencySymbol() -> String {
        var currency = APPSESSION.userDetail?.currency ?? "AED"
        if Utils.stringIsNullOrEmpty(currency) {
            currency = "AED"
        }
        if let symbol = APPSETTING.currencies.first(where: { $0.currency == currency })?.symbol {
            return symbol
        }
        let currencySymbols: [String: String] = [
            // Common Currencies
            "USD": "USD",     // US Dollar
            "EUR": "€",     // Euro
            "GBP": "£",     // British Pound
            "INR": "₹",     // Indian Rupee
            "JPY": "¥",     // Japanese Yen
            "CNY": "¥",     // Chinese Yuan
            "KRW": "₩",     // South Korean Won
            "RUB": "₽",     // Russian Ruble
            "AED": "D",    // UAE Dirham
            "SAR": "﷼",     // Saudi Riyal
            "QAR": "﷼",     // Qatari Riyal
            "OMR": "﷼",     // Omani Rial
            "KWD": "د.ك",    // Kuwaiti Dinar
            "BHD": ".د.ب",   // Bahraini Dinar
            
            // Americas
            "CAD": "$",     // Canadian Dollar
            "MXN": "$",     // Mexican Peso
            "BRL": "R$",    // Brazilian Real
            "ARS": "$",     // Argentine Peso
            "CLP": "$",     // Chilean Peso
            "COP": "$",     // Colombian Peso
            "PEN": "S/",    // Peruvian Sol
            "UYU": "$U",    // Uruguayan Peso
            
            // Europe
            "CHF": "CHF",   // Swiss Franc
            "SEK": "kr",    // Swedish Krona
            "NOK": "kr",    // Norwegian Krone
            "DKK": "kr",    // Danish Krone
            "PLN": "zł",    // Polish Zloty
            "CZK": "Kč",    // Czech Koruna
            "HUF": "Ft",    // Hungarian Forint
            "RON": "lei",   // Romanian Leu
            "BGN": "лв",    // Bulgarian Lev
            "HRK": "€",     // Croatia (now using Euro)
            
            // Middle East / Africa
            "EGP": "£",     // Egyptian Pound
            "ZAR": "R",     // South African Rand
            "NGN": "₦",     // Nigerian Naira
            "KES": "KSh",   // Kenyan Shilling
            "TZS": "TSh",   // Tanzanian Shilling
            "MAD": "DH",    // Moroccan Dirham
            "TND": "د.ت",    // Tunisian Dinar

            // Asia-Pacific
            "AUD": "$",     // Australian Dollar
            "NZD": "$",     // New Zealand Dollar
            "SGD": "$",     // Singapore Dollar
            "MYR": "RM",    // Malaysian Ringgit
            "THB": "฿",     // Thai Baht
            "IDR": "Rp",    // Indonesian Rupiah
            "VND": "₫",     // Vietnamese Dong
            "PHP": "₱",     // Philippine Peso
            "PKR": "₨",     // Pakistani Rupee
            "BDT": "৳",     // Bangladeshi Taka
            "LKR": "Rs",    // Sri Lankan Rupee
            "MMK": "K",     // Myanmar Kyat

            // Europe micro states
            "ISK": "kr",    // Icelandic Króna
            "GEL": "₾",     // Georgian Lari
            "AMD": "֏",     // Armenian Dram
            "AZN": "₼",     // Azerbaijani Manat
            "KZT": "₸",     // Kazakhstani Tenge
            "UZS": "so'm",  // Uzbekistani Som
            "TMT": "m",     // Turkmenistani Manat

            // Miscellaneous / Rare
            "ILS": "₪",     // Israeli Shekel
            "TRY": "₺",     // Turkish Lira
            "UAH": "₴",     // Ukrainian Hryvnia
            "BYN": "Br",    // Belarusian Ruble
            "BND": "$",     // Brunei Dollar
            "HKD": "$",     // Hong Kong Dollar
            "MOP": "P",     // Macanese Pataca
            "NPR": "₨",     // Nepalese Rupee
            "BWP": "P",     // Botswana Pula
            "ETB": "Br",    // Ethiopian Birr
            "GHS": "₵",     // Ghanaian Cedi
            "MWK": "MK",    // Malawian Kwacha
            "ZMW": "ZK",    // Zambian Kwacha
            "UGX": "USh",   // Ugandan Shilling
            "BBD": "$",     // Barbadian Dollar
            "TTD": "$",     // Trinidad Dollar
            "JMD": "$",     // Jamaican Dollar
            "BSD": "$",     // Bahamian Dollar
            "FJD": "$",     // Fijian Dollar
            "PGK": "K",     // Papua New Guinean Kina
            "WST": "T",     // Samoan Tala
            "TOP": "T$",    // Tongan Paʻanga
            "XPF": "₣",     // CFP Franc (Polynesia)
            "XOF": "CFA",   // West African CFA Franc
            "XAF": "FCFA",  // Central African CFA Franc
            "MUR": "₨",     // Mauritian Rupee
            "SCR": "₨"      // Seychelles Rupee


        ]
        return currencySymbols[currency] ?? currency
    }
    
    class func convertToAED(price: Double) -> Double {
        guard let rate = APPSETTING.currencies.first(where: { $0.currency == APPSESSION.userDetail?.currency })?.rate else {
            return price
        }
        return price / rate
    }

    class func convertCurrent(_ price: Double) -> Double {
        guard let rate = APPSETTING.currencies.first(where: { $0.currency == APPSESSION.userDetail?.currency })?.rate else {
            return price
        }
        return price * rate
    }
    
    class func isWhatsAppInstalled() -> Bool {
        let whatsappURL = URL(string: "whatsapp://send")!
        return UIApplication.shared.canOpenURL(whatsappURL)
    }

}

