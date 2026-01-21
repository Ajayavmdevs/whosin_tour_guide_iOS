import RealmSwift
import ObjectMapper

class HomeRepository: Repository {
    
    func getHome(shouldRefresh: Bool = false, callback: @escaping(_ model: HomeModel?, _ error: NSError?) -> Void) {
        
//        if !shouldRefresh {
//            if let model = Mapper<HomeModel>().map(JSONString: Preferences.homeBlock) {
//                callback(model, nil)
//            }
//        }
//        
        WhosinServices.getHome(shouldRefresh: shouldRefresh) { container, error in
            guard let data = container?.data else {
                callback(nil, error)
                return
            }
            if let json = data.toJSONString() {
                Preferences.homeBlock = json
            }
            callback(data, nil)
        }
    }
    
    class func getStoryList() -> [VenueDetailModel]? {
        if let model = Mapper<HomeModel>().map(JSONString: Preferences.homeBlock) {
            return model.storiesModel.toArrayDetached(ofType: VenueDetailModel.self)
        }
        return nil
    }
    
    class func getStoryByVenueId(_ venueId:String) -> VenueDetailModel? {
        if let model = Mapper<HomeModel>().map(JSONString: Preferences.homeBlock) {
            let story = model.storiesModel.toArrayDetached(ofType: VenueDetailModel.self).first(where: {$0.id == venueId})
            return story;
        }
        return nil
    }

    class func getStoryArrayByVenueId(_ venueId:String) -> [VenueDetailModel]? {
        if let model = Mapper<HomeModel>().map(JSONString: Preferences.homeBlock) {
            guard let story = model.storiesModel.toArrayDetached(ofType: VenueDetailModel.self).first(where: {$0.id == venueId}) else { return nil }
            return [story]
        }
        return nil
    }
}

