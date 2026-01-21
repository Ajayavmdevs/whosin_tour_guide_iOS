import Foundation
import RealmSwift
import ObjectMapper

class ExploreBannerModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var subTitle: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var typeId: String = kEmptyString
    @objc dynamic var buttonColor: String = kEmptyString
    @objc dynamic var buttonText: String = kEmptyString
    @objc dynamic var media: String = kEmptyString
    @objc dynamic var mediaType: String = kEmptyString
    @objc dynamic var thumbnail: String = kEmptyString

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["_id"]
        title <- map["title"]
        subTitle <- map["subTitle"]
        descriptions <- map["description"]
        type <- map["type"]
        typeId <- map["typeId"]
        buttonColor <- map["buttonColor"]
        buttonText <- map["buttonText"]
        media <- map["media"]
        mediaType <- map["mediaType"]
        thumbnail <- map["thumbnail"]
    }

    func isValid() -> Bool {
        return true
    }
}
