import Foundation
import ObjectMapper
import RealmSwift

class CartModel: Object, ModelProtocol {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var discountValue: String = kEmptyString
    @objc dynamic var discount: Int = 0
    @objc dynamic var _floatDiscountedPrice: Float = 0
    @objc dynamic var originalPrice: Int = 0
    @objc dynamic var startDate: String = kEmptyString
    @objc dynamic var startTime: String = kEmptyString
    @objc dynamic var endTime: String = kEmptyString
    @objc dynamic var endDate: Date?
    @objc dynamic var days: String = kEmptyString
    @objc dynamic var quantity: Int = 0
    @objc dynamic var activityDate: String = kEmptyString
    @objc dynamic var activityTime: String = kEmptyString
    @objc dynamic var activityType: String = kEmptyString
    
    
    @objc dynamic var venueId: String = kEmptyString
    @objc dynamic var venueName: String = kEmptyString
    @objc dynamic var venueAddress: String = kEmptyString
    @objc dynamic var venueLogo: String = kEmptyString
    @objc dynamic var venueCover: String = kEmptyString
    @objc dynamic var dealImage: String = kEmptyString
    @objc dynamic var offerId: String = kEmptyString
    @objc dynamic var dealId: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var packageId: String = kEmptyString
    @objc dynamic var eventId: String = kEmptyString
    @objc dynamic var activityId: String = kEmptyString
    @objc dynamic var maxQty: Int = 0
    @objc dynamic var floatDiscountedPrice: Float  {
        get {
            _floatDiscountedPrice  > 0 ? _floatDiscountedPrice : Float(originalPrice)
        }
        set {
            _floatDiscountedPrice  > 0 ? _floatDiscountedPrice : Float(originalPrice)
        }
    }
    dynamic var features = List<CommonSettingsModel>()
    dynamic var vouchars = List<VoucharsModel>()
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    public override init() {}
    
    
    public convenience init?(dealsModel: DealsModel) {
        self.init()
        self.id = dealsModel.id
        self.dealId = dealsModel.id
        self.title = dealsModel.title
        self.descriptions = dealsModel.descriptions
        self.discountValue = dealsModel.discountValues
        self.discount = dealsModel.discountValue
        self._floatDiscountedPrice = Float(dealsModel.discountedPrice)
        self.originalPrice = dealsModel.originalPrice != 0 ? dealsModel.originalPrice : dealsModel.actualPrice
        self.startDate = dealsModel.startDate
        self.dealImage = dealsModel.image
        self.endDate = Utils.stringToDate(dealsModel.endDate, format: kFormatDate)
        self.startTime = dealsModel.startTime
        self.endTime = dealsModel.endTime
        self.days = dealsModel._days
        self.venueId = dealsModel.venueModel?.id ?? ""
        self.venueName = dealsModel.venueModel?.name ?? ""
        self.venueAddress = dealsModel.venueModel?.address ?? ""
        self.venueLogo = dealsModel.venueModel?.logo ?? ""
        self.venueCover = dealsModel.venueModel?.cover ?? ""
//        self.features = dealsModel.features
//        self.vouchars = dealsModel.vouchars
        self.type = "deal"
        
    }
    
    public convenience init?(venueModel: VenueDetailModel,_ packageModel: PackageModel) {
        self.init()
        self.id = packageModel.id
        self.title = packageModel.title
        self.descriptions = packageModel.subTitle
        self.discountValue = packageModel.discount
        self._floatDiscountedPrice = packageModel._flootdiscountedPrice
        self.originalPrice = packageModel.actualPrice
        self.startDate = ""
        self.endDate = Date()
        self.maxQty = packageModel.remainingQty
        
        self.venueId = venueModel.id
        self.venueName = venueModel.name
        self.venueAddress = venueModel.address
        self.venueLogo = venueModel.logo
        self.venueCover = venueModel.cover
        self.offerId = packageModel.offerId
        self.type = "offer"
    }
    
    public convenience init?(event: EventModel, venue: VenueDetailModel,_ packageModel: PackageModel) {
        self.init()
        self.id = packageModel.id
        self.title = packageModel.title
        self.descriptions = packageModel.descriptions
        self.discountValue = "\(packageModel.discounts)"
        self._floatDiscountedPrice = packageModel._flootdiscountedPrice
        self.originalPrice = packageModel.actualPrice
        self.packageId = packageModel.id
        let satartTime = Utils.stringToDate(event.eventTime, format: kStanderdDate)
        self.startDate =  Utils.dateToString(satartTime, format: kFormatDateLocal)
        self.endDate = Utils.dateOnly(satartTime)
        self.maxQty = packageModel.remainingQty

        self.venueId = venue.id
        self.venueName = venue.name
        self.venueAddress = venue.address
        self.venueLogo = venue.logo
        self.venueCover = venue.cover
        self.eventId = event.id
        self.type = "event"
    }
    
    public convenience init?(_ activityModel: ActivitiesModel) {
        self.init()
        self.id = activityModel.id
        self.activityId = activityModel.id
        self.title = activityModel.name
        self.descriptions = activityModel.descriptions
        self.discountValue = "\(activityModel.discount)"
        self._floatDiscountedPrice = Float(activityModel._disocuntedPrice) ?? 0
        self.originalPrice = activityModel.price
        self.startDate = Utils.dateToString(activityModel.startDate, format: kFormatDateLocal)
        self.endDate = activityModel.endDate
        self.activityType = activityModel.time?.type ?? kEmptyString
        
        self.venueId = activityModel.provider?.id ?? ""
        self.venueName = activityModel.provider?.name ?? ""
        self.venueAddress = activityModel.provider?.address ?? ""
        self.venueLogo = activityModel.provider?.logo ?? ""
        self.venueCover = activityModel.provider?.logo ?? ""
        self.offerId = ""
        self.type = "activity"
    }
    

    
    public convenience init?(cartModel : CartModel) {
        self.init()
        self.id = cartModel.id
        self.title = cartModel.title
        self.descriptions = cartModel.descriptions
        self.discountValue = cartModel.discountValue
        self.discount = cartModel.discount
        self.originalPrice = cartModel.originalPrice
        self._floatDiscountedPrice = cartModel.floatDiscountedPrice
        self.startDate = cartModel.startDate
        self.endDate = cartModel.endDate
        self.startTime = cartModel.startTime
        self.endTime = cartModel.endTime
        self.days = cartModel.days
        self.offerId = cartModel.offerId
        self.venueId = cartModel.venueId
        self.venueName = cartModel.venueName
        self.venueAddress = cartModel.venueAddress
        self.venueLogo = cartModel.venueLogo
        self.venueCover = cartModel.venueCover
        self.type = cartModel.type
        self.dealId = cartModel.dealId
        self.dealImage = cartModel.dealImage
        self.activityId = cartModel.activityId
        self.maxQty = cartModel.maxQty
        self.features = cartModel.features
        self.vouchars = cartModel.vouchars
    }
    
    public convenience init?(cartModel : CartModel, qty: Int, dealId: String) {
        self.init()
        self.id = cartModel.id
        self.title = cartModel.title
        self.descriptions = cartModel.descriptions
        self.discountValue = cartModel.discountValue
        self.discount = cartModel.discount
        self.originalPrice = cartModel.originalPrice
        self._floatDiscountedPrice = cartModel.floatDiscountedPrice
        self.startDate = cartModel.startDate
        self.endDate = cartModel.endDate
        self.startTime = cartModel.startTime
        self.endTime = cartModel.endTime
        self.days = cartModel.days
        self.quantity = qty
        self.venueId = cartModel.venueId
        self.venueName = cartModel.venueName
        self.venueAddress = cartModel.venueAddress
        self.venueLogo = cartModel.venueLogo
        self.venueCover = cartModel.venueCover
        self.offerId = cartModel.offerId
        self.type = cartModel.type
        self.dealId = dealId
        self.dealImage = cartModel.dealImage
        self.eventId = cartModel.eventId
        self.packageId = cartModel.packageId
        self.maxQty = cartModel.maxQty
//        self.features = cartModel.features
//        self.vouchars = cartModel.vouchars
    }
    
    class func idPredicate(_ id: String) -> NSPredicate {
        NSPredicate(format: "id == %@", id)
    }
    
    class func idsPredicate(_ ids: [String]) -> NSPredicate {
        NSPredicate(format: "id IN %@", ids)
    }
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}


class TicketCartListModel: Object, Mappable, ModelProtocol, Identifiable {
    
    @objc dynamic var total: String = kEmptyString
    dynamic var items = List<BookingModel>()
    dynamic var customTickets = List<TicketModel>()
    @objc dynamic var contactUsBlock: ContactUsModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    required convenience init?(map: Map) {
        self.init()
    }
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    func mapping(map: Map) {
        total <- map["total"]
        items <- (map["items"], ListTransform<BookingModel>())
        customTickets <- (map["customTickets"], ListTransform<TicketModel>())
        contactUsBlock <- map["contactUsBlock"]
    }

    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}
