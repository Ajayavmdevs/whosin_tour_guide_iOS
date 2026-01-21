import Foundation
import RealmSwift
import ObjectMapper

class TourImagesModel: Object, Mappable, ModelProtocol {

    @objc dynamic var tourId: Int = 0
    @objc dynamic var imagePath: String = kEmptyString
    @objc dynamic var imageCaptionName: String = kEmptyString
    @objc dynamic var isFrontImage: Int = 0
    @objc dynamic var isBannerImage: Int = 0
    @objc dynamic var isBannerRotateImage: Int = 0

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        tourId <- map["tourId"]
        imagePath <- map["imagePath"]
        imageCaptionName <- map["imageCaptionName"]
        isFrontImage <- map["isFrontImage"]
        isBannerImage <- map["isBannerImage"]
        isBannerRotateImage <- map["isBannerRotateImage"]
    }
    
    func isValid() -> Bool {
        return true
    }
}
