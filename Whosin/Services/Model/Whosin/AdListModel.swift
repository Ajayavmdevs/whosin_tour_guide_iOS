import Foundation
import ObjectMapper

class AdListModel: Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var headline: String = kEmptyString
    @objc dynamic var subHeadline: String = kEmptyString
    @objc dynamic var size: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var item: String = kEmptyString
    @objc dynamic var background: String = kEmptyString
    @objc dynamic var logo: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var subTitle: String = kEmptyString
    @objc dynamic var badgeText: String = kEmptyString
    @objc dynamic var buttonText: String = kEmptyString
    @objc dynamic var status: Bool = false
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var typeId: String = kEmptyString
    @objc dynamic var video: String = kEmptyString
    @objc dynamic var venue: VenueDetailModel?
    @objc dynamic var activity: ActivitiesModel?
    @objc dynamic var event: EventModel?
    @objc dynamic var offer: OffersModel?
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["_id"]
        headline <- map["headline"]
        subHeadline <- map["subHeadline"]
        size <- map["size"]
        type <- map["type"]
        item <- map["item"]
        background <- map["background"]
        logo <- map["logo"]
        title <- map["title"]
        subTitle <- map["subTitle"]
        badgeText <- map["badgeText"]
        buttonText <- map["buttonText"]
        status <- map["status"]
        createdAt <- map["createdAt"]
        venue <- map["venue"]
        activity <- map["activity"]
        event <- map["event"]
        offer <- map["offer"]
        descriptions <- map["description"]
        typeId <- map["typeId"]
        video <- map["video"]

        
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}


