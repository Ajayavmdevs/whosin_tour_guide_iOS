import SnapKit
import PanModal
import UIKit
import SkeletonView
import NotificationBannerSwift

class BaseViewController: UIViewController {

	var isRequesting: Bool = false
    var isModal: Bool = false
    var didLoad: Bool = false
    var feedbackGenerator: UIImpactFeedbackGenerator?
    @IBInspectable var enableBackgroundImage: Bool = false
    @IBInspectable var isTopShadow: Bool = true
    var banner: NotificationBanner?
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
		super.viewDidLoad()
        _setupBackgroundImageView()
        feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator?.prepare()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationBadgeEvent(_:)), name: .updateNotificationBadge, object: nil)
	}
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .updateNotificationBadge, object: nil)
    }

//    override var preferredStatusBarStyle: UIStatusBarStyle {
//		UIStatusBarStyle.lightContent
//	}
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupBackgroundImageView() {
        if enableBackgroundImage {
            let imageView = UIImageView.init(image: UIImage(named: isTopShadow ? "image_gradientBg" : "image_gradientBg"))
            imageView.contentMode = .scaleAspectFill
            view.insertSubview(imageView, at: 0)
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func _updateSkeletonLoading(isShow: Bool = true) {
        guard isShow else {
            view.hideSkeleton(transition: .crossDissolve(0.5))
            return
        }
        
        DISPATCH_ASYNC_MAIN_AFTER(0.0001) {
            self.view.isSkeletonable = true
            guard !self.didLoad else { return }
            let gradient = SkeletonGradient(baseColor: ColorBrand.brandGray)
            self.view.showAnimatedGradientSkeleton(usingGradient: gradient, transition: .crossDissolve(0.5))
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc func handleNotificationBadgeEvent(_ sender: Notification) {
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func checkForAppUpdate() {
        let currentVersion = APP.version
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(APP.bundleId)") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching latest version: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(response)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let latestVersion = results.first?["version"] as? String {
                    if Float(latestVersion) ?? 0.0  > Float(currentVersion) ?? 0.0 {
                        DispatchQueue.main.async {
                            self.showUpdateAlert()
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        task.resume()
    }

    func showUpdateAlert() {
        let vc = INIT_CONTROLLER_XIB(AppUpdatePopupVc.self)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }

    func dismissOrBack(_ annimation:Bool = true) {
        if let presentingViewController = self.presentationController?.presentingViewController {
            dismiss(animated: annimation)
        } else {
            self.navigationController?.popViewController(animated: annimation)
        }
    }

    var isVisible: Bool {
		isViewLoaded && view.window != nil
	}

    func setupUi() {}
    
    func alert(title: String = kAppName, message: String?, showfaq: Bool = false, faq: String = kEmptyString) {
        let customAlert = INIT_CONTROLLER_XIB(CustomAlertVC.self)
        customAlert._title = title
        customAlert._msg = message ?? ""
        if showfaq {
            customAlert._faq = faq
        }
        customAlert._handleYesEvent = { [weak self] in
        }
        customAlert._handleNoEvent = nil
        DISPATCH_ASYNC_MAIN { [weak self] in
            customAlert.modalPresentationStyle = .overFullScreen
            customAlert.modalTransitionStyle = .crossDissolve
            self?.present(customAlert, animated: true)
        }
    }

    func alert(title: String = kAppName, message: String?,showfaq: Bool = false, faq: String = kEmptyString, handler: ((UIAlertAction) -> Void)? = nil) {
        let customAlert = INIT_CONTROLLER_XIB(CustomAlertVC.self)
        customAlert._title = title
        customAlert._msg = message ?? ""
        if showfaq {
            customAlert._faq = faq
        }
        customAlert._handleYesEvent = { [weak customAlert] in
            handler?(UIAlertAction()) // Call the completion handler
        }
        customAlert._handleNoEvent = nil
        DISPATCH_ASYNC_MAIN { [weak self] in
            customAlert.modalPresentationStyle = .overFullScreen
            customAlert.modalTransitionStyle = .crossDissolve
            self?.present(customAlert, animated: true)
        }
    }
    
    func alert(title: String = kAppName, message: String?, option : String = "ok".localized(),showfaq: Bool = false, faq: String = kEmptyString, okHandler: ((UIAlertAction) -> Void)? = nil, cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        let customAlert = INIT_CONTROLLER_XIB(CustomAlertVC.self)
        customAlert._title = title
        customAlert._msg = message ?? ""
        if showfaq {
            customAlert._faq = faq
        }
        customAlert._handleYesEvent = { [weak customAlert] in
            okHandler?(UIAlertAction()) // Call the ok handler
        }
        customAlert.yesButtonTitle = option
        customAlert.noButtonTitle = "no".localized()
        customAlert._handleNoEvent = { [weak customAlert] in
            cancelHandler?(UIAlertAction()) // Call the cancel handler
        }
        DISPATCH_ASYNC_MAIN { [weak self] in
            customAlert.modalPresentationStyle = .overFullScreen
            customAlert.modalTransitionStyle = .crossDissolve
            self?.present(customAlert, animated: true)
        }


    }

    func alert(title: String = kAppName, message: String?, okActionTitle: String = "ok".localized(), cancelActionTitle: String = "no".localized(), showfaq: Bool = false, faq: String = kEmptyString, okHandler: ((UIAlertAction) -> Void)? = nil, cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        let customAlert = INIT_CONTROLLER_XIB(CustomAlertVC.self)
        customAlert._title = title
        customAlert._msg = message ?? ""
        if showfaq {
            customAlert._faq = faq
        }
        customAlert._handleYesEvent = { [weak customAlert] in
            okHandler?(UIAlertAction()) // Call the ok handler
            customAlert?.dismiss(animated: true, completion: nil)
        }
        customAlert._handleNoEvent = { [weak customAlert] in
            cancelHandler?(UIAlertAction()) // Call the cancel handler
            customAlert?.dismiss(animated: true, completion: nil)
        }
        customAlert.yesButtonTitle = okActionTitle
        customAlert.noButtonTitle = cancelActionTitle
        DISPATCH_ASYNC_MAIN { [weak self] in
            customAlert.modalPresentationStyle = .overFullScreen
            customAlert.modalTransitionStyle = .crossDissolve
            self?.present(customAlert, animated: true)
        }
    }

    func confirmAlert(title: String = kAppName, message: String?,showfaq: Bool = false, faq: String = kEmptyString, okHandler: ((UIAlertAction) -> Void)? = nil, noHandler: ((UIAlertAction) -> Void)? = nil) {
        let customAlert = INIT_CONTROLLER_XIB(CustomAlertVC.self)
        customAlert._title = title
        customAlert._msg = message ?? ""
        if showfaq {
            customAlert._faq = faq
        }
        customAlert._handleYesEvent = { [weak customAlert] in
            okHandler?(UIAlertAction())
            customAlert?.dismiss(animated: true, completion: nil)
        }
        customAlert._handleNoEvent = { [weak customAlert] in
            noHandler?(UIAlertAction())
            customAlert?.dismiss(animated: true, completion: nil)
        }
        customAlert.yesButtonTitle = "yes".localized()
        customAlert.noButtonTitle = "cancel".localized()
        DISPATCH_ASYNC_MAIN { [weak self] in
            customAlert.modalPresentationStyle = .overFullScreen
            customAlert.modalTransitionStyle = .crossDissolve
            self?.present(customAlert, animated: true)
        }

    }
    
    func showCustomAlert(title: String = kAppName, message: String?, yesButtonTitle: String = "yes".localized(), noButtonTitle: String = "cancel".localized(), okHandler: ((UIAlertAction) -> Void)? = nil, noHandler: ((UIAlertAction) -> Void)? = nil) {
        let customAlert = INIT_CONTROLLER_XIB(CustomAlertVC.self)
        customAlert._title = title
        customAlert._msg = message ?? ""
        
        customAlert._handleYesEvent = { [weak customAlert] in
            okHandler?(UIAlertAction())
        }
        
        customAlert._handleNoEvent = { [weak customAlert] in
            noHandler?(UIAlertAction())
        }
        customAlert.yesButtonTitle = yesButtonTitle
        customAlert.noButtonTitle = noButtonTitle

        if Utils.stringIsNullOrEmpty(noButtonTitle) {
            customAlert._handleNoEvent = nil
        }
        
        DISPATCH_ASYNC_MAIN { [weak self] in
            customAlert.modalPresentationStyle = .overFullScreen
            customAlert.modalTransitionStyle = .crossDissolve
            self?.present(customAlert, animated: true)
        }
    }
    
    func presentDailogueBox(_ view: UIViewController) {
        DISPATCH_ASYNC_MAIN { [weak self] in
            view.modalPresentationStyle = .overFullScreen
            view.modalTransitionStyle = .crossDissolve
            self?.present(view, animated: true)
        }
    }

    
    func dismissAllPresentedControllers(animated: Bool, complition: (() -> Void)? = nil) {
        APP.window?.rootViewController?.dismiss(animated: animated, completion: complition)
    }
    
    func dismissToParentViewController(animated: Bool, completion: (() -> Void)? = nil) {
        if let presentingViewController = APP.window?.rootViewController?.presentingViewController {
            presentingViewController.dismiss(animated: animated, completion: completion)
        } else {
            APP.window?.rootViewController?.dismiss(animated: animated, completion: completion)
        }
    }
    
    func getHudView() -> UIView? {
        let indicator = MLTontiatorView()
        indicator.spinnerSize = .MLSpinnerSizeSmall
        indicator.spinnerColor = ColorBrand.brandPink
        indicator.startAnimating()
        indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        baseView.backgroundColor = .clear
        baseView.addSubview(indicator)
        indicator.startAnimating()
        return baseView
    }

    func checkSession() {
        APPSESSION.sessionCheck { message, error  in
            if !Utils.stringIsNullOrEmpty(message) {
                if message == "Session expired, please login again!" {
                    self.alert(message: "session_expired".localized()) { UIAlertAction in
                        APPSESSION.clearSessionData()
                        APPSESSION._moveToLogin()
                    }
                } else {
                    self.alert(message: message)
                }
            }
        }
    }
    
    func showError(_ error: NSError?) {
        guard let error = error else { return }
        
        alert(message: error.localizedDescription) { _ in
            guard ErrorCode(rawValue: error.code) == .sessionExpired else { return }
            guard APP.window != nil else { return }
//            APPSESSION.clearSessionData()
//            APPSESSION._moveToLogin()
        }
    }
    
    func showSuccessMessage(_ title: String, subtitle: String) {
        if banner != nil {
            banner?.dismiss()
            banner = nil
        }
        banner = NotificationBanner(title: title, subtitle: subtitle, style: .success, colors: self)
        banner?.show(bannerPosition: .top)
        banner?.applyStyling(titleFont: FontBrand.navBarTitleFont, titleColor: .darkText, titleTextAlign: .left, subtitleFont: FontBrand.navBarSubtitleFont, subtitleColor: .darkGray, subtitleTextAlign: .left )
    }
    
    func showFailMessage(_ title: String, subtitle: String) {
        if banner != nil {
            banner?.dismiss()
            banner = nil
        }
        banner = NotificationBanner(title: title, subtitle: subtitle, style: .danger)
        banner?.show()
    }
    
    func showHUD(_ view: UIView? = nil, loadingText: String = kEmptyString, shouldReload: Bool = false) {
        print("Loader is started....................")
        if view is CustomTableView {
            guard let tableView = view as? CustomTableView else { return }
            _updateSkeletonLoading()
            tableView.isLoading = true
            if shouldReload {
                tableView.reload()
            }
        }
        else if view is CustomNoKeyboardTableView {
            guard let tableView = view as? CustomNoKeyboardTableView else { return }
            _updateSkeletonLoading()
            tableView.isLoading = true
            if shouldReload {
                tableView.reload()
            }
        }
        else if view is CustomCollectionView {
            guard let collectionView = view as? CustomCollectionView else { return }
            _updateSkeletonLoading()
            if shouldReload {
                collectionView.reload()
            }
        } else {
            Loader.shared.show(loadingText: loadingText)
        }
        isRequesting = true
    }
    
    func hideHUD(_ view: UIView? = nil, error: NSError? = nil, shouldReload: Bool = false) {
        if view is CustomTableView {
            guard let tableView = view as? CustomTableView else { return }
            _updateSkeletonLoading(isShow: false)
            tableView.isLoading = false
            if tableView.isRefreshing {
                tableView.endRefreshing()
            }
            if tableView.isDummyLoad {
                tableView.clearAndReload()
            } else if shouldReload {
                tableView.reload()
            }
        }
        else if view is CustomNoKeyboardTableView {
            guard let tableView = view as? CustomNoKeyboardTableView else { return }
            _updateSkeletonLoading(isShow: false)
            tableView.isLoading = false
            if tableView.isRefreshing {
                tableView.endRefreshing()
            }
            if tableView.isDummyLoad {
                tableView.clearAndReload()
            } else if shouldReload {
                tableView.reload()
            }
        }
        else if view is CustomCollectionView {
            guard let collectionView = view as? CustomCollectionView else { return }
            _updateSkeletonLoading(isShow: false)
            if collectionView.isRefreshing {
                collectionView.endRefreshing()
            }
            if collectionView.isDummyLoad {
                collectionView.clearAndReload()
            } else if shouldReload {
                collectionView.reload()
            }
        } else {
            Loader.shared.hide()
        }
        isRequesting = false
        showError(error)
    }
    
    func shareAppLink() {
        let items: [Any] = [kInviteMessage]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .print,
            .message,
            .airDrop,
            .postToWeibo,
            .postToVimeo,
            .postToFlickr,
            .postToTwitter,
            .postToFacebook
        ]
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func hideNavigationSepratorLine() {
        (navigationController as? NavigationController)?.updateSepratorLine(isHidden: true)
    }
    
    func showNavigationSepratorLine() {
        (navigationController as? NavigationController)?.updateSepratorLine()
    }
    
    var isInternetAvailable: Bool {
        let isAvailable = NETWORKMANAGER.isConnectionAvailable
        if !isAvailable { NETWORKMANAGER.presentAlert() }
        return isAvailable
    }
}

extension BaseViewController {

  override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
  }

  override var prefersStatusBarHidden: Bool {
    return StatusBarOverlay.prefersStatusBarHidden
  }

  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return StatusBarOverlay.preferredStatusBarUpdateAnimation
  }
}

extension BaseViewController: BannerColorsProtocol {

    public func color(for style: BannerStyle) -> UIColor {
        switch style {
            case .danger:
                return UIColor(red:0.90, green:0.31, blue:0.26, alpha:1.00)
            case .info:
                return UIColor(red:0.23, green:0.60, blue:0.85, alpha:1.00)
            case .customView:
                return .clear
            case .success:
                return UIColor(red:254/256, green:245/256, blue:245/256, alpha:1.00)
            case .warning:
                return UIColor(red:1.00, green:0.66, blue:0.16, alpha:1.00)
        @unknown default:
            return UIColor(red:0.23, green:0.60, blue:0.85, alpha:1.00)
        }
    }
}

class PanBaseViewController: BaseViewController {

    var dismissCallback: (() -> Void)?
    var isAllowsTapToDismiss = true

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension PanBaseViewController: PanModalPresentable {

    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        .contentHeight(400)   // 👈 REQUIRED
    }

    var longFormHeight: PanModalHeight {
        .contentHeight(400)   // or .maxHeight
    }


    var anchorModalToLongForm: Bool {
        return true
    }

    var springDamping: CGFloat {
        return 1.0
    }

    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.5)
    }

    var isHapticFeedbackEnabled: Bool {
        return true
    }

    var allowsTapToDismiss: Bool {
        return isAllowsTapToDismiss
    }

    var allowsDragToDismiss: Bool {
        return isAllowsTapToDismiss
    }

    public var showDragIndicator: Bool {
        return false
    }

    func panModalWillDismiss() {
        dismissCallback?()
    }
}
