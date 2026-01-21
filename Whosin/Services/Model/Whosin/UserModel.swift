import UIKit
import DifferenceKit
import ObjectMapper
import DialCountries
import RealmSwift

class UserModel: Object, Mappable, ModelProtocol, Identifiable {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var firstName: String = kEmptyString
    @objc dynamic var lastName: String = kEmptyString
    @objc dynamic var deviceId: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var phone: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var token: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var invitedBy: UserModel?
    @objc dynamic var inviteStatus: String = kEmptyString
    @objc dynamic var follow: String = kEmptyString
    @objc dynamic var userDetail: UserDetailModel?
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    @objc dynamic var invitation: InvitationModel?
    @objc dynamic var email: String = kEmptyString
    @objc dynamic var countryCode: String = kEmptyString
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var isSignUp: Bool = false
    @objc dynamic var isVip: Bool = false
    @objc dynamic var isAuthenticationPending: Bool = false
    @objc dynamic var isManagePromoter: Bool = false
    @objc dynamic var promoterId: String = kEmptyString
    @objc dynamic var loginType: String = kEmptyString
    @objc dynamic var isGuest: Bool = false
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "userId"
    }
    
    class func idPredicate(_ id: String) -> NSPredicate {
        NSPredicate(format: "userId == %@", id)
    }
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        deviceId <- map["deviceId"]
        image <- map["image"]
        userId <- map["userId"]
        token <- map["token"]
        userDetail <- map["userDetail"]
        type <- map["type"]
        inviteStatus <- map["inviteStatus"]
        invitedBy <- map["invitedBy"]
        follow <- map["follow"]
        lat <- map["lat"]
        lng <- map["lng"]
        invitation <- map["invitation"]
        phone <- map["phone"]
        email <- map["email"]
        status <- map["status"]
        countryCode <- map["country_code"]
        isSignUp <- map["isSignUp"]
        isVip <- map["isVip"]
        isAuthenticationPending <- map["isAuthenticationPending"]
        isManagePromoter <- map["isManagePromoter"]
        promoterId <- map["promoterId"]
        loginType <- map["loginType"]
        isGuest <- map["isGuest"]

    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

class UserDetailModel: Object, Mappable, ModelProtocol, Differentiable, Identifiable {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var promoterId: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var countryCode: String = kEmptyString
    @objc dynamic var firstName: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var lastName: String = kEmptyString
    @objc dynamic var phone: String = kEmptyString
    @objc dynamic var photo: String = kEmptyString
    @objc dynamic var platform: String = kEmptyString
    @objc dynamic var socialId: String = kEmptyString
    @objc dynamic var socialPlatform: String = kEmptyString
    @objc dynamic var gender: String = kEmptyString
    @objc dynamic var email: String = kEmptyString
    @objc dynamic var enable: String = kEmptyString
    @objc dynamic var isSignUp: String = kEmptyString
    @objc dynamic var dateOfBirth: String = kEmptyString
    @objc dynamic var password: String = kEmptyString
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var updatedAt: String = kEmptyString
    @objc dynamic var nationality: String = kEmptyString
    @objc dynamic var follow: String = kEmptyString
    @objc dynamic var follower: Int = 0
    @objc dynamic var following: Int = 0
    @objc dynamic var isPhoneVerified: Int = 0
    @objc dynamic var isEmailVerified: Int = 0
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    @objc dynamic var location: LocationModel?
    @objc dynamic var bio: String = kEmptyString
    dynamic var mutualFriends = List<UserDetailModel>()
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var invitedBy: UserModel?
    @objc dynamic var inviteStatus: String = kEmptyString
    @objc dynamic var inviteId: String = kEmptyString
    @objc dynamic var invitation: InvitationModel?
    @objc dynamic var isVip: Bool = false
    @objc dynamic var token: String = kEmptyString
    @objc dynamic var isProfilePrivate: Bool = false
    @objc dynamic var isRequestPending: Bool = false
    @objc dynamic var isMembershipActive: Bool = false
    @objc dynamic var isTwoFactorActive: Bool = false
    @objc dynamic var facebook: String = kEmptyString
    @objc dynamic var instagram: String = kEmptyString
    @objc dynamic var youtube: String = kEmptyString
    @objc dynamic var tiktok: String = kEmptyString
    @objc dynamic var referralCode: String = kEmptyString
    @objc dynamic var address: String = kEmptyString
    dynamic var availabities = List<TimeSlot>()
    dynamic var images = List<String>()
    @objc dynamic var isPromoter: Bool = false
    @objc dynamic var isRingMember: Bool = false
    @objc dynamic var isGuest: Bool = false
    @objc dynamic var avatar: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var totalMembers: Int = 0
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var eventId: String = kEmptyString
    @objc dynamic var circleId: String = kEmptyString
    @objc dynamic var promoterStatus: String = kEmptyString
    @objc dynamic var myRingStatus: String = kEmptyString
    @objc dynamic var ringPromoterStatus: String = kEmptyString
    dynamic var members = List<UserDetailModel>()
    dynamic var circles = List<UserDetailModel>()
    @objc dynamic var circlesString: String = kEmptyString
    dynamic var ringMember: String = kEmptyString
    @objc dynamic var  banStatus: String = kEmptyString
    @objc dynamic var loginType: String = kEmptyString
    @objc dynamic var plusOneStatus: String = kEmptyString
    @objc dynamic var adminStatusOnPlusOne: String = kEmptyString
    @objc dynamic var plusOneRequestedAt: String = kEmptyString
    @objc dynamic var accountStatus: String = kEmptyString
    @objc dynamic var currency: String = "AED"
    @objc dynamic var lang: String = kEmptyString
    dynamic var roleAcess = List<NotificationModel>()
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    class func idPredicate(_ userId: String) -> NSPredicate {
        NSPredicate(format: "id == %@", userId)
    }
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    

    
    func mapping(map: Map) {
        id <- map["_id"]
        userId <- map["userId"]
        promoterId <- map["promoterId"]
        countryCode <- map["country_code"]
        firstName <- map["first_name"]
        image <- map["image"]
        lastName <- map["last_name"]
        isGuest <- map["isGuest"]
        phone <- map["phone"]
        photo <- map["photo"]
        platform <- map["platform"]
        socialId <- map["social_id"]
        socialPlatform <- map["social_platform"]
        gender <- map["gender"]
        email <- map["email"]
        enable <- map["enable"]
        isSignUp <- map["isSignUp"]
        dateOfBirth <- map["dateOfBirth"]
        password <- map["password"]
        createdAt <- map["createdAt"]
        updatedAt <- map["updatedAt"]
        nationality <- map["nationality"]
        follow <- map["follow"]
        follower <- map["follower"]
        following <- map["following"]
        location <- map["location"]
        isEmailVerified <- map["isEmailVerified"]
        isPhoneVerified <- map["isPhoneVerified"]
        lat <- map["lat"]
        lng <- map["lng"]
        bio <- map["bio"]
        status <- map["status"]
        type <- map["type"]
        inviteStatus <- map["inviteStatus"]
        inviteId <- map["inviteId"]
        invitedBy <- map["invitedBy"]
        invitation <- map["invitation"]
        isVip <- map["isVip"]
        mutualFriends <- (map["mutualFriends"], UserDetailListTransform())
        token <- map["token"]
        isProfilePrivate <- map["isProfilePrivate"]
        isRequestPending <- map["isRequestPending"]
        isMembershipActive <- map["isMembershipActive"]
        isTwoFactorActive <- map["isTwoFactorActive"]
        facebook <- map["facebook"]
        instagram <- map["instagram"]
        youtube <- map["youtube"]
        tiktok <- map["tiktok"]
        referralCode <- map["referralCode"]
        address <- map["address"]
        images <- (map["images"], StringListTransform())
        isPromoter <- map["isPromoter"]
        isRingMember <- map["isRingMember"]
        avatar <- map["avatar"]
        descriptions <- map["description"]
        totalMembers <- map["totalMembers"]
        title <- map["title"]
        eventId <- map["eventId"]
        circleId <- map["circleId"]
        promoterStatus <- map["promoterStatus"]
        myRingStatus <- map["myRingStatus"]
        ringPromoterStatus <- map["ringPromoterStatus"]
        members <- (map["members"], UserDetailListTransform())
        circles <- (map["circles"], UserDetailListTransform())
        circlesString <- map["circles"]
        ringMember <- map["ringMember"]
        banStatus <- map["banStatus"]
        loginType <- map["loginType"]
        plusOneStatus <- map["plusOneStatus"]
        adminStatusOnPlusOne <- map["adminStatusOnPlusOne"]
        plusOneRequestedAt <- map["plusOneRequestedAt"]
        accountStatus <- map["accountStatus"]
        currency <- map["currency"]
        lang <- map["lang"]
        roleAcess <- (map["roleAcess"], ListTransform<NotificationModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public var fullName : String {
        "\(firstName) \(lastName)"
    }
    
    public var statusImage: UIImage? {
        if inviteStatus == "pending" {
            return UIImage(named: "icon_invitePending")
        } else if inviteStatus == "out" {
            return UIImage(named: "icon_inviteOut")
        } else if inviteStatus == "in" {
            return UIImage(named: "icon_inviteIn")
        } else {
            return nil
        }
    }
    
    public var _countryCode: String {
        if countryCode.hasPrefix("+") {
            return countryCode
        } else {
            return Utils.stringIsNullOrEmpty(countryCode) ? "" : "+\(countryCode)"
        }
    }
    
    public var isNameEmpty: Bool {
        Utils.stringIsNullOrEmpty(fullName)
    }
    
    public func requiredFields() -> Bool {
        let isEmpty = email.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        bio.isEmpty ||
        dateOfBirth.isEmpty ||
        gender.isEmpty ||
        nationality.isEmpty ||
        instagram.isEmpty || image.isEmpty
        
        return isEmpty
    }
    
    public func requiredFieldsForPlusOne() -> (isEmpty: Bool, missingFields: [String]) {
        var missingFields = [String]()
        
        if instagram.isEmpty { missingFields.append("Instagram profile") }
        if image.isEmpty { missingFields.append("Profile picture") }
        if firstName.isEmpty { missingFields.append("name") }
        if lastName.isEmpty { missingFields.append("name") }
        if gender.isEmpty { missingFields.append("gender")}
        if nationality.isEmpty { missingFields.append("nationality")}
        if dateOfBirth.isEmpty { missingFields.append("date of birth")}
        
        return (!missingFields.isEmpty, missingFields)
    }
        
    func isValid() -> Bool {
        return !id.isEmpty
    }
    
    var differenceIdentifier: String {
        return id
    }
    
    func isContentEqual(to source: UserDetailModel) -> Bool {
        return self.id == source.id && self.firstName == source.firstName && self.image == source.image && self.follow == source.follow && self.isRequestPending == source.isRequestPending
    }
}

class ImageModel:Object, Mappable, ModelProtocol {
    
    @objc dynamic var url: String = kEmptyString
    @objc dynamic var fileName: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    dynamic var urlList: List<String> = List<String>()
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        url <- map["url"]
        urlList <- (map["url"], StringListTransform())
        fileName <- map["FileName"]
        type     <- map["Type"]


    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}


class TimeSlot: Object, Mappable, ModelProtocol  {
    
    @objc dynamic var fromDate: String = kEmptyString
    @objc dynamic var tillDate: String = kEmptyString

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    override init() {
        super.init()
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        fromDate <- map["fromDate"]
        tillDate <- map["tillDate"]
    }
    
    init(fromDate: String, tillDate: String) {
        super.init()
        self.fromDate = fromDate
        self.tillDate = tillDate
    }
    
    func toDictionary() -> [String: String] {
        return ["fromDate": fromDate, "tillDate": tillDate]
    }

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }

}
