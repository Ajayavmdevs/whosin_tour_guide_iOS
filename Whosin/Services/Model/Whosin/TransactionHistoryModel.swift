import Foundation
import ObjectMapper

class TransactionHistoryModel: Mappable, ModelProtocol {
    
    var title: String = kEmptyString
    var subtitle: String = kEmptyString
    var date: String = kEmptyString
    var amount: String = kEmptyString
    var status: String = kEmptyString
    var bottomText: String = kEmptyString
    var bottomRightText: String = kEmptyString
    var bottomIcon: String = kEmptyString
    var imageName: String = kEmptyString
    var isCredit: Bool = false
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    init() {}
    
    init(title: String, subtitle: String, date: String, amount: String, status: String, bottomText: String, bottomRightText: String, bottomIcon: String, imageName: String = "", isCredit: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.amount = amount
        self.status = status
        self.bottomText = bottomText
        self.bottomRightText = bottomRightText
        self.bottomIcon = bottomIcon
        self.imageName = imageName
        self.isCredit = isCredit
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        subtitle <- map["subtitle"]
        date <- map["date"]
        amount <- map["amount"]
        status <- map["status"]
        bottomText <- map["bottomText"]
        bottomRightText <- map["bottomRightText"]
        bottomIcon <- map["bottomIcon"]
        imageName <- map["imageName"]
        isCredit <- map["isCredit"]
    }
    
    func isValid() -> Bool {
        return true
    }
}
