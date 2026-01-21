import Foundation
import UIKit
import CoreTelephony
import DialCountries

public let kAppName = "WHOS’IN"
public let kScreenWidth = UIScreen.main.bounds.width
public let kScreenHeight = UIScreen.main.bounds.height
public let kEmptyString = ""
public let kBarButtonDefaultWidth: CGFloat = 24.0
public let kBarButtonDefaultHeight: CGFloat = 24.0
public let kNavigationBarDefaultHeight: CGFloat = 84.0
public let kJsonEncoding: String = "JSONENCODING"
public let kDefaultOperator: String = "="
public let kEmtpyJsonString: String = "{}"
public let kDefaultSpacing: CGFloat = 16.0
public let kCollectionDefaultMargin: CGFloat = 16.0
public let kCollectionDefaultSpacing: CGFloat = 8.0
public let kMaxDifferenceData: Int = 200
public let kShadowOpacityWidget: CGFloat = 0.2
public let kShadowOffsetWidget: CGSize = CGSize(width: 1.0, height: 1.0)
public let kCornerRadiusButton: CGFloat = 5.0
public let kCornerRadius: CGFloat = 8.0
public let kCornerRadius30: CGFloat = 30
public let kBorderWidth: CGFloat = 1.0
public let kShadowOpacity: CGFloat = 0.5
public let kShadowRadius: CGFloat = 1.0
public let kShadowOffset: CGSize = CGSize(width: 0.0, height: 1.0)
public let kShadowWireRadius: CGFloat = 2.0
public let kShadowWireOffset: CGSize = CGSize(width: 1.0, height: 3.0)
public let kShadowColor: UIColor = ColorBrand.white
public let kNavigationBarHeight: CGFloat = 44.0
public let kTableFooterSpinnerDefaultHeight: CGFloat = 60.0
public let kAnimationDuration: CGFloat = 1.0
public let kTypeSomething: String = "Type something..."
public var fileManager = FileManager()
public let kMapDefaultZoom: Double = 200
public let kAppId: String = "6463130137"
public let kOpenWebViewPackagePayment = Notification.Name("open_paymentUrl_webview")
public let kReloadBucketList = Notification.Name("reloadBucketList")
public let kRelaodActivitInfo = Notification.Name("activityInfoReload")
public let kReloadEventDetail = Notification.Name("reloadEventDetails")
public let kReloadContacts = Notification.Name("reloadContacts")
public let kReloadFollowStatus = Notification.Name("reloadFollowStatus")
public let kReloadComplementaryProfile = Notification.Name("reloadComplementaryProfile")

public let kChatListNotification = Notification.Name("chatList.notify")
public let kMessageNotification = Notification.Name("messageupdate.notify")
public let kUpdateMessageNotification = Notification.Name("messageupdate.notifyupdate")
public let kMessageCountNotification = Notification.Name("messageCountupdate.notify")
public let kTypingNotification = Notification.Name("messageupdate.typing")
public let kNewSquadNotification = Notification.Name("squadcreate.notify")
public let kWhosInNotification = Notification.Name("whosIn.notify")
public let kAudioPlayerEventNotification = Notification.Name("audioPlayerstatus.notify")
public let kCompleteProfileNotification = Notification.Name("profileComplete.notify")
public let kInAppNotification = Notification.Name("messageupdate.inappnotification")
public let kTwoStepAuthentication = Notification.Name("messageupdate.twostepauthentication")

public let kScocketEmitKey: String = "new_message"
public let kGoogleMapKey: String = "AIzaSyChoUrQiPueRcaggmExPj-drFBv3Wz1pE4"
public let kLiveAdminId: String = "65c0d6ad1ccb8aa07703d3aa"
public let kDevAdminId: String = "67e3ec4d073aaccac53fe908"

public var isMuteVideo:Bool = true

// --------------------------------------
// MARK: UITableView
// --------------------------------------

public let kCellTitleKey: String = "celltitle"
public let kCellInformationKey: String = "cellinformation"
public let kCellKeyboardType: String = "cellkeyboardtype"
public let kCellPlaceholderKey: String = "cellplaceholder"
public let kCellShowDisclosureIndicatorKey: String = "cellshowdisclosureindicator"
public let kCellStatusKey: String = "cellstatus"
public let kCellColorCodeKey: String = "cellstatuscolorcode"
public let kCellIconImageKey: String = "celliconimage"
public let kCellImageUrlKey: String = "cellimageurlkey"
public let kCellImageKey: String = "cellimagekey"
public let kCellIdentifierKey: String = "cellidentifier"
public let kCellAllowCacheKey: String = "cellallowcache"
public let kCellCacheKey: String = "cellcache"
public let kCellClickEffectKey: String = "cellclickeffect"
public let kCellIsSelectedKey: String = "cellisselected"
public let kCellNibNameKey: String = "cellnibname"
public let kCellClassKey: String = "cellclass"
public let kCellErrorMessageKey: String = "cellerrormessage"
public let kCellFontKey: String = "cellfont"
public let kCellHeightKey: String = "cellheight"
public let kCellWidthKey: String = "cellWidth"
public let kCellDifferenceIdentifierKey: String = "celldifferenceidentifier"
public let kCellDifferenceContentKey: String = "celldifferencecontent"
public let kCellObjectDataKey: String = "cellobjectdata"
public let kCellTagKey: String = "celltag"
public let kCellItemsKey: String = "items"
public let kCellLabelsKey: String = "labels"
public let kCellValuesKey: String = "values"
public let kCellVideoUrlKey: String = "videourlkey"
public let kCellVideoDateKey: String = "videoassetkey"
public let kCellButtonTitleKey: String = "cellbuttontitlekey"
public let kCellButtonBgColorKey: String = "cellbuttonbgcolorkey"
public let kCellEnabledKey: String = "cellenabledkey"
public let kCellDisableKey: String = "cellDisabledkey"
public let kCellTimerDelayKey: String = "cellTimerDelay"
public let kSectionTitleKey: String = "sectiontitle"
public let kSectionIconImageKey: String = "sectioniconimage"
public let kSectionRightInfoKey: String = "sectionRightInfo"
public let kSectionShowRightInforAsActionButtonKey: String = "showRightInfo"
public let kSectionRightTextColorKey: String = "sectionRightTextColor"
public let kSectionRightTextBgColor : String = "sectionRightTextBgColor"
public let kSectionBgColor: String = "sectionBgColorBgColor"
public let kSectionFontColor: String = "sectionFontColorFontColor"
public let kSectionFontSize: String = "sectionFontSizeFont"
public let kSectionSearchInputKey: String = "sectionsearchinput"
public let kSectionNeumorphismKey: String = "sectionNeumorphismKey"
public let kSectionReloadKey: String = "sectionReloadKey"
public let kSectionSearchInputPlaceholderKey: String = "sectionsearchinputplaceholder"
public let kSectionSearchInputButtonLblKey: String = "sectionsearchinputbtnlbl"
public let kSectionDataKey: String = "sectionvalue"
public let kSectionIdentifierKey: String = "sectionIdentifier"
public let kSectionCollapsedKey: String = "collapsed"
public let kSectionHeightKey: String = "sectionHeight"
public let kSectionTextAlignmentKey: String = "textalignment"
public let kSectionbarViewKey: String = "barview"
public let kHeaderFooterPadding: CGFloat = 16.0
public let kHeaderFooterHeight: CGFloat = 36.0
public let kHeaderSearchInnputLayoutHeight: CGFloat = 78.0
public let kSectionViewType = "sectionViewType"
public let kSectionOrientationType = "sectionOrientation"
public let kAvatarPlaceholder = UIImage(named: "icon_user_avatar_default")
public let kSectionGestureKey: String = "sectionGestureKey"


// --------------------------------------
// MARK: Date Format
// --------------------------------------
public let kFormatDateStandard: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
public let kStanderdDate: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
public let kFormatDate: String = "yyyy-MM-dd"
public let kFormatDateLocal: String = "dd/MM/yyyy"
public let kFormatDateDOB: String = "dd-MM-yyyy"
public let kFormatDateHourMinuteAM: String = "hh:mm a"
public let kFormatDateHourMinuteAMCopy: String = "h:mma"
public let kFormatDateDayLong: String = "EEEE"
public let kFormatDateDayShort: String = "E"
public let kFormatDateReview: String = "d MMM yyyy"
public let kFormatDateWithHourMinuteAM: String = "d MMM, h:mm a"
public let kFormatDateImageName: String = "yyyyMMddHHmmss"
public let kFormatDateDay: String = "dd"
public let kFormatDateMonth: String = "MMM"
public let kFormatDateMonthShort: String = "E\ndd\nMMM"
public let kFormatDateUS: String = "MM/dd/yyyy"
public let kFormatDateTimeUS: String = "HH:mm"
public let kFormatDateTimeLocal: String = "yyyy-MM-dd HH:mm"
public let kFormatEventDate: String = "E, d MMM yyyy"
public let kFormatMonthYearLong: String = "MMMM yyyy"
public let kChatTimeFormat: String = "dd/MM/yyyy HH:mm:ss"
public let kValidityDateTimeFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
public let kValidityPlanDateFormat = "dd MMM yyyy hh:mm a"
public let kValidityDateFormat = "dd MMM yyyy HH:mm"
public let kFormatDateWith24Hour: String = "d MMM, HH:mm"
public let kFormatDateWithouTimezone: String = "yyyy-MM-dd HH:mm:ss"
public let kFormatDateWithouTimezone2: String = "yyyy/MM/dd HH:mm:ss"

typealias ResultClosure = (_ result: Bool) -> Void

// --------------------------------------
// MARK: Preferences
// --------------------------------------

public let kPrefUsernameKey: String = "username"
public let kPrefPasswordKey: String = "password"
let kReloadStoryyNotification = Notification.Name("reloadStory")
let kopenVenueDetailNotification = Notification.Name("openVenueDetailFromStory")


// --------------------------------------
// MARK: Google
// --------------------------------------

public let GOOGLE_CLIENT_ID = "965402678086-bb6veb4ef80v8a8sf75v29mntff3qmlo.apps.googleusercontent.com"
public let GOOGLE_SERVER_ID = "965402678086-bb6veb4ef80v8a8sf75v29mntff3qmlo.apps.googleusercontent.com"
//public let ONESIGNAL_APP_ID = "49c1255d-2425-4e3a-97b0-79ad54e21ebb"

// --------------------------------------
// MARK: Tuples
// --------------------------------------

public typealias BottomSheetTupple = (tag: Int, title: String, icon: String?)
public typealias ShareSheetMessage = ()

// --------------------------------------
// MARK: Whosin
// --------------------------------------

public let kInviteMessage = "WHOS'IN\nCheck out WHOS'IN APP. I use it to browse through UAE's venues. Get it for free at\n\nhttps://onelink.to/826pb7"
public let contactsPermissionMessage = "contacts_permission_message".localized()


// --------------------------------------
// MARK: Common Macros
// --------------------------------------

func urls(for directory: FileManager.SearchPathDirectory) -> URL? {
    return fileManager.urls(for: directory, in: .userDomainMask).last
}

public var HOMEDIRECTORY: String {
    ProcessInfo.processInfo.environment["HOME"] ?? kEmptyString
}

public func LOCALIZED(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

public func LOCALIZEDFORMAT(_ key: String, _ args: [CVarArg]) -> String {
    return String(format: NSLocalizedString(key, comment: kEmptyString), locale: Locale.current, arguments: args)
}

public func INIT_CONTROLLER_XIB<T: UIViewController>(_ clazz: T.Type) -> T {
    print(clazz)
    return T.init(nibName: String(describing: clazz), bundle: nil)
}

public func FTRACE(_ message: String, file: String = #file, function: String = #function, line: Int = #line ) {
    #if DEBUG
        let url = NSURL(fileURLWithPath: file)
        print("\(Date.init()) CLASS=\(url.lastPathComponent ?? kEmptyString):\(line) | FUNC=\(function) | \(message) ")
    #endif
}

public func TRACE(_ message: String) {
    #if DEBUG
        print("\(Date.init()) \(message) ")
    #endif
}

public func DISPATCH_ASYNC_MAIN_AFTER(_ delay: Double, closure: @escaping () -> Void) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

public func DISPATCH_ASYNC_MAIN(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async(execute: closure)
}
public func DISPATCH_ASYNC_USER_INITIALIZED (_ closure: @escaping () -> Void) {
    DispatchQueue.global(qos: .userInitiated).async(execute: closure)
}
public func DISPATCH_ASYNC_BG(_ closure: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async(execute: closure)
}
public func DISPATCH_SYNC_BG(_ closure: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).sync(execute: closure)
}

public func DISPATCH_ASYNC_BG_AFTER(_ delay: Double, _ closure: @escaping () -> Void) {
    let when = DispatchTime.now() + delay
    DispatchQueue.global(qos: .background).asyncAfter(deadline: when, execute: closure)
}

//--------------------------------------
// MARK: MessageType enum
//--------------------------------------

public enum MessageType: String {
    case text
    case image
    case audio
    case venue
    case story
    case user
    case offer
    case yacht
    case yachtClub
    case promoterEvent
    case ticket
}

public enum AdSize {
    case none
    case small
    case medium
    case large
}

public enum ContactBlockScreens: String {
    case homeBlock = "homeBlock"
    case ticket = "ticket"
    case cart = "cart"
    case exploreBlock = "exploreBlock"
}

// --------------------------------------
// MARK: Common Protocols
// --------------------------------------
@objc
public
enum DataType: Int {
  case Number = 0
  case Email = 1
}

@objc
public
enum ActionType: Int {
    case none = 0
    case follow = 1
    case wishlist = 2
}

public enum ChatType: String {
    case user = "user"
    case bucket = "bucket"
    case event = "event"
    case outing = "outing"
    case yacht = "yacht"
    case promoterEvent = "promoter_event"
}

public enum RatingType: String {
    case activity = "activities"
    case venue = "venues"
    case eventsOrganizers = "events_organizers"
    case yachts = "yachts"
    case complimentary = "complimentary"
    case promoter = "promoter"
    case ticket = "ticket"
}

// --------------------------------------
// MARK: Gender enum
// --------------------------------------

public enum GenderType: String {
    case male = "male"
    case female = "female"
    case preferNotSay = "prefer not to say"
}

@objc
public
enum WhoActionType: Int {
    case cancel = 0
    case confirm = 1
    case iAmInOut = 2
    case view = 3
    case adminTransfer = 4
    case more = 5
}

@objc
public
protocol ActionButtonDelegate {
    @objc optional func cellValidate(_ isValid: Bool)
    @objc optional func cellTapped(_ tag: Int)
    @objc optional func buttonClicked(_ tag: Int)
    @objc optional func buttonClicked(tag: String, type: ActionType)
    @objc optional func buttonClicked(tag: String, status: String, type: WhoActionType)
}

struct PhoneHelper {
    static func getCountryCode() -> String {
        guard let carrier = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.values.first,
              let countryCode = carrier.isoCountryCode else { return "+" }
        let prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
        let countryDialingCode = prefixCodes[countryCode.uppercased()] ?? ""
        return "+" + countryDialingCode
    }
    
    static func getCountrySortCode(code: String) -> String {
        let numericCode = code.trimmingCharacters(in: CharacterSet(charactersIn: "+"))
        let prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]

        guard let country = prefixCodes.first(where: { $0.value == numericCode }) else {
            return ""
        }
        
        return country.key
    }

}
