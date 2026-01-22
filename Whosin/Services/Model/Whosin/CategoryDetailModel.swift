import Foundation
import ObjectMapper
import RealmSwift

class CategoryDetailModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var subTitle: String = kEmptyString
    @objc dynamic var color: ColorModel?
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var bigImage: String = kEmptyString
    dynamic var bannersModel = List<BannerModel>()
    @objc dynamic var offers: Int = 0
    
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
        name <- map["name"]
        subTitle <- map["subTitle"]
        color <- map["color"]
        image <- map["image"]
        bigImage <- map["bigImage"]
        bannersModel <- (map["banners"], ListTransform<BannerModel>())
        offers <- map["offers"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
