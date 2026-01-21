//
//  ReportedUserListModel.swift
//  Whosin
//
//  Created by CI on 16/05/25.
//

import Foundation
import ObjectMapper
import RealmSwift

class ReportedUserListModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var reporterId: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var typeId: String = kEmptyString
    @objc dynamic var reason: String = kEmptyString
    @objc dynamic var message: String = kEmptyString
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var action: String = kEmptyString
    @objc dynamic var createdAt: Date?
    @objc dynamic var user: UserDetailModel?
    @objc dynamic var reporUser: UserDetailModel?
    @objc dynamic var chat: MessageModel?
    @objc dynamic var review: RatingModel?
    
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kFormatDateStandard)
    

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["_id"]
        title <- map["title"]
        reporterId <- map["reporterId"]
        userId <- map["userId"]
        type <- map["type"]
        typeId <- map["typeId"]
        reason <- map["reason"]
        message <- map["message"]
        status <- map["status"]
        action <- map["action"]
        createdAt <- (map["createdAt"], DateFormatterTransform(dateFormatter: _dateFormatter))
        reporUser <- map["reporUser"]
        user <- map["user"]
        chat <- map["chat"]
        review <- map["review"]
    }

    func isValid() -> Bool {
        return true
    }
}
