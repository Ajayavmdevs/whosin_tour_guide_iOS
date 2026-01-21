import Foundation
import ObjectMapper

class PromotionalBannerModel: Mappable, ModelProtocol {
    dynamic var list: [PromotionalBannerItemModel] = []
    dynamic var tickets: [TicketModel] = []
    
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        list <- map["list"]
        tickets <- map["tickets"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}


class PromotionalBannerItemModel: Mappable, ModelProtocol {
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    dynamic var banners: [BannerModel] = []
    dynamic var tickets: [TicketModel] = []
    dynamic var size: SizeModel?
    
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        banners <- map["banners"]
        title <- map["title"]
        _id <- map["_id"]
        tickets <- map["tickets"]
        size <- map["size"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

