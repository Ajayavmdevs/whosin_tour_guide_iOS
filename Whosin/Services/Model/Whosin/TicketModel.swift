import Foundation
import ObjectMapper
import RealmSwift

class TicketModel: Object, Mappable, ModelProtocol, Identifiable {

    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var descriptions: String = kEmptyString
    @objc dynamic var badge: String = kEmptyString
    @objc dynamic var city: String = kEmptyString
    dynamic var images: List<String> = List<String>()
    @objc dynamic var bookingType: String = kEmptyString
    @objc dynamic var isFreeCancellation: Bool = false
    @objc dynamic var title: String = kEmptyString
    @objc dynamic var code: String = kEmptyString
    @objc dynamic var cancellationPolicyText: String = kEmptyString
    @objc dynamic var startingAmount: Double = 0
    @objc dynamic var discount: Int = 0
    dynamic var categoryIds = List<String>()
    dynamic var subCategoryIds = List<String>()
    dynamic var cancellationPolicy = List<String>()
    dynamic var status: String = kEmptyString
    dynamic var cancellationPolicyRules = List<String>()
    dynamic var features = List<CommonSettingsModel>()
    dynamic var whatsInclude = List<CommonSettingsModel>()
    dynamic var tourData: TourDataModel?
    dynamic var juniperTourData: List<ServiceModel> = List<ServiceModel>()
    dynamic var jpHotelTourData: List<JPHotelOptionModel> = List<JPHotelOptionModel>()
    dynamic var tourOptionData = List<TourOptionDataModel>()
    dynamic var optionData = List<TourOptionsModel>()
    dynamic var tourOption = List<TourOptionsModel>()
    dynamic var options = List<TourOptionsModel>()
    dynamic var travelOtions = List<TravelDeskTourModel>()
    dynamic var travelDeskTourData = List<TravelDeskTourModel>()
    dynamic var whosinModuleTourData = List<WhosinModule>()
    dynamic var bigBusTourData = List<BigBusTourModel>()
    @objc dynamic var tourId: String = kEmptyString
    @objc dynamic var contractId: String = kEmptyString
    @objc dynamic var disableChild: Bool = false
    @objc dynamic var disableInfant: Bool = false
    @objc dynamic var allowAdult: Bool = false
    @objc dynamic var allowChild: Bool = false
    @objc dynamic var allowInfant: Bool = false
    @objc dynamic var isEnableRating: Bool = false
    @objc dynamic var isEnableReview: Bool = false
    @objc dynamic var isReviewVisible: Bool = false
    @objc dynamic var vat: Bool = false
    @objc dynamic var adultAge: String = kEmptyString
    @objc dynamic var cancellationPolicyDescription: String = kEmptyString
    @objc dynamic var childAge: String = kEmptyString
    @objc dynamic var childPolicy: String = kEmptyString
    @objc dynamic var inclusion: String = kEmptyString
    @objc dynamic var overview: String = kEmptyString
    @objc dynamic var infantAge: String = kEmptyString
    @objc dynamic var markup: Double = 0
    @objc dynamic var vatPercentage: Double = 0
    @objc dynamic var maximumPax: String = "0"
    @objc dynamic var minimumPax: String = "0"
    @objc dynamic var customMessage: String = kEmptyString
    @objc dynamic var currentUserReview: TicketReviewModel?
    dynamic var reviews = List<TicketReviewModel>()
    dynamic var users = List<UserModel>()
    @objc dynamic var avg_ratings: Double = 0.0
    @objc dynamic var importantInformation: String = kEmptyString
    @objc dynamic var usefulInformation: String = kEmptyString
    @objc dynamic var tourExclusion: String = kEmptyString
    @objc dynamic var faqDetails: String = kEmptyString
    @objc dynamic var howToRedeem: String = kEmptyString
    @objc dynamic var departurePoint: String = kEmptyString
    @objc dynamic var googleMapUrl: String = kEmptyString
    @objc dynamic var raynaToursAdvantage: String = kEmptyString
    @objc dynamic var startingAmountWithoutDiscount: Double = 0.0
    @objc dynamic var meal: String = kEmptyString
    @objc dynamic var cityTourType: String = kEmptyString
    @objc dynamic var duration: String = kEmptyString
    @objc dynamic var bookingEndDate: Date?
    @objc dynamic var bookingStartDate: Date?
    @objc dynamic var location: LocationModel?
    dynamic var bookingDates = List<BookingDatesModel>()
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kStanderdDate)
    @objc dynamic var isFavourite: Bool = false
    dynamic var tags = List<String>()
    dynamic var contactUsBlock: ContactUsModel?

    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    override class func primaryKey() -> String? {
        "_id"
    }

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        _id <- map["_id"]
        descriptions <- map["description"]
        badge <- map["badge"]
        city <- map["city"]
        bookingType <- map["bookingType"]
        isFreeCancellation <- map["isFreeCancellation"]
        title <- map["title"]
        code <- map["code"]
        customMessage <- map["customMessage"]
        startingAmount <- map["startingAmount"]
        images <- (map["images"], StringListTransform())
        categoryIds <- (map["categoryIds"], StringListTransform())
        subCategoryIds <- (map["subCategoryIds"], StringListTransform())
        cancellationPolicy <- (map["cancellationPolicy"], StringListTransform())
        cancellationPolicyText <- map["cancellationPolicy"]
        status <- map["status"]
        cancellationPolicyRules <- (map["cancellationPolicyRules"], StringListTransform())
        features <- (map["features"], ListTransform<CommonSettingsModel>())
        whatsInclude <- (map["whatsInclude"], ListTransform<CommonSettingsModel>())
        tourOptionData <- (map["tourOptionData"], ListTransform<TourOptionDataModel>())
        optionData <- (map["optionData"], ListTransform<TourOptionsModel>())
        tourOption <- (map["tourOptions"], ListTransform<TourOptionsModel>())
        options <- (map["options"], ListTransform<TourOptionsModel>())
        travelOtions <- (map["options"], ListTransform<TravelDeskTourModel>())
        tourId <- map["tourId"]
        contractId <- map["contractId"]
        discount <- map["discount"]
        disableChild <- map["disableChild"]
        disableInfant <- map["disableInfant"]
        allowAdult <- map["allowAdult"]
        allowChild <- map["allowChild"]
        allowInfant <- map["allowInfant"]
        isEnableRating <- map["isEnableRating"]
        isEnableReview <- map["isEnableReview"]
        isReviewVisible <- map["isReviewVisible"]
        vat <- map["vat"]
        adultAge <- map["adultAge"]
        cancellationPolicyDescription <- map["cancellationPolicyDescription"]
        childAge <- map["childAge"]
        childPolicy <- map["childPolicy"]
        inclusion <- map["inclusion"]
        overview <- map["overview"]
        infantAge <- map["infantAge"]
        markup <- map["markup"]
        vatPercentage <- map["vatPercentage"]
        maximumPax <- map["maximumPax"]
        minimumPax <- map["minimumPax"]
        reviews <- (map["reviews"], ListTransform<TicketReviewModel>())
        users <- (map["users"], ListTransform<UserModel>())
        avg_ratings <- map["avg_ratings"]
        currentUserReview <- map["currentUserReview"]
        importantInformation <- map["importantInformation"]
        usefulInformation <- map["usefulInformation"]
        tourExclusion <- map["tourExclusion"]
        faqDetails <- map["faqDetails"]
        howToRedeem <- map["howToRedeem"]
        departurePoint <- map["departurePoint"]
        googleMapUrl <- map["googleMapUrl"]
        raynaToursAdvantage <- map["raynaToursAdvantage"]
        meal <- map["meal"]
        location <- map["location"]
        isFavourite <- map["is_favorite"]
        cityTourType <- map["cityTourType"]
        duration <- map["duration"]
        startingAmountWithoutDiscount <- map["startingAmountWithoutDiscount"]
        bookingDates <- (map["bookingDates"], ListTransform<BookingDatesModel>())
        bookingEndDate <- (map["bookingEndDate"], DateFormatterTransform(dateFormatter: _dateFormatter))
        bookingStartDate <- (map["bookingStartDate"], DateFormatterTransform(dateFormatter: _dateFormatter))
        tags <- (map["tags"], StringListTransform())
        contactUsBlock <- map["contactUsBlock"]
        if bookingType == "big-bus" || bookingType == "hero-balloon" {
            bigBusTourData <- (map["tourData"], ListTransform<BigBusTourModel>())
        } else if bookingType == "travel-desk" {
            travelDeskTourData <- (map["tourData"], ListTransform<TravelDeskTourModel>())
        } else if bookingType == "whosin-ticket" {
            whosinModuleTourData <- (map["tourData"], ListTransform<WhosinModule>())
        } else if bookingType == "juniper" {
            juniperTourData <- (map["tourData"], ListTransform<ServiceModel>())
        } else if bookingType == "hotel" {
            jpHotelTourData <- (map["tourData"], ListTransform<JPHotelOptionModel>())
        } else {
            tourData <- map["tourData"]
        }
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
    var isRefundable: Bool {
        let plainText = cancellationPolicyText
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return !plainText.contains("non refundable")
    }

    
    var discountValue: Int {
        return Utils.calculateDiscountValueInt(originalPrice: Int(startingAmount.roundedValue()), discountPercentage: discount)
    }
    
    var hasDiscount: Bool {
        return startingAmountWithoutDiscount > startingAmount
    }

    
    var maxPax: Int {
        return maximumPax == "NA" ? 1000 : Int(maximumPax) ?? 1000
    }
    
    var minPax: Int {
        return minimumPax == "NA" ? 0 : Int(minimumPax) ?? 0
    }
    
    func getVatPrice(_ price: Double) -> String {
//        let vatAmount = vat ? (price * vatPercentage) / 100 : 0.0
        return String(format: "%.2f", 0.0)
    }
    
    func getPriceWithMarkup(_ price: Double) -> String {
        return String(format: "%.2f", price)
    }
    
    func getTotalPrice(_ price: Double) -> String {
        return String(format: "%.2f", price.roundedValue())
    }
    
    public func dateRange(_ isTodayBooking: Bool = true, validDays: [String], option: TourOptionsModel, isWhosin: Bool = false) -> [Date] {
        var availableDates: [Date] = []
        let calendar = Calendar.current
        let today = Date()

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"

        var bookingRanges: [(start: Date, end: Date)] = []
        if let startDate = option.startDate, let endDate = option.endDate {
                bookingRanges.append((start: startDate, end: endDate))
        } else if option.optionDetail?.bookingDates.isEmpty == false, let bookingDates = option.optionDetail?.bookingDates {
            for booking in bookingDates {
                guard let parsedBookingStart = booking.fromDate
                        ,let parsedBookingEnd =  booking.toDate else {
                    continue
                }
                bookingRanges.append((start: parsedBookingStart, end: parsedBookingEnd))
            }
        } else if !bookingDates.isEmpty {
            for booking in bookingDates {
                guard let parsedBookingStart = booking.startDate
                        ,let parsedBookingEnd =  booking.endDate else {
                    continue
                }
                bookingRanges.append((start: parsedBookingStart, end: parsedBookingEnd))
            }
        } else {
            let defaultEndDate = calendar.date(byAdding: .day, value: 364, to: today) ?? today
            bookingRanges.append((start: today, end: defaultEndDate))
        }

        for range in bookingRanges {
            var currentDate = range.start

            if !isTodayBooking && Calendar.current.isDate(currentDate, inSameDayAs: today) {
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = nextDay
                }
            }

            while currentDate <= range.end {
                let dayString = formatter.string(from: currentDate).lowercased()
                if validDays.count == 0 && (Calendar.current.isDate(currentDate, inSameDayAs: today) || currentDate > today) && !isWhosin {
                    availableDates.append(currentDate)
                } else {
                    if validDays.contains(dayString) && (Calendar.current.isDate(currentDate, inSameDayAs: today) || currentDate > today) {
                        availableDates.append(currentDate)
                    }
                }
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = nextDate
            }
        }

        return availableDates
    }
    
    public func dateRange(_ isTodayBooking: Bool = true, validDays: [String], option: BigBusOptionsModel) -> [Date] {
        var availableDates: [Date] = []
        let calendar = Calendar.current
        let today = Date()

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"

        var bookingRanges: [(start: Date, end: Date)] = []
        if let startDate = option.availabilityLocalDateStart.toDate(), let endDate = option.availabilityLocalDateEnd.toDate() {
                bookingRanges.append((start: startDate, end: endDate))
        } else if let startDate = option.availabilityLocalDateStart.toDate(), option.availabilityLocalDateEnd.toDate() == nil {
            let defaultEnd = calendar.date(byAdding: .day, value: 364, to: today) ?? today
            bookingRanges.append((start: startDate, end: defaultEnd))
        } else if let endDate = option.availabilityLocalDateEnd.toDate(), option.availabilityLocalDateStart.toDate() == nil {
            bookingRanges.append((start: today, end: endDate))
        } else if !bookingDates.isEmpty {
            for booking in bookingDates {
                guard let parsedBookingStart = booking.startDate
                        ,let parsedBookingEnd =  booking.endDate else {
                    continue
                }
                bookingRanges.append((start: parsedBookingStart, end: parsedBookingEnd))
            }
        } else {
            let defaultEndDate = calendar.date(byAdding: .day, value: 364, to: today) ?? today
            bookingRanges.append((start: today, end: defaultEndDate))
        }

        for range in bookingRanges {
            var currentDate = range.start

            if !isTodayBooking && Calendar.current.isDate(currentDate, inSameDayAs: today) {
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = nextDay
                }
            }

            while currentDate <= range.end {
                let dayString = formatter.string(from: currentDate).lowercased()
                if validDays.count == 0 && (Calendar.current.isDate(currentDate, inSameDayAs: today) || currentDate > today) {
                    availableDates.append(currentDate)
                } else {
                    if validDays.contains(dayString) && (Calendar.current.isDate(currentDate, inSameDayAs: today) || currentDate > today) {
                        availableDates.append(currentDate)
                    }
                }
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = nextDate
            }
        }

        return availableDates
    }

    public func dateRange(from startDate: String, to endDate: String, isTodayBooking: Bool = true, validDays: [String]) -> [Date] {
        var availableDates: [Date] = []
        let calendar = Calendar.current
        let today = Date()

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"

        let bookingStart = startDate.toDate()
        let bookingEnd = endDate.toDate()

        let defaultEnd = calendar.date(byAdding: .day, value: 364, to: today) ?? today

        let start = bookingStart ?? today
        let end = min(bookingEnd ?? defaultEnd, defaultEnd)

        var currentDate = start

        if !isTodayBooking && calendar.isDate(currentDate, inSameDayAs: today) {
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDay
            }
        }

        while currentDate <= end {
            let dayString = formatter.string(from: currentDate).lowercased()
            if validDays.count == 0 && currentDate >= today  {
                availableDates.append(currentDate)
            } else {
                if validDays.contains(dayString) && currentDate >= today {
                    availableDates.append(currentDate)
                }
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return availableDates
    }
    
    var differenceIdentifier: String {
        return _id
    }
    
    func isContentEqual(to source: TicketModel) -> Bool {
        return self._id == source._id && self.title == source.title && self.descriptions == source.descriptions && self.images == source.images
    }


}


class TicketReviewModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var _id: String = kEmptyString
    @objc dynamic var userId: String = kEmptyString
    @objc dynamic var review: String = kEmptyString
    @objc dynamic var createdAt: Date?
    @objc dynamic var isDeleted: Bool = false
    @objc dynamic var stars: Int = 0
    
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kFormatDateStandard)
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "_id"
    }
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        _id <- map["_id"]
        userId <- map["userId"]
        stars <- map["stars"]
        review <- map["review"]
        isDeleted <- map["isDeleted"]
        createdAt <- (map["createdAt"], DateFormatterTransform(dateFormatter: _dateFormatter))
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
    
}


class BookingDatesModel: Object, Mappable, ModelProtocol {
    
    @objc dynamic var startDate: Date?
    @objc dynamic var endDate: Date?
    @objc dynamic var fromDate: Date?
    @objc dynamic var toDate: Date?
    @objc dynamic var tourId: Int = 0
    @objc dynamic var tourOptionId: Int = 0
    
    private let _dateFormatter = DATEFORMATTER.dateFormatterWith(format: kFormatDate)
    private let fallbackFormatter = DATEFORMATTER.dateFormatterWith(format: kStanderdDate)
    private let optionFormatter = DATEFORMATTER.dateFormatterWith(format: "yyyy-MM-dd'T'HH:mm:ss")
    
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
        
        var startDateString: String?
        var endDateString: String?
        var fromDateString: String?
        var toDateString: String?
        
        startDateString <- map["startDate"]
        endDateString <- map["endDate"]
        fromDateString <- map["fromDate"]
        toDateString <- map["toDate"]
        tourId <- map["tourId"]
        tourOptionId <- map["tourOptionId"]

        if let startString = startDateString {
            startDate = _dateFormatter.date(from: startString) ?? fallbackFormatter.date(from: startString)
        }
        
        if let fromString = fromDateString {
            fromDate = optionFormatter.date(from: fromString) ?? fallbackFormatter.date(from: fromString)
        }

        if let endString = endDateString {
            endDate = _dateFormatter.date(from: endString) ?? fallbackFormatter.date(from: endString)
        }
        
        if let toString = toDateString {
            toDate = optionFormatter.date(from: toString) ?? fallbackFormatter.date(from: toString)
        }
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
    
}
