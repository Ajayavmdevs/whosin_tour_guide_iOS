import Foundation
import ObjectMapper
import RealmSwift

class BucketListModel: Mappable, ModelProtocol {

    dynamic var buckets: [BucketDetailModel] = []
    dynamic var users: [UserDetailModel] = []
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    

    required init?(map _: Map) {}
    
    func mapping(map: Map) {
        buckets <- map["buckets"]
        users <- map["users"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}


class MyBucketModel:Object, Mappable, ModelProtocol {

    @objc dynamic var id: String = "1"
    dynamic var bucketList = List<BucketDetailModel>()
    dynamic var outings = List<OutingListModel>()
    dynamic var events = List<EventModel>()
    dynamic var deals = List<DealsModel>()
    
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
        bucketList <- (map["buckets"],ListTransform<BucketDetailModel>())
        outings <- (map["outings"],ListTransform<OutingListModel>())
        events <- (map["events"],ListTransform<EventModel>())
        deals <- (map["deals"],ListTransform<DealsModel>())
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------

    func isValid() -> Bool {
        return true
    }
    
}
