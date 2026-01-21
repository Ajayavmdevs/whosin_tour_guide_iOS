import Foundation
import ObjectMapper
import RealmSwift

class YachtOfferDetailModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var yachtId: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var startDate: String = kEmptyString
    @objc dynamic var endDate: String = kEmptyString
    @objc dynamic var importantNotice: String = kEmptyString
    @objc dynamic var disclaimer: String = kEmptyString
    @objc dynamic var isExpired: String = kEmptyString
    @objc dynamic var packageType: String = kEmptyString
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var startingAmount: Int = 0
    @objc dynamic var discount: Int = 0
    @objc dynamic var needToKnow: String = kEmptyString 
//    {
//        didSet {
//            if needToKnow == nil || needToKnow.isEmpty {
//                return
//            }
//            // Convert the string to Data
//            guard let data = needToKnow.data(using: .utf8) else {
//                needToKnow = kEmptyString
//                return
//            }
//
//            do {
//                // Attempt to parse the JSON data into an array
//                if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
//                    // Add bullets before each string and join them with ", \n"
//                    let bulletList = array.map { "• \($0)" }.joined(separator: ", \n")
//                    needToKnow = bulletList
//                } else {
//                    needToKnow = kEmptyString
//                    fatalError("Failed to convert JSON data to array")
//                }
//            } catch {
//                needToKnow = kEmptyString
//                print("Error parsing JSON: \(error)")
//            }
//        }
//    }
    @objc dynamic var yacht: YachtDetailModel?
    dynamic var images = List<String>()
    dynamic var needToKnowArray = List<String>()
    dynamic var packages = List<YachtPackgeModel>()
    dynamic var addOns = List<AddOnsModel>()
    dynamic var whatsInclude = List<CommonSettingsModel>()

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
        yachtId <- map["yachtId"]
        title <- map["title"]
        descriptions <- map["description"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        importantNotice <- map["importantNotice"]
        disclaimer <- map["disclaimer"]
        isExpired <- map["isExpired"]
        packageType <- map["packageType"]
        createdAt <- map["createdAt"]
        startingAmount <- map["startingAmount"]
        discount <- map["discount"]
        yacht <- map["yacht"]
        needToKnow <- map["needToKnow"]
        images <- (map["images"], StringListTransform())
        needToKnowArray <- (map["needToKnow"], StringListTransform())
        addOns <- (map["addOns"], ListTransform<AddOnsModel>())
        packages <- (map["packages"], ListTransform<YachtPackgeModel>())
        whatsInclude <- (map["whatsInclude"], ListTransform<CommonSettingsModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}


class AddOnsModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var image: Bool = false
    @objc dynamic var price: Int = 0
    
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
        image <- map["image"]
        title <- map["title"]
        descriptions <- map["description"]
        price <- map["price"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
