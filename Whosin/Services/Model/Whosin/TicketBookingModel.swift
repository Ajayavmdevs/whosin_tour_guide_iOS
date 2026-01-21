import Foundation
import RealmSwift
import ObjectMapper

class TicketBookingModel: Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var uniqueNo: String = kEmptyString
    @objc dynamic var bookingType: String = kEmptyString
    @objc dynamic var bookingCode: String = kEmptyString
    @objc dynamic var paymentStatus: String = kEmptyString
    @objc dynamic var bookingStatus: String = kEmptyString
    @objc dynamic var referenceNo: String = kEmptyString
    @objc dynamic var customTicketId: String = kEmptyString
    dynamic var tourDetails = List<TourDetailsModel>()
    dynamic var passengers: [PassengersModel] = []
    dynamic var hotelGuest: [JPPassengerModel] = []
    dynamic var holder: PassengersModel?
    dynamic var details: [BookingDetailsModel] = []
    dynamic var travelDetails: [TravelDeskDetailModel] = []
    dynamic var bigBusDetails: [OctoDetailsModel] = []
    dynamic var cancellationPolicy: [TourPolicyModel] = []
    dynamic var jpCancellationPolicy: [JPCancellationPolicyModel] = []
    @objc dynamic var createdAt: String = kEmptyString
    @objc dynamic var amount: Double = 0
    @objc dynamic var promoCode: String = kEmptyString
    @objc dynamic var totalAmount: Double = 0
    @objc dynamic var discount: Double = 0
    @objc dynamic var departureTime: String = kEmptyString
    @objc dynamic var downloadTicket: String = kEmptyString
    @objc dynamic var supplier: String = kEmptyString
    @objc dynamic var reviewStatus: String = kEmptyString
    @objc dynamic var externalBookingReference: String = kEmptyString
    @objc dynamic var currency: String = kEmptyString
    @objc dynamic var ticketPdfUrl: String = kEmptyString

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["_id"]
        userId <- map["userId"]
        uniqueNo <- map["uniqueNo"]
        bookingType <- map["bookingType"]
        bookingCode <- map["bookingCode"]
        details <- map["details"]
        travelDetails <- map["details"]
        bigBusDetails <- map["details"]
        paymentStatus <- map["paymentStatus"]
        bookingStatus <- map["bookingStatus"]
        referenceNo <- map["referenceNo"]
        customTicketId <- map["customTicketId"]
        tourDetails <- (map["TourDetails"], ListTransform<TourDetailsModel>())
        createdAt <- map["createdAt"]
        if bookingType == "juniper-hotel" {
            hotelGuest <- map["passengers"]
            jpCancellationPolicy <- map["cancellationPolicy"]
        } else {
            passengers <- map["passengers"]
            cancellationPolicy <- map["cancellationPolicy"]
        }
        holder <- map["holder"]
        amount <- map["amount"]
        totalAmount <- map["totalAmount"]
        discount <- map["discount"]
        departureTime <- map["departureTime"]
        downloadTicket <- map["downloadTicket"]
        supplier <- map["supplier"]
        reviewStatus <- map["reviewStatus"]
        externalBookingReference <- map["externalBookingReference"]
        currency <- map["currency"]
        ticketPdfUrl <- map["ticketPdfUrl"]
    }

    func isValid() -> Bool {
        return true
    }
}

class TourDetailsModel: Object, Mappable, ModelProtocol {

    @objc dynamic var serviceUniqueId: Int = 0
    @objc dynamic var tourId: Int = 0
    @objc dynamic var travelTourId: String = kEmptyString
    @objc dynamic var optionId: Int = 0
    @objc dynamic var ticketOptionId: String = kEmptyString
    @objc dynamic var adult: Int = 0
    @objc dynamic var child: Int = 0
    @objc dynamic var infant: Int = 0
    @objc dynamic var tourDate: String = kEmptyString
    @objc dynamic var timeSlotId: Int = 0
    @objc dynamic var startTime: String = kEmptyString
    @objc dynamic var timeSlot: String = kEmptyString
    @objc dynamic var transferId: Int = 0
    @objc dynamic var pickup: String = kEmptyString
    @objc dynamic var adultRate: Int = 0
    @objc dynamic var childRate: Int = 0
    @objc dynamic var serviceTotal: String = kEmptyString
    @objc dynamic var whosinTotal: String = kEmptyString
    @objc dynamic var bookingId: String = kEmptyString
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var startDate: String = kEmptyString
    @objc dynamic var endDate: String = kEmptyString
    @objc dynamic var adultTitle: String = kEmptyString
    @objc dynamic var childTitle: String = kEmptyString
    @objc dynamic var infantTitle: String = kEmptyString
    @objc dynamic var addOndesc: String = kEmptyString
    @objc dynamic var addOnImage: String = kEmptyString
    @objc dynamic var addOnTitle: String = kEmptyString
    dynamic var customData: TourOptionsModel?
    @objc dynamic var tour: TourDataModel?
    @objc dynamic var optionData: TourOptionModel?
    @objc dynamic var whosinOptionData: TourOptionsModel?
    @objc dynamic var tourOption: TourOptionDataModel?
    @objc dynamic var customTicket: TicketModel?
    @objc dynamic var tourData: HotelDetailsModel?
    @objc dynamic var jpHoleOptionData: JPHoleOptionData?
    @objc dynamic var cancellable: Bool = false
    dynamic var addons = List<TourDetailsModel>()
    @objc dynamic var addonOption: TourOptionsModel?

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        serviceUniqueId <- map["serviceUniqueId"]
        tourId <- map["tourId"]
        travelTourId <- map["tourId"]
        optionId <- map["optionId"]
        ticketOptionId <- map["optionId"]
        adult <- map["adult"]
        child <- map["child"]
        infant <- map["infant"]
        tourDate <- map["tourDate"]
        timeSlotId <- map["timeSlotId"]
        startTime <- map["startTime"]
        timeSlot <- map["timeSlot"]
        transferId <- map["transferId"]
        pickup <- map["pickup"]
        adultRate <- map["adultRate"]
        childRate <- map["childRate"]
        serviceTotal <- map["serviceTotal"]
        whosinTotal <- map["whosinTotal"]
        status <- map["status"]
        bookingId <- map["bookingId"]
        customData <- map["customData"]
        tour <- map["tour"]
        optionData <- map["optionData"]
        whosinOptionData <- map["optionData"]
        jpHoleOptionData <- map["optionData"]
        tourOption <- map["tourOption"]
        customTicket <- map["customTicket"]
        cancellable <- map["cancellable"]
        tourData <- map["tourData"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        adultTitle <- map["adult_title"]
        childTitle <- map["child_title"]
        infantTitle <- map["infant_title"]
        addons <- (map["Addons"], ListTransform<TourDetailsModel>())
        addonOption <- map["addonOption"]
        addOndesc <- map["addOndesc"]
        addOnTitle <- map["addOnTitle"]
        addOnImage <- map["addOnImage"]
    }

    func isValid() -> Bool {
        return true
    }
}

class BookingDetailsModel: Object, Mappable {
    
    @objc dynamic var bookingId: String = kEmptyString
    @objc dynamic var referenceNo: String = kEmptyString
    @objc dynamic var ticketURL: String = kEmptyString
    @objc dynamic var optionName: String = kEmptyString
    @objc dynamic var validity: String = kEmptyString
    @objc dynamic var validityExtraDetails: String?
    @objc dynamic var printType: String = kEmptyString
    @objc dynamic var slot: String = kEmptyString
    @objc dynamic var pnrNumber: String?
    dynamic var ticketDetails = List<TicketDetailModel>()
    @objc dynamic var status: String = kEmptyString
    @objc dynamic var downloadRequired: Bool = false
    @objc dynamic var serviceUniqueId: String = kEmptyString
    @objc dynamic var serviceType: String = kEmptyString
    @objc dynamic var confirmationNo: String = kEmptyString

    // MARK: - Primary Key
    override class func primaryKey() -> String? {
        return "referenceNo"
    }

    // MARK: - ObjectMapper Init
    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        bookingId <- (map["bookingId"], TransformOf<String, Any>(fromJSON: { value in
            if let intValue = value as? Int {
                return String(intValue)
            } else if let strValue = value as? String {
                return strValue
            }
            return nil
        }, toJSON: { value in
            return value
        }))
        referenceNo <- map["referenceNo"]
        ticketURL <- map["ticketURL"]
        optionName <- map["optionName"]
        validity <- map["validity"]
        validityExtraDetails <- map["validityExtraDetails"]
        printType <- map["printType"]
        slot <- map["slot"]
        pnrNumber <- map["pnrNumber"]
        ticketDetails <- (map["ticketDetails"], ListTransform<TicketDetailModel>())
        status <- map["status"]
        downloadRequired <- map["downloadRequired"]
        serviceUniqueId <- (map["serviceUniqueId"], TransformOf<String, Any>(fromJSON: { value in
            if let intValue = value as? Int {
                return String(intValue)
            } else if let strValue = value as? String {
                return strValue
            }
            return nil
        }, toJSON: { value in
            return value
        }))
        serviceType <- map["servicetype"]
        confirmationNo <- map["confirmationNo"]
    }
}

class TicketDetailModel: Object, Mappable {
    
    @objc dynamic var barCode: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var noOfAdult: Int = 0
    @objc dynamic var noOfChild: Int = 0
    @objc dynamic var noOfInfant: Int = 0
    @objc dynamic var guides: Int = 0
    @objc dynamic var optionName: String?

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        barCode <- map["barCode"]
        type <- map["type"]
        noOfAdult <- map["noOfAdult"]
        noOfChild <- map["noOfchild"]
        noOfInfant <- map["noOfinfant"]
        guides <- map["guides"]
        optionName <- map["optionName"]
    }
}

class TravelDeskDetailModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var notesToClientsPostBooking: String = ""
    var cancellationPolicy = List<TourPolicyModel>()
    @objc dynamic var ticketsDetails: TicketDetailsModel?
    @objc dynamic var customerSupportPhone: String = ""
    @objc dynamic var guid: String = ""
    @objc dynamic var date: String = ""
    @objc dynamic var bookingDateTime: String = ""
    @objc dynamic var offerId: Int = 0
    @objc dynamic var offerName: String = ""
    @objc dynamic var offerCode: String = ""
    @objc dynamic var bookingType: Int = 0
    @objc dynamic var bookingReference: String = ""
    @objc dynamic var tourId: Int = 0
    @objc dynamic var tourName: String = ""
    @objc dynamic var tourCode: String = ""
    @objc dynamic var hotelId: Int = 0
    @objc dynamic var timeSlotId: Int = 0
    @objc dynamic var hotelName: String = ""
    @objc dynamic var customPickUpPoint: String?
    @objc dynamic var roomNumber: String?
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var adults: Int = 0
    @objc dynamic var children: Int = 0
    @objc dynamic var infants: Int = 0
    @objc dynamic var pickUpTime: String = ""
    @objc dynamic var tourTime: String = ""
    @objc dynamic var totalCost: Double = 0
    @objc dynamic var guestName: String = ""
    @objc dynamic var publishedRatePerAdult: Double = 0
    @objc dynamic var publishedRatePerChild: Double = 0
    @objc dynamic var status: Int = 0
    @objc dynamic var remarks: String = ""
    @objc dynamic var paidToName: String?
    @objc dynamic var totalPaidFromBalance: Double = 0
    @objc dynamic var netRate: Double = 0
    @objc dynamic var netRateUsd: Double = 0
    @objc dynamic var downloadVoucherUrl: String?
    @objc dynamic var downloadInvoiceUrl: String?
    @objc dynamic var descriptionStr: String = ""
    @objc dynamic var id: Int = 0
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        notesToClientsPostBooking <- map["notesToClientsPostBooking"]
        cancellationPolicy <- (map["cancellationPolicy"], ListTransform<TourPolicyModel>())
        ticketsDetails <- map["ticketsDetails"]
        customerSupportPhone <- map["customerSupportPhone"]
        guid <- map["guid"]
        date <- map["date"]
        bookingDateTime <- map["bookingDateTime"]
        offerId <- map["offerId"]
        offerName <- map["offerName"]
        offerCode <- map["offerCode"]
        bookingType <- map["bookingType"]
        bookingReference <- map["bookingReference"]
        tourId <- map["tourId"]
        tourName <- map["tourName"]
        tourCode <- map["tourCode"]
        hotelId <- map["hotelId"]
        timeSlotId <- map["timeSlotId"]
        hotelName <- map["hotelName"]
        customPickUpPoint <- map["customPickUpPoint"]
        roomNumber <- map["roomNumber"]
        phoneNumber <- map["phoneNumber"]
        email <- map["email"]
        adults <- map["adults"]
        children <- map["children"]
        infants <- map["infants"]
        pickUpTime <- map["pickUpTime"]
        tourTime <- map["tourTime"]
        totalCost <- map["totalCost"]
        guestName <- map["guestName"]
        publishedRatePerAdult <- map["publishedRatePerAdult"]
        publishedRatePerChild <- map["publishedRatePerChild"]
        status <- map["status"]
        remarks <- map["remarks"]
        paidToName <- map["paidToName"]
        totalPaidFromBalance <- map["totalPaidFromBalance"]
        netRate <- map["netRate"]
        netRateUsd <- map["netRateUsd"]
        downloadVoucherUrl <- map["downloadVoucherUrl"]
        downloadInvoiceUrl <- map["downloadInvoiceUrl"]
        descriptionStr <- map["description"]
        id <- map["id"]
    }
    
    func isValid() -> Bool { return true }
}

class TicketDetailsModel: Object, Mappable {
    @objc dynamic var ticketCodeDisplayType: Int = 0
    @objc dynamic var ticketCode: String = ""
    @objc dynamic var downloadCodeLink: String = ""
    @objc dynamic var tickets: String? = nil

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        ticketCodeDisplayType <- map["ticketCodeDisplayType"]
        ticketCode <- map["ticketCode"]
        downloadCodeLink <- map["downloadCodeLink"]
        tickets <- map["tickets"]
    }
    func isValid() -> Bool { return true }

}

class HotelDetailsModel: Object, Mappable {
    
    // MARK: - Properties
    @objc dynamic var id: String = ""
    @objc dynamic var intCode: String = ""
    @objc dynamic var address: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var checkIn: String = ""
    @objc dynamic var checkOut: String = ""
    @objc dynamic var city: String = ""
    @objc dynamic var createdAt: String = ""
    @objc dynamic var updatedAt: String = ""
    @objc dynamic var descriptionText: String = ""
    @objc dynamic var latitude: String = ""
    @objc dynamic var longitude: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var roomCount: Int = 0
    @objc dynamic var type: String = ""
    @objc dynamic var zipCode: String = ""
    
    @objc dynamic var contact: HotelContactModel? = nil
    var images = List<HotelImageModel>()
    
    // MARK: - Init
    required convenience init?(map: Map) {
        self.init()
    }
    
    // MARK: - Mapping
    func mapping(map: Map) {
        id              <- map["_id"]
        intCode         <- map["intCode"]
        address         <- map["address"]
        category        <- map["category"]
        checkIn         <- map["checkIn"]
        checkOut        <- map["checkOut"]
        city            <- map["city"]
        createdAt       <- map["createdAt"]
        updatedAt       <- map["updatedAt"]
        descriptionText <- map["description"]
        latitude        <- map["latitude"]
        longitude       <- map["longitude"]
        name            <- map["name"]
        roomCount       <- map["roomCount"]
        type            <- map["type"]
        zipCode         <- map["zipCode"]
        contact         <- map["contact"]
        
        var imagesArray: [HotelImageModel]? = nil
        imagesArray <- map["images"]
        if let arr = imagesArray {
            images.removeAll()
            images.append(objectsIn: arr)
        }
    }
    
    func isValid() -> Bool {
        return !id.isEmpty && !name.isEmpty
    }
}

class HotelContactModel: Object, Mappable {
    @objc dynamic var phone: String = ""
    @objc dynamic var fax: String = ""
    @objc dynamic var email: String = ""
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        phone <- map["phone"]
        fax   <- map["fax"]
        email <- map["email"]
    }
}

class HotelImageModel: Object, Mappable {
    @objc dynamic var type: String = ""
    @objc dynamic var image: String = ""
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        type  <- map["type"]
        image <- map["image"]
    }
}

class JPHoleOptionData: Object, Mappable {
    @objc dynamic var code: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var start: String = ""
    @objc dynamic var end: String = ""
    @objc dynamic var hotelInfo: JPHotelInfoModel?
    @objc dynamic var board: JPBoardModel?
    @objc dynamic var prices: JPPriceModel?
    @objc dynamic var cancellationPolicy: JPCancellationPolicyWrapper?
    dynamic var offers: JPOfferModel?
    var rooms = List<JPHotelRoomModel>()
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        code  <- map["code"]
        status <- map["status"]
        start <- map["start"]
        end <- map["end"]
        hotelInfo <- map["hotelInfo"]
        board <- map["board"]
        prices <- map["prices"]
        cancellationPolicy <- map["cancellationPolicy"]
        offers <- map["offers"]
        rooms <- (map["rooms"], ListTransform<JPHotelRoomModel>())
    }
}

