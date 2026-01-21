import Foundation
import Reachability
import FAPanels

let NETWORKMANAGER = NetworkManager.shared

class NetworkManager: NSObject {

    private var _reachability: Reachability?
    private var _isRechable: Bool = true
    private var _alertVC: NoInternetAlertVC?
    
    // -------------------------------------
    // MARK: Singleton
    // --------------------------------------
    
    class var shared: NetworkManager {
        struct Static {
            static let instance = NetworkManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        _reachability = try? Reachability()
        NotificationCenter.default.addObserver(self, selector: #selector(_handleNetworkStatusChangedEvent(_:)), name: .reachabilityChanged, object: _reachability)
                
        _reachability?.whenReachable = { [weak self] reachability in
            guard let self = self else { return }
            self._handleReachableEvent()
        }
    }
    
    // -------------------------------------
    // MARK: Getter
    // --------------------------------------
    
    var isRechable: Bool { _isRechable }
    
    var isConnectionAvailable: Bool { (try? Reachability())?.connection != .unavailable }
    
    // -------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _handleReachableEvent() {
        _isRechable = true
        _alertVC?.dismiss(animated: true)
        _alertVC = nil
    }
    
    private func _handleUnreachableEvent() {
        guard let currentController = APP.window?.rootViewController,
              _alertVC == nil else { return }
        
        _isRechable = false
        _alertVC = INIT_CONTROLLER_XIB(NoInternetAlertVC.self)
        
        guard let controller = _alertVC else { return }
        controller.modalPresentationStyle = .overFullScreen
        
        guard let presentedController = currentController.presentedViewController else {
            currentController.present(controller, animated: true, completion: nil)
            return
        }
        presentedController.present(controller, animated: true, completion: nil)
    }
    
    // -------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc private func _handleNetworkStatusChangedEvent(_ sender: Notification) {
        // COMMENTED FOR IMPLEMENT LATER
        if sender.name.rawValue == "reachabilityChanged" {
            if !isConnectionAvailable {
                print("Not reachable called")
                _handleUnreachableEvent()
            } else if isConnectionAvailable {
                print("reachable called")
                _handleReachableEvent()
            }
        }
    }
    
    // -------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func startNotifier() {
        do {
            try _reachability?.startNotifier()
        } catch {
            Log.debug("Unable to start notifier error: \(error.localizedDescription)")
        }
    }
    
    func stopNotifier() {
        do {
            try _reachability?.startNotifier()
        } catch {
            Log.debug("Unable stopping notifier error: \(error.localizedDescription)")
        }
    }
    
    func dismissAlert() {
        _handleReachableEvent()
    }
    
    func presentAlert() {
        _handleUnreachableEvent()
    }
}
