import Foundation
import ObjectMapper
import RealmSwift

class EventModel: Object, Mappable, ModelProtocol, Identifiable {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var userType: String = kEmptyString
    @objc dynamic var orgId: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    dynamic var venueType: String = kEmptyString
    dynamic var reservationTime: String = kEmptyString
    @objc dynamic var venue: String = kEmptyString
    @objc dynamic var venueDetail: VenueDetailModel?
    @objc dynamic var eventTime: String = kEmptyString
    @objc dynamic var customVenue: CustomVenuesModel?
    @objc dynamic var eventImage: String = kEmptyString
    dynamic var packages = List<PackageModel>()
    @objc dynamic var package: PackageModel?
    @objc dynamic var orgData: VenueDetailModel?
    @objc dynamic var org: VenueDetailModel?
    @objc dynamic var eventsOrganizer: VenueDetailModel?
    dynamic var invitedGuest = List<InvitationModel>()
    dynamic var invitedUsers = List<InvitationModel>()
    @objc dynamic var invitedGuestCount: Int = 0
    @objc dynamic var extraGuestCount: Int = 0
    @objc dynamic var pendingGuestCount: Int = 0
    dynamic var admins: [String] = []
    @objc dynamic var myInvitationStatus: String = kEmptyString
    dynamic var inGuest = List<InvitationModel>()
    @objc dynamic var inGuestCount: Int = 0
    public var lastMsg: MessageModel?
    dynamic var members: List<String> = List<String>()
    dynamic var eventOrg = List<VenueDetailModel>()
    @objc dynamic var disclaimerDescription: String = kEmptyString
    @objc dynamic var disclaimerTitle: String = kEmptyString
    @objc dynamic var eventStatus: String = kEmptyString
    
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
        descriptions <- map["description"]
        userType <- map["user_type"]
        orgId <- map["org_id"]
        userId <- map["user_id"]
        type <- map["type"]
        venueType <- map["venueType"]
        venue <- map["venue"]
        venueDetail <- map["venue"]
        reservationTime <- map["reservation_time"]
        eventTime <- map["event_time"]
        customVenue <- map["custom_venue"]
        eventImage <- map["image"]
        packages <- (map["packages"], ListTransform<PackageModel>())
        orgData <- map["orgData"]
        invitedGuest <- (map["invitedGuests"], ListTransform<InvitationModel>())
        invitedUsers <- (map["invitedUsers"], ListTransform<InvitationModel>())
        invitedGuestCount <- map["invitedGuestsCount"]
        admins <- map["admins"]
        myInvitationStatus <- map["myInvitationStatus"]
        inGuest <- (map["inGuests"], ListTransform<InvitationModel>())
        inGuestCount <- map["inGuestsCount"]
        org <- map["org"]
        package <- map["package"]
        eventsOrganizer <- map["events_organizer"]
        eventOrg <- (map["eventOrg"], ListTransform<VenueDetailModel>())
        disclaimerDescription <- map["disclaimerDescription"]
        disclaimerTitle <- map["disclaimerTitle"]
        extraGuestCount <- map["extraGuestCount"]
        pendingGuestCount <- map["pendingGuestCount"]
        eventStatus <- map["event_status"]
    }
    
    

    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    var borderColor: UIColor {
        if myInvitationStatus.lowercased() == "in" {
            return ColorBrand.brandGreen
        } else if myInvitationStatus.lowercased() == "pending" {
            return ColorBrand.yellowColor
        } else {
            guard let userDetail = APPSESSION.userDetail else { return ColorBrand.brandBorderRed }
            if let user = invitedUsers.filter({ $0.userId == userDetail.id }).first {
                if user.inviteStatus.lowercased() == "in" {
                    return ColorBrand.brandGreen
                }
                else if user.inviteStatus.lowercased() == "pending" {
                    return ColorBrand.yellowColor
                }
            }
            return ColorBrand.brandBorderRed
        }
    }
    
    public var image: String {
        return Utils.addResolutionToURL(urlString: eventImage, resolution: "300")
    }

    var myInviteStatus: String {
        guard let userDetail = APPSESSION.userDetail else { return "out" }
        if let user = invitedUsers.filter({ $0.userId == userDetail.id }).first {
            if user.inviteStatus.lowercased() == "in" {
                return "in"
            }
            else if user.inviteStatus.lowercased() == "pending" {
                return "pending"
            }
        }
        return "out"
    }

    var _eventDate: String {
        return Utils.stringToDate(eventTime, format: kStanderdDate)?.display ?? ""
    }
    
    var _eventDay: String {
        return Utils.stringToDate(eventTime, format: kStanderdDate)?.day ?? ""
    }

    
    var _eventTime: String {
        return Utils.stringToDate(eventTime, format: kStanderdDate)?.timeOnly ?? ""
    }
    
    var _reservationTime: String {
        return Utils.stringToDate(reservationTime, format: kStanderdDate)?.display ?? ""
    }
    
    var eventTimeSlot: String {
        let reservatinDate = Utils.stringToDate(reservationTime, format: kStanderdDate)
        let eventDate = Utils.stringToDate(eventTime, format: kStanderdDate)
        return "\(Utils.dateToString(reservatinDate, format: kFormatDateTimeUS)) - \(Utils.dateToString(eventDate, format: kFormatDateTimeUS))"
    }

    public var isPackagewithzeroPrice: Bool {
        return packages.count == 1 ? packages.contains { $0.actualPrice == 0 && $0._flootdiscountedPrice == 0 } : false
    }
    
    public var _isEventExpired: Bool {
        return Utils.isDateExpired(dateString: eventTime, format: kStanderdDate)
    }
    
    public var isHideBuyButton: Bool {
        return packages.allSatisfy({ $0.isAllowSale == false }) ? true : packages.allSatisfy({ $0.remainingQty <= 0 })
    }

    var chatName: String {
        var name: String = kEmptyString
        if let orgName = orgData?.name {
            name = title + " - \(orgName)"
        } else if let orgName = org?.name {
            name = title + " - \(orgName)"
        } else if let orgName = eventsOrganizer?.name {
            name = title + " - \(orgName)"
        } else {
            name = title
        }

        return name
    }

    var chatHomeEventName: String {
        var name: String = kEmptyString
        if let eventVenue = venueDetail {
            name = eventVenue.name
        } else {
            name = customVenue?.title ?? kEmptyString
        }
        return name
    }

    var chatHomeOrgName: String {
        if let orgName = orgData?.name {
            return orgName
        } else if let orgName = org?.name {
            return orgName
        } else if let orgName = eventsOrganizer?.name {
            return orgName
        }
        return ""
    }

    var chatHomeOrgImage: String {
        if let orgName = orgData?.logo {
            return orgName
        } else if let orgName = org?.logo {
            return orgName
        } else if let orgName = eventsOrganizer?.logo {
            return orgName
        }
        return ""
    }

    var chatVenueId: String {
        var name: String = kEmptyString
        if let eventVenue = venueDetail {
            name = eventVenue.id
        } else {
            name = customVenue?.id ?? kEmptyString
        }
        return name
    }

    var chatOrgId: String {
        if let orgName = orgData?.id {
            return orgName
        } else if let orgName = org?.id {
            return orgName
        } else if let orgName = eventsOrganizer?.id {
            return orgName
        }
        return ""
    }

    func isValid() -> Bool {
        return true
    }
    
    var differenceIdentifier: String {
        return id
    }
    
    func isContentEqual(to source: EventModel) -> Bool {
        return self.id == source.id && self.chatHomeOrgName == source.chatHomeOrgName && self.image == source.image && self.lastMsg == source.lastMsg && self.title == source.title
    }
}

class InvitedGuestsModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var extraGuest: Int = 0
    @objc dynamic var invitedById: String = kEmptyString
    @objc dynamic var inviteStatus: String = kEmptyString
    @objc dynamic var updatedAt: String = kEmptyString
    @objc dynamic var user: UserModel?
    @objc dynamic var invitedBy: UserModel?

    // ---------------------------`-----------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        extraGuest <- map["extraGuest"]
        invitedById <- map["invitedBy"]
        inviteStatus <- map["inviteStatus"]
        updatedAt <- map["updatedAt"]
        user <- map["user"]
        invitedBy <- map["invited_by"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
