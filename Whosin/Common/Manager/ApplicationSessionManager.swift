import Foundation
import AVFoundation
import UIKit
import ObjectMapper
import FAPanels
import DeviceKit
import PINCache
import Amplitude
import OneSignalCore
import OneSignalFramework

let APPSESSION = ApplicationSessionManager.shared

class ApplicationSessionManager: NSObject {
    
    
    // -------------------------------------
    // MARK: Singleton
    // --------------------------------------
    
    class var shared: ApplicationSessionManager {
        struct Static {
            static let instance = ApplicationSessionManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
    }
    
    // --------------------------------------
    // MARK: Acccesors
    // --------------------------------------
    
    public var didLogin: Bool {
        Preferences.didLogin
    }
    
    public var userId: String {
        Preferences.userId
    }
    
    public var isAuthenticationPending: Bool {
        Preferences.isAuthenticationPending
    }
    
    public var type: String {
        Preferences.type
    }
        
    public var addToCart: Int {
        Preferences.addedToCart
    }
    
    public var userDetail: UserDetailModel? {
        if Preferences.userDetailModel.isEmpty {
            return nil
        }
        guard let members = Mapper<UserDetailModel>().map(JSONString: Preferences.userDetailModel)else {
            return nil
        }
        return members
    }
    
    public var promoterProfile: PromoterProfileModel? {
        if Preferences.promoterProfile.isEmpty {
            return nil
        }
        guard let promoter = Mapper<PromoterProfileModel>().map(JSONString: Preferences.promoterProfile)else {
            return nil
        }
        return promoter
    }
    
    public var CMProfile: PromoterProfileModel? {
        if Preferences.cmProfile.isEmpty {
            return nil
        }
        guard let members = Mapper<PromoterProfileModel>().map(JSONString: Preferences.cmProfile)else {
            return nil
        }
        return members
    }
    
    public var preferences: PrefrencesModel {
        guard let members = Mapper<PrefrencesModel>().map(JSONString: Preferences.preferencesModel)else {
            return self.preferences
        }
        return members
    }
    
    public var token: String {
        String(format: "Bearer %@", Preferences.token.trim)
    }
    
    public var notificationCount: Int = 0
    public var getUpdateModel: GetUpdatesModel?
    public var didCloseMiniPlayer = false
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func newLoginUser(params: [String: Any], callback: BooleanResult?) {
        WhosinServices.newLoginUser(params: params) { [weak self] model, error in
            guard let self = self else { return }
            guard let model = model, model.isSuccess, let data = model.data else {
                callback?(false, error)
                return
            }
            self.saveUserModel(data)
            Preferences.isSubAdmin = data.isManagePromoter
            let error = ErrorUtils.error(.objectParsing, message: data.isSignUp ? "account_created".localized() : "verify_mobile_number".localized())
            callback?(true, error)
        }
    }
    
    public func loginWithPhone(params: [String: Any], callback: BooleanResult?) {
        WhosinServices.signinwithPhone(params: params) { [weak self] model, error in
            guard let self = self else { return }
            guard let model = model, model.isSuccess, let data = model.data else {
                callback?(false, error)
                return
            }
            self.saveUserModel(data)
            Preferences.isSubAdmin = data.isManagePromoter
            let error = ErrorUtils.error(.objectParsing, message: data.isSignUp ? "account_created".localized() : "verify_mobile_number".localized())
            callback?(true, error)
        }
    }
    
    public func verifyOtp(userId: String, code: String, token: String, callback: BooleanResult?) {
        let device = Device.current
        LOCATIONSERVICE.getCurrentCityAndCountry { city, country in
            let metadata: [String: Any] = ["device_id": Utils.getDeviceID(),
                                           "device_name": device.name ?? UIDevice.current.name,
                                           "device_model": device.description ,
                                           "device_location": "\(city ?? " "), \(country ?? "Dubai")"]
            var params: [String: Any] = ["userId": userId, "otp": code, "metadata": metadata]
            params["isManagePromoter"] = Preferences.isSubAdmin
            WhosinServices.userVerify(params: params) { [weak self] container, error in
                guard let self = self else { return }
                guard let model = container, model.isSuccess, let data = model.data else {
                    callback?(false, error)
                    return
                }
                self.saveUserModel(data)
                callback?(true, nil)
            }
        }
        
    }
    
    public func loginWithGoogle(token: String, callback: BooleanResult?) {
        let params: [String: Any] = ["token": token, "deviceId" : Utils.getDeviceID()]
        WhosinServices.loginGoogleAuth(params: params) { [weak self] model, error in
            guard let self = self else { return }
            guard let model = model, model.isSuccess, let data = model.data else {
                callback?(false, error)
                return
            }
            self.saveUserModel(data)
            APPSETTING.configureSubscrition()
            callback?(true, nil)
        }
    }
    
    public func loginGuest(params: [String: Any], callback: BooleanResult?) {
        WhosinServices.loginGuestAuth(params: params) { [weak self] model, error in
            guard let self = self else { return }
            guard let model = model, model.isSuccess, let data = model.data else {
                callback?(false, error)
                return
            }
            self.saveUserModel(data)
            callback?(true, nil)
        }
    }

    
    public func loginWithFacebook(token: String, callback: BooleanResult?) {
        let params: [String: Any] = ["token": token, "provider": "facebook", "deviceId" : Utils.getDeviceID()]
        WhosinServices.loginFacebookAuth(params: params) { [weak self] model, error in
            guard let self = self else { return }
            guard let model = model, model.isSuccess, let data = model.data else {
                callback?(false, error)
                return
            }
            self.saveUserModel(data)
            APPSETTING.configureSubscrition()
            callback?(true, nil)
        }
    }
    
    public func loginWithApple(token: String, firstName: String, lastName: String, callback: BooleanResult?) {
        let params: [String: Any] = ["token": token, "first_name": firstName, "last_name": lastName, "deviceId" : Utils.getDeviceID()]
        WhosinServices.loginAppleAuth(params: params) { [weak self] model, error in
            guard let self = self else { return }
            guard let model = model, model.isSuccess, let data = model.data else {
                callback?(false, error)
                return
            }
            self.saveUserModel(data)
            APPSETTING.configureSubscrition()
            callback?(true, nil)
        }
    }
    
    public func logout(callback: BooleanResult?) {
        WhosinServices.logout { [weak self] model, error in
            guard let self = self else { return }
            guard let model = model, model.isSuccess, let data = model.data else {
                callback?(false, error)
                return
            }
            if model.isSuccess {
                self.clearSessionData()
                LANGMANAGER.reset()
            }
            callback?(true, nil)
        }
    }
    
    public func deleteAccount(type: String, callback: BooleanResult?) {
        WhosinServices.userDeleteAccount(type: type) { [weak self] model, error in
            guard let self = self else { return }
            guard let model = model, model.isSuccess else {
                callback?(false, error)
                return
            }
        }
        self.clearSessionData()
        callback?(true, nil)
    }
    
    public func updateProfile(param: [String: Any], isUpdate: Bool = false, callback: BooleanResult?) {
        WhosinServices.updateProfile(params: param) { [weak self] model, error in
            guard let self = self else { return }
            guard let model = model, model.isSuccess,let data = model.data else {
                callback?(false, error)
                return
            }
            self.saveUserDetail(data, iscurrencyUpdate: isUpdate)
            callback?(true, nil)
        }
    }
    
    public func updateProfileStatus(_ params: [String: Any], callback: BooleanResult?) {
        WhosinServices.updateUserStatus(params: params) { [weak self] model, error in
            guard let self = self else { return }
            guard let model = model, model.isSuccess,let data = model.data else {
                callback?(false, error)
                return
            }
            self.saveUserDetail(data)
            callback?(data.isProfilePrivate, nil)
        }
    }
    
    public func updatePrefrences(param: [String: Any], callback: BooleanResult?) {
        WhosinServices.saveUserPrefrences(params: param) { [weak self] model, error in
            guard self != nil else { return }
            guard let model = model, model.isSuccess,let data = model.data else {
                callback?(false, error)
                return
            }
            self?.saveUserPreferences(data)
            callback?(true, nil)
        }
    }
    
    public func getSettings() {
        WhosinServices.getSettings { [weak self] model, error in
            guard let self = self else { return }
            guard let model = model, let _ = model.data else { return }
        }
    }

    public func getProfile(isFromMenu: Bool = false, callback: BooleanResult?) {
        guard let userDetail = userDetail else { return }
        WhosinServices.getUserProfile(userId: userDetail.id) {  [weak self] container , error in
            guard let self = self else { return }
            guard let model = container, model.isSuccess, let data = model.data else {
                callback?(false, error)
                return
            }
            self.saveUserDetail(data)
            callback?(true, error)
            if !isFromMenu {
                NotificationCenter.default.post(name: .changeUserUpdateState, object: nil)
            }
        }
    }
    
    public func getUnreadInAPPNotifications(completion: @escaping ([InAppNotificationModel]) -> Void) {
        WhosinServices.inAppNotificationList { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data?.list else {
                completion([])
                return
            }
            let unreadNotifications = data.filter { $0.readStatus == false }
            completion(unreadNotifications)
        }
    }

    
    public func sessionCheck(callback: StringResult?) {
        WhosinServices.sessionCheck {  [weak self] container , error in
            guard let self = self else { return }
            guard let model = container, model.isSuccess, let data = model.data else {
                if error != nil, error?.localizedDescription.lowercased().contains("session expired!") ?? false {
                    callback?("Session expired, please login again!", error)
                    return
                }
                callback?("", error)
                return
            }
            if data.accountStatus == "permanent-ban" {
                callback?("account_permanently_banned_message".localized(), error)
                return
            } else if data.accountStatus == "temporary-ban" {
                callback?("account_temporarily_banned_message".localized(), error)
                return
            }
            callback?("", error)
        }
    }
    
    public func getUnreadCount() {
        WhosinServices.getUnreadCount { [weak self]container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.notificationCount = data.count
        }
    }
    
    public func getUpdate() {
        WhosinServices.getUpdates { [weak self]container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            DispatchQueue.main.async {
                self.getUpdateModel = data
                NotificationCenter.default.post(name: .readUpdatesState, object: nil)
            }
        }
    }
    
    public func readUpdate(type: String) {
        WhosinServices.readUpdate(type: type) { [weak self]container, error in
            guard let self = self else { return }
            self.getUpdate()
        }
    }
    
    func moveToHome() {
        guard let userDetail = userDetail else { return }
        guard let window = APP.window else { return }

        let controller: UIViewController
        Amplitude.instance().setUserId(userDetail.userId)
        if Utils.stringIsNullOrEmpty(userDetail.firstName), Preferences.isGuest == false {
            controller = INIT_CONTROLLER_XIB(SignInNameVC.self)
        } else {
            controller = INIT_CONTROLLER_XIB(MainTabBarVC.self)
        }
        let navController = NavigationController(rootViewController: controller)
        navController.setNavigationBarHidden(true, animated: false)
        window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction: .fade, style: .easeInOut))
    }
    
    func _moveToLogin() {
        guard let window = APP.window else { return }
        guard !APPSESSION.didLogin else { APPSESSION.moveToHome(); return }
        let navController = NavigationController(rootViewController: INIT_CONTROLLER_XIB(LoginVC.self))
        navController.setNavigationBarHidden(true, animated: false)
        window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
    }
    
    public func saveUserDetail(_ model: UserDetailModel, iscurrencyUpdate: Bool = false ){
        if model.roleAcess.first?.type == "promoter-subadmin" {
            model.isPromoter = true
            Preferences.isSubAdmin = true
            model.promoterId = model.roleAcess.first?.typeId ?? kEmptyString
        }
        
        if let json = model.toJSONString() {
            Preferences.userDetailModel = json
        }

        Preferences.userId = model.id
        if !Utils.stringIsNullOrEmpty(model.token) {
            Preferences.token = model.token
        }
        LANGMANAGER.currentLanguage = Utils.stringIsNullOrEmpty(model.lang) ? "en" : model.lang
        if iscurrencyUpdate {
            Preferences.token = model.token
        }
    }
    
    public func saveUserPreferences(_ model: PrefrencesModel) {
        
        if let json = model.toJSONString() {
            Preferences.preferencesModel = json
        }
        
        Preferences.userId = model.userId
    }
    
    public func saveUserModel(_ model: UserModel?, isTokenValidate: Bool = false) {
        guard let userModel = model else { return }
        Preferences.isAuthenticationPending = userModel.isAuthenticationPending
        if userModel.userDetail?.isGuest == true {
            Preferences.isGuest = true
            userModel.userDetail?.firstName = "Guest"
        }

        if userModel.loginType == "sub-admin", let json = userModel.toJSONString() {
            Preferences.userDetailModel = json
        }
        
        if userModel.userDetail?.roleAcess.first?.type == "promoter-subadmin" {
            model?.userDetail?.isPromoter = true
            Preferences.isSubAdmin = true
            userModel.userDetail?.promoterId = userModel.userDetail?.roleAcess.first?.typeId ?? kEmptyString
        }
        
        if let json = userModel.userDetail?.toJSONString() {
            Preferences.userDetailModel = json
        }
        Preferences.userId = userModel.userId
        if !Utils.stringIsNullOrEmpty(userModel.token) && !userModel.isAuthenticationPending {
            Preferences.token = userModel.token
            Preferences.didLogin = true
        }
        
        if model?.userDetail?.isPromoter == true {
            Preferences.profileType = ProfileType.promoterProfile
        } else if model?.userDetail?.isRingMember == true {
            Preferences.profileType = ProfileType.complementaryProfile
        } else if userModel.userDetail?.roleAcess.first?.type == "promoter-subadmin" {
            Preferences.profileType = ProfileType.promoterProfile
        } else {
            Preferences.profileType = ProfileType.profile
        }
    }
    
    func clearSessionData() {
        OneSignal.logout()
        PINCache.shared.removeAllObjects()
        ChatRepository().resetRealm()
        HomeRepository().resetRealm()
        UserRepository().resetRealm()
        CartRepository().resetRealm()
        Preferences.clearConnectedData()
        
    }
    
}

