import Foundation
import ObjectMapper

class InAppNotificationModel: Mappable, ModelProtocol {
    
    
    dynamic var title: IANComponentModel?
    dynamic var subTitle: IANComponentModel?
    dynamic var description: IANComponentModel?
    dynamic var button1: IANComponentModel?
    dynamic var button2: IANComponentModel?
    dynamic var background: IANComponentModel?
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var layout: String = "classic"
    @objc dynamic var viewType: String = "classic"
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var userId: String = "classic"
    @objc dynamic var userType: String = ""
    @objc dynamic var showOnAppLoad: Bool = false
    @objc dynamic var readStatus: Bool = false
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        title <- map["title"]
        _id <- map["_id"]
        userId <- map["userId"]
        subTitle <- map["subtitle"]
        description <- map["description"]
        userType <- map["userType"]
        image <- map["image"]
        button1 <- map["button1"]
        button2 <- map["button2"]
        background <- map["background"]
        layout <- map["layout"]
        viewType <- map["viewType"]
        showOnAppLoad <- map["showOnAppLoad"]
        readStatus <- map["readStatus"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}

class IANComponentModel: Mappable, ModelProtocol {
    @objc dynamic var text: String = kEmptyString
    @objc dynamic var color: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var alignment: String = kEmptyString
    @objc dynamic var bgColor: String = kEmptyString
    @objc dynamic var action: String = kEmptyString
    @objc dynamic var data: String = kEmptyString
    
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        text <- map["text"]
        color <- map["color"]
        image <- map["image"]
        alignment <- map["alignment"]
        bgColor <- map["bgColor"]
        action <- map["action"]
        data <- map["data"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
    var textAlignment: NSTextAlignment {
        if alignment == "center" {
            return .center
        }
        else if alignment == "right" {
            return .right
        }
        return .left
    }
}

class IANListModel: Mappable, ModelProtocol {
    @objc dynamic var total: String = kEmptyString
    dynamic var list: [InAppNotificationModel] = []
    @objc dynamic var page: String = kEmptyString
    
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        total <- map["total"]
        list <- map["list"]
        page <- map["page"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
