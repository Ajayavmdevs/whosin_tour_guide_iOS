import UIKit

class PurchaseSuccessVC: ChildViewController {

    @IBOutlet weak var _animationView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        if let localURL = Bundle.main.url(forResource: "successAnim", withExtension: "gif") {
            _animationView.sd_setImage(with: localURL, completed: nil)
        }

    }

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("dissmissVC"), object: nil, userInfo: nil)
        }
    }
    
    @IBAction func _handleOpenWallet(_ sender: UIButton) {
        dismiss(animated: true) {
            guard let window = APP.window, APPSESSION.didLogin  else { return }
            let controller = INIT_CONTROLLER_XIB(MainTabBarVC.self)
            controller.selectedIndex = 4
            let navController = NavigationController(rootViewController: controller)
            navController.setNavigationBarHidden(true, animated: false)
            window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))

        }
    }
}
