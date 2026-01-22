import Foundation
import ObjectMapper
import RealmSwift

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
