import Alamofire
import UIKit

let APP = Application.shared

class Application: NSObject {

    let mediumFeedback = UIImpactFeedbackGenerator(style: .medium)
    let heavyFeedback = UIImpactFeedbackGenerator(style: .heavy)
	var window: UIWindow?
    
	private var _reachability: NetworkReachabilityManager!

	// --------------------------------------
	// MARK: Singleton
	// --------------------------------------

	class var shared: Application {
		struct Static {
			static let instance = Application()
		}
		return Static.instance
	}

	override init() {
		super.init()
        _reachability = NetworkReachabilityManager()
	}
        
	// --------------------------------------
	// MARK: Public
	// --------------------------------------

    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

	var bundleId: String {
		Bundle.main.bundleIdentifier ?? kEmptyString
	}
    
    var displayName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? kAppName
    }

	var version: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? kEmptyString
	}

	var buildVersion: String {
		Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? kEmptyString
	}

	var systemApplication: UIApplication {
		return UIApplication.shared
	}

	var iconBadgeNumber: Int {
		return systemApplication.applicationIconBadgeNumber
	}
  
    var appState: UIApplication.State {
        return systemApplication.applicationState
    }
    
    var isConnectedToInternet : Bool{
       return _reachability.isReachable
    }

	func setIconBadgeNumber(_ iconBadgeNumber: Int) {
		systemApplication.applicationIconBadgeNumber = iconBadgeNumber
	}
}
