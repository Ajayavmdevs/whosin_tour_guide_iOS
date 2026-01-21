import ObjectMapper

class LanguageFileModel: BaseModel {
    
    var data: [String: [String: String]] = [:]

    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }

    override func isValid() -> Bool {
        return super.isValid() && !data.isEmpty
    }
}
