import Foundation
import ObjectMapper
import RealmSwift

class ChatListModel: Object, Mappable, ModelProtocol {
    
    dynamic var chat = List<ChatModel>()
    dynamic var users = List<UserDetailModel>()
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        chat <- (map["chat"],ListTransform<ChatModel>())
        users <- (map["users"],ListTransform<UserDetailModel>())

    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
