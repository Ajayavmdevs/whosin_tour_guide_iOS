import UIKit
import INTULocationManager

class VarificationVC: BottomSheetViewController {
    
    @IBOutlet private weak var _verifyButton: UIButton!
    @IBOutlet private weak var _closeButton: UIButton!
    @IBOutlet private weak var _changeButton: UIButton!
    @IBOutlet private weak var _titleTextLabel: UILabel!
    @IBOutlet private weak var _btnResend: UIButton!
    @IBOutlet private weak var _lblResend: UILabel!
    @IBOutlet private weak var _lblMobileNumber: UILabel!
    @IBOutlet private weak var _textFieldOne: UITextField!
    @IBOutlet private weak var _textFieldTwo: UITextField!
    @IBOutlet private weak var _textFieldThree: UITextField!
    @IBOutlet private weak var _textFieldFour: UITextField!
    @IBOutlet private weak var _textFieldFive: UITextField!
    @IBOutlet private weak var _textFieldSix: UITextField!
    private var _varificationfieldList: [UITextField] = []
    private var _varificationCode: String = ""
    private var _totalTime: Int = 30
    private var _countdownTimer: Timer!
    @IBOutlet weak var bottomConatraint: NSLayoutConstraint!
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        enableLeftBarButton(true)
//        showNavigationBar()
    }
    
    func setupUi() {
        _varificationfieldList = [_textFieldOne,_textFieldTwo,_textFieldThree,_textFieldFour,_textFieldFive,_textFieldSix]
        for field in  _varificationfieldList {
            field.text = ""
            field.textAlignment = .center
            field.delegate = self
            field.keyboardType = .numberPad
        }
        _countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        if let frame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            self.bottomConatraint.constant = height
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.bottomConatraint.constant = 40
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    func _requestOtpVerify() {
        APPSESSION.verifyOtp(userId: APPSESSION.userId, code: _varificationCode) { [weak self] isSuccess, error in
            guard let self = self else { return }
//            self.hideHUD(error: error)
            guard isSuccess else { return }
            for field in  self._varificationfieldList {
                field.text = ""
                field.textAlignment = .center
                field.delegate = self
                field.keyboardType = .numberPad
            }
            self.view.makeToast("OTP verified")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let navController = NavigationController(rootViewController: INIT_CONTROLLER_XIB(MainTabBarVC.self))
                navController.setNavigationBarHidden(true, animated: false)
                APP.window?.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
            }
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleVerifyEmailEvent(_ sender: UIButton) {
        _requestOtpVerify()
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func _handlechangeNumber(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(MobileLoginVC.self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func _handleResendCodeEvent(_ sender: UIButton) {
        _totalTime = 30
        _countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    @IBAction private func _handleOTPTextFieldEditingBegan(_ sender: UITextField) {
    }
    
    @IBAction private func _handleOTPTextFieldEditingEnd(_ sender: UITextField) {
    }
    
}

extension VarificationVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (range.length == 0 && string.isEmpty) { self.textFieldDidDelete(textField); return false }
        
        if (range.length == 1 && string.isEmpty) { textField.text = ""; return false }
        
        if string.count == 0 { return false }
        
        if !(string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil) { return false }
        
        textField.text = string
        self.textFieldDidChange(textField)
        return false
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        var index = 0
        for textField in _varificationfieldList {
            index += 1
            if textField.isFirstResponder && index < _varificationfieldList.count {
                _varificationfieldList[index].becomeFirstResponder()
                break
            } else if (index == _varificationfieldList.count) {
                var otpCode: [String] = []
                for txt in _varificationfieldList {
                    otpCode.append(txt.text ?? kEmptyString)
                }
                if otpCode.count == _varificationfieldList.count {
                    _varificationCode = otpCode.joined()
                }
            }
        }
    }
    
    func textFieldDidDelete(_ textField: UITextField) {
        guard var index = _varificationfieldList.firstIndex(of: textField) else { return }
        index -= 1
        if index >= 0 {
            let textField = _varificationfieldList[index]
            textField.becomeFirstResponder()
            textField.text = ""
        }
    }
}

extension VarificationVC {
    
    @objc private func updateTimerLabel() {
        _btnResend.isHidden = true
        _totalTime -= 1
        _lblResend.text = "Resend OTP in \(self.timeFormatted(_totalTime)) sec"
        if _totalTime == 0 {
            _countdownTimer.invalidate()
            _btnResend.isHidden = false
            _lblResend.text = "Didn’t get a code?"
        }
    }
    
    private func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        return String(format: "%02d", seconds)
    }
}


