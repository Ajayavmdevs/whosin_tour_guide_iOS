
import UIKit
import PanModal
import FSCalendar
import SnapKit


class ReportOptionsSheet: PanBaseViewController {
    @IBOutlet private weak var _mainContainerView: UIView!
    @IBOutlet weak var _reportBtnText: CustomLabel!
    @IBOutlet weak var _blockBtnText: CustomLabel!
    @IBOutlet weak var _reportAndBlockText: CustomLabel!
    var isUserBlocked: Bool = false
    var didUpdateCallback: ((_ type: String) -> Void)?


    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
        
    override func setupUi() {
        _mainContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        if isUserBlocked {
            _blockBtnText.text = "unblock".localized()
        }
        
    }
    
    // --------------------------------------
    // MARK: Private Accessor
    // --------------------------------------
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    
    // --------------------------------------
    // MARK: Updater
    // --------------------------------------
    
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    @IBAction func _handleReportEvent(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.didUpdateCallback?("report")
        }
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismissOrBack()
    }
    
    @IBAction func _handleBlockEvent(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.didUpdateCallback?("block")
        }
    }
    
    @IBAction func _handleReportAndblockEvent(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.didUpdateCallback?("both")
        }
    }
}
