import UIKit
import MHLoadingButton

class VerifyBottomSheet: PanBaseViewController {
        
    @IBOutlet private weak var _subtitleLabel: UILabel!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _resendButton: UIButton!
    @IBOutlet private weak var _resendLabel: UILabel!
    @IBOutlet private weak var _textFieldFour: OTPTextField!
    @IBOutlet private weak var _textFieldThree: OTPTextField!
    @IBOutlet private weak var _textFieldTwo: OTPTextField!
    @IBOutlet private weak var _textFieldOne: OTPTextField!
    @IBOutlet private weak var _verifyButton: LoadingButton!
    @IBOutlet private weak var _buttonIcon: CustomGradientBorderButton!
    @IBOutlet weak var _progressView: RoundProgressView!
    private var _totalTime: Int = 30
    private var _countdownTimer: Timer!
    var delegate: ActionButtonDelegate?
    var isFromEmailVerify: Bool = false
    private var _otpCodeList: [UITextField] = []
    private var _code: String = kEmptyString
    var isUpdateUserPhone: Bool = false
    var phoneNumber: String = kEmptyString
    var countryCode: String = kEmptyString
    var email: String = kEmptyString
    
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
    
    override func setupUi() {
        _progressView.startCountdown()
        _resendButton.isHidden = true
        _resendLabel.text = kEmptyString
        _progressView.timerCompletion = {
            self._progressView.isHidden = true
            self._buttonIcon.isHidden = false
            self._resendButton.isHidden = false
            self._resendLabel.text = "didnt_get_code".localized()
        }
        if  !isUpdateUserPhone { _requestSendOtp(type: isFromEmailVerify ? "email" : "phone") }
        if !isFromEmailVerify {
            _titleLabel.text = "verify_phone".localized()
            _subtitleLabel.text = "otp_sent_phone".localized()
        } else if isFromEmailVerify {
            _titleLabel.text = "Verify_email!"
            _subtitleLabel.text = "We_sent_digits_to_your_email".localized()
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

    }
    
    // --------------------------------------
    // MARK: Public Methods
    // --------------------------------------
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
    
    @objc private func updateTimerLabel() {
        _resendButton.isHidden = true
        _totalTime -= 1
        _resendLabel.text = LANGMANAGER.localizedString(forKey: "resent_otp_timer", arguments: ["value": "\(self.timeFormatted(_totalTime))"])
        if _totalTime == 0 {
            _countdownTimer.invalidate()
            _resendButton.isHidden = false
            _resendLabel.text = "didnt_get_code".localized()
        }
    }
    
    private func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        return String(format: "%02d", seconds)
    }
    
    private func _validateVerifyButton() {
        let isValid = _otpCodeList.first(where: { Utils.stringIsNullOrEmpty($0.text) }) == nil
        _verifyButton.isEnabled = isValid
        _verifyButton.alpha = isValid ? 1 : 0.5
        if isValid {
            var otpCodes: [String] = []
            for txt in _otpCodeList { otpCodes.append(txt.text ?? kEmptyString) }
            
            if otpCodes.count == _otpCodeList.count {
                view.endEditing(true)
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
    private func _requestSendOtp(type: String){
        WhosinServices.userSendOtp(type: type) { [weak self] container, error in
            guard let self = self  else { return }
            self.showError(error)
        }
    }
    
    func _requestOtpVerify(type: String, code: String, token: String) {
        _verifyButton.showLoader(userInteraction: true)
        UIView.transition(with: _buttonIcon, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self._buttonIcon.buttonImage = UIImage(named: "icon_loading")
        }, completion: nil)
        WhosinServices.userVerifyOtp(type: type, otp: code) { [weak self] container, error in
            guard let self = self else { return }
            self._verifyButton.hideLoader()
            guard let model = container, model.isSuccess, let data = model.data else {
                self._buttonIcon.buttonImage = UIImage(named: "icon_verify")
                self.view.makeToast(error?.localizedDescription)
                return
            }
            print(data)
            guard let userDetail = APPSESSION.userDetail else { return }
            if type == "phone" {
                userDetail.isPhoneVerified = 1
            } else {
                userDetail.isEmailVerified = 1
                userDetail.email = email
            }
            APPSESSION.saveUserDetail(userDetail)
            self.view.makeToast(container?.message)
            UIView.transition(with: self._buttonIcon, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self._buttonIcon.buttonImage = UIImage(named: "icon_rightgreen")
            }, completion: nil)
            self._verifyButton.setTitle("verified".localized())
            self._verifyButton.hideLoader()
            self._progressView.stopTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.isFromEmailVerify {
                    self.delegate?.buttonClicked?(1)
                } else {
                    self.delegate?.buttonClicked?(0)
                }
                self.dismiss(animated: true)
            }
        }
    }
        
    func _requestUpdatePhoneVerifyOtp(type: String, code: String, token: String) {
        _verifyButton.showLoader(userInteraction: true)
        UIView.transition(with: _buttonIcon, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self._buttonIcon.buttonImage = UIImage(named: "icon_loading")
        }, completion: nil)
        WhosinServices.userUpdateOtp(type: type, otp: code, email: email, phone: phoneNumber, countryCode: countryCode) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.view.makeToast(container?.message)
            APPSESSION.saveUserDetail(data)
            UIView.transition(with: self._buttonIcon, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self._buttonIcon.buttonImage = UIImage(named: "icon_rightgreen")
            }, completion: nil)
            self._verifyButton.setTitle("verified".localized())
            self._verifyButton.hideLoader()
            self._progressView.stopTimer()
            DISPATCH_ASYNC_MAIN_AFTER(0.5) {
                self.delegate?.buttonClicked?(1)
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
                if self.isFromEmailVerify {
                    self._requestOtpVerify(type:"email", code: code, token: "token")
                }else {
                    if self.isUpdateUserPhone {
                        self._requestUpdatePhoneVerifyOtp(type: "phone", code: code, token: "token")
                    } else {
                        self._requestOtpVerify(type: "phone", code: code, token: "token")
                    }
                }
//            }
//        }
    }
    
    // --------------------------------------
    // MARK: IBActions Event
    // --------------------------------------
    
    @IBAction func _handleResedEvent(_ sender: UIButton) {
        self._progressView.isHidden = false
        self._buttonIcon.isHidden = true
        _resendButton.isHidden = true
        _resendLabel.text = kEmptyString
        _progressView.totalTime = 120
        _progressView.startCountdown()
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func _handleVerifyEvent(_ sender: LoadingButton) {
        var otpCodes: [String] = []
        for txt in _otpCodeList { otpCodes.append(txt.text ?? kEmptyString) }
        
        if otpCodes.count == _otpCodeList.count {
            let code = otpCodes.joined()
            view.endEditing(true)
            checkDeviceToken(code)
        }
    }
    
}

// --------------------------------------
// MARK: TextField Delegate
// --------------------------------------

extension VerifyBottomSheet: UITextFieldDelegate {
    
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
