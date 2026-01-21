import Foundation
import ObjectMapper
import RealmSwift

public enum ComponentType : String {
    case offer = "offer"
    case venue = "venue"
    case slider = "slider"
    case video = "video"
    case custom = "custom-components"
    case customVenue = "custom-venue"
    case customOffer = "custom-offer"
    case suggestedUsers = "suggested-users"
    case suggestedVenues = "suggested-venues"
    case ticketCategories = "ticket-category"
}

class HomeBlockModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kAppName
    @objc dynamic var title: String = kAppName
    @objc dynamic var showTitle: Bool = false
    @objc dynamic var descriptions: String = kAppName
    @objc dynamic var type: String = kAppName
    @objc dynamic var sliders: String = kAppName
    dynamic var venues = List<String>()
    dynamic var yachts = List<String>()
    dynamic var yachtOffer = List<String>()
    dynamic var nearByVenues = List<VenueDetailModel>()
    dynamic var customVenues = List<CustomVenuesModel>()
    dynamic var customOffers = List<CustomVenuesModel>()
    dynamic var videos = List<VideosModel>()
    dynamic var offers = List<String>()
    dynamic var ticketCategories = List<String>()
    dynamic var customComponents = List<CustomComponentModel>()
    dynamic var deals = List<DealsModel>()
    dynamic var myOutings = List<OutingListModel>()
    dynamic var activities = List<String>()
    dynamic var  events = List<String>()
    dynamic var users = List<UserDetailModel>()
    dynamic var membershipPackages = List<String>()
    @objc dynamic var size: SizeModel?
    @objc dynamic var visibilityStatus: Bool = false
    dynamic var venueList: [VenueDetailModel] = []
    dynamic var offerList: [OffersModel] = []
    dynamic var ticketCategoryList: [CategoryDetailModel] = []
    dynamic var activityList: [ActivitiesModel] = []
    dynamic var eventList: [EventModel] = []
    dynamic var videoList: [VideosModel] = []
    dynamic var myOutingsList: [OutingListModel] = []
    dynamic var dealsList: [DealsModel] = []
    dynamic var customVenuesList: [CustomVenuesModel] = []
    dynamic var customOffersList: [CustomVenuesModel] = []
    dynamic var membershipList: [MembershipPackageModel] = []
    dynamic var suggestedUsers = List<UserDetailModel>()
    dynamic var suggestedVenue = List<VenueDetailModel>()
    dynamic var yachtList: [YachtDetailModel] = []
    dynamic var yachtOfferList: [YachtOfferDetailModel] = []
    dynamic var promoterEvents = List<PromoterEventsModel>()
    dynamic var tickets = List<String>()
    dynamic var hotels = List<String>()
    dynamic var ticketList: [TicketModel] = []
    dynamic var cities = List<String>()
    dynamic var cityList: [CategoryDetailModel] = []
    dynamic var categories = List<String>()
    dynamic var categoryList: [CategoryDetailModel] = []
    dynamic var banners = List<String>()
    dynamic var bannerList: [ExploreBannerModel] = []
    dynamic var exploreVideoComponent: [ExploreBannerModel] = []
    dynamic var exploreCustomComponents = List<String>()
    dynamic var favoriteTicketIds = List<String>()
    @objc dynamic var color: String = kEmptyString
    @objc dynamic var backgroundImage: String = kEmptyString
    @objc dynamic var applicationStatus: String = kEmptyString
    @objc dynamic var shape: String = "rounded"
    dynamic var contactUsBlock: [ContactUsModel] = []

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    class func mediaTypePredicate(_ type: String) -> NSPredicate {
        NSPredicate(format: "type == %@", type)
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
        showTitle <- map["showTitle"]
        descriptions <- map["description"]
        type <- map["type"]
        nearByVenues <- (map["nearByVenues"], ListTransform<VenueDetailModel>())
        customVenues <- (map["customVenues"], ListTransform<CustomVenuesModel>())
        customOffers <- (map["customOffers"], ListTransform<CustomVenuesModel>())
        sliders <- map["sliders"]
        size <- map["size"]
        videos <- (map["videos"], ListTransform<VideosModel>())
        deals <- (map["deals"], ListTransform<DealsModel>())
        customComponents <- (map["customComponents"], ListTransform<CustomComponentModel>())
        users <- (map["users"], ListTransform<UserDetailModel>())
        myOutings <- (map["myOuting"], ListTransform<OutingListModel>())
        visibilityStatus <- map["visibilityStatus"]
        activities <- (map["activities"], StringListTransform())
        events <- (map["events"], StringListTransform())
        venues <- (map["venues"], StringListTransform())
        offers <- (map["offers"], StringListTransform())
        ticketCategories <- (map["ticketCategories"], StringListTransform())
        yachts <- (map["yachts"], StringListTransform())
        yachtOffer <- (map["yachtOffers"], StringListTransform())
        membershipPackages <- (map["membershipPackages"], StringListTransform())
        suggestedUsers <- (map["suggestedUsers"], ListTransform<UserDetailModel>())
        suggestedVenue <- (map["suggestedVenues"], ListTransform<VenueDetailModel>())
        promoterEvents <- (map["promoterEvents"], ListTransform<PromoterEventsModel>())
        tickets <- (map["tickets"], StringListTransform())
        hotels <- (map["hotels"], StringListTransform())
        cities <- (map["cities"], StringListTransform())
        categories <- (map["categories"], StringListTransform())
        banners <- (map["banners"], StringListTransform())
        exploreCustomComponents <- (map["customComponents"], StringListTransform())
        favoriteTicketIds <- (map["favoriteTicketIds"], StringListTransform())
        color <- map["color"]
        backgroundImage <- map["backgroundImage"]
        applicationStatus <- map["applicationStatus"]
        shape <- map["shape"]
        contactUsBlock <- map["contactUsBlock"]
    }
    
    var isVisible : Bool {
        switch cellType {
        case .venue, .venueSmall :
            if venues.isEmpty { return false }
            venueList.removeAll()
            venues.forEach { venueId in
                if let venue = APPSETTING.venueModel?.first(where: {$0.id == venueId}) {
                    venueList.append(venue)
                }
            }
            return !venueList.isEmpty
        case .offer:
            if offers.isEmpty { return false }
            offerList.removeAll()
            offers.forEach { offerId in
                if let offer = APPSETTING.offers?.first(where: {$0.id == offerId}), !offer._isExpired {
                    offerList.append(offer)
                }
            }
            return !offerList.isEmpty
        case .ticketCategories, .ticketCategoryRounded:
            if ticketCategories.isEmpty { return false }
            ticketCategoryList.removeAll()
            ticketCategories.forEach { offerId in
                if let category = APPSETTING.ticketCategories?.first(where: {$0.id == offerId}) {
                    ticketCategoryList.append(category)
                }
            }
            return !ticketCategoryList.isEmpty
        case .customVenue:
            if customVenues.isEmpty { return false }
            customVenuesList.removeAll()
            var isVisble = false
            customVenues.forEach{ customVenue in
                if let venueModel = APPSETTING.venueModel?.first(where: {$0.id == customVenue.venueId}) {
                    customVenue.venueModel = venueModel
                    customVenuesList.append(customVenue)
                    isVisble = true
                }
            }
            return isVisble
        case .customOffer:
            if customOffers.isEmpty { return false }
            customOffersList.removeAll()
            var isVisble = false
            customOffers.forEach { customOffer in
                if let offerModel = APPSETTING.offers?.first(where: {$0.id == customOffer.offerId}) {
                    customOffer.offerModel = offerModel
                    isVisble = true
                    customOffersList.append(customOffer)
                }
            }
            return isVisble
        case .customComponents:
            return !customComponents.isEmpty
        case .video:
            if let venueModel = APPSETTING.venueModel {
                let list = videos.toArrayDetached(ofType: VideosModel.self)
                let result = list.filter { v in
                    v.venueModel = APPSETTING.venueModel?.first(where: { $0.id == v.venueId })
                    v.ticketModel = APPSETTING.ticketList?.first(where: { $0._id == v.ticketId })
                    if !Utils.stringIsNullOrEmpty(v.ticketId),let ticketList = APPSETTING.ticketList  {
                        return ticketList.contains { $0._id == v.ticketId }
                    }
                    return venueModel.contains { $0.id == v.venueId }
                }
                videoList = result
                return !result.isEmpty
            }
            return false
        case .deal:
            if deals.isEmpty { return false }
            var isVisble = false
            dealsList.removeAll()
            deals.forEach { deal in
                if let venueModel = APPSETTING.venueModel?.first(where: {$0.id == deal.venueId}) {
                    deal.venueModel = venueModel
                    dealsList.append(deal)
                    isVisble = true
                }
            }
            return isVisble
        case .activity:
            if activities.isEmpty { return false }
            activityList.removeAll()
            activities.forEach { activityId in
                if let activity = APPSETTING.activities?.first(where: {$0.id == activityId}) {
                    if activity.provider != nil {
                        activityList.append(activity)
                    }
                }
            }
            return !activityList.isEmpty
        case .event:
            if events.isEmpty { return false }
            eventList.removeAll()
            events.forEach { eventId in
                if let event = APPSETTING.events?.first(where: {$0.id == eventId}) {
                    if event.venueDetail != nil && event.orgData != nil {
                        eventList.append(event)
                    }
                }
            }
            return !eventList.isEmpty
        case .nearBy:
            return false
        case .myOuting:
            myOutingsList = myOutings.toArrayDetached(ofType: OutingListModel.self)
            myOutingsList = myOutingsList.filter({ $0.owner != nil })
            return !myOutingsList.isEmpty
        case .userSuggested:
            return !suggestedUsers.isEmpty
        case .suggestedVenue:
            return !suggestedVenue.isEmpty
        case .membershipPackage:
            if membershipPackages.isEmpty { return false }
            membershipList.removeAll()
            membershipPackages.forEach { eventId in
                if let event = APPSETTING.membershipPackage?.first(where: {$0.id == eventId}) {
                    membershipList.append(event)
                }
            }
            return !membershipList.isEmpty
        case .yacht :
            if yachts.isEmpty { return false }
            yachtList.removeAll()
            yachts.forEach { yachtId in
                if let yacht = APPSETTING.yachtModel?.first(where: {$0.id == yachtId}) {
                    yachtList.append(yacht)
                }
            }
            return !yachtList.isEmpty
        case .yachtOffer:
            if yachtOffer.isEmpty { return false }
            yachtOfferList.removeAll()
            yachtOffer.forEach { yachtOfferId in
                if let yacht = APPSETTING.yachtOfferModel?.first(where: {$0.id == yachtOfferId}) {
                    yachtOfferList.append(yacht)
                }
            }
            return !yachtOfferList.isEmpty
        case .promoter:
            return true
        case .promoterEvents:
            return !promoterEvents.isEmpty
        case .ticket:
            if tickets.isEmpty {
                if hotels.isEmpty {
                    return false
                }
                ticketList.removeAll()
                hotels.forEach { ticketId in
                    if let ticket = APPSETTING.ticketList?.first(where: { $0._id == ticketId }) {
                        ticketList.append(ticket)
                    }
                }
                return !ticketList.isEmpty
            }
            ticketList.removeAll()
            tickets.forEach { ticketId in
                if let ticket = APPSETTING.ticketList?.first(where: { $0._id == ticketId }) {
                    ticketList.append(ticket)
                }
            }
            return !ticketList.isEmpty
        case .favoriteTicket:
            if favoriteTicketIds.isEmpty { return false }
            ticketList.removeAll()
            favoriteTicketIds.forEach { ticketId in
                if let ticket = APPSETTING.ticketList?.first(where: { $0._id == ticketId }) {
                    ticketList.append(ticket)
                }
            }
            return !ticketList.isEmpty
        case .cities:
            if cities.isEmpty { return false }
            cityList.removeAll()
            cities.forEach { id in
                if let city = APPSETTING.cityList?.first(where: { $0.id == id }) {
                    cityList.append(city)
                }
            }
            return !cityList.isEmpty
        case .banner, .bigCategory, .smallCategory:
            if banners.isEmpty { return false }
            bannerList.removeAll()
            banners.forEach { id in
                if let banner = APPSETTING.exploreBanners?.first(where: { $0.id == id }) {
                    bannerList.append(banner)
                }
            }
            return !bannerList.isEmpty
        case .singleVideo:
            if exploreCustomComponents.isEmpty { return false }
            exploreVideoComponent.removeAll()
            exploreCustomComponents.forEach { id in
                if let banner = APPSETTING.exploreBanners?.first(where: { $0.id == id }) {
                    exploreVideoComponent.append(banner)
                }
            }
            return !exploreVideoComponent.isEmpty
        case .contactUs:
            if contactUsBlock.isEmpty || (contactUsBlock.first?.isEnabled(screenName: .homeBlock) == false) { return false }
            return true
        default:
            return false
        }
    }
    
    func isVisibleForSearch(venue: [VenueDetailModel], offer: [OffersModel], activity: [ActivitiesModel], event: [EventModel], suggestedUsers: [UserDetailModel], ticket: [TicketModel]) -> Bool {
        switch cellTypeForSearch {
        case .offer:
            if offers.isEmpty { return false }
            offerList.removeAll()
            offers.forEach { offerId in
                if let offer = offer.first(where: {$0.id == offerId}), !offer._isExpired {
                    offerList.append(offer)
                }
            }
            return !offerList.isEmpty
        case .venue :
            if venues.isEmpty { return false }
            venueList.removeAll()
            venues.forEach { venueId in
                if let venue = venue.first(where: {$0.id == venueId}) {
                    venueList.append(venue)
                }
            }
            return !venueList.isEmpty
        case .activity:
            if activities.isEmpty { return false }
            activityList.removeAll()
            activities.forEach { activityId in
                if let venue = activity.first(where: {$0.id == activityId}) {
                    activityList.append(venue)
                }
            }
            return !activityList.isEmpty
        case .event:
            if events.isEmpty { return false }
            eventList.removeAll()
            events.forEach { eventId in
                if let venue = event.first(where: {$0.id == eventId}) {
                    eventList.append(venue)
                }
            }
            return !eventList.isEmpty
        case .ticket:
            if tickets.isEmpty { return false }
            ticketList.removeAll()
            tickets.forEach { ticketId in
                if let ticket = ticket.first(where: { $0._id == ticketId }) {
                    ticketList.append(ticket)
                }
            }
            return !ticketList.isEmpty
        case .userSuggested:
            return !suggestedUsers.isEmpty
        case .suggestedVenue:
            return !suggestedVenue.isEmpty
        case .contactUs:
            if contactUsBlock.isEmpty { return false }
            return true
        default:
            return false
        }
    }
    
    var isVisibleExplore: Bool {
        switch cellTypeForExplore {
        case .ticket:
            if tickets.isEmpty {
                if hotels.isEmpty {
                    return false
                }
                ticketList.removeAll()
                hotels.forEach { ticketId in
                    if let ticket = APPSETTING.ticketList?.first(where: { $0._id == ticketId }) {
                        ticketList.append(ticket)
                    }
                }
                return !ticketList.isEmpty
            }
            ticketList.removeAll()
            tickets.forEach { ticketId in
                if let ticket = APPSETTING.ticketList?.first(where: { $0._id == ticketId }) {
                    ticketList.append(ticket)
                }
            }
            return !ticketList.isEmpty
        case .video:
            if exploreCustomComponents.isEmpty { return false }
            exploreVideoComponent.removeAll()
            exploreCustomComponents.forEach { id in
                if let banner = APPSETTING.customComponent?.first(where: { $0.id == id }) {
                    exploreVideoComponent.append(banner)
                }
            }
            return !exploreVideoComponent.isEmpty
        case .cities:
            if cities.isEmpty { return false }
            cityList.removeAll()
            cities.forEach { id in
                if let city = APPSETTING.cityList?.first(where: { $0.id == id }) {
                    cityList.append(city)
                }
            }
            return !cityList.isEmpty
        case .categories, .reqtangleCategory:
            if categories.isEmpty { return false }
            categoryList.removeAll()
            categories.forEach { id in
                if let category = APPSETTING.exploreCategories?.first(where: { $0.id == id }) {
                    categoryList.append(category)
                }
            }
            return !categoryList.isEmpty
        case .banner, .bigCategory, .smallCategory:
            if banners.isEmpty { return false }
            bannerList.removeAll()
            banners.forEach { id in
                if let banner = APPSETTING.exploreBanners?.first(where: { $0.id == id }) {
                    bannerList.append(banner)
                }
            }
            return !bannerList.isEmpty
        case .contactUs:
            if contactUsBlock.isEmpty || contactUsBlock.first?.isEnabled(screenName: .exploreBlock) == false { return false }
            return true
        default:
            return false
        }
    }

    
    var cellTypeForSearch: HomeBlockCellType {
        if type == "venue" {
            return .venue
        } else if type == "offer" {
            return .offer
        } else if type == "event" {
            return .event
        } else if type == "activity" {
            return .activity
        } else if type == "suggested-users" {
            return .userSuggested
        } else if type == "suggested-venues" {
            return .suggestedVenue
        } else if type == "ticket" {
            return .ticket
        } else if type == "contact-us" {
            return .contactUs
        } else {
            return .none
        }
    }
    
    var cellTypeForExplore: ExploreCellType {
        if type == "ticket" {
            return .ticket
        } else if type == "city" {
            return .cities
        } else if type == "category" {
            return shape == "rectangular" ? .reqtangleCategory : .categories
        } else if type == "banner" {
            return .banner
        } else if type == "custom-component" {
            return .video
        } else if type == "ticket" {
            return .ticket
        } else if type == "big-category" {
            return .bigCategory
        } else if type == "small-category" {
            return .smallCategory
        } else if type == "juniper-hotel" {
            return .ticket
        } else if type == "contact-us" {
            return .contactUs
        } else {
            return .none
        }
    }
    
    var cellType: HomeBlockCellType {
        if type == "venue" {
            guard let type = size?.type else { return .venue }
            if type == "large" || type == "XXL" { return .venue }
            return .venueSmall
        } else if type == "offer" {
            return .offer
        } else if type == "event" {
            return .event
        } else if type == "video" {
            return .video
        } else if type == "custom-venue" {
            return .customVenue
        } else if type == "custom-offer" {
            return .customOffer
        } else if type == "custom-components" {
            return .customComponents
        } else if type == "deal" || type == "deals" {
            return .deal
        } else if type == "activity" {
            return .activity
        } else if type == "nearby" {
            return .nearBy
        } else if type == "my-outing" {
            return .myOuting
        } else if type == "suggested-users" {
            return .userSuggested
        } else if type == "suggested-venues" {
            return .suggestedVenue
        } else if type == "membership-package" {
            return .membershipPackage
        } else if type == "yacht" {
            return .yacht
        } else if type == "yacht-offer" {
            return .yachtOffer
        } else if type == "apply-ring" || type == "apply-promoter" {
            return .promoter
        } else if type == "promoter-events" {
            return .promoterEvents
        } else if type == "ticket" {
            return .ticket
        } else if type == "ticket-category" {
            return shape == "rectangular" ? .ticketCategories : .ticketCategoryRounded
        } else if type == "city" {
            return .cities
        } else if type == "big-category" {
            return .bigCategory
        } else if type == "small-category" {
            return .smallCategory
        } else if type == "custom-component" {
            return .singleVideo
        } else if type == "banner" {
            return .banner
        } else if type == "favorite_ticket" {
            return .favoriteTicket
        } else if type == "juniper-hotel" {
            return .ticket
        } else if type == "contact-us" {
            return .contactUs
        } else {
            return .none
        }
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}



class SizeModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var ratio: String = kEmptyString
    
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
        type <- map["type"]
        ratio <- map["ratio"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}
