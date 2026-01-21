//
//  NotificationListModel.swift
//  Whosin
//
//  Created by Samir Makadia on 28/10/23.
//

import Foundation
import ObjectMapper
import RealmSwift

class NotificationListModel: Mappable, ModelProtocol {
    
    @objc dynamic var total: Int = 0
    dynamic var notification = List<NotificationModel>()
    dynamic var category = List<CategoryDetailModel>()
    dynamic var offer = List<OffersModel>()
    dynamic var venue = List<VenueDetailModel>()
    dynamic var user = List<UserDetailModel>()
    @objc dynamic var page: Int = 0
    @objc dynamic var count: Int = 0
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        total <- map["total"]
        notification <- (map["notification"], ListTransform<NotificationModel>())
        category <- ( map["category"], ListTransform<CategoryDetailModel>())
        offer <- (map["offer"], ListTransform<OffersModel>())
        venue <- (map["venue"], ListTransform<VenueDetailModel>())
        user <- (map["user"], ListTransform<UserDetailModel>())
        page <- map["page"]
        count <- map["count"]
        
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}

class NotificationModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var image: String = kEmptyString
    @objc dynamic var platform: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var offerId: String = kEmptyString
    @objc dynamic var categoryId: String = kEmptyString
    @objc dynamic var typeId: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var updatedAt: Date = Date()
    @objc dynamic var readStatus: Bool = false
    @objc dynamic var requestStatus: String = kEmptyString
    @objc dynamic var inviteStatus: String = kEmptyString
    @objc dynamic var promoterStatus: String = kEmptyString
    @objc dynamic var isPromoter: Bool = false
    @objc dynamic var isRingMember: Bool = false
    @objc dynamic var plusOneStatus: String = kEmptyString
    @objc dynamic var subAdminStatus: String = kEmptyString
    @objc dynamic var adminStatusOnPlusOne: String = kEmptyString
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kStanderdDate)
    dynamic var list = List<NotificationModel>()
    @objc dynamic var event: PromoterEventsModel?
    dynamic var images = List<String>()
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["_id"]
        title <- map["title"]
        descriptions <- map["description"]
        image <- map["image"]
        platform <- map["platform"]
        type <- map["type"]
        venueId <- map["venueId"]
        offerId <- map["offerId"]
        categoryId <- map["categoryId"]
        typeId <- map["typeId"]
        userId <- map["userId"]
        updatedAt <- (map["updatedAt"], DateFormatterTransform(dateFormatter: _dateFormatter))
        readStatus <- map["readStatus"]
        requestStatus <- map["requestStatus"]
        inviteStatus <- map["inviteStatus"]
        promoterStatus <- map["promoterStatus"]
        isPromoter <- map["isPromoter"]
        isRingMember <- map["isRingMember"]
        list <- (map["list"], ListTransform<NotificationModel>())
        event <- map["event"]
        images <- (map["images"], StringListTransform())
        plusOneStatus <- map["plusOneStatus"]
        subAdminStatus <- map["subAdminStatus"]
        adminStatusOnPlusOne <- map["adminStatusOnPlusOne"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}

class GetUpdatesModel: Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var wallet: Bool = false
    @objc dynamic var outing: Bool = false
    @objc dynamic var bucket: Bool = false
    @objc dynamic var event: Bool = false
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        userId <- map["userId"]
        wallet <- map["wallet"]
        outing <- map["outing"]
        bucket <- map["bucket"]
        event <- map["event"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}
