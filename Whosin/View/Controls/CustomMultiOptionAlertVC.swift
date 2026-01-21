import UIKit

class CustomMultiOptionAlertVC: ChildViewController {

    @IBOutlet private weak var _msgLbl: CustomLabel!
    @IBOutlet private weak var _titleText: CustomLabel!
    @IBOutlet weak var _firstOption: CustomButton!
    @IBOutlet weak var _secOption: CustomButton!
    @IBOutlet weak var _thirdOption: CustomButton!

    public var _msg = kEmptyString
    public var _title = kEmptyString
    public var firstButtonTitle = "yes".localized()
    public var secButtonTitle = "no".localized()
    public var thirdOptionTitle = "cancel".localized()
    public var _handleFirstEvent: (() -> Void)?
    public var _handleSecEvent: (() -> Void)?
    public var _handleThirdEvent: (() -> Void)?


    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        _msgLbl.text = _msg
        _titleText.text = _title
        if _handleFirstEvent == nil {
            _firstOption?.isHidden = true
        }
        if _handleSecEvent == nil {
            _secOption.isHidden = true
        }
        if _handleThirdEvent == nil {
            _thirdOption.isHidden = true
        }
        _firstOption.setTitle(firstButtonTitle)
        _secOption.setTitle(secButtonTitle)
        _thirdOption.setTitle(thirdOptionTitle)
    }

    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func _handlefirstOptionEvent(_ sender: Any) {
        dismiss(animated: true, completion: {
            self._handleFirstEvent?()
        })
    }
    
    @IBAction private func _handleSecOptionEvent(_ sender: UIButton) {
            dismiss(animated: true, completion: {
                self._handleSecEvent?()
            })
    }
    
    @IBAction private func _handleThirdOptionEvnet(_ sender: Any) {
        dismiss(animated: true, completion: {
            self._handleThirdEvent?()
        })
    }
    
}
