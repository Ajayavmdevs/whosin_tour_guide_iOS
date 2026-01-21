import UIKit
import PanModal

class PanNavigationController: UINavigationController {
    
    var dismissCallback: (() -> Void)?
    var isAllowsTapToDismiss = true

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        UIStatusBarStyle.lightContent
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        setNavigationBarHidden(true, animated: false)
    }
}

extension PanNavigationController: PanModalPresentable {
        
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var anchorModalToLongForm: Bool {
        return true
    }
    
    var springDamping: CGFloat {
        return 1.0
    }
    
    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.3)
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

