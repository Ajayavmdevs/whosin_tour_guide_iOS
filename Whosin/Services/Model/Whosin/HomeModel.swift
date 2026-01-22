import Foundation
import ObjectMapper
import RealmSwift

class HomeModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var homeId: String = kAppName
    dynamic var storiesModel = List<VenueDetailModel>()
    dynamic var homeblocksModel = List<HomeBlockModel>()
    dynamic var categories = List<CategoryDetailModel>()
    dynamic var ticketCategories = List<CategoryDetailModel>()
    dynamic var tickets = List<TicketModel>()
    dynamic var cities = List<CategoryDetailModel>()
    dynamic var banners = List<ExploreBannerModel>()
    dynamic var customComponents = List<ExploreBannerModel>()
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "homeId"
    }
    
    class func homeIdPredicate(_ homeId: String) -> NSPredicate {
        NSPredicate(format: "homeId == %@", homeId)
    }
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        storiesModel <- (map["stories"], ListTransform<VenueDetailModel>())
        homeblocksModel <- (map["blocks"], ListTransform<HomeBlockModel>())
        categories <- (map["categories"],ListTransform<CategoryDetailModel>())
        ticketCategories <- (map["ticketCategories"],ListTransform<CategoryDetailModel>())
        tickets <- (map["tickets"], ListTransform<TicketModel>())
        cities <- (map["cities"],ListTransform<CategoryDetailModel>())
        banners <- (map["banners"],ListTransform<ExploreBannerModel>())
        customComponents <- (map["customComponents"], ListTransform<ExploreBannerModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}
