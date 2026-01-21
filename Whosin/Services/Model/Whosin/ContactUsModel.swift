import Foundation
import RealmSwift
import ObjectMapper

class ContactUsModel: Object, Mappable, ModelProtocol {

    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var desc: String = kEmptyString
    @objc dynamic var platform: String = kEmptyString

    dynamic var cta = List<CTAModel>()
    dynamic var screen = List<ScreenModel>()
    @objc dynamic var media: MediaModel?

    // MARK: - Mappable
    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        _id <- map["_id"]
        title <- map["title"]
        desc <- map["description"]
        screen <- (map["screen"], ListTransform<ScreenModel>())
        platform <- map["platform"]
        cta <- (map["cta"],ListTransform<CTAModel>())
        media <- map["media"]
    }
    
    func height(screenName: ContactBlockScreens) -> CGFloat? {
        guard let size = screen.first(where: { $0.screenName == screenName.rawValue })?.size,
              let height = Double(size) else {
            return nil
        }
        return CGFloat(height)
    }
    
    func isEnabled(screenName: ContactBlockScreens) -> Bool {
        return screen.first(where: { $0.screenName == screenName.rawValue })?.isEnabled ?? false
    }

    // MARK: - ModelProtocol
    func isValid() -> Bool {
        return true
    }
}

class MediaModel: Object, Mappable, ModelProtocol {

    @objc dynamic var type: String = kEmptyString
    @objc dynamic var url: String = kEmptyString
    @objc dynamic var backgroundColor: String = "#191919"

    @objc dynamic var height: Double = 0.0
    @objc dynamic var ratio: String = kEmptyString

    // MARK: - Mappable
    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        type <- map["type"]
        url <- map["url"]
        backgroundColor <- map["backgroundColor"]
        height <- map["height"]
        ratio <- map["ratio"]
    }

    // MARK: - ModelProtocol
    func isValid() -> Bool {
        return true
    }
}

class ScreenModel: Object, Mappable, ModelProtocol {

    @objc dynamic var screenName: String = kEmptyString
    @objc dynamic var isEnabled: Bool = false
    @objc dynamic var size: String = "280"

    // MARK: - Mappable
    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        screenName <- map["screenName"]
        isEnabled <- map["isEnabled"]
        size <- map["size"]
    }

    // MARK: - ModelProtocol
    func isValid() -> Bool {
        return true
    }
}

