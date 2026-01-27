import Foundation
import CoreLocation
import ObjectMapper
import DialCountries
//import INTULocationManager
import UIKit
import SwiftLocation

let APPSETTING = AppSettingsManager.shared

class AppSettingsManager: NSObject {
    
    var oncartChange: (() -> Void)?
    var currentLocation : CLLocation?
    var uploadedImage: UIImage?
    var appSetiings: SettingsModel?
    var cuisine: [CommonSettingsModel] = []
    var music: [CommonSettingsModel] = []
    var feature: [CommonSettingsModel] = []
    var themes: [CommonSettingsModel] = []
    var membershipPackage: [MembershipPackageModel]?
    var userModel: UserDetailModel?
    var venueModel: [VenueDetailModel]?
    var users: [UserDetailModel]?
    var followingList: [UserDetailModel]?
    var pendingRequestList: [UserDetailModel] = []
    var loginRequests: [LoginApprovalModel] = []
    var categories: [CategoryDetailModel]?
    var ticketCategories: [CategoryDetailModel]?
    var ticketList: [TicketModel]?
    var myVenueList: [VenueDetailModel] = []
    var subAdmins: [UserDetailModel] = []
    var cityList: [CategoryDetailModel]?
    var exploreCategories: [CategoryDetailModel]?
    var exploreBanners: [ExploreBannerModel]?
    var customComponent: [ExploreBannerModel]?
    var inAppModel: IANComponentModel?
    var currencies: [CurrenciesModel] = []
    var languages: [LanguagesModel] = []
    var ticketCartModel: TicketCartListModel? {
        didSet {
            oncartChange?()
        }
    }


    // -------------------------------------
    // MARK: Singleton
    // --------------------------------------

    class var shared: AppSettingsManager {
        struct Static {
            static let instance = AppSettingsManager()
        }
        return Static.instance
    }

    override init() {
        super.init()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    func _requestAppSetting(callback: ((_ success: Bool) -> Void)? = nil) {
        WhosinServices.getSettings { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.appSetiings = data
            self.cuisine = data.cuisine
            self.music = data.music
            self.feature = data.feature
            self.themes = data.themes
            self.membershipPackage = data.membershipPackage
            self.currencies = data.currencies
            self.languages = data.languages
            self.loginRequests = data.loginRequests
            if callback != nil {
                callback?(true)
            }
        }
    }
    
    func _getProfile() {
        APPSESSION.getProfile { [weak self] success, error in
            guard let self = self else { return }
            if APPSESSION.userDetail?.isPromoter == true {
                Preferences.profileType = ProfileType.promoterProfile
            } else if APPSESSION.userDetail?.isRingMember == true {
                Preferences.profileType = ProfileType.complementaryProfile
            } else if APPSESSION.userDetail?.roleAcess.first?.type == "promoter-subadmin" {
                Preferences.profileType = ProfileType.promoterProfile
            } else {
                Preferences.profileType = ProfileType.profile
            }
        }
    }
    
    private func _requestSubscriptionDetail(completion: @escaping () -> Void) {
        WhosinServices.subscriptionDetail { [weak self] container, error in
            defer { completion() }
            guard self != nil else { return }
            guard (container?.data) != nil else { return }
            NotificationCenter.default.post(name: .changeSubscriptionState, object: nil)
        }
    }

    private func _updateUserLoaction(lat: Double, lng: Double) {
        if !APPSESSION.didLogin { return }
        WhosinServices.updateUserLocation(lat: lat, lng: lng) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.userModel = data
        }
    }
    
    public func _getBlockList() {
        WhosinServices.getBlockList { [weak self] container, error in
            guard let self = self else{ return}
            guard let data = container?.data else { return }
            for user in data {
                if !Preferences.blockedUsers.contains(user.id) {
                    Preferences.blockedUsers.append(user.id)
                }
            }
        }
    }
    
    public func _getReportList() {
        WhosinServices.reportedUserList { [weak self] container, error in
            guard let self = self else{ return}
            guard let data = container?.data else { return }
            for user in data {
                if !Preferences.blockedUsers.contains(user.userId) {
                    Preferences.blockedUsers.append(user.userId)
                }
            }
        }
    }
    
    
    // --------------------------------------
    // MARK: Getter
    // --------------------------------------
    
    var latitude: Double {
        currentLocation?.coordinate.latitude ?? 28.7426
    }

    var longitude: Double {
        currentLocation?.coordinate.longitude ?? 78.0839
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    
    func configureSubscrition() {
        let group = DispatchGroup()

        group.enter()
        _requestSubscriptionDetail {
            group.leave()
        }

        group.notify(queue: .main) {
            print("🎉 Both subscription and promo APIs completed")
        }
    }
    
    func configure() {
        DispatchQueue.global(qos: .background).async {
            self._requestAppSetting()
            self._getProfile()
            self._getReportList()
            self._getBlockList()
        }
//        configureSubscrition()
    }
    
    func configoreLocation() {
        if let lastLocation = SwiftLocation.lastKnownGPSLocation {
            self.currentLocation = lastLocation
        }
        self.fetchCurrentLocation()
    }
    
    private func fetchCurrentLocation() {
        SwiftLocation.gpsLocationWith {
            $0.subscription = .significant
            $0.precise = .reducedAccuracy
            $0.accuracy = .block
        }.then { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let cLocation):
                guard CLLocationCoordinate2DIsValid(cLocation.coordinate) else {
                    print("Invalid location coordinate")
                    return
                }
                DispatchQueue.main.async {
                    let safeLocation = CLLocation(latitude: cLocation.coordinate.latitude,
                                                  longitude: cLocation.coordinate.longitude)
                    self.handleNewLocation(safeLocation)
                }
            case .failure(let error):
                print("Error fetching location: \(error.localizedDescription)")
            }
        }
    }

    
    private func handleNewLocation(_ newLocation: CLLocation) {
        let safeLocation = CLLocation(latitude: newLocation.coordinate.latitude,
                                      longitude: newLocation.coordinate.longitude)
        let oldLocation = self.currentLocation

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            var shouldUpdate = false
            if let oldLoc = oldLocation {
                let localOld = CLLocation(latitude: oldLoc.coordinate.latitude,
                                          longitude: oldLoc.coordinate.longitude)
                shouldUpdate = safeLocation.distance(from: localOld) >= 100
            } else {
                shouldUpdate = true
            }

            guard shouldUpdate else { return }

            DispatchQueue.main.async {
                self.currentLocation = safeLocation
                self._updateUserLoaction(lat: safeLocation.coordinate.latitude,
                                         lng: safeLocation.coordinate.longitude)
                NotificationCenter.default.post(name: .updateLocationState, object: nil)
            }
        }
    }


    
    public var searchHistory: [SearchHistoryModel] {
        guard let history = Mapper<SearchHistoryModel>().mapArray(JSONString: Preferences.searchHistory) else {
            return []
        }
        return history
    }
    
    public func addSearchHistory(id: String, title: String, subtitle: String, type: String, image: String, venueId: String = kEmptyString) {
        let historyModel = SearchHistoryModel()
        historyModel.id = id
        historyModel.title = title
        historyModel.subtitle = subtitle
        historyModel.type = type
        historyModel.image = image
        historyModel.venueId = venueId
        
        if let existingData = APPSETTING.searchHistory.first(where: { $0.id == id }) {
            APPSETTING.removeSearchHistory(existingData)
        }
        
        var current = searchHistory
        current.insert(historyModel, at: 0)
        Preferences.searchHistory = current.toJSONString() ?? kEmptyString
    }
    
    public func removeSearchHistory(_ model: SearchHistoryModel) {
        var current = searchHistory
        if let index = current.firstIndex(where: { $0.id == model.id }) {
            current.remove(at: index)
            Preferences.searchHistory = current.toJSONString() ?? kEmptyString
        }
    }
    
    public func removeAllSearchHistory() {
        Preferences.searchHistory.removeAll()
    }
}
