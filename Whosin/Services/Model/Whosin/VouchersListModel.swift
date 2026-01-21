import Foundation
import ObjectMapper
import RealmSwift

class VouchersListModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    dynamic var items = List<VoucherItems>()
    @objc dynamic var giftBy: UserDetailModel? = nil
    @objc dynamic var giftTo: UserDetailModel? = nil
    @objc dynamic var orderId: String = kEmptyString
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var packageId: String = kEmptyString
    @objc dynamic var eventId: String = kEmptyString
    @objc dynamic var octoTicketId: String = kEmptyString
    @objc dynamic var price: Int = 0
    @objc dynamic var qty: Int = 0
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var vouchar: VoucharsModel? = nil
    @objc dynamic var venue: VenueDetailModel? = nil
    @objc dynamic var offer: OffersModel? = nil
    @objc dynamic var deal: DealsModel? = nil
    @objc dynamic var event:EventModel? = nil
    @objc dynamic var activity: ActivitiesModel? = nil
    @objc dynamic var activityDetail: ActivityDetailModel? = nil
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var dealId: String = kEmptyString
    @objc dynamic var voucherId: String = kEmptyString
    @objc dynamic var activityId: String = kEmptyString
    @objc dynamic var date: String = kEmptyString
    @objc dynamic var time: String = kEmptyString
    @objc dynamic var remainingQty: Int = 0
    @objc dynamic var usedQty: Int = 0
    @objc dynamic var uniqueCode: String = kEmptyString
    @objc dynamic var ticketId: String = kEmptyString
    @objc dynamic var whosinTicketId: String = kEmptyString
    @objc dynamic var ticket: TicketBookingModel? = nil
    @objc dynamic var whosinTicket: TicketBookingModel? = nil
    @objc dynamic var traveldeskTicket: TicketBookingModel? = nil
    @objc dynamic var octoTicket: TicketBookingModel? = nil
    @objc dynamic var juniperHotel: TicketBookingModel? = nil

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
        id <- map["_id"]
        items <- (map["items"], ListTransform<VoucherItems>())
        giftBy <- map["giftBy"]
        giftTo <- map["giftTo"]
        orderId <- map["orderId"]
        venueId <- map["venueId"]
        packageId <- map["packageId"]
        octoTicketId <- map["octoTicketId"]
        eventId <- map["eventId"]
        price <- map["price"]
        qty <- map["qty"]
        createdAt <- map["createdAt"]
        vouchar <- map["vouchar"]
        venue <- map["venue"]
        offer <- map["offer"]
        deal <- map["deal"]
        event <- map["event"]
        activityDetail <- map["activityDetail"]
        activity <- map["activity"]
        type <- map["type"]
        dealId <- map["dealId"]
        voucherId <- map["voucherId"]
        activityId <- map["activityId"]
        date <- map["date"]
        time <- map["time"]
        remainingQty <- map["remainingQty"]
        usedQty <- map["usedQty"]
        uniqueCode <- map["uniqueCode"]
        ticketId <- map["ticketId"]
        whosinTicketId <- map["whosinTicketId"]
        ticket <- map["ticket"]
        whosinTicket <- map["whosinTicket"]
        traveldeskTicket <- map["traveldeskTicket"]
        octoTicket <- map["octoTicket"]
        juniperHotel <- map["juniperHotel"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public var _createdAt: Date {
        return Utils.stringToDate(createdAt, format: kStanderdDate) ?? Date()
    }

    func isValid() -> Bool {
        return true
    }
}

class ActivityDetailModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var activityType: String = kEmptyString
    @objc dynamic var date: String = kEmptyString
    @objc dynamic var time: String = kEmptyString

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
        id <- map["_id"]
        activityType <- map["activityType"]
        date <- map["date"]
        time <- map["time"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
}

class VoucherItems: Object, Mappable, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var packageId: String = kEmptyString
    @objc dynamic var uniqueCode: String = kEmptyString
    @objc dynamic var date: String = kEmptyString
    @objc dynamic var time: String = kEmptyString
    @objc dynamic var qty: Int = 0
    @objc dynamic var remainingQty: Int = 0
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var price: Int = 0
    @objc dynamic var usedQty: Int = 0
    dynamic var giftMessage: List<String> = List<String>()

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
        id <- map["_id"]
        packageId <- map["packageId"]
        uniqueCode <- map["uniqueCode"]
        date <- map["date"]
        time <- map["time"]
        qty <- map["qty"]
        remainingQty <- map["remainingQty"]
        createdAt <- map["createdAt"]
        price <- map["price"]
        usedQty <- map["usedQty"]
        giftMessage <- (map["giftMessage"] , StringListTransform())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    public var _activityDate: Date {
        if let formattedDate = Utils.stringToDate(date, format: kFormatDate) {
            return formattedDate
        } else {
            return Utils.stringToDate(date, format: kFormatDateDOB) ?? Date()
        }
    }

    func isValid() -> Bool {
        return true
    }
}
