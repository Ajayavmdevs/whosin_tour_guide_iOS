import UIKit
import DialCountries
import RangeSeekSlider
import RealmSwift
import ObjectMapper

struct PlusOneSpecificationData {
    var nationality: String
    var minAge: Int
    var maxAge: Int
    var dressCode: String
}


class PlusOneSpecificationTableCell: UITableViewCell {
        
    @IBOutlet weak var _selectedNationality: CustomLabel!
    @IBOutlet weak var _nationality: UIView!
    @IBOutlet weak var _dressCode: LeftSpaceTextField!
    @IBOutlet weak var _dressCodeChip: UIView!
    @IBOutlet weak var _dressCodeText: UILabel!
    @IBOutlet weak var _ageRangeSlider: RangeSeekSlider!
    
    var dataUpdated: ((_ data: PlusOneSpecificationData) -> Void)?
    private var plusOneData = PlusOneSpecificationData(
        nationality: "Not Specified",
        minAge: 18,
        maxAge: 50,
        dressCode: ""
    )

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _dressCode.delegate = self
        _dressCodeChip.isHidden = true
        _ageRangeSlider.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDressCodeChip))
        _dressCodeChip.addGestureRecognizer(tapGesture)
        _dressCodeChip.isUserInteractionEnabled = true
        let tapNationalityGesture = UITapGestureRecognizer(target: self, action: #selector(didTapNationality))
        _nationality.addGestureRecognizer(tapNationalityGesture)
        _nationality.isUserInteractionEnabled = true



    }
    
    public func setupData(_ param: [String:Any]) {
        if let dressCode = param["extraGuestDressCode"] as? String, !Utils.stringIsNullOrEmpty(dressCode) {
            _dressCode.text = dressCode
            plusOneData.dressCode = dressCode
        }
        if let nationality = param["extraGuestNationality"] as? String {
            _selectedNationality.text = nationality
            plusOneData.nationality = nationality
        }
        if let ageRange = param["extraGuestAge"] as? String,
           let parsedRange = parseAgeRange(ageRange) {
            plusOneData.minAge = parsedRange.minAge
            plusOneData.maxAge = parsedRange.maxAge
            _ageRangeSlider.selectedMinValue = CGFloat(plusOneData.minAge)
            _ageRangeSlider.selectedMaxValue = CGFloat(plusOneData.maxAge)
        } else {
            plusOneData.minAge = 16
            plusOneData.maxAge = 60
        _ageRangeSlider.selectedMinValue = CGFloat(plusOneData.minAge)
        _ageRangeSlider.selectedMaxValue = CGFloat(plusOneData.maxAge)
        }
        print(plusOneData.minAge)
        print(plusOneData.maxAge)
    }

    func parseAgeRange(_ range: String) -> (minAge: Int, maxAge: Int)? {
        let components = range.split(separator: "-").map { String($0).trimmingCharacters(in: .whitespaces) }
        guard components.count == 2,
              let minAge = Int(components[0]),
              let maxAge = Int(components[1]) else {
            return nil // Return nil if parsing fails
        }
        return (minAge, maxAge)
    }

    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    @IBAction func _dressCodeCancelEvent(_ sender: Any) {
        _dressCodeChip.isHidden = true
        _dressCode.text = ""
        _dressCode.isHidden = false
        _dressCode.becomeFirstResponder()
    }
    
    func openNationalityActionSheet(from viewController: UIViewController) {
        let actionSheet = UIAlertController(title: "select_option".localized(), message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "not_specified".localized(), style: .default, handler: { _ in
            self._selectedNationality.text = "not_specified".localized()
            self.plusOneData.nationality = "Not Specified"
            self.triggerDataUpdate()

        }))

        actionSheet.addAction(UIAlertAction(title: "select_nationality".localized(), style: .default, handler: { _ in
            let controller = DialCountriesController(locale: Locale(identifier: "en"))
            controller.delegate = self
            controller.show(vc: viewController)
        }))

        actionSheet.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))

        viewController.present(actionSheet, animated: true, completion: nil)
    }

    private func triggerDataUpdate() {
        dataUpdated?(plusOneData)
    }

    
    @objc func didTapNationality() {
        openNationalityActionSheet(from: self.parentBaseController ?? self.parentViewController ?? BaseViewController())
    }
    
    @objc func didTapDressCodeChip() {
        _dressCodeChip.isHidden = true
        _dressCode.isHidden = false
        _dressCode.text = _dressCodeText.text
        _dressCode.becomeFirstResponder()
    }

}

extension PlusOneSpecificationTableCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == _dressCode {
            if let dressCode = _dressCode.text, !dressCode.isEmpty {
                _dressCodeText.text = dressCode
                plusOneData.dressCode = dressCode
                _dressCode.resignFirstResponder()
                _dressCode.isHidden = true
                _dressCodeChip.isHidden = false
                triggerDataUpdate()
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == _dressCode {
            if let dressCode = _dressCode.text, !dressCode.isEmpty {
                _dressCodeText.text = dressCode
                plusOneData.dressCode = dressCode
                _dressCode.isHidden = true
                _dressCodeChip.isHidden = false
                triggerDataUpdate()
            }
        }
        return true
    }

}

extension PlusOneSpecificationTableCell: RangeSeekSliderDelegate {
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        plusOneData.minAge = Int(minValue)
        plusOneData.maxAge = Int(maxValue)
        triggerDataUpdate()
    }
}

extension PlusOneSpecificationTableCell :DialCountriesControllerDelegate {
    func didSelected(with country: DialCountries.Country) {
        _selectedNationality.text = country.name
        plusOneData.nationality = country.name
        triggerDataUpdate()
    }
}
