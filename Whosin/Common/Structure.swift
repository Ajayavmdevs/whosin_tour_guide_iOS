import Foundation
import UIKit
import CoreTelephony
import Foundation
import UIKit
import Hero

enum ProfileType: String {
    case profile = "ProfileVC"
    case promoterProfile = "PromoterProfileVC"
    case complementaryProfile = "ComplementaryProfileVC"
}

enum HomeBlockCellType: Int {
    case none = 0
    case offer = 1
    case venue = 2
    case venueSmall = 3
    case customVenue = 4
    case customOffer = 5
    case customComponents = 6
    case video = 7
    case deal = 8
    case activity = 9
    case event = 10
    case nearBy = 11
    case myOuting = 12
    case userSuggested = 13
    case suggestedVenue = 14
    case membershipPackage = 15
    case yacht = 16
    case yachtOffer = 17
    case promoter = 18
    case promoterEvents = 19
    case ticket = 20
    case ticketCategories = 21
    case cities = 22
    case banner = 23
    case singleVideo = 24
    case bigCategory = 25
    case smallCategory = 26
    case ticketCategoryRounded = 27
    case favoriteTicket = 28
    case contactUs = 29
    

    var identifier: String {
        switch self {
        case .venue:
            return String(describing: LargeVenueComponentTableCell.self)
        case .venueSmall:
            return String(describing: SmallVenueComponentTableCell.self)
        case .customOffer, .customVenue:
            return String(describing: CustomVenueComponetCell.self)
        case .video:
            return String(describing: VideoComponentTableCell.self)
        case .offer:
            return String(describing: LargeOfferComponentTableCell.self)
        case .customComponents:
            return String(describing: CustomComponentTableCell.self)
        case .deal:
            return String(describing: ExlusiveDealsTableCell.self)
        case .activity:
            return String(describing: ActivityComponantTableCell.self)
        case .event:
            return String(describing: EventsTableCell.self)
        case .nearBy:
            return String(describing: MapComponentTableCell.self)
        case .myOuting:
            return String(describing: MyOutingTableCell.self)
        case .userSuggested:
            return String(describing: SuggestedFriendsTableCell.self)
        case .suggestedVenue:
            return String(describing: SuggestedFriendsTableCell.self)
        case .membershipPackage:
            return String(describing: CompleteProfileTableCell.self)
        case .yacht:
            return String(describing: YachtComponentTableCell.self)
        case .yachtOffer:
            return String(describing: YachtComponentTableCell.self)
        case .none:
            return String(describing: MyOutingTableCell.self)
        case .promoter:
            return String(describing: PromoterComponentCell.self)
        case .promoterEvents:
            return String(describing: HomeCmEventTableCell.self)
        case .ticket:
            return String(describing: CustomTicketTableCell.self)
        case .ticketCategories:
            return String(describing: CategoryTableCell.self)
        case .cities:
            return String(describing: CitiesListTableCell.self)
        case .banner:
            return String(describing: ExploreBannerTableCell.self)
        case .singleVideo:
            return String(describing: SingleVideoTableCell.self)
        case .bigCategory:
            return String(describing: ExploreBannerTableCell.self)
        case .smallCategory:
            return String(describing: ExploreBannerTableCell.self)
        case .ticketCategoryRounded:
            return String(describing: ExploreCategoryTableCell.self)
        case .favoriteTicket:
            return String(describing: CustomTicketTableCell.self)
        case .contactUs:
            return String(describing: ConnectUSTableViewCell.self)
        }
    }

    var height: CGFloat {
        switch self {
        case .venue:
            return LargeVenueComponentTableCell.height
        case .venueSmall:
            return SmallVenueComponentTableCell.height
        case .video:
            return VideoComponentTableCell.height
        case .offer:
            return LargeOfferComponentTableCell.height
        case .customVenue:
            return CustomVenueComponetCell.height
        case .customOffer:
            return CustomVenueComponetCell.height
        case .customComponents:
            return CustomComponentTableCell.height
        case .deal:
            return ExlusiveDealsTableCell.height
        case .activity:
            return ActivityComponantTableCell.height
        case .event:
            return EventsTableCell.height
        case .nearBy:
            return MapComponentTableCell.height
        case .myOuting:
            return MyOutingTableCell.height
        case .userSuggested:
            return SuggestedFriendsTableCell.height
        case .suggestedVenue:
            return SuggestedFriendsTableCell.height
        case .membershipPackage:
            return CompleteProfileTableCell.height
        case .yacht:
            return YachtComponentTableCell.height
        case .yachtOffer:
            return YachtComponentTableCell.height
        case .promoter:
            return PromoterComponentCell.height
        case .promoterEvents:
            return HomeCmEventTableCell.height
        case .ticket:
            return CustomTicketTableCell.height
        case .ticketCategories:
            return CategoryTableCell.height
        case .cities:
            return CitiesListTableCell.height
        case .banner:
            return ExploreBannerTableCell.height
        case .singleVideo:
            return SingleVideoTableCell.height
        case .bigCategory:
            return ExploreBannerTableCell.height
        case .smallCategory:
            return ExploreBannerTableCell.height
        case .ticketCategoryRounded:
            return ExploreCategoryTableCell.height
        case .none:
            return 0.0
        case .favoriteTicket:
            return CustomTicketTableCell.height
        case .contactUs:
            return ConnectUSTableViewCell.height
        }
    }

    var isNeedCacheCell: Bool {
        switch self {
        case .video:
            return true
        case .favoriteTicket:
            return true
        case .ticket:
            return true
        default:
            return false
        }
    }
    
    var prototype : [String: Any] {
        return [kCellIdentifierKey: self.identifier, kCellNibNameKey: self.identifier, kCellHeightKey: self.height]
    }
    
    var cachedCell : UITableViewCell? {
        if !isNeedCacheCell { return nil }
        guard let cell = Bundle.main.loadNibNamed(identifier, owner: nil, options: nil)?.first as? UITableViewCell else {
            return nil
        }
        return cell
    }
    
}

enum ExploreCellType: Int {
    case none = 0
    case cities = 1
    case categories = 2
    case banner = 3
    case video = 4
    case ticket = 5
    case bigCategory = 6
    case smallCategory = 7
    case reqtangleCategory = 8
    case contactUs = 9

    var identifier: String {
        switch self {
        case .cities:
            return String(describing: CitiesListTableCell.self)
        case .categories:
            return String(describing: ExploreCategoryTableCell.self)
        case .banner:
            return String(describing: ExploreBannerTableCell.self)
        case .video:
            return String(describing: SingleVideoTableCell.self)
        case .ticket:
            return String(describing: ExploreCustomTicketTableCell.self)
        case .bigCategory:
            return String(describing: ExploreBannerTableCell.self)
        case .smallCategory:
            return String(describing: ExploreBannerTableCell.self)
        case .reqtangleCategory:
            return String(describing: CategoryTableCell.self)
        case .contactUs:
            return String(describing: ConnectUSTableViewCell.self)
        case .none:
            return String(describing: ExploreCustomTicketTableCell.self)
        }
    }

    var height: CGFloat {
        switch self {
        case .none:
            return 0.0
        case .cities:
            return CitiesListTableCell.height
        case .categories:
            return ExploreCategoryTableCell.height
        case .banner:
            return ExploreBannerTableCell.height
        case .video:
            return SingleVideoTableCell.height
        case .bigCategory:
            return ExploreBannerTableCell.height
        case .smallCategory:
            return ExploreBannerTableCell.height
        case .ticket:
            return ExploreCustomTicketTableCell.height
        case .reqtangleCategory:
            return CategoryTableCell.height
        case .contactUs:
            return ConnectUSTableViewCell.height
        }
    }

    var isNeedCacheCell: Bool {
        switch self {
        case .video:
            return true
        default:
            return false
        }
    }
    
    var prototype : [String: Any] {
        return [kCellIdentifierKey: self.identifier, kCellNibNameKey: self.identifier, kCellHeightKey: self.height]
    }
}

enum SizeType: String {
    case small = "small"
    case medium = "medium"
    case large = "large"
}

struct HeroAnimationModifier {
    static let stories: [HeroModifier] = [.useOptimizedSnapshot, .spring(stiffness: 250, damping: 25)]
    static let visualEffect: [HeroModifier] = [.fade, .useOptimizedSnapshot]
    static let sourceView: [HeroModifier] = [.useOptimizedSnapshot, .spring(stiffness: 250, damping: 25)]
    static let venueDetail: [HeroModifier] = [.useOptimizedSnapshot, .spring(stiffness: 250, damping: 25)]
}

public enum EventType: String {
    case upcoming = "Upcoming"
    case history = "History"
}

public enum OutingType: String {
    case all = "All"
    case createdByMe = "Created"
    case invited = "Invitation"
    case history = "History"
}

public enum ContentType: Int {
    case feed = 0
    case Invitations = 1
    case myEvent = 2
    case friends = 3

    func getReturnType() -> String {
        switch self {
        case .feed:
            return "Feed"
        case .Invitations:
            return "Invitations"
        case .myEvent:
            return "My Event"
        case .friends:
            return "Friends"
        }
    }

    static func returnType(for index: Int) -> String? {
        if let contentType = ContentType(rawValue: index) {
            return contentType.getReturnType()
        } else {
            return nil
        }
    }
    
    static func indexForType(_ type: String) -> Int? {
        switch type {
        case ContentType.feed.getReturnType():
            return ContentType.feed.rawValue
        case ContentType.Invitations.getReturnType():
            return ContentType.Invitations.rawValue
        case ContentType.myEvent.getReturnType():
            return ContentType.myEvent.rawValue
        case ContentType.friends.getReturnType():
            return ContentType.friends.rawValue
        default:
            return nil
        }
    }
}

public enum PromoType: String {
    case activity = "activity"
    case offerPackage = "offerPackage"
    case discount = "discount"
    case membershipPackage = "membershipPackage"
    case deal = "deal"
}

public enum RequirementType: String {
    case requirementsAllowed = "requirementsAllowed"
    case requirementsNotAllowed = "requirementsNotAllowed"
    case benefitsIncluded = "benefitsIncluded"
    case benefitsNotIncluded = "benefitsNotIncluded"
}

public enum SocialPlatforms: String {
    case instagram = "instagram"
    case tiktok = "tiktok"
    case facebook = "facebook"
    case google = "google"
    case youtube = "youtube"
    case snapchat = "snapchat"
    case website = "website"
    case whatsapp = "whatsapp"
    case email = "email"
    case whosin = "whosin"
    
    static func checkType(_ platform: String) -> SocialPlatforms? {
        return SocialPlatforms(rawValue: platform)
    }

}

public enum ExtraGuestSpecificationsType: String {
    case age = "age"
    case gender = "gender"
    case dresscode = "dresscode"
    case nationality = "nationality"
    
    static func checkType(_ platform: String) -> SocialPlatforms? {
        return SocialPlatforms(rawValue: platform)
    }

}
