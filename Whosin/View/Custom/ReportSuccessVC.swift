import UIKit

class ReportSuccessVC: ChildViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
    }

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("dissmissVC"), object: nil, userInfo: nil)
        }
    }
    
}
