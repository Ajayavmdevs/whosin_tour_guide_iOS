import Foundation
import ObjectMapper
import RealmSwift

class EventGuestListModel: Object, Mappable, ModelProtocol {
    
    dynamic var invitation = List<InvitationModel>()
    dynamic var user = List<UserDetailModel>()

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        invitation <- (map["invitations"], ListTransform<InvitationModel>())
        user <- (map["users"], ListTransform<UserDetailModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

class HighlightsListModel: Object, Mappable, ModelProtocol {
    
    dynamic var list = List<InvitationModel>()
    dynamic var user = List<UserDetailModel>()

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        list <- (map["list"], ListTransform<InvitationModel>())
        user <- (map["user"], ListTransform<UserDetailModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
