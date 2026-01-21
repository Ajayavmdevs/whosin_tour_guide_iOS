import UIKit
import Alamofire

let ADSETTING = AdSettingManager.shared

class AdSettingManager: NSObject {
    
    var adList: [AdListModel]?
    var banners: PromotionalBannerModel?
    var showCount: [String:Any] = [:]
    private var adRequestTask: DataRequest?
    
    var getAd: AdListModel? {
        guard let _adList = adList else { return nil}
        let randomNumber = Int(arc4random_uniform(UInt32(_adList.count)))
        if(randomNumber < _adList.count) {
            return _adList[randomNumber]
        }
        return nil
    }

    // -------------------------------------
    // MARK: Singleton
    // --------------------------------------
    
    class var shared: AdSettingManager {
        struct Static {
            static let instance = AdSettingManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func requestAdSetting(completion: @escaping ([AdListModel]?) -> Void) {
        self.adRequestTask?.cancel()
        self.adRequestTask = WhosinServices.adVideoList { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else {
                completion(nil)
                return
            }
            self.adList = data
            completion(data)
        }
    }

    
    public func requestPromotionBanner(completion: @escaping ([[String: Any]]) -> Void) {
        WhosinServices.promotionalBanner { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else {
                completion([])
                return
            }

            self.banners = data
            let bannerCells: [[String: Any]] = data.list.map { model in
                return [
                    kCellIdentifierKey: BannerAdsTableCell.identifier,
                    kCellTagKey: "promotionBanner",
                    kCellAllowCacheKey: false,
                    kCellObjectDataKey: model,
                    kCellClassKey: BannerAdsTableCell.self,
                    kCellHeightKey: BannerAdsTableCell.height(model.size?.ratio ?? "1:1")
                ]
            }
            completion(bannerCells)
        }
    }

    
    public func requestAdSetting() {
        WhosinServices.adList { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.adList = data
        }
    }

}
