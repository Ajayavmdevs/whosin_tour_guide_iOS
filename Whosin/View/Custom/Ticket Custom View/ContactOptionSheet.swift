import UIKit
import IQKeyboardManagerSwift

class ContactOptionSheet: PanBaseViewController {
    
    public var openWhosinAdmin: (() -> Void)?
    public var openWhatsappContact: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func _handleWhosinAdminEvent(_ sender: Any) {
        self.dismiss(animated: true) {
            self.openWhosinAdmin?()
        }
    }
    
    @IBAction func _handleWhosinWhatsappEvent(_ sender: Any) {
        self.dismiss(animated: true) {
            self.openWhatsappContact?()
        }
    }
    
    @IBAction func _handleCloseEvent(_ sender: Any) {
        dismiss(animated: true)
    }
}
 
