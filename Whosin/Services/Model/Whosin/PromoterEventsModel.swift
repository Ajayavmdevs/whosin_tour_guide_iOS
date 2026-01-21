import Foundation
import ObjectMapper
import RealmSwift

class PromoterEventBaseModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    dynamic var events = List<PromoterEventsModel>()
    dynamic var users = List<UserDetailModel>()
    dynamic var venues = List<VenueDetailModel>()
    dynamic var circles = List<UserDetailModel>()
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["_id"]
        events <- (map["events"], ListTransform<PromoterEventsModel>())
        users <- (map["users"], ListTransform<UserDetailModel>())
        venues <- (map["venues"], ListTransform<VenueDetailModel>())
        circles <- (map["circles"], ListTransform<UserDetailModel>())
        populatePromoterEvents()
    }
    
    private func populatePromoterEvents() {
        let userDict = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
        let venueDict = Dictionary(uniqueKeysWithValues: venues.map { ($0.id, $0) })
        let circleDict = Dictionary(uniqueKeysWithValues: circles.map { ($0.id, $0) })
        
        for event in events {
            if let venue = venueDict[event.venueId] {
                event.venue = venue
            }
            
            let invitedCircles = event.invitedCirclesString.compactMap { circleDict[$0] }
            event.invitedCircles.append(objectsIn: invitedCircles)
            
            let invitedUsers = event.invitedUsers.toArrayDetached(ofType: UserDetailModel.self).compactMap { user in
                return userDict[user.userId]
            }
            event.invitedUsers.removeAll()
            event.invitedUsers.append(objectsIn: invitedUsers)
            
            let inUsers = event.inMembers.toArrayDetached(ofType: UserDetailModel.self).compactMap { user in
                return userDict[user.userId]
            }
            event.inMembers.removeAll()
            event.inMembers.append(objectsIn: inUsers)
            
            let interestedMembers = event.interestedMembers.toArrayDetached(ofType: UserDetailModel.self).compactMap { user in
                return userDict[user.userId]
            }
            event.interestedMembers.removeAll()
            event.interestedMembers.append(objectsIn: interestedMembers)
            
            let plusOneMembers = event.plusOneMembers.toArrayDetached(ofType: UserDetailModel.self).compactMap { user in
                return userDict[user.userId]
            }
            event.plusOneMembers.removeAll()
            event.plusOneMembers.append(objectsIn: plusOneMembers)
        }
    }

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }

}

class PromoterEventsModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var cloneId: String = kEmptyString
    @objc dynamic var eventId: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var venueType: String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var offerId: String = kEmptyString
    @objc dynamic var date: String = kEmptyString
    @objc dynamic var startTime: String =  kEmptyString
    @objc dynamic var endTime: String = kEmptyString
    @objc dynamic var dressCode: String = kEmptyString
    @objc dynamic var category: String = kEmptyString
    @objc dynamic var maxInvitee: Int = 0
    @objc dynamic var totalInMembers: Int = 0
    @objc dynamic var isEventFull: Bool = false
    dynamic var requirementsAllowed: List<String> = List<String>()
    dynamic var requirementsNotAllowed: List<String> = List<String>()
    dynamic var benefitsIncluded: List<String> = List<String>()
    dynamic var benefitsNotIncluded: List<String> = List<String>()
    dynamic var socialAccountsToMention = List<SocialAccountsModel>()
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var isDeleted: Bool = false
    @objc dynamic var createdAt: String = kEmptyString
    dynamic var invitedUser: List<String> = List<String>()
    @objc dynamic var user: UserDetailModel?
    @objc dynamic var venue: VenueDetailModel?
    @objc dynamic var offer: OffersModel?
    @objc dynamic var customVenue: VenueDetailModel?
    dynamic var invitedUsers = List<UserDetailModel>()
    dynamic var invitedCirclesString = List<String>()
    dynamic var invitedCircles = List<UserDetailModel>()
    dynamic var inMembers = List<UserDetailModel>()
    dynamic var interestedMembers = List<UserDetailModel>()
    dynamic var inviteCancelList = List<UserDetailModel>()
    @objc dynamic var invite: UserDetailModel?
    @objc dynamic var isWishlisted: Bool = false
    @objc dynamic var isConfirmationRequired: Bool = false
    @objc dynamic var invitedGender: String = kEmptyString
    @objc dynamic var repeatEvent: String = kEmptyString
    @objc dynamic var repeatDate: String = kEmptyString
    @objc dynamic var distance: Double = 0.0
    @objc dynamic var isHidden: Bool = false
    @objc dynamic var repeatCount: Int = 0
    @objc dynamic var maleSeats: Int = 0
    @objc dynamic var femaleSeats: Int = 0
    @objc dynamic var plusOneAccepted: Bool = false
    @objc dynamic var plusOneQty: Int = 0
    @objc dynamic var extraGuestType: String = kEmptyString
    @objc dynamic var extraGuestAge: String = kEmptyString
    @objc dynamic var extraGuestDressCode: String = kEmptyString
    @objc dynamic var extraGuestGender: String = kEmptyString
    @objc dynamic var extraGuestNationality: String = kEmptyString
    @objc dynamic var remainingSeats: Int = 0
    @objc dynamic var extraGuestMaleSeats: Int = 0
    @objc dynamic var extraGuestFemaleSeats: Int = 0
    @objc dynamic var extraSeatPreference: String = kEmptyString
    @objc dynamic var totalInvitedUsers: Int = 0
    @objc dynamic var totalInvitedCircles: Int = 0
    @objc dynamic var totalInterestedMembers: Int = 0
    dynamic var plusOneMembers = List<UserDetailModel>()
    dynamic var plusOneInvites = List<UserDetailModel>()
    @objc dynamic var selectAllUsers: Bool = false
    @objc dynamic var selectAllCircles: Bool = false
    @objc dynamic var spotCloseType: String = kEmptyString
    @objc dynamic var spotCloseAt: String = kEmptyString
    @objc dynamic var isSpotClosed: Bool = false
    @objc dynamic var repeatStartDate: String = kEmptyString
    @objc dynamic var repeatEndDate: String = kEmptyString
    dynamic var repeatDatesAndTime = List<RepeatDateAndTimeModel>()
    dynamic var repeatDays = List<String>()
    @objc dynamic var plusOneMandatory: Bool = false
    dynamic var eventGallery = List<String>()
    @objc dynamic var faq: String = kEmptyString
    @objc dynamic var paidPassType: String = kEmptyString
    @objc dynamic var paidPassId: String = kEmptyString

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        userId <- map["userId"]
        cloneId <- map["cloneId"]
        eventId <- map["eventId"]
        descriptions <- map["description"]
        image <- map["image"]
        type <- map["type"]
        venueType <- map["venueType"]
        venueId <- map["venueId"]
        offerId <- map["offerId"]
        date <- map["date"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        dressCode <- map["dressCode"]
        category <- map["category"]
        maxInvitee <- map["maxInvitee"]
        isEventFull <- map["isEventFull"]
        totalInMembers <- map["totalInMembers"]
        requirementsAllowed <- (map["requirementsAllowed"], StringListTransform())
        requirementsNotAllowed <- (map["requirementsNotAllowed"], StringListTransform())
        benefitsIncluded <- (map["benefitsIncluded"], StringListTransform())
        benefitsNotIncluded <- (map["benefitsNotIncluded"], StringListTransform())
        socialAccountsToMention <- (map["socialAccountsToMention"], ListTransform<SocialAccountsModel>())
        status <- map["status"]
        isDeleted <- map["isDeleted"]
        createdAt <- map["createdAt"]
        invitedUser <- (map["invitedUser"], StringListTransform())
        user <- map["user"]
        venue <- map["venue"]
        offer <- map["offer"]
        customVenue <- map["customVenue"]
        invitedUsers <- (map["invitedUsers"], ListTransform<UserDetailModel>())
        invitedCirclesString <- (map["invitedCircles"], StringListTransform())
        invitedCircles <- (map["invitedCircles"], ListTransform<UserDetailModel>())
        inMembers <- (map["inMembers"], ListTransform<UserDetailModel>())
        interestedMembers <- (map["interestedMembers"], ListTransform<UserDetailModel>())
        inviteCancelList <- (map["inviteCancelList"], ListTransform<UserDetailModel>())
        invite <- map["invite"]
        isWishlisted <- map["isWishlisted"]
        isConfirmationRequired <- map["isConfirmationRequired"]
        invitedGender <- map["invitedGender"]
        repeatEvent <- map["repeat"]
        repeatDate <- map["repeatDate"]
        distance <- map["distance"]
        isHidden <- map["isHidden"]
        repeatCount <- map["repeatCount"]
        maleSeats <- map["maleSeats"]
        femaleSeats <- map["femaleSeats"]
        plusOneAccepted <- map["plusOneAccepted"]
        plusOneQty <- map["plusOneQty"]
        extraGuestType <- map["extraGuestType"]
        extraGuestAge <- map["extraGuestAge"]
        extraGuestDressCode <- map["extraGuestDressCode"]
        extraGuestGender <- map["extraGuestGender"]
        extraGuestNationality <- map["extraGuestNationality"]
        remainingSeats <- map["remainingSeats"]
        extraGuestMaleSeats <- map["extraGuestMaleSeats"]
        extraGuestFemaleSeats <- map["extraGuestFemaleSeats"]
        extraSeatPreference <- map["extraSeatPreference"]
        plusOneMembers <- (map["plusOneMembers"], ListTransform<UserDetailModel>())
        plusOneInvites <- (map["plusOneInvites"], ListTransform<UserDetailModel>())
        totalInvitedUsers <- map["totalInvitedUsers"]
        totalInvitedCircles <- map["totalInvitedCircles"]
        totalInterestedMembers <- map["totalInterestedMembers"]
        selectAllUsers <- map["selectAllUsers"]
        selectAllCircles <- map["selectAllCircles"]
        spotCloseType <- map["spotCloseType"]
        spotCloseAt <- map["spotCloseAt"]
        isSpotClosed <- map["isSpotClosed"]
        repeatStartDate <- map["repeatStartDate"]
        repeatEndDate <- map["repeatEndDate"]
        repeatDatesAndTime <- (map["repeatDatesAndTime"], ListTransform<RepeatDateAndTimeModel>())
        repeatDays <- (map["repeatDays"], StringListTransform())
        plusOneMandatory <- map["plusOneMandatory"]
        eventGallery <- (map["eventGallery"], StringListTransform())
        faq <- map["faq"]
        paidPassType <- map["paidPassType"]
        paidPassId <- map["paidPassId"]
    }
    
    func toEventJSON() -> [String: Any] {
        var param: [String: Any] = [:]
        param["eventId"] = id
        param["description"] = descriptions
        param["type"] = type
        param["venueType"] = venueType
        param["date"] = date
        param["startTime"] = startTime
        param["endTime"] = endTime
        param["dressCode"] = dressCode
        param["maxInvitee"] = maxInvitee
        param["category"] = category
        if !Utils.stringIsNullOrEmpty(offerId) {
            param["offerId"] = offerId
        }
        param["cloneId"] = cloneId
        if !eventGallery.isEmpty {
            param["eventGallery"] = eventGallery.toArray(ofType: String.self).map { $0 }
        }
        
        if !requirementsAllowed.isEmpty {
            param["requirementsAllowed"] = requirementsAllowed.toArray(ofType: String.self).map { $0 }
        }
        if !requirementsNotAllowed.isEmpty {
            param["requirementsNotAllowed"] = requirementsNotAllowed.toArray(ofType: String.self).map { $0 }
        }
        if !benefitsIncluded.isEmpty {
            param["benefitsIncluded"] = benefitsIncluded.toArray(ofType: String.self).map { $0 }
        }
        if !benefitsNotIncluded.isEmpty {
            param["benefitsNotIncluded"] = benefitsNotIncluded.toArray(ofType: String.self).map { $0 }
        }
        if !socialAccountsToMention.isEmpty {
            param["socialAccountsToMention"] = socialAccountsToMention.toArrayDetached(ofType: SocialAccountsModel.self).toJSON()
        }
        if venueType == "venue" {
            param["venueId"] = Utils.stringIsNullOrEmpty(venueId) ? venue?.id : venueId
            param["image"] = Utils.stringIsNullOrEmpty(image) ? venue?.cover : image
        } else {
            param["customVenue"] = ["name": customVenue?.name ?? kEmptyString, "address": customVenue?.address ?? kEmptyString, "image": customVenue?.image ?? kEmptyString, "description": customVenue?.descriptions ?? kEmptyString]
        }
        if !invitedUsers.isEmpty {
            param["invitedUser"] = invitedUsers.toArrayDetached(ofType: UserDetailModel.self).map({ $0.userId })
        }
        if !invitedCircles.isEmpty {
            param["invitedCircles"] = invitedCircles.toArrayDetached(ofType: UserDetailModel.self).map({ $0.id })
        }
        param["isConfirmationRequired"] = isConfirmationRequired
        if type == "public" {
            param["invitedGender"] = invitedGender
        }
        param["repeat"] = repeatEvent
        param["repeatStartDate"] = repeatStartDate
        param["repeatEndDate"] = repeatEndDate
        if repeatEvent == "weekly" {
            param["repeatDays"] = repeatDays.toArray(ofType: String.self)
        }
        if repeatEvent == "specific-dates" || repeatEvent == "specific dates" {
            param["repeatDatesAndTime"] = repeatDatesAndTime.toArrayDetached(ofType: RepeatDateAndTimeModel.self)
        }
//        param["repeatCount"] = repeatCount
        if invitedGender == "both", type == "public" {
            param["femaleSeats"] = femaleSeats
            param["maleSeats"]  = maleSeats
        }
        param["plusOneAccepted"] = plusOneAccepted
        param["selectAllCircles"] = selectAllCircles
        param["selectAllUsers"] = selectAllUsers
        if plusOneAccepted {
            param["plusOneMandatory"] = plusOneMandatory
            param["plusOneQty"] = plusOneQty
            param["extraGuestType"] = extraGuestType
            if extraGuestType == "specific" {
                param["extraGuestAge"] = extraGuestAge
                param["extraGuestDressCode"] = extraGuestDressCode
                param["extraGuestNationality"] = extraGuestNationality
            }
            param["extraGuestGender"] = extraGuestGender
            if extraGuestGender == "both" {
                param["extraSeatPreference"] = extraSeatPreference
            }
            if extraGuestGender == "both" && extraSeatPreference == "specific" {
                param["extraGuestMaleSeats"] = extraGuestMaleSeats
                param["extraGuestFemaleSeats"] = extraGuestFemaleSeats
            }
        }
        param["spotCloseType"] = spotCloseType
        param["spotCloseAt"] = spotCloseAt
        if !Utils.stringIsNullOrEmpty(faq) {
            param["faq"] = faq
        }
        param["paidPassType"] = paidPassType
        if paidPassType == "override" {
            param["paidPassId"] = paidPassId
        }
        return param
    }
        
    func toEventJSONChat() -> [String: Any] {
        var param: [String: Any] = [:]
        param["eventId"] = id
        param["type"] = type
        param["venueType"] = venueType
        param["date"] = date
        param["startTime"] = startTime
        param["endTime"] = endTime
        param["status"] = status
        if venueType == "venue" {
            param["venueId"] = Utils.stringIsNullOrEmpty(venueId) ? venue?.id : venueId
            param["customVenue"] = ["name": venue?.name ?? kEmptyString, "address": venue?.address ?? kEmptyString, "image": venue?.cover ?? kEmptyString, "description": venue?.descriptions ?? kEmptyString, "logo":venue?.logo ]
        } else {
            param["customVenue"] = ["name": customVenue?.name ?? kEmptyString, "address": customVenue?.address ?? kEmptyString, "image": customVenue?.image ?? kEmptyString, "description": customVenue?.descriptions ?? kEmptyString]
        }
        param["isConfirmationRequired"] = isConfirmationRequired
        return param
    }
    
    public var isTwoHourRemaining: Bool {
        if let time = Utils.stringToDate("\(date) \(startTime)", format: kFormatDateTimeLocal) {
            let currentDate = Utils.localTimeZoneDate()
            let calendar = Calendar.current
            if let twoHoursBefore = calendar.date(byAdding: .hour, value: -2, to: time) {
                return currentDate >= twoHoursBefore
            }
        }
        return false
    }
    
    public var isSameTimeEvent: Bool {
        APPSETTING.InEventsList.contains(where: { "\($0.date) \($0.startTime)" == "\(date) \(startTime)" })
    }

    public var startingSoon: Date? {
        let fullDateString = "\(date) \(startTime)"
        return Utils.stringToDate(fullDateString, format: "yyyy-MM-dd HH:mm") 
    }
    
    public var lastAdded: Date? {
        return Utils.stringToDate(createdAt, format: kStanderdDate)
    }
    
    public var lastExpiredEvents: Date? {
        let fullDateString = "\(date) \(endTime)"
        return Utils.stringToDate(fullDateString, format: "yyyy-MM-dd HH:mm")
    }
    
    public var isNew: Bool {
        
        if !Utils.stringIsNullOrEmpty(cloneId) || invite?.inviteStatus == "in" {
            return false
        }

        guard let eventDate = Utils.stringToDate(createdAt, format: kStanderdDate) else {
            return false
        }
        
        let currentDate = Date()
        let sevenHoursAgo = currentDate.addingTimeInterval(-7 * 60 * 60)
        return eventDate > sevenHoursAgo && eventDate < currentDate
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

class RepeatDateAndTimeModel: Object, Mappable, ModelProtocol {
    
    @objc var date: String = kEmptyString
    @objc var startTime: String = kEmptyString
    @objc var endTime: String = kEmptyString

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        date <- map["date"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
    }

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

class SocialAccountsModel: Object, Mappable, ModelProtocol  {

    @objc var platform: String = kEmptyString
    @objc var account: String = kEmptyString
    @objc var title: String = kEmptyString
//    @objc var id: String = kEmptyString
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        platform <- map["platform"]
        account <- map["account"]
        title <- map["title"]
//        id <- map["_id"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

class InviteListModel: Object, Mappable, ModelProtocol  {
    dynamic var invitedUsers = List<InvitedUserModel>()
    dynamic var inMembers = List<InvitedUserModel>()
    dynamic var interestedMembers = List<InvitedUserModel>()
    dynamic var inviteCancelList = List<InvitedUserModel>()
    dynamic var usersList = List<UserDetailModel>()

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        invitedUsers <- (map["invitedUsers"],ListTransform<InvitedUserModel>())
        inMembers <- (map["inMembers"],ListTransform<InvitedUserModel>())
        interestedMembers <- (map["interestedMembers"],ListTransform<InvitedUserModel>())
        inviteCancelList <- (map["inviteCancelList"],ListTransform<InvitedUserModel>())
        usersList <- (map["users"],ListTransform<UserDetailModel>())
        
    }

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

class InvitedUserModel: Object, Mappable, ModelProtocol  {
        @objc var id: String = kEmptyString
    @objc var eventId: String = kEmptyString
    @objc var userId: String = kEmptyString
    @objc var circleId: String = kEmptyString
    @objc var inviteStatus: String = kEmptyString
    @objc var promoterStatus: String = kEmptyString
    @objc var isCancelAfterConfirm: Bool = false
    dynamic var plusOneInvite = List<InvitedUserModel>()
    dynamic var logs = List<LogsModel>()
    @objc dynamic var user: UserDetailModel? = nil
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        eventId <- map["eventId"]
        userId <- map["userId"]
        circleId <- map["circleId"]
        inviteStatus <- map["inviteStatus"]
        promoterStatus <- map["promoterStatus"]
        isCancelAfterConfirm <- map["isCancelAfterConfirm"]
        plusOneInvite <- (map["plusOneInvite"],ListTransform<InvitedUserModel>())
        logs <- (map["logs"],ListTransform<LogsModel>())
    }
    
    
    func getUser(_ list: [UserDetailModel]) -> UserDetailModel? {
        if let existingUser = user {
            return existingUser
        }
        
        if let matchedUser = list.first(where: { $0.id == userId }) {
            self.user = matchedUser
            return matchedUser
        }
        
        return nil
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

class LogsModel: Object, Mappable, ModelProtocol  {
    
    @objc var id: String = kEmptyString
    @objc var type: String = kEmptyString
    @objc var subType: String = kEmptyString
    @objc var typeId: String = kEmptyString
    @objc var dateTime: Date = Date()
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: "yyyy-MM-dd'T'HH:mm:ss")
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        type <- map["type"]
        subType <- map["subType"]
        typeId <- map["typeId"]
        dateTime <- (map["dateTime"], DateFormatterTransform(dateFormatter: _dateFormatter))
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}
