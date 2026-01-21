import UIKit

class SelectBirthDayVC: ChildViewController {

    @IBOutlet weak var _dateLabel: UILabel!
    @IBOutlet weak var _nextButton: CustomGradientBorderButton!
    @IBOutlet weak var _backButton: CustomGradientBorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func setupUi() {
        _nextButton.buttonImage = UIImage(named: "icon_btnNext")
        _backButton.buttonImage = UIImage(named: "icon_back")
    }

    @IBAction func _handleDatePickerEvent(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(DatePickerVC.self)
        controller.didUpdateCallback = { [weak self] date in
            guard let self = self else { return }
            self._dateLabel.text = Utils.dateToString(date, format: kFormatDateLocal)
        }
        parent?.presentAsPanModal(controller: controller)

    }
}
