import UIKit

class PrivacyPolicyVC: ChildViewController {

    @IBOutlet private weak var _privacyPolicyLabel: UILabel!
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    
    
    override func setupUi() {
//        setTitle(title: title)
//        _privacyPolicyLabel.text = privacyPolicy.description
    }
    
}

