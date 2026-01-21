import ObjectMapper
import DialCountries


class PrefrencesModel:  Mappable, ModelProtocol {
    
    var _id: String = kEmptyString
    var userId: String = kEmptyString
    var music: [String] = []
    var cuisine: [String] = []
    var features: [String] = []
    var createdAt: String = kEmptyString
    var updatedAt: String = kEmptyString
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        _id <- map["_id"]
        userId <- map["userId"]
        music <- map["music"]
        cuisine <- map["cuisine"]
        features <- map["features"]
        createdAt <- map["createdAt"]
        updatedAt <- map["updatedAt"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
