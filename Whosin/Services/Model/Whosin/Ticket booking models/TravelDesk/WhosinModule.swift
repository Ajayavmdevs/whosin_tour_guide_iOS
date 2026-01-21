import ObjectMapper
import RealmSwift

class WhosinModule: Object, Mappable, ModelProtocol {

    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var tourId: String = kEmptyString
    @objc dynamic var supplierId: String = kEmptyString
    @objc dynamic var tourName: String = kEmptyString
    @objc dynamic var countryId: String = kEmptyString
    @objc dynamic var countryName: String = kEmptyString
    @objc dynamic var cityId: String = kEmptyString
    @objc dynamic var cityName: String = kEmptyString
    @objc dynamic var duration: String = kEmptyString
    @objc dynamic var cityTourTypeId: String = kEmptyString
    @objc dynamic var cityTourType: String = kEmptyString
    @objc dynamic var tourShortDescription: String = kEmptyString
    @objc dynamic var cancellationPolicyName: String = kEmptyString
    @objc dynamic var contractId: String = kEmptyString
    dynamic var images: List<String> = List<String>()
    @objc dynamic var startAmount: Int = 0
    @objc dynamic var onlyChild: Bool = false
    @objc dynamic var recommended: Bool = false
    @objc dynamic var isPrivate: Bool = false
    dynamic var optionData = List<TourOptionsModel>()

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        _id <- map["_id"]
        tourId <- map["tourId"]
        supplierId <- map["supplierId"]
        tourName <- map["tourName"]
        countryId <- map["countryId"]
        countryName <- map["countryName"]
        cityId <- map["cityId"]
        cityName <- map["cityName"]
        images <- (map["images"], StringListTransform())
        onlyChild <- map["onlyChild"]
        recommended <- map["recommended"]
        isPrivate <- map["isPrivate"]
        duration <- map["duration"]
        cityTourTypeId <- map["cityTourTypeId"]
        tourShortDescription <- map["tourShortDescription"]
        cityTourType <- map["cityTourType"]
        startAmount <- map["startAmount"]
        cancellationPolicyName <- map["cancellationPolicyName"]
        contractId <- map["contractId"]
        optionData <- (map["optionData"], ListTransform<TourOptionsModel>())
    }

    func isValid() -> Bool {
        return true
    }
}
