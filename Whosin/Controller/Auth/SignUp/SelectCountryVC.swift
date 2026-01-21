import UIKit
import DialCountries
import libPhoneNumber_iOS


class SelectCountryVC: ChildViewController {

    @IBOutlet weak var _countryNameLabel: UILabel!
    @IBOutlet weak var _flagLabel: UILabel!
    @IBOutlet weak var _nextButton: CustomGradientBorderButton!
    @IBOutlet weak var _backButton: CustomGradientBorderButton!
    private var _defaultCountryCode: String = "🇱🇧"
    private var _defaultDialCode: String = "+961"
    private var _selectedCountry: Country?


    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    override func setupUi() {
        _backButton.buttonImage = UIImage(named: "icon_back")
        _nextButton.buttonImage = UIImage(named: "icon_btnNext")
        _countryNameLabel.text = "United state arab"
        _flagLabel.text = "🇱🇧"
    }
    
    @IBAction func _handleCountryPicker(_ sender: Any) {
        let controller = DialCountriesController(locale: Locale(identifier: "en"))
        controller.delegate = self
        controller.show(vc: self)

    }
}

// --------------------------------------
// MARK: Conttry code extention
// --------------------------------------

extension SelectCountryVC: DialCountriesControllerDelegate {
    func didSelected(with country: Country) {
        _countryNameLabel.text = country.name
        _flagLabel.text = country.flag
        _selectedCountry = country
    }
}
