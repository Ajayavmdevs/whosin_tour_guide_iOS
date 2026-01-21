import Foundation
import DialCountries
import UIKit
import SnapKit
import ExpandableLabel


public enum FormFieldType: String {
    case name = "name"
    case email = "email"
    case phone = "phone"
    case about = "about"
    case social = "social"
    case socialForm = "socialForm"
    case nationality = "nationality"
    case gender = "gender"
    case date = "date"
}

class CustomFormField: UIView {
    
    @IBOutlet weak var _socialBgView: UIView!
    @IBOutlet weak var _dropDownArrow: UIImageView!
    @IBOutlet weak var _socialAccountField: LeftSpaceTextField!
    @IBOutlet weak var _socialView: UIView!
    @IBOutlet weak var _titleLbl: CustomLabel!
    @IBOutlet weak var _textField: LeftSpaceTextField!
    @IBOutlet weak var _textFieldBgView: UIView!
    @IBOutlet weak var _textView: UITextView!
    @IBOutlet weak var _socialIcon: UIImageView!
    @IBOutlet weak var _countryView: UIView!
    @IBOutlet weak var _countryFlag: UILabel!
    @IBOutlet weak var _countryCode: UILabel!
    public var isEvent: Bool = false
    public var callback: ((_ text: String?) -> Void)?
    public var dialCodecallback: ((_ text: String?) -> Void)?
    private var selectedDate: String = kEmptyString
    public var fieldType: String = FormFieldType.name.rawValue {
        didSet {
            validateField()
        }
    }
    public var isFromEvent: Bool = false
        
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _textView.delegate = self
        _textField.delegate = self
        _socialAccountField.delegate = self
        _textView.autocapitalizationType = .sentences
        _textField.autocapitalizationType = .sentences
        _socialAccountField.autocapitalizationType = .sentences
        _textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        validateField()
    }
    
    private func validateField() {
        switch fieldType {
        case FormFieldType.name.rawValue, FormFieldType.email.rawValue:
            _textFieldBgView.isHidden = false
            _textView.isHidden = true
            _socialView.isHidden = true
            _titleLbl.isHidden = false
            _dropDownArrow.isHidden = true
        case FormFieldType.about.rawValue:
            _textView.isHidden = false
            _textFieldBgView.isHidden = true
            _socialView.isHidden = true
            _titleLbl.isHidden = false
            _dropDownArrow.isHidden = true
        case FormFieldType.social.rawValue:
            _titleLbl.isHidden = true
            _textView.isHidden = true
            _textFieldBgView.isHidden = true
            _socialView.isHidden = false
            _dropDownArrow.isHidden = true
        case FormFieldType.nationality.rawValue:
            _textFieldBgView.isHidden = false
            _textView.isHidden = true
            _socialView.isHidden = true
            _titleLbl.isHidden = false
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNationalityFieldTap))
            _textField.addGestureRecognizer(tapGesture)
            _textField.isUserInteractionEnabled = true
            _dropDownArrow.isHidden = true
        case FormFieldType.phone.rawValue:
            _textFieldBgView.isHidden = false
            _textView.isHidden = true
            _socialView.isHidden = true
            _titleLbl.isHidden = false
            _textField.keyboardType = .phonePad
            _countryView.isHidden = false
            _dropDownArrow.isHidden = true
        case FormFieldType.gender.rawValue:
            _textFieldBgView.isHidden = false
            _textView.isHidden = true
            _socialView.isHidden = true
            _titleLbl.isHidden = false
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlegenderFieldTap))
            _textField.addGestureRecognizer(tapGesture)
            _textField.isUserInteractionEnabled = true
            _dropDownArrow.isHidden = false
        case FormFieldType.socialForm.rawValue:
            _titleLbl.isHidden = true
            _textView.isHidden = true
            _textFieldBgView.isHidden = true
            _socialView.isHidden = false
            _socialBgView.borderWidth = 0
            _dropDownArrow.isHidden = true
        case FormFieldType.date.rawValue:
            _textFieldBgView.isHidden = false
            _textView.isHidden = true
            _socialView.isHidden = true
            _titleLbl.isHidden = false
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDOBFieldTap))
            _textField.addGestureRecognizer(tapGesture)
            _textField.isUserInteractionEnabled = true
            _dropDownArrow.isHidden = false
        default:
            print("type mismatched")
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomFormField", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    public func setupData(_ title: String, subtitle: String = kEmptyString, icon: String = kEmptyString, isEnable: Bool = true, isComplementary: Bool = false, text: String = kEmptyString) {
        _socialAccountField.isEnabled = isEnable
        if !Utils.stringIsNullOrEmpty(title) {
            _socialAccountField.text = title
        } else {
            _socialAccountField.text = kEmptyString
        }
        _titleLbl.text = title
        if Utils.stringIsNullOrEmpty(text) {
            _textField.placeholder = subtitle
        } else {
            _textField.text = text
        }
        _textView.text = subtitle
        _socialAccountField.placeholder = subtitle
        _socialIcon.image = UIImage(named: icon)
        if isComplementary {
            let countryCode = Utils.getCountryCode(for: APPSESSION.userDetail?._countryCode ?? "+971")
            _countryFlag.text = Utils.getCountyFlag(code: countryCode ?? "UAE")
            _countryCode.text = APPSESSION.userDetail?._countryCode
        }
    }
    
    public func setupEdit(_ title: String, text: String = kEmptyString, subtitle: String = kEmptyString, countryCode: String? = kEmptyString) {
        _titleLbl.text = title
        _textField.placeholder = subtitle
        if title == "dob".localized() {
            let date = Utils.stringToDate(text, format: kFormatDate)
            _textField.text = Utils.dateToString(date, format: kFormatDateReview)
        } else {
            _textField.text = text
        }
        if Utils.stringIsNullOrEmpty(text) {
            _textView.text = subtitle
        } else {
            _textView.text = text
            _textView.textColor = ColorBrand.white
        }
        if let dialCode = countryCode, let code = Utils.getCountryCode(for: dialCode) {
            let countryFlag = Utils.getCountryCode(for: dialCode)
            _countryFlag.text = Utils.getCountyFlag(code: countryFlag ?? kEmptyString)
            _countryCode.text = dialCode
            PromoterApplicationVC.promoterParams["country_code"] = dialCode
        }
//        else {
//            _countryFlag.text = Utils.getcurrentFlag()
//            _countryCode.text = Utils.getCurrentDialCode()
//            PromoterApplicationVC.promoterParams["country_code"] = Utils.getCurrentDialCode()
//
//        }
        _socialAccountField.placeholder = subtitle
    }
  
    @objc private func handleNationalityFieldTap() {
        let controller = DialCountriesController(locale: Locale(identifier: "en"))
        controller.delegate = self
        controller.show(vc: parentBaseController ?? BaseViewController())
    }
    
    @objc private func handleDOBFieldTap() {
        showDatePicker()
    }
    
    private func showDatePicker() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        let calendar = Calendar.current
        if let maxDate = calendar.date(byAdding: .year, value: -18, to: Date()) {
            datePicker.maximumDate = maxDate
        }
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        alertController.view.addSubview(datePicker)
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alertController.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        alertController.view.addConstraint(height)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 8),
            datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -100)
        ])
        
        let selectAction = UIAlertAction(title: "select".localized(), style: .default) { _ in
            let selectedDate = datePicker.date
            let normalizedDate = Calendar.current.startOfDay(for: selectedDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = kFormatDate
            let date = dateFormatter.string(from: normalizedDate)
            self.selectedDate = dateFormatter.string(from: normalizedDate)
            dateFormatter.dateFormat = kFormatDateReview
            self._textField.text = dateFormatter.string(from: normalizedDate)
            self.callback?(self.selectedDate)
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        self.parentViewController?.present(alertController, animated: true, completion: nil)
    }
    
    @objc func handlegenderFieldTap() {
        let alertController = UIAlertController(title: "select_gender".localized(), message: nil, preferredStyle: .actionSheet)

        let maleAction = UIAlertAction(title: "male".localized(), style: .default) { _ in
            self.callback?("Male")
            self._textField.text = "male".localized()
        }
        maleAction.setValue(ColorBrand.white, forKey: "titleTextColor")
        alertController.addAction(maleAction)

        let femaleAction = UIAlertAction(title: "female".localized(), style: .default) { _ in
            self.callback?("Female")
            self._textField.text = "female".localized()
        }
        femaleAction.setValue(ColorBrand.white, forKey: "titleTextColor")
        alertController.addAction(femaleAction)

        let otherAction = UIAlertAction(title: "prefer_not_to_say".localized(), style: .default) { _ in
            self.callback?("prefer not to say")
            self._textField.text = "prefer_not_to_say".localized()
        }
        otherAction.setValue(ColorBrand.white, forKey: "titleTextColor")
        alertController.addAction(otherAction)

        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .destructive, handler: nil)
        alertController.addAction(cancelAction)

        parentBaseController?.present(alertController, animated: true, completion: nil)

    }
    
    @IBAction func _handleCountryPickerEvent(_ sender: UIButton) {
        handleNationalityFieldTap()
    }
    
}

// --------------------------------------
// MARK: Delegates Method
// --------------------------------------

extension CustomFormField :DialCountriesControllerDelegate {
    func didSelected(with country: DialCountries.Country) {
        if fieldType == "phone" {
            _countryFlag.text = country.flag
            _countryCode.text = country.dialCode
            dialCodecallback?(country.dialCode)
        } else {
            _textField.text = isFromEvent ? country.name : country.title
            callback?(country.name)
        }
    }
}

extension CustomFormField :UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Travel, Fashion, Modelling, Going out, Discovering, Sporting" {
            textView.textColor = ColorBrand.white
            textView.text = ""
        }
        callback?(textView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Travel, Fashion, Modelling, Going out, Discovering, Sporting"
            textView.textColor = ColorBrand.brandLightGray
        }
        callback?(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
         if text == "\n" {
             textView.resignFirstResponder()
             return false
         }
        if !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            callback?(textView.text)
        }
         return true
     }
}

extension CustomFormField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        callback?(textField.text)
        print("return", textField.text)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        callback?(textField.text)
        print("endediting", textField.text)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if !isEvent {
            callback?(textField.text)
        }
        print("didchange", textField.text)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if fieldType == FormFieldType.nationality.rawValue || fieldType == FormFieldType.gender.rawValue {
            return
        }
    }
}
