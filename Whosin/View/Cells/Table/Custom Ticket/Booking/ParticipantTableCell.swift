import UIKit
import DialCountries
import DropDown
import MapKit
import IQKeyboardManagerSwift


class ParticipantTableCell: UITableViewCell {
    
    @IBOutlet private weak var _maritalStatusLbl: CustomLabel!
    @IBOutlet private weak var _primaryView: UIView!
    @IBOutlet private weak var _pickupStack: UIStackView!
    @IBOutlet weak var _titleLbl: UILabel!
    @IBOutlet private weak var _phonenoView: UIStackView!
    @IBOutlet private weak var _emailView: UIStackView!
    @IBOutlet private weak var _lblFlag: UILabel!
    @IBOutlet private weak var _lblDialCode: UILabel!
    @IBOutlet private weak var _firstName: CustomTextField!
    @IBOutlet private weak var _lastName: CustomTextField!
    @IBOutlet private weak var _email: CustomTextField!
    @IBOutlet private weak var _pickupTextField: CustomTextField!
    @IBOutlet private weak var _phoneNumber: UITextField!
    @IBOutlet private weak var _nationalityLabel: UILabel!
    @IBOutlet private weak var _messageField: CustomTextField!
    @IBOutlet private weak var _nationalityView: UIStackView!
    @IBOutlet private weak var _messageView: UIStackView!
    @IBOutlet private weak var _paxTypeLabel: CustomLabel!
    @IBOutlet private weak var _emailTitleText: CustomLabel!
    @IBOutlet private weak var _phoneTitleText: CustomLabel!
    @IBOutlet weak var _firstNameContainerView: UIView!
    @IBOutlet weak var _lastNameContainerView: UIView!
    @IBOutlet weak var _emailContainerView: UIView!
    @IBOutlet weak var _phoneContainerView: UIView!
    @IBOutlet weak var _nationalityContainerView: UIView!
    private var _selectedCountry: Country?
    private var isNationality: Bool = false
    private var pickerType: String = "phone"
    
    public var passengersList: PassengersModel?
    
    public var callback: (() -> Void)?

    let dropDown = DropDown()
    let allowedRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 23.4241, longitude: 53.8478),span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0))
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _emailTitleText.attributedText = getAttributedEmailText(string: "make_sure_this_is_your_correct_email".localized())
        _phoneTitleText.attributedText = getAttributedEmailText(string: "please_enter_your_active_whatsapp_number".localized(), isPhone: true)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 10
        _setup()
    }
    
    private func getAttributedEmailText(string: String, isPhone: Bool = false) -> NSAttributedString {
        let fullText = isPhone ? "" : "email_id".localized()
        
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ])
        
        let emailAttributedString = NSAttributedString(string: string, attributes: [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(90)
        ])
        
        attributedString.append(emailAttributedString)
        return attributedString
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: PassengersModel?,_ isPrimaryGuest: Bool = false) {
        passengersList = data
        passengersList?.prefix = _maritalStatusLbl.text ?? kEmptyString
        _phonenoView.isHidden = !isPrimaryGuest
        _emailView.isHidden = !isPrimaryGuest
        _nationalityView.isHidden = !isPrimaryGuest
        _messageView.isHidden = !isPrimaryGuest
        _paxTypeLabel.text = passengersList?.paxType ?? "Select"
        _pickupStack.isHidden = true
        _messageView.isHidden = true
        setAppSessionData()
        callback?()
    }
    
    private func setAppSessionData() {
        _firstName.text = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.firstName) ? "" : APPSESSION.userDetail?.firstName
        _lastName.text = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.lastName) ? "" : APPSESSION.userDetail?.lastName
        _email.text = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.email) ? "" : APPSESSION.userDetail?.email
        _phoneNumber.text = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.phone) ? "" : APPSESSION.userDetail?.phone
        updateBorder(for: _firstNameContainerView, isValid: !Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.firstName))
        updateBorder(for: _lastNameContainerView, isValid: !Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.lastName))
        updateBorder(for: _emailContainerView, isValid: !Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.email))
        updateBorder(for: _phoneContainerView, isValid: !Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.phone))

        if Utils.stringIsNullOrEmpty(APPSESSION.userDetail?._countryCode) {
            _lblFlag.text = Utils.getCountyFlag(code: "AE")
            _lblDialCode.text = "+971"
            
            let flag = Utils.getCountyFlag(code: "AE")
            _nationalityLabel.text = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.nationality) ? "select_nationality".localized() : "\(flag) \(APPSESSION.userDetail?.nationality ?? kEmptyString)"
            updateBorder(for: _nationalityContainerView, isValid: !Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.nationality ?? kEmptyString))
            let countryCode = Utils.getCountryCode(for: Utils.stringIsNullOrEmpty(APPSESSION.userDetail?._countryCode) ? "+971" : APPSESSION.userDetail?._countryCode ?? "+971") ?? "AE"
            let isValidPhone = Utils.isValidNumber(APPSESSION.userDetail?.phone ?? "", countryCode)
            updateBorder(for: _phoneContainerView, isValid: isValidPhone)
        } else {
            _lblFlag.text = Utils.getCountyFlag(code: Utils.getCountryCode(for: APPSESSION.userDetail?._countryCode ?? "AE") ?? "AE")
            _lblDialCode.text = APPSESSION.userDetail?._countryCode ?? "AE"
            
            let dialCode = Utils.getCountryCodeByName(byCountryName: APPSESSION.userDetail?.nationality ?? kEmptyString) ?? Country.getCurrentCountry()?.code ?? "AE"
            let flag = Utils.getCountyFlag(code: dialCode)
            _nationalityLabel.text = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.nationality) ? "select_nationality".localized() : "\(flag) \(APPSESSION.userDetail?.nationality ?? kEmptyString)"
            updateBorder(for: _nationalityContainerView, isValid: !Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.nationality))
            let countryCode = Utils.getCountryCode(for: Utils.stringIsNullOrEmpty(APPSESSION.userDetail?._countryCode) ? "+971" : APPSESSION.userDetail?._countryCode ?? "+971") ?? "AE"
            let isValidPhone = Utils.isValidNumber(APPSESSION.userDetail?.phone ?? "", countryCode)
            updateBorder(for: _phoneContainerView, isValid: isValidPhone)
        }
        
        passengersList?.firstName = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.firstName) ? "" : APPSESSION.userDetail?.firstName ?? kEmptyString
        passengersList?.lastName = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.lastName) ? "" : APPSESSION.userDetail?.lastName ?? kEmptyString
        passengersList?.email = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.email) ? "" : APPSESSION.userDetail?.email ?? kEmptyString
        passengersList?.mobile = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.phone) ? "" : APPSESSION.userDetail?.phone ?? kEmptyString
        passengersList?.countryCode =  Utils.stringIsNullOrEmpty(APPSESSION.userDetail?._countryCode) ? "+971" : APPSESSION.userDetail?._countryCode ?? kEmptyString
        passengersList?.nationality =  Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.nationality) ? kEmptyString : APPSESSION.userDetail?.nationality ?? kEmptyString
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setup() {
        _firstName.delegate = self
        _lastName.delegate = self
        _email.delegate = self
        _phoneNumber.delegate = self
        _pickupTextField.delegate = self
    }
    
    private func isInsideAllowedRegion(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let latRange = allowedRegion.center.latitude - allowedRegion.span.latitudeDelta/2 ... allowedRegion.center.latitude + allowedRegion.span.latitudeDelta/2
        let lonRange = allowedRegion.center.longitude - allowedRegion.span.longitudeDelta/2 ... allowedRegion.center.longitude + allowedRegion.span.longitudeDelta/2
        return latRange.contains(coordinate.latitude) && lonRange.contains(coordinate.longitude)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleMaritalStatus(_ sender: UIButton) {
        dropDown.dataSource = ["Mr.","Ms.","Mrs."]
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
        dropDown.direction = .bottom
        dropDown.backgroundColor = ColorBrand.cardBgColor
        dropDown.textColor = ColorBrand.white
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self._maritalStatusLbl.text = item
            self.passengersList?.prefix = item
            self.callback?()
        }
    }
    
    @IBAction private func _handleCountryEvent(_ sender: Any) {
        pickerType = "phone"
        let controller = DialCountriesController(locale: Locale(identifier: "en"))
        controller.delegate = self
        controller.show(vc: (parentViewController.self)!)
    }
    
    @IBAction private func _handleNationalityEvent(_ sender: UIButton) {
        pickerType = "nationality"
        let controller = DialCountriesController(locale: Locale(identifier: "en"))
        controller.delegate = self
        controller.show(vc: (parentViewController.self)!)
    }
    
    @IBAction private func _handlePaxTypeEvent(_ sender: UIButton) {
        dropDown.dataSource = ["Adult","Child","Infant"]
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
        dropDown.direction = .bottom
        dropDown.backgroundColor = ColorBrand.cardBgColor
        dropDown.textColor = ColorBrand.white
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self._paxTypeLabel.text = item
            self.passengersList?.paxType = item
            self.callback?()
        }
    }
    
    @IBAction private func _handleLocationPickerEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(LocationPickerVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.isRestricted = true
        vc.completion = { location in
            self._pickupTextField.text = location?.address ?? ""
            self.passengersList?.pickup = location?.address ?? ""
            self.callback?()
        }
        parentBaseController?.navigationController?.present(vc, animated: true)
    }
    
}

extension ParticipantTableCell: DialCountriesControllerDelegate {
    func didSelected(with country: Country) {
        if pickerType == "nationality" {
            _nationalityLabel.text = "\(country.flag) \(country.name)"
            passengersList?.nationality = country.code
            updateBorder(for: _nationalityContainerView, isValid: !Utils.stringIsNullOrEmpty(country.name))
        } else {
            _lblDialCode.text = country.dialCode
            _lblFlag.text = country.flag
            _selectedCountry = country
            let isValidPhone = Utils.isValidNumber(_phoneNumber.text ?? "", country.dialCode ?? "+971")
            updateBorder(for: _phoneContainerView, isValid: isValidPhone)
            passengersList?.countryCode = country.dialCode ?? "+971"
        }
        self.callback?()
    }
}

extension ParticipantTableCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }

        switch textField {
        case _phoneNumber:
            passengersList?.mobile = text
            let countryCode = Utils.getCountryCode(for: passengersList?.countryCode ?? "+971") ?? "AE"
            let isValidPhone = Utils.isValidNumber(text, countryCode)
            updateBorder(for: _phoneContainerView, isValid: isValidPhone)

        case _email:
            passengersList?.email = text
            let isValidEmail = Utils.isEmail(emailString: text)
            updateBorder(for: _emailContainerView, isValid: isValidEmail)

        case _firstName:
            passengersList?.firstName = text
            let isValid = !Utils.stringIsNullOrEmpty(text)
            updateBorder(for: _firstNameContainerView, isValid: isValid)

        case _lastName:
            passengersList?.lastName = text
            let isValid = !Utils.stringIsNullOrEmpty(text)
            updateBorder(for: _lastNameContainerView, isValid: isValid)

        case _messageView:
            passengersList?.message = text

        default:
            break
        }

        callback?()
    }
    
    private func updateBorder(for view: UIView, isValid: Bool) {
        view.borderColor = isValid ? ColorBrand.brandGray : .red
        view.borderWidth = isValid ? 0.5 : 0.75
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = self.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
