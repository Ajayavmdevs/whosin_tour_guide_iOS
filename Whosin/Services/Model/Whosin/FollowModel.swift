import Foundation
import ObjectMapper
import RealmSwift

class FollowModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var followerId: String = kEmptyString
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var updatedAt: String = kEmptyString
    @objc dynamic var v: Int = 0

    
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
        userId <- map["userId"]
        followerId <- map["follower_id"]
        status <- map["status"]
        id <- map["_id"]
        createdAt <- map["createdAt"]
        updatedAt <- map["updatedAt"]
        v <- map["__v"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}
