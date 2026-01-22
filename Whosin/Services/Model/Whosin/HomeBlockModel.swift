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
    dynamic var videos = List<VideosModel>()
    dynamic var offers = List<String>()
    dynamic var ticketCategories = List<String>()
    dynamic var customComponents = List<CustomComponentModel>()
    dynamic var activities = List<String>()
    dynamic var  events = List<String>()
    dynamic var users = List<UserDetailModel>()
    dynamic var membershipPackages = List<String>()
    @objc dynamic var size: SizeModel?
    @objc dynamic var visibilityStatus: Bool = false
    dynamic var venueList: [VenueDetailModel] = []
    dynamic var ticketCategoryList: [CategoryDetailModel] = []
    dynamic var videoList: [VideosModel] = []
    dynamic var membershipList: [MembershipPackageModel] = []
    dynamic var suggestedUsers = List<UserDetailModel>()
    dynamic var suggestedVenue = List<VenueDetailModel>()
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
        sliders <- map["sliders"]
        size <- map["size"]
        videos <- (map["videos"], ListTransform<VideosModel>())
        customComponents <- (map["customComponents"], ListTransform<CustomComponentModel>())
        users <- (map["users"], ListTransform<UserDetailModel>())
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
        case .ticketCategories, .ticketCategoryRounded:
            if ticketCategories.isEmpty { return false }
            ticketCategoryList.removeAll()
            ticketCategories.forEach { offerId in
                if let category = APPSETTING.ticketCategories?.first(where: {$0.id == offerId}) {
                    ticketCategoryList.append(category)
                }
            }
            return !ticketCategoryList.isEmpty
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
    
    func isVisibleForSearch(ticket: [TicketModel]) -> Bool {
        switch cellTypeForSearch {
        case .ticket:
            if tickets.isEmpty { return false }
            ticketList.removeAll()
            tickets.forEach { ticketId in
                if let ticket = ticket.first(where: { $0._id == ticketId }) {
                    ticketList.append(ticket)
                }
            }
            return !ticketList.isEmpty
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
        if type == "ticket" {
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
        if type == "video" {
            return .video
        } else
        if type == "ticket" {
            return .ticket
        } else
        if type == "ticket-category" {
            return shape == "rectangular" ? .ticketCategories : .ticketCategoryRounded
        } else
        if type == "city" {
            return .cities
        } else
        if type == "big-category" {
            return .bigCategory
        } else
        if type == "small-category" {
            return .smallCategory
        } else
        if type == "custom-component" {
            return .singleVideo
        } else
        if type == "banner" {
            return .banner
        } else
        if type == "favorite_ticket" {
            return .favoriteTicket
        } else
        if type == "juniper-hotel" {
            return .ticket
        } else
        if type == "contact-us" {
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
