import UIKit
import DialCountries
import libPhoneNumber_iOS


class SelectDetailsVC: ChildViewController {

    @IBOutlet weak var _dateView: UIView!
    @IBOutlet weak var _datePickerButton: UIButton!
    @IBOutlet private weak var _backButton: CustomGradientBorderButton!
    @IBOutlet private weak var _nextButton: CustomGradientBorderButton!
    @IBOutlet private weak var _countryNameLabel: UILabel!
    @IBOutlet private weak var _flagLabel: UILabel!
    @IBOutlet private weak var _dateLabel: UILabel!
    @IBOutlet private weak var _maleButton: GradientBorderButton!
    @IBOutlet private weak var _femaleButton: GradientBorderButton!
    @IBOutlet private weak var _preferNotSayButton: GradientBorderButton!
    
    private var _defaultCountryCode: String = "🇦🇪"
    private var _defaultDialCode: String = "+971"
    private var _selectedCountry: Country?
    private var _genderButtons:[UIButton] = []
    private var _gender: String = kEmptyString
    public var params: [String: Any] = [:]

    let _datePicker: DatePicker = {
        let v = DatePicker()
        return v
    }()
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }

    override func setupUi() {
        _backButton.buttonImage = UIImage(named: "icon_backArrow")
        _nextButton.buttonImage = UIImage(named: "icon_btnNext")
        _countryNameLabel.text = "Select your nationality"
        _flagLabel.text = ""
        _genderButtons = [_maleButton, _femaleButton, _preferNotSayButton]
        
        // --------------------------------------
        // MARK: DatePicker
        // --------------------------------------
        
        [_datePickerButton, _datePicker].forEach { v in
            v!.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v!)
        }
        
        _dateView.addSubview(_datePickerButton)
        _datePickerButton.centerXAnchor.constraint(equalTo: _dateView.centerXAnchor).isActive = true
        _datePickerButton.centerYAnchor.constraint(equalTo: _dateView.centerYAnchor).isActive = true
        _datePickerButton.leadingAnchor.constraint(equalTo: _dateView.leadingAnchor).isActive = true
        _datePickerButton.trailingAnchor.constraint(equalTo: _dateView.trailingAnchor).isActive = true
        
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
            self._dateLabel.text = Utils.dateToString(val, format: kFormatDateLocal)
            self._datePickerButton.setTitle(Utils.dateToString(val, format: kFormatEventDate), for: .normal)
        }
        
        _datePickerButton.addTarget(self, action: #selector(tapDate(_:)), for: .touchUpInside)

    }
    
    
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc private func tapDate(_ sender: Any) {
        _datePicker.isHidden = false
    }

    @IBAction private func _handleCountryPicker(_ sender: Any) {
        let controller = DialCountriesController(locale: Locale(identifier: "en"))
        controller.delegate = self
        controller.show(vc: self)

    }
    
    @IBAction private func _handleDatePickerEvent(_ sender: UIButton) {
    }
    
    @IBAction private func _handleSelectGenderEvent(_ sender: GradientBorderButton) {
        if sender.tag == 1 {
            _gender = GenderType.female.rawValue
        } else if sender.tag == 2 {
            _gender = GenderType.preferNotSay.rawValue
        }else {
            _gender = GenderType.male.rawValue
        }
        for button in _genderButtons {
            if sender.tag == button.tag{
                button.isSelected = true;
                button.titleLabel?.font = FontBrand.SFheavyFont(size: 16)
                button.backgroundColor = ColorBrand.brandPink
            }else{
                button.isSelected = false;
                button.titleLabel?.font = FontBrand.SFregularFont(size: 16)
                button.backgroundColor = ColorBrand.white.withAlphaComponent(0.13)
            }
        }
    }
    
    @IBAction func _handleNextbuttonEvent(_ sender: Any) {
        if Utils.stringIsNullOrEmpty(_gender) {
            alert(title: kAppName, message: "please_select_gender".localized())
        }
        
        if Utils.stringIsNullOrEmpty(_dateLabel.text) {
            alert(title: kAppName, message: "select_date".localized())
            return
        }
        
        params["nationality"] = _selectedCountry?.name
        params["gender"] = _gender
        params["dateOfBirth"] = _dateLabel.text
        let presentedViewController = INIT_CONTROLLER_XIB(TermsAndConditionVC.self)
        presentedViewController.params = params
        navigationController?.pushViewController(presentedViewController, animated: true)
    }
    
    @IBAction private func _handelBackButtonEvent(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

// --------------------------------------
// MARK: UIViewControllerTransitioning Delegate
// --------------------------------------

extension SelectDetailsVC: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
    
}

// --------------------------------------
// MARK: Conttry code extention
// --------------------------------------

extension SelectDetailsVC: DialCountriesControllerDelegate {
    func didSelected(with country: Country) {
        _countryNameLabel.text = country.name
        _flagLabel.text = country.flag
        _selectedCountry = country
    }
}
