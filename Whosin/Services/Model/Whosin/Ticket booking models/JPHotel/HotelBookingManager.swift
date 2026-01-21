import Foundation
import RealmSwift

let HOTELBOOKINGMANAGER = HotelBookingManager.shared

/// Manager for hotel booking flow, maintains a JPHotelBookingModel and booking state.
final class HotelBookingManager {
    
    // MARK: - Singleton
    static let shared = HotelBookingManager()
    private init() {}
    
    // MARK: - Model State
    /// The main booking model used for persistence and data transfer.
    private(set) var bookingModel = JPHotelBookingModel()
    
    /// Booking state for UI: start/end dates and selected option
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    var selectedRoomPaxes: [RoomPaxes] = []
    var selectedHotelOption: JPHotelAvailibilityOptionModel?
    var bookingRuls: JPBookingRulesData?
    var availibilityModel: JPHotelAvailibilityModel?
    
    /// Callback for observers (e.g. screens) to react to changes
    var onBookingChanged: (() -> Void)?
    
    // MARK: - Public API
    
    /// Save date and pax selection from DateAndPaxSelectionSheetVC
    func saveDateAndPaxes(startDate: Date?, endDate: Date?, ticketId: String, hotelCode: String, roomPaxes: [RoomPaxes]) {
        self.selectedStartDate = startDate
        self.selectedEndDate = endDate
        self.selectedRoomPaxes = roomPaxes

        // Update bookingModel
        bookingModel.bookingCode = hotelCode
        bookingModel.customTicketId = ticketId
        bookingModel.comment = ""
        bookingModel.tourDetails.removeAll()
        bookingModel.passengers.removeAll()
        
        // Add tour detail (room info)
        for (i, room) in roomPaxes.enumerated() {
            let detail = JPTourDetailModel()
            detail.tourId = hotelCode
            detail.optionId = nil
            detail.startTime = availibilityModel?.hotelInfo?.checkTime?.checkIn ?? ""
            detail.adult = room.pax.filter { $0.age >= 12 }.count
            detail.child = room.pax.filter { $0.age < 12 && $0.age >= 0 }.count
            detail.infant = 0
            bookingModel.tourDetails.append(detail)
        }
        onBookingChanged?()
    }
    
    /// Save selected hotel option from SelectHotelOptionVC
    func saveSelectedOption(_ option: JPHotelAvailibilityOptionModel?) {
        selectedHotelOption = option
        saveWhosinAndServiceTotals(option: option) // dedicated save method
        onBookingChanged?()
    }
    
    // MARK: - Save Whosin and Service Totals
    private func saveWhosinAndServiceTotals(option: JPHotelAvailibilityOptionModel?) {
        guard let option = option else { return }
        let nettPrice = option.price?.nett ?? ""
        bookingModel.amount = Double(nettPrice) ?? 0

        for detail in bookingModel.tourDetails {
            detail.startTime = availibilityModel?.hotelInfo?.checkTime?.checkIn ?? ""
            detail.whosinTotal = nettPrice
            detail.serviceTotal = nettPrice
        }
    }


    
    /// Clears the manager and resets the state
    func clearManager() {
        bookingModel = JPHotelBookingModel()
        selectedStartDate = nil
        selectedEndDate = nil
        selectedRoomPaxes.removeAll()
        selectedHotelOption = nil
        onBookingChanged?()
    }
    
    /// Set additional passenger info if needed
    func setPassengerModels(_ passengers: [JPPassengerModel]) {
        bookingModel.passengers.removeAll()
        bookingModel.passengers.append(objectsIn: passengers)
        onBookingChanged?()
    }
    
    /// Validation for completeness
    func isValid() -> Bool {
        // Add more robust validation as needed
        return !bookingModel.tourDetails.isEmpty && selectedHotelOption != nil
    }
    
    /// Save required hotel booking fields (from booking rules) to the booking model
    func saveRequiredFields(from requiredFields: JPHotelBookingRequiredFields?, cancellationPolicy: [JPCancellationPolicyModel]?) {
        guard let requiredFields = requiredFields else { return }
        let model = bookingModel
        model.bookingCode = requiredFields.bookingCode
        model.customTicketId = BOOKINGMANAGER.ticketModel?._id ?? ""
        model.comment = ""
        model.amount = Double(bookingRuls?.priceInformation.first?.price?.nett ?? "0") ?? 0
        model.priceRange = requiredFields.priceRange
        model.passengers.removeAll()
        model.passengers.append(objectsIn: requiredFields.paxes)
        model.relPaxesDist.removeAll()
        model.relPaxesDist.append(objectsIn: requiredFields.relPaxesDist)
        model.tourDetails.removeAll()
        let detail = JPTourDetailModel()
        detail.tourId = requiredFields.hotelCode
        if detail.adult == 0 { detail.adult = selectedRoomPaxes.first?.pax.filter { $0.age >= 12 }.count ?? 0 }
        if detail.child == 0 { detail.child = selectedRoomPaxes.first?.pax.filter { $0.age < 12 && $0.age >= 0 }.count ?? 0 }
        detail.startDate = requiredFields.startDate
        detail.endDate = requiredFields.endDate
        detail.startTime = availibilityModel?.hotelInfo?.checkTime?.checkIn ?? ""
        detail.serviceTotal = selectedHotelOption?.price?.nett ?? ""
        detail.whosinTotal = selectedHotelOption?.price?.nett ?? ""
        model.tourDetails.append(detail)
        if let priceRange = requiredFields.priceRange {
            model.currency = APPSESSION.userDetail?.currency ?? "aed"
        }
        if let cancellationPolicy = cancellationPolicy {
            model.cancellationPolicy.removeAll()
            model.cancellationPolicy.append(objectsIn: cancellationPolicy)
        }
        onBookingChanged?()
    }
    
    public func validateMembers() -> String? {
        for (index, model) in bookingModel.passengers.enumerated() {
            let paxTypeText = model.paxType.capitalized // "Adult" or "Child"
            let paxNumber = index + 1                  // 1-based index
            let prefix = "\(paxTypeText) \(paxNumber):"
            
            // First Name
            if model.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "\(prefix) " + "please_enter_first_name".localized()
            }
            
            // Last Name
            if model.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "\(prefix) " + "please_enter_last_name".localized()
            }
            
            // Age
            if model.age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "\(prefix) " + "please_enter_age".localized()
            }
            if let intAge = Int(model.age), intAge < 0 || intAge > 120 {
                return "\(prefix) " + "please_enter_valid_age".localized()
            }
            
            // Email
            if model.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "\(prefix) " + "please_enter_email".localized()
            }
            if !Utils.isValidEmail(model.email) {
                return "\(prefix) " + "please_enter_valid_email".localized()
            }
            
            // Mobile
            if model.mobile.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "\(prefix) " + "please_enter_mobile_number".localized()
            }
            if model.mobile.count < 6 {
                return "\(prefix) " + "please_enter_valid_mobile_number".localized()
            }
            
            // Country Code
            if model.countryCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "\(prefix) " + "please_select_country_code".localized()
            }
            
            // Nationality
            if model.nationality.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "\(prefix) " + "please_select_nationality".localized()
            }
        }
        
        return nil // ✅ All passengers are valid
    }

    public func calculateTourTotals(promo: PromoBaseModel?) -> TourPriceSummary {
        var totalAmount: Double = 0
        var priceToPay: Double = 0
        var pricePerTrip: Double = 0
        var pricePerTripWithoutdiscount: Double = 0
                
        totalAmount = Double(selectedHotelOption?.price?.nett ?? "0") ?? 0
        priceToPay = Double(selectedHotelOption?.price?.nett ?? "0") ?? 0
        
        let discountPrice: Double = {
            if let promo = promo {
                return promo.itemsDiscount.formatted()
            } else {
                return totalAmount - priceToPay
            }
        }()
        
        let priceWithPromo: Double = {
            if let promo = promo {
                return promo.metadata.first?.finalAmount.formatted() ?? priceToPay
            } else {
                return priceToPay
            }
        }()
        
        return TourPriceSummary(
            totalAmount: totalAmount,
            priceToPay: priceToPay,
            discountPrice: discountPrice < 0 ? 0 : discountPrice,
            priceWithPromo: priceWithPromo,
            pricePerTrip: pricePerTrip, totalAddOnAmout: 0)
    }

}
