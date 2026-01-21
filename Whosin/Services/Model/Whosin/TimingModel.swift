import Foundation
import ObjectMapper
import RealmSwift

class TimingModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var day: String = kEmptyString
    @objc dynamic var openingTime: String = kEmptyString
    @objc dynamic var closingTime: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var startTime: String = kEmptyString
    @objc dynamic var endTime: String = kEmptyString
    dynamic var slot = List<AvilableDateTimeModel>()

    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kFormatDateStandard)

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
        day <- map["day"]
        openingTime <- map["openingTime"]
        closingTime <- map["closingTime"]
        type <- map["type"]
        startTime <- map["start"]
        endTime <- map["end"]
        slot <- (map["slot"], ListTransform<AvilableDateTimeModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
