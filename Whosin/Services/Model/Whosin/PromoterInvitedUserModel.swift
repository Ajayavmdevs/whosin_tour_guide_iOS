//
//  PromoterInvitedUserModel.swift
//  Whosin
//
//  Created by CI on 06/11/24.
//

import Foundation
import ObjectMapper
import RealmSwift

class PromoterInvitedUserModel: Object, Mappable, ModelProtocol {

    @objc dynamic var selectAllUsers: Bool = false
    @objc dynamic var selectAllCircles: Bool = false
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    dynamic var invitedUsers: List<String> = List<String>()
   
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        selectAllUsers <- map["selectAllUsers"]
        selectAllCircles <- map["selectAllCircles"]
        _id <- map["_id"]
        descriptions <- map["description"]
        invitedUsers <- (map["invitedUsers"], StringListTransform())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}
