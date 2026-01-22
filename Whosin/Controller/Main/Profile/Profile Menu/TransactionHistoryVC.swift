import UIKit

class TransactionHistoryVC: ChildViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
    }

    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
