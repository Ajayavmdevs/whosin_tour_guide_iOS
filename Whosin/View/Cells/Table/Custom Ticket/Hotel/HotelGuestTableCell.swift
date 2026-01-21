import UIKit
import DialCountries
import DropDown
import MapKit
import IQKeyboardManagerSwift


class HotelGuestTableCell: UITableViewCell {
    
    @IBOutlet private weak var _maritalStatusLbl: CustomLabel!
    @IBOutlet private weak var _primaryView: UIView!
    @IBOutlet weak var _titleLbl: UILabel!
    @IBOutlet private weak var _phonenoView: UIStackView!
    @IBOutlet private weak var _emailView: UIStackView!
    @IBOutlet private weak var _lblFlag: UILabel!
    @IBOutlet private weak var _lblDialCode: UILabel!
    @IBOutlet private weak var _firstName: CustomTextField!
    @IBOutlet private weak var _lastName: CustomTextField!
    @IBOutlet private weak var _email: CustomTextField!
    @IBOutlet private weak var _phoneNumber: UITextField!
    @IBOutlet private weak var _nationalityLabel: UILabel!
    @IBOutlet private weak var _messageField: CustomTextField!
    @IBOutlet private weak var _ageField: CustomTextField!
    @IBOutlet private weak var _nationalityView: UIStackView!
    @IBOutlet private weak var _messageView: UIStackView!
    @IBOutlet private weak var _paxTypeLabel: CustomLabel!
    @IBOutlet private weak var _emailTitleText: CustomLabel!
    @IBOutlet private weak var _phoneTitleText: CustomLabel!
    @IBOutlet weak var _firstNameContainerView: UIView!
    @IBOutlet weak var _lastNameContainerView: UIView!
    @IBOutlet weak var _ageContainerView: UIView!
    @IBOutlet weak var _emailContainerView: UIView!
    @IBOutlet weak var _phoneContainerView: UIView!
    @IBOutlet weak var _nationalityContainerView: UIView!
    private var _selectedCountry: Country?
    private var isNationality: Bool = false
    private var pickerType: String = "phone"
    
    public var guestList: JPPassengerModel?
    
    public var callback: (() -> Void)?

    let dropDown = DropDown()
    
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
    
    public func setupData(_ data: JPPassengerModel?, _ isPrimaryGuest: Bool = false) {
        guestList = data
        guestList?.prefix = _maritalStatusLbl.text ?? kEmptyString
        _phonenoView.isHidden = false
        _emailView.isHidden = false
        _nationalityView.isHidden = false
        _messageView.isHidden = true
        _ageField.text = data?.age
        guestList?.leadPassenger = isPrimaryGuest ? 1 : 0
        
        let paxAge = Int(data?.age ?? "") ?? 0
        let paxType: String = paxAge < 12 ? "childTitle".localized() : "adult".localized()
        _paxTypeLabel.text = paxType
        guestList?.paxType = paxType.lowercased()

        if isPrimaryGuest {
            // Primary Guest → Fill all data from session
            setAppSessionData(fillAll: true)
        } else {
            // Other Guests → Fill only email, phone & nationality from session
            setAppSessionData(fillAll: false)
        }

        // If passenger data already exists, prefer that over defaults
        if let firstName = data?.firstName, !Utils.stringIsNullOrEmpty(firstName) {
            _firstName.text = firstName
            guestList?.firstName = firstName
        }
        if let lastName = data?.lastName, !Utils.stringIsNullOrEmpty(lastName) {
            _lastName.text = lastName
            guestList?.lastName = lastName
        }
        if let age = data?.age, !Utils.stringIsNullOrEmpty(age) {
            _ageField.text = age
            guestList?.age = age
        }

        validateAndUpdateGuestList()
        callback?()
    }


    private func setAppSessionData(fillAll: Bool) {
        let user = APPSESSION.userDetail
        
        // Fill phone and email for all guests
        _email.text = user?.email ?? ""
        _phoneNumber.text = user?.phone ?? ""
        guestList?.email = user?.email ?? ""
        guestList?.mobile = user?.phone ?? ""
        
        // Setup flag & dial code
        let dialCode = Utils.stringIsNullOrEmpty(user?._countryCode) ? "+971" : user?._countryCode ?? "+971"
        _lblDialCode.text = dialCode
        let code = Utils.getCountryCode(for: dialCode) ?? "AE"
        _lblFlag.text = Utils.getCountyFlag(code: code)
        guestList?.countryCode = code

        // Nationality (always prefilled)
        let nationalityCode = Utils.getCountryCodeByName(byCountryName: user?.nationality ?? "AE") ?? "AE"
        let nationalityFlag = Utils.getCountyFlag(code: nationalityCode)
        _nationalityLabel.text = Utils.stringIsNullOrEmpty(user?.nationality) ? "select_nationality".localized() : "\(nationalityFlag) \(user?.nationality ?? "")"
        guestList?.nationality = user?.nationality ?? ""

        // Only primary guest gets name fields prefilled
        if fillAll {
            _firstName.text = user?.firstName ?? ""
            _lastName.text = user?.lastName ?? ""
            guestList?.firstName = user?.firstName ?? ""
            guestList?.lastName = user?.lastName ?? ""
        } else {
            _firstName.text = ""
            _lastName.text = ""
            guestList?.firstName = ""
            guestList?.lastName = ""
        }

        // Update borders based on validity
        updateBorder(for: _firstNameContainerView, isValid: fillAll && !Utils.stringIsNullOrEmpty(user?.firstName))
        updateBorder(for: _lastNameContainerView, isValid: fillAll && !Utils.stringIsNullOrEmpty(user?.lastName))
        updateBorder(for: _emailContainerView, isValid: Utils.isEmail(emailString: user?.email ?? ""))
        updateBorder(for: _phoneContainerView, isValid: Utils.isValidNumber(user?.phone ?? "", code))
        updateBorder(for: _nationalityContainerView, isValid: !Utils.stringIsNullOrEmpty(user?.nationality))
    }

    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setup() {
        _firstName.delegate = self
        _lastName.delegate = self
        _email.delegate = self
        _phoneNumber.delegate = self
        _ageField.delegate = self
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
            self.guestList?.prefix = item
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
    
    private func validateAndUpdateGuestList() {
        guard let guest = guestList else { return }
        // Validate first name
        let isFirstNameValid = !Utils.stringIsNullOrEmpty(guest.firstName)
        updateBorder(for: _firstNameContainerView, isValid: isFirstNameValid)
        // Validate last name
        let isLastNameValid = !Utils.stringIsNullOrEmpty(guest.lastName)
        updateBorder(for: _lastNameContainerView, isValid: isLastNameValid)
        // Validate email
        let isEmailValid = Utils.isEmail(emailString: guest.email)
        updateBorder(for: _emailContainerView, isValid: isEmailValid)
        // Validate phone
        let isPhoneValid = Utils.isValidNumber(guest.mobile, guest.countryCode)
        updateBorder(for: _phoneContainerView, isValid: isPhoneValid)
        // Validate nationality
        let isNationalityValid = !Utils.stringIsNullOrEmpty(guest.nationality)
        updateBorder(for: _nationalityContainerView, isValid: isNationalityValid)
        // Validate age
        let paxAge = Int(guest.age) ?? 0
        let paxType = guest.paxType
        var isAgeValid = !Utils.stringIsNullOrEmpty(guest.age)
        if paxType == "childTitle".localized() {
            isAgeValid = isAgeValid && paxAge < 18
        } else if paxType == "adult".localized() {
            isAgeValid = isAgeValid && paxAge >= 18
        }
        updateBorder(for: _ageContainerView, isValid: isAgeValid)
        // Update booking manager model
        if let idx = HOTELBOOKINGMANAGER.bookingModel.passengers.firstIndex(where: { $0.id == guest.id }) {
            HOTELBOOKINGMANAGER.bookingModel.passengers[idx] = guest
        }
        callback?()
    }
}

extension HotelGuestTableCell: DialCountriesControllerDelegate {
    func didSelected(with country: Country) {
        if pickerType == "nationality" {
            _nationalityLabel.text = "\(country.flag) \(country.name)"
            guestList?.nationality = country.name
            validateAndUpdateGuestList()
        } else {
            _lblDialCode.text = country.dialCode
            _lblFlag.text = country.flag
            _selectedCountry = country
            guestList?.countryCode = country.code ?? "AE"
            validateAndUpdateGuestList()
        }
    }
}

extension HotelGuestTableCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }

        switch textField {
        case _phoneNumber:
            guestList?.mobile = text

        case _email:
            guestList?.email = text

        case _firstName:
            guestList?.firstName = text

        case _lastName:
            guestList?.lastName = text
            
        case _ageField:
            guestList?.age = text

        default:
            break
        }

        validateAndUpdateGuestList()
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
