import UIKit

class BankDetailVC: ChildViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
    }

    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
