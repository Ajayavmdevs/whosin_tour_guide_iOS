import UIKit
import DialCountries
import IQKeyboardManagerSwift

protocol ReloadProfileDelegate: AnyObject {
    func didRequestReload()
}

class EditProfileVC: ChildViewController {
    
    
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _bioTextView: UITextView!
    @IBOutlet private weak var _firstNameTextField: UITextField!
    @IBOutlet private weak var _lastNameTextField: UITextField!
    @IBOutlet private weak var _emailTextField: UITextField!
    @IBOutlet private weak var _phoneTextField: UITextField!
    @IBOutlet private weak var _lblCountryFlag: UILabel!
    @IBOutlet private weak var _lblCountryCode: UILabel!
    @IBOutlet private weak var _lblBirthDate: UILabel!
    @IBOutlet private weak var _lblNationality: UILabel!
    @IBOutlet private weak var _lblGender: UILabel!
    @IBOutlet private weak var _datePickerBtn: UIButton!
    @IBOutlet private weak var _dateView: UIView!
    @IBOutlet private weak var _profileImageView: UIImageView!
    @IBOutlet private weak var _emailVerifyView: GradientView!
    @IBOutlet private weak var _phoneVerifyView: GradientView!
    @IBOutlet private weak var _phoneVerifyButton: UIButton!
    @IBOutlet private weak var _emailVerifyButton: UIButton!
    @IBOutlet weak var _editImage: UIImageView!
    @IBOutlet weak var _emailStack: UIStackView!
    @IBOutlet weak var _phoneStack: UIStackView!
    @IBOutlet weak var _dobStack: UIStackView!
    @IBOutlet weak var _nationalityStack: UIStackView!
    @IBOutlet weak var _genderStack: UIStackView!
    @IBOutlet weak var _instagramField: CustomFormField!
    @IBOutlet weak var _tiktokField: CustomFormField!
    @IBOutlet weak var _youtubeField: CustomFormField!
    @IBOutlet weak var _facebookField: CustomFormField!
    private var _selectedCountry: Country?
    private var _defaultCountrycode: String = "UAE"
    private var _defaultDialCode: String = "+971"
    private let _imagePicker = UIImagePickerController()
    public var delegate: ReloadProfileDelegate?
    private var selectedBirthDate: String = kEmptyString
    private var instagram: String = kEmptyString
    private var tiktok: String = kEmptyString
    private var youtube: String = kEmptyString
    private var facebook: String = kEmptyString
    var callback: (() -> Void)?
    
    let _datePicker: DatePicker = {
        let v = DatePicker()
        return v
    }()
    var selectedGender: String?
    private var isFromNatinality: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        hideNavigationBar()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        _profileImageView.addGestureRecognizer(tapGesture)
        _editImage.addGestureRecognizer(tapGesture)
        
        let emailTap = UITapGestureRecognizer(target: self, action: #selector(emailTapped))
        _emailStack.addGestureRecognizer(emailTap)
        
//        let phoneTap = UITapGestureRecognizer(target: self, action: #selector(phoneTapped))
//        _phoneStack.addGestureRecognizer(phoneTap)
        
        let dobTap = UITapGestureRecognizer(target: self, action: #selector(dateofBirthTapped))
        _dobStack.addGestureRecognizer(dobTap)
        
        let nationalityTap = UITapGestureRecognizer(target: self, action: #selector(nationalityTapped))
        _nationalityStack.addGestureRecognizer(nationalityTap)
        
        let genderTap = UITapGestureRecognizer(target: self, action: #selector(genderTapped))
        _genderStack.addGestureRecognizer(genderTap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func setupUi() {
        _firstNameTextField.text = APPSESSION.userDetail?.firstName
        _lastNameTextField.text = APPSESSION.userDetail?.lastName
        _emailTextField.text = APPSESSION.userDetail?.email
        _lblCountryCode.text = Utils.getCurrentDialCode()
        _phoneTextField.text = APPSESSION.userDetail?.phone
        _bioTextView.text = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.bio) ? "about_you_placeholder".localized() : APPSESSION.userDetail?.bio
        _bioTextView.textColor = _bioTextView.text == "about_you_placeholder".localized() ? ColorBrand.brandLightGray : ColorBrand.white
        _bioTextView.delegate = self
        let countryCode = Utils.getCurrentDialCode()
        _lblCountryFlag.text = Utils.getcurrentFlag()
        selectedBirthDate = APPSESSION.userDetail?.dateOfBirth ?? kEmptyString
        let birthDate = Utils.stringToDate(selectedBirthDate, format: kFormatDate)
        _lblBirthDate.text = Utils.stringIsNullOrEmpty(Utils.dateToString(birthDate, format: kFormatDateReview)) ? "select_dob".localized() : Utils.dateToString(birthDate, format: kFormatDateReview)
        _lblNationality.text = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.nationality) ? "select_nationality".localized() : APPSESSION.userDetail?.nationality
        _lblGender.text = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.gender) ? "select_gender".localized() : APPSESSION.userDetail?.gender
        _profileImageView.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
        _visualEffectView.alpha = 0
        if APPSESSION.userDetail?.isPhoneVerified == 1 {
            _phoneVerifyButton.setTitle("verified".localized())
            _phoneVerifyButton.isUserInteractionEnabled = false
            _phoneVerifyView.startColor = ColorBrand.brandGreen
            _phoneVerifyView.endColor = ColorBrand.brandGreen
        } else {
            _phoneVerifyButton.setTitle("verify".localized())
            _phoneVerifyView.startColor = UIColor.init(hexString: "#DE1399")
            _phoneVerifyView.endColor = UIColor.init(hexString: "#B820EE")
        }
        
        if APPSESSION.userDetail?.email.isEmpty == true {
            _emailVerifyView.isHidden = true
        } else if APPSESSION.userDetail?.isEmailVerified == 1 {
            _emailVerifyButton.setTitle("verified".localized())
            _emailVerifyButton.isUserInteractionEnabled = false
            _emailVerifyView.startColor = ColorBrand.brandGreen
            _emailVerifyView.endColor = ColorBrand.brandGreen
        } else {
            _emailVerifyButton.setTitle("verify".localized())
            _emailVerifyView.startColor = UIColor.init(hexString: "#DE1399")
            _emailVerifyView.endColor = UIColor.init(hexString: "#B820EE")

        }
        setupSocialData()
        
        // --------------------------------------
        // MARK: DatePicker
        // --------------------------------------
        
        [_datePickerBtn, _datePicker].forEach { v in
            v!.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v!)
        }
        
        _dateView.addSubview(_datePickerBtn)
        _datePickerBtn.centerXAnchor.constraint(equalTo: _dateView.centerXAnchor).isActive = true
        _datePickerBtn.centerYAnchor.constraint(equalTo: _dateView.centerYAnchor).isActive = true
        _datePickerBtn.leadingAnchor.constraint(equalTo: _dateView.leadingAnchor).isActive = true
        _datePickerBtn.trailingAnchor.constraint(equalTo: _dateView.trailingAnchor).isActive = true

        let d = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            _datePicker.topAnchor.constraint(equalTo: d.topAnchor),
            _datePicker.leadingAnchor.constraint(equalTo: d.leadingAnchor),
            _datePicker.trailingAnchor.constraint(equalTo: d.trailingAnchor),
            _datePicker.bottomAnchor.constraint(equalTo: d.bottomAnchor),
        ])
        
        _datePicker.isHidden = true
        
        _datePicker.dismissClosure = { [weak self] in
            guard let self = self else { return }
            self._datePicker.isHidden = true
        }
        _datePicker.changeClosure = { [weak self] val in
            guard let self = self else { return }
            self.selectedBirthDate = Utils.dateToString(val, format: kFormatDate)
            self._lblBirthDate.text = Utils.dateToString(val, format: kFormatDateReview)
        }
        
        _datePickerBtn.addTarget(self, action: #selector(tapDate(_:)), for: .touchUpInside)

    }
    
    private func setupSocialData() {
        _instagramField.fieldType = FormFieldType.social.rawValue
        _tiktokField.fieldType = FormFieldType.social.rawValue
        _youtubeField.fieldType = FormFieldType.social.rawValue
        _facebookField.fieldType = FormFieldType.social.rawValue
        
        instagram = APPSESSION.userDetail?.instagram ?? kEmptyString
        tiktok = APPSESSION.userDetail?.tiktok ?? kEmptyString
        youtube = APPSESSION.userDetail?.youtube ?? kEmptyString
        facebook = APPSESSION.userDetail?.facebook ?? kEmptyString

        _instagramField.setupData(instagram, subtitle: "add_your_instagram_handle".localized(), icon: "icon_instagram", isEnable: true)
        _tiktokField.setupData(tiktok, subtitle: "add_your_tiktok_account_optional".localized(), icon: "icon_tiktok",isEnable: true)
        _youtubeField.setupData(youtube, subtitle: "add_your_youtube_channel_optional".localized(), icon: "icon_youtube",isEnable: true)
        _facebookField.setupData(facebook, subtitle: "add_your_facebook_account_optional".localized(), icon: "icon_facebook",isEnable: true)
        
        _instagramField.callback = { text in
            self.instagram = text ?? kEmptyString
        }
        _tiktokField.callback = { text in
            self.tiktok = text ?? kEmptyString
        }
        _youtubeField.callback = { text in
            self.youtube = text ?? kEmptyString

        }
        _facebookField.callback = { text in
            self.facebook = text ?? kEmptyString
        }
    }

    private func _showEmailVerification() {
        alert(message: "verify_email".localized(), handler: { action in
            let presentedViewController = INIT_CONTROLLER_XIB(VerifyBottomSheet.self)
            presentedViewController.isFromEmailVerify = true
            presentedViewController.delegate = self
            self.presentAsPanModal(controller: presentedViewController)
        })
    }

    // --------------------------------------
    // MARK: DATA/SERVICES
    // --------------------------------------

    private func _requestUpdateProfile(params: [String: Any], isShowEmailDialog: Bool = false ) {
        showHUD()
        APPSESSION.updateProfile(param: params) { [weak self] isSuccess, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard isSuccess else { return }
            if isShowEmailDialog {
                self._showEmailVerification()
            }
            self.parent?.showToast("profile_update".localized())
            NotificationCenter.default.post(name: .changeUserUpdateState, object: nil)
            DISPATCH_ASYNC_MAIN_AFTER(0.1) {
                self.callback?()
                self.delegate?.didRequestReload()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func _requestUploadProfileImage(_ image: UIImage) {
        self.showHUD()
        WhosinServices.uploadProfileImage(image: image) { [weak self] model, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let photoUrl = model?.data else { return }
            var params: [String: Any] = [:]
            params["image"] = photoUrl.url
            self._requestUpdateProfile(params: params)
        }
    }
    
   
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    private func _moveToLogin() {
        guard let window = APP.window else { return }
        let navController = NavigationController(rootViewController: INIT_CONTROLLER_XIB(LoginVC.self))
        navController.setNavigationBarHidden(true, animated: false)
        window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
    }
    
    private func _requestSendOtp(type: String){
        WhosinServices.userSendOtp(type: type) { [weak self] container, error in
            guard let self = self  else { return }
            self.hideHUD(error: error)
        }
    }
    
    private func editEmail() {
        let controller = INIT_CONTROLLER_XIB(EmailVerifyVC.self)
        controller.isUpdateEmail = true
        controller.delegate = self
        self.presentAsPanModal(controller: controller)
    }
    
    private func editPhoneNumber() {
        let controller = INIT_CONTROLLER_XIB(MobileLoginVC.self)
        controller.isUpdatePhone = true
        controller.delegate = self
        self.presentAsPanModal(controller: controller)
    }
    
    private func editNationality() {
        isFromNatinality = true
        let controller = DialCountriesController(locale: Locale(identifier: "en"))
        controller.delegate = self
        controller.show(vc: self)
    }
    
    private func editGender() {
        let alertController = UIAlertController(title: "select_gender".localized(), message: nil, preferredStyle: .actionSheet)

        let maleAction = UIAlertAction(title: "male".localized(), style: .default) { _ in
            self.selectedGender = "Male"
            self._lblGender.text = self.selectedGender
        }
        maleAction.setValue(ColorBrand.white, forKey: "titleTextColor")
        alertController.addAction(maleAction)

        let femaleAction = UIAlertAction(title: "female".localized(), style: .default) { _ in
            self.selectedGender = "Female"
            self._lblGender.text = self.selectedGender
        }
        femaleAction.setValue(ColorBrand.white, forKey: "titleTextColor")
        alertController.addAction(femaleAction)

        let otherAction = UIAlertAction(title: "prefer_not_to_say".localized(), style: .default) { _ in
            self.selectedGender = "prefer not to say"
            self._lblGender.text = self.selectedGender
        }
        otherAction.setValue(ColorBrand.white, forKey: "titleTextColor")
        alertController.addAction(otherAction)

        let cancelAction = UIAlertAction(title: "cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)

    }

    @objc private func tapDate(_ sender: Any) {
        _datePicker.isHidden = false
    }
    
    @objc private func emailTapped() {
        editEmail()
    }
    
//    @objc private func phoneTapped() {
//        editPhoneNumber()
//    }
    
    @objc private func dateofBirthTapped() {
        tapDate(self)
    }
    
    @objc private func nationalityTapped() {
        editNationality()
    }
    
    @objc private func genderTapped() {
        editGender()
    }
    
    @objc private func imageTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            _imagePicker.delegate = self
            _imagePicker.sourceType = .savedPhotosAlbum
            _imagePicker.allowsEditing = true
            self.present(_imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction private func _handleCountryCodeEvent(_ sender: UIButton) {
        isFromNatinality = false
        let controller = DialCountriesController(locale: Locale(identifier: "en"))
        controller.delegate = self
        controller.show(vc: self)
    }
    
    @IBAction private func _handleEmailVerifyEvent(_ sender: UIButton) {
        if !Utils.isValidEmail(_emailTextField.text) {
            alert(title: kAppName, message: "invalid_email".localized())
            return
        }

        let presentedViewController = INIT_CONTROLLER_XIB(VerifyBottomSheet.self)
        presentedViewController.isFromEmailVerify = true
        presentedViewController.delegate = self
        self.presentAsPanModal(controller: presentedViewController)
    }
    
    @IBAction private func _handlePhoneVerifyEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(VerifyBottomSheet.self)
        presentedViewController.isFromEmailVerify = false
        presentedViewController.delegate = self
        self.presentAsPanModal(controller: presentedViewController)
    }
    
    @IBAction func _handleEditEmailEvent(_ sender: UIButton) {
        editEmail()
    }
    
    @IBAction private func _handleEditPhoneEvent(_ sender: UIButton) {
        editPhoneNumber()
    }
    
    @IBAction private func _handeleNationalityPicker(_ sender: UIButton) {
        editNationality()
    }
    
    @IBAction private func _handleGenderEvent(_ sender: UIButton) {
        editGender()
    }
    
    @IBAction private func _handleUpdateEvent(_ sender: UIButton) {
        if Utils.stringIsNullOrEmpty(_firstNameTextField.text) {
            return alert(title: kAppName, message: "enter_first_name".localized())
        }
        if Utils.stringIsNullOrEmpty(_lastNameTextField.text) {
            return alert(title: kAppName, message: "enter_last_name".localized())
        }
        
        if !Utils.stringIsNullOrEmpty(_phoneTextField.text) && !Utils.stringIsNullOrEmpty(_lblCountryCode.text) {
            if !Utils.isValidNumber(_phoneTextField.text!, Utils.getCountryCode(for: _lblCountryCode.text!) ?? "AE") {
                alert(message: "invalid_phone".localized())
                return
            }
        }
        
//        if Utils.stringIsNullOrEmpty(_lblCountryCode.text) {
//            return alert(title: kAppName, message: "Please select country code")
//        }
        
//        if !Utils.validateInstagramProfileUrl(URL(string: instagram)) {
//            return alert(title: kAppName, message: "Please enter valid instagram profile link.")
//        }

        var params: [String: Any] = [:]
        params["first_name"] = _firstNameTextField.text
        params["last_name"] = _lastNameTextField.text
        params["phone"] = _phoneTextField.text
        params["country_code"] = _lblCountryCode.text
        params["bio"] = _bioTextView.text != "about_you_placeholder".localized() ? _bioTextView.text : kEmptyString

        if !Utils.stringIsNullOrEmpty(_lblGender.text) {
            params["gender"] = _lblGender.text
        }
        if !Utils.stringIsNullOrEmpty(selectedBirthDate) {
            params["dateOfBirth"] = selectedBirthDate
        }
        
        if !Utils.stringIsNullOrEmpty(_emailTextField.text) {
            params["email"] = _emailTextField.text
        } 

        if !Utils.stringIsNullOrEmpty(_lblNationality.text) {
            params["nationality"] = _lblNationality.text
        }
        
        if !Utils.stringIsNullOrEmpty(instagram) {
            params["instagram"] = instagram
        }
        
        if !Utils.stringIsNullOrEmpty(tiktok) {
            params["tiktok"] = tiktok
        }
        
        if !Utils.stringIsNullOrEmpty(youtube) {
            params["youtube"] = youtube
        }
        
        if !Utils.stringIsNullOrEmpty(facebook) {
            params["facebook"] = facebook
        }
        
        _requestUpdateProfile(params: params)
    }
    
    @IBAction private func _handleUserDeleteAccount(_ sender: UIButton) {
        showDeleteAlert()
    }
    
    private func deleteAccount(_ type: String) {
        APPSESSION.deleteAccount(type: type) { success, error in
            self.hideHUD(error: error)
            if success {
                self._moveToLogin()
            }
        }
    }
    
    private func showDeleteAlert() {
        let alertController = UIAlertController(title: kAppName, message: "delete_account_confirmation".localized(), preferredStyle: .alert)

        let temporaryAction = UIAlertAction(title: "temporary".localized(), style: .default) { _ in
            self.showCustomAlert(title: kAppName, message: "temporary_delete_info".localized(), yesButtonTitle: "yes_delete".localized(), noButtonTitle: "cancel".localized()) { UIAlertAction in
                self.deleteAccount("deactive")
            } noHandler: { UIAlertAction in
            }
        }
        alertController.addAction(temporaryAction)

        let permanentlyAction = UIAlertAction(title: "permanently".localized(), style: .default) { _ in
            self.showCustomAlert(title: kAppName, message: "delete_data_warning".localized(), yesButtonTitle: "yes_delete".localized(), noButtonTitle: "cancel".localized()) { UIAlertAction in
                self.deleteAccount("deactive")
            } noHandler: { UIAlertAction in
            }
        }
        alertController.addAction(permanentlyAction)

        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction private func _handleDeactivateEvent(_ sender: UIButton) {
        showCustomAlert(title: kAppName, message: "deactivate_info".localized(), yesButtonTitle: "yes_deactivate".localized(), noButtonTitle: "cancel".localized()) { UIAlertAction in
            self.deleteAccount("deactive")
        } noHandler: { UIAlertAction in
        }
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}


extension EditProfileVC: DialCountriesControllerDelegate {
    func didSelected(with country: Country) {
        if isFromNatinality {
            _lblNationality.text = country.name
        }else {
            _lblCountryCode.text = country.dialCode
            _lblCountryFlag.text = country.flag
            _selectedCountry = country
        }
    }
}

// --------------------------------------
// MARK: UIViewControllerTransitioning Delegate
// --------------------------------------

extension EditProfileVC: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}

extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        _imagePicker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self._profileImageView.image = image
                self._requestUploadProfileImage(image)
            }
        }
    }
}


// --------------------------------------
// MARK: Action Button Delagate
// --------------------------------------

extension EditProfileVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == _firstNameTextField {
            _lastNameTextField.becomeFirstResponder()
        } else if textField == _lastNameTextField {
            _bioTextView.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension EditProfileVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 20
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 0.0
            }, completion: nil)
        }
    }
}

extension EditProfileVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "about_you_placeholder".localized() {
            textView.textColor = ColorBrand.white
            textView.text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "about_you_placeholder".localized()
            textView.textColor = ColorBrand.brandLightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
         if text == "\n" {
             textView.resignFirstResponder()
             return false
         }
         return true
     }
}

extension EditProfileVC: ActionButtonDelegate {
    func buttonClicked(_ tag: Int) {
        if tag == 1 {
            APPSESSION.getProfile { success, error in
                if success {
                    self.setupUi()
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
