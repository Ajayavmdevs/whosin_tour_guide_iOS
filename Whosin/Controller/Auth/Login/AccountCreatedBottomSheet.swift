import UIKit
import MHLoadingButton

class AccountCreatedBottomSheet: PanBaseViewController {
        
    @IBOutlet weak var _resendButton: UIButton!
    @IBOutlet weak var _resendText: UILabel!
    @IBOutlet weak var _titleText: UILabel!
    @IBOutlet private weak var _textFieldFour: OTPTextField!
    @IBOutlet private weak var _textFieldThree: OTPTextField!
    @IBOutlet private weak var _textFieldTwo: OTPTextField!
    @IBOutlet private weak var _textFieldOne: OTPTextField!
    @IBOutlet private weak var _verifyButton: LoadingButton!
    @IBOutlet private weak var _buttonIcon: CustomGradientBorderButton!
    @IBOutlet weak var _progressView: RoundProgressView!
    @IBOutlet weak var _subTitleText: UILabel!
    @IBOutlet weak var _emailText: UILabel!
    var delegate: ActionButtonDelegate?
    var isFromEmailorMobileVerify: Bool = false
    private var _otpCodeList: [UITextField] = []
    private var _totalTime: Int = 30
    private var _countdownTimer: Timer!
    public var countryCode: String = kEmptyString
    public var phoneNumber: String = kEmptyString
    public var titleString: String = kEmptyString
    public var isEmailLogin: Bool = false

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    // --------------------------------------
    // MARK: SetUp method
    // --------------------------------------
    @objc private func updateTimerLabel() {
        _resendButton.isHidden = true
        _totalTime -= 1
        _resendText.text = LANGMANAGER.localizedString(forKey: "resent_otp_timer", arguments: ["value": "\(self.timeFormatted(_totalTime))"])
        if _totalTime == 0 {
            _countdownTimer.invalidate()
            _resendButton.isHidden = false
            _resendText.text = "didnt_get_code".localized()
        }
    }
    
    override func setupUi() {
        _progressView.startCountdown()
        _resendButton.isHidden = true
        _resendText.text = kEmptyString
        _progressView.timerCompletion = {
            self._progressView.isHidden = true
            self._buttonIcon.isHidden = false
            self._resendButton.isHidden = false
            self._resendText.text = "didnt_get_code".localized()
        }
        _otpCodeList = [
            _textFieldOne, _textFieldTwo, _textFieldThree, _textFieldFour
        ]
        for field in _otpCodeList {
            field.text = ""
            field.textAlignment = .center
            field.delegate = self
            field.keyboardType = .numberPad
        }
        _buttonIcon.buttonImage = UIImage(named: "icon_verify")
        _verifyButton.indicator = BallBeatIndicator(color: ColorBrand.white)
        _validateVerifyButton()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self._textFieldOne.becomeFirstResponder()
        }
//        _countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
        
        _titleText.text = isEmailLogin ? "verify_email_address".localized() : titleString
        _emailText.isHidden = !isEmailLogin
        if isEmailLogin {
            _subTitleText.text = "We_sent_digits_to_your_email".localized()
        }
    }
    
    // --------------------------------------
    // MARK: Public Methods
    // --------------------------------------

    
    private func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        return String(format: "%02d", seconds)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        self.view.frame.origin.y = keyboardSize.origin.y - self.view.frame.size.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = view.frame.size.height - self.view.frame.size.height
    }

    
    // --------------------------------------
    // MARK: Private method
    // --------------------------------------
    
    private func _validateVerifyButton() {
        let isValid = _otpCodeList.first(where: { Utils.stringIsNullOrEmpty($0.text) }) == nil
        _verifyButton.isEnabled = isValid
        _verifyButton.alpha = isValid ? 1 : 0.5
        if isValid {
            var otpCodes: [String] = []
            for txt in _otpCodeList { otpCodes.append(txt.text ?? kEmptyString) }
            
            if otpCodes.count == _otpCodeList.count {
                let code = otpCodes.joined()
                view.endEditing(true)
                if isFromEmailorMobileVerify{
                    _requestVerifyEmailOrMobile(code: code)
                } else {
                    self.checkDeviceToken(code)
                }
            }
        }
    }
    
    private func _reset() {
        for field in self._otpCodeList { field.text = kEmptyString }
        _validateVerifyButton()
    }
    
    // --------------------------------------
    // MARK: Service method
    // --------------------------------------
    
    private func _requestPhoneLogin(param: [String: Any]) {
        showHUD()
        APPSESSION.loginWithPhone(params: param) { [weak self] isSuccess, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard isSuccess else { return }
            self.view.makeToast("otp_sent_successfully".localized())
        }
    }
    
    func _requestOtpVerify(code: String, token: String) {
        _verifyButton.showLoader(userInteraction: true)
        UIView.transition(with: _buttonIcon, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self._buttonIcon.buttonImage = UIImage(named: "icon_loading")
        }, completion: nil)
        APPSESSION.verifyOtp(userId: APPSESSION.userId, code: code, token: token) { [weak self] isSuccess, error in
            guard let self = self else { return }
            self._verifyButton.hideLoader()
            self.hideHUD(error: error)
            guard isSuccess else { return }
            for field in  self._otpCodeList {
                field.text = ""
                field.textAlignment = .center
                field.delegate = self
                field.keyboardType = .numberPad
                field.textContentType = .oneTimeCode
            }
            self.view.makeToast("otp_verified".localized())
            UIView.transition(with: self._buttonIcon, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self._buttonIcon.buttonImage = UIImage(named: "icon_rightgreen")
            }, completion: nil)
            self._verifyButton.setTitle("verified".localized())
            self._verifyButton.hideLoader()
            self._progressView.stopTimer()
            APPSETTING.configure()
//            ADSETTING.requestAdSetting()
            NOTIFICATION.getUnreadCount()
            APPSESSION.getUpdate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.buttonClicked?(0)
                self.dismiss(animated: true)
            }
        }
    }
    
    func checkDeviceToken(_ code: String) {
//        APPINTIGRITY.generateDeviceToken { [weak self] data, error  in
//            guard let self = self else { return }
//            self.hideHUD(error: error as NSError?)
//            guard let token = data else { return }
//            DISPATCH_ASYNC_MAIN {
                self._requestOtpVerify(code: code, token: "token")
//            }
//        }
    }
    
    func _requestVerifyEmailOrMobile(code: String) {
        _verifyButton.showLoader(userInteraction: true)
        UIView.transition(with: _buttonIcon, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self._buttonIcon.buttonImage = UIImage(named: "icon_loading")
        }, completion: nil)
        self.view.makeToast("otp_verified".localized())
        UIView.transition(with: self._buttonIcon, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self._buttonIcon.buttonImage = UIImage(named: "icon_rightgreen")
        }, completion: nil)
        self._verifyButton.setTitle("verified".localized())
        self._verifyButton.hideLoader()
        self._progressView.stopTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.delegate?.buttonClicked?(1)
            self.dismiss(animated: true)
        }
    }
    
    // --------------------------------------
    // MARK: IBActions Event
    // --------------------------------------
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func _handleVerifyEvent(_ sender: LoadingButton) {
        var otpCodes: [String] = []
        for txt in _otpCodeList { otpCodes.append(txt.text ?? kEmptyString) }
        
        if otpCodes.count == _otpCodeList.count {
            let code = otpCodes.joined()
            view.endEditing(true)
            if isFromEmailorMobileVerify{
                _requestVerifyEmailOrMobile(code: code)
            }else {
                checkDeviceToken(code)
            }
        }
    }
    
    @IBAction private func _handleResendEvent(_ sender: UIButton) {
//        _totalTime = 30
        self._progressView.isHidden = false
        self._buttonIcon.isHidden = true
        _resendButton.isHidden = true
        _resendText.text = kEmptyString
        _progressView.totalTime = 120
        _progressView.startCountdown()
//        _countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
        let params: [String: Any] = ["phone": phoneNumber,"platform": "ios","countryCode": countryCode]
        _requestPhoneLogin(param: params)

    }
    
}

// --------------------------------------
// MARK: TextField Delegate
// --------------------------------------

extension AccountCreatedBottomSheet: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length == 0 && string.isEmpty) {
            self.textFieldDidDelete(textField)
            return false }
        
        if (range.length == 1 && string.isEmpty) {
            textField.text = kEmptyString
            _validateVerifyButton()
            return false
        }
        
        if string.count == 0 {
            _validateVerifyButton()
            return false
        }
        
        if !(string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil) {
            _validateVerifyButton()
            return false
        }
        
        textField.text = string
        self.textFieldDidChange(textField)
        return false
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        _validateVerifyButton()
        var index = 0
        for textField in _otpCodeList {
            index += 1
            if textField.isFirstResponder && index < _otpCodeList.count {
                _otpCodeList[index].becomeFirstResponder()
                break
            }
        }
    }
    
    func textFieldDidDelete(_ textField: UITextField) {
        guard var index = _otpCodeList.firstIndex(of: textField) else { return }
        index -= 1
        if index >= 0 {
            let textField = _otpCodeList[index]
            textField.becomeFirstResponder()
            textField.text = kEmptyString
            _validateVerifyButton()
        }
    }
}
