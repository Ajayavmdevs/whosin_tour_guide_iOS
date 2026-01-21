import Foundation
import ObjectMapper
import DialCountries
import RealmSwift

class InboxListModel: Object, Mappable, ModelProtocol, Identifiable {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var name: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var phone: String = kEmptyString
    @objc dynamic var email: String = kEmptyString
    @objc dynamic var subject: String = kEmptyString
    @objc dynamic var message: String = kEmptyString
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var lastMessagecreatedAt: String = kEmptyString
    dynamic var replies = List<RepliesModel>()

    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        userId <- map["userId"]
        name <- map["name"]
        image <- map["image"]
        email <- map["email"]
        phone <- map["phone"]
        subject <- map["subject"]
        message <- map["message"]
        status <- map["status"]
        createdAt <- map["createdAt"]
        replies <- (map["replies"], ListTransform<RepliesModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

class RepliesModel: Object, Mappable, ModelProtocol, Identifiable {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var conctactUsId: String = kEmptyString
    @objc dynamic var reply: String = kEmptyString
    @objc dynamic var replyBy: String = kEmptyString
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var isRead: Bool = false
        
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        conctactUsId <- map["conctactUsId"]
        reply <- map["reply"]
        replyBy <- map["replyBy"]
        createdAt <- map["createdAt"]
        isRead <- map["isRead"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}

