import UIKit

class CustomAlertVC: ChildViewController {

    @IBOutlet private weak var _msgLbl: CustomLabel!
    @IBOutlet private weak var _titleText: CustomLabel!
    @IBOutlet private weak var _noButton: UIButton!
    @IBOutlet private weak var _yesButton: UIButton!
    @IBOutlet private weak var _faqButton: CustomButton!
    public var _msg = kEmptyString
    public var _title = kEmptyString
    public var _faq = kEmptyString
    public var yesButtonTitle = "ok".localized()
    public var noButtonTitle = "no".localized()
    public var _handleYesEvent: (() -> Void)?
    public var _handleNoEvent: (() -> Void)?


    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        _msgLbl.text = _msg
        _titleText.text = _title
        if _handleNoEvent == nil {
            _noButton?.isHidden = true
        }
        if _handleYesEvent == nil {
            _yesButton.isHidden = true
        }
        _yesButton.setTitle(yesButtonTitle)
        _noButton.setTitle(noButtonTitle)
        _faqButton.isHidden = Utils.stringIsNullOrEmpty(_faq)
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func _handleNoEvent(_ sender: Any) {
        dismiss(animated: true, completion: {
            self._handleNoEvent?()
        })
    }
    
    @IBAction private func _handleYesEvent(_ sender: UIButton) {
            dismiss(animated: true, completion: {
                self._handleYesEvent?()
            })
    }
    
    @IBAction private func _handleFAQEvnet(_ sender: Any) {
        let vc = INIT_CONTROLLER_XIB(FaqVC.self)
        vc.faqText = _faq
        present(vc, animated: true)
    }
}
