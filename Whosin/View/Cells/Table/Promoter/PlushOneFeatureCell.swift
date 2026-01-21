import UIKit
import ContextMenuSwift

struct PlusOneData {
    var isAllowed: Bool = false
    var isRequired: Bool = false
    var guestType: String = "anyone"
    var seatAllocationType: String = "random"
    var gender: String = "both"
    var totalGuests: Int = 0
    var maleGuests: Int = 0
    var femaleGuests: Int = 0
}


class PlushOneFeatureCell: UITableViewCell {

    @IBOutlet weak var _requiredView: UIStackView!
    @IBOutlet weak var _seatSplitingtypeView: UIView!
    @IBOutlet weak var _numberOfGuestView: UIStackView!
    @IBOutlet var _typeBtns: [UIButton]!
    @IBOutlet weak var _typeView: UIView!
    @IBOutlet weak var _requireBtn: UIButton!
    @IBOutlet weak var _checkBtn: UIButton!
    @IBOutlet var _genderBtns: [UIButton]!
    @IBOutlet weak var _seatSplitView: UIStackView!
    @IBOutlet weak var _genderView: UIView!
    @IBOutlet weak var _maleSeatTextField: LeftSpaceTextField!
    @IBOutlet weak var _femaleSeatTextField: LeftSpaceTextField!
    @IBOutlet weak var _numberOfExtraGuest: LeftSpaceTextField!
    @IBOutlet var _spotSplitType: [UIButton]!
    
    public var updateCallback: ((_ data: PlusOneData) -> Void)?
    private var plusOneData = PlusOneData(
        isAllowed: false,
        isRequired: false,
        guestType: "random",
        gender: "both",
        totalGuests: 0,
        maleGuests: 0,
        femaleGuests: 0
    )

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
        _numberOfExtraGuest.delegate = self
        _maleSeatTextField.delegate = self
        _femaleSeatTextField.delegate = self
        _numberOfGuestView.isHidden = true
        for button in _genderBtns {
            switch button.tag {
            case 0:
                button.setTitle("both".localized(), for: .normal)
                button.setTitle("both".localized(), for: .selected)
            case 1:
                button.setTitle("male".localized(), for: .normal)
                button.setTitle("male".localized(), for: .selected)
            case 2:
                button.setTitle("female".localized(), for: .normal)
                button.setTitle("female".localized(), for: .selected)
            default: break
            }
        }
        for button in _spotSplitType {
            switch button.tag {
            case 0:
                button.setTitle("random".localized(), for: .normal)
                button.setTitle("random".localized(), for: .selected)
            case 1:
                button.setTitle("specific".localized(), for: .normal)
                button.setTitle("specific".localized(), for: .selected)
            default: break
            }
        }
        for button in _typeBtns {
            switch button.tag {
            case 0:
                button.setTitle("random_guest".localized(), for: .normal)
                button.setTitle("random_guest".localized(), for: .selected)
            case 1:
                button.setTitle("specific_guest".localized(), for: .normal)
                button.setTitle("specific_guest".localized(), for: .selected)
            default: break
            }
        }

    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ params: [String: Any]) {
        guard let isAllow = params["plusOneAccepted"] as? Bool else { return }
        if let qty = params["plusOneQty"] as? Int { plusOneData.totalGuests = qty } else { plusOneData.totalGuests = 0 }
        if let type = params["extraGuestType"] as? String { plusOneData.guestType = type }
        if let gender = params["extraGuestGender"] as? String { plusOneData.gender = gender }
        if let splitType = params["extraSeatPreference"] as? String { plusOneData.seatAllocationType = splitType }
//        if let ageRange = params["extraGuestAge"] as? String { updateAge(ageRange) } else {
//            plusOneData.maleGuests = 0
//            plusOneData.femaleGuests = 0
//        }
        if let maleGuest = params["extraGuestMaleSeats"] as? Int { plusOneData.maleGuests = maleGuest } else { plusOneData.maleGuests = 0 }
        if let femaleGuest = params["extraGuestFemaleSeats"] as? Int { plusOneData.femaleGuests = femaleGuest } else { plusOneData.femaleGuests = 0 }
        if let isRequired = params["plusOneMandatory"] as? Bool {
            plusOneData.isRequired = isRequired
        } else { plusOneData.isRequired = false }
        _requiredView.isHidden = !isAllow
        _checkBtn.isSelected = isAllow
        plusOneData.isAllowed = isAllow
        _numberOfGuestView.isHidden = !isAllow
        _typeView.isHidden = !isAllow
        _genderView.isHidden = !isAllow
        _requireBtn.isSelected = plusOneData.isRequired
        _seatSplitView.isHidden = !isAllow || plusOneData.gender != "both" || plusOneData.seatAllocationType == "random"
        _seatSplitingtypeView.isHidden = plusOneData.gender != "both" || !isAllow
        _maleSeatTextField.text = "\(plusOneData.maleGuests)"
        _femaleSeatTextField.text = "\(plusOneData.femaleGuests)"
        _numberOfExtraGuest.text = "\(plusOneData.totalGuests)"
        updateGenderSelection(for: plusOneData.gender)
        updateSpecificationSelection(for: plusOneData.guestType == "anyone" ? "random" : plusOneData.guestType)
        updateSpotsAllocationSelection(for: plusOneData.seatAllocationType)
       
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    func updateAge(_ age: String) {
        let rangeParts = age.split(separator: "-")
        
        if let minString = rangeParts.first, let maxString = rangeParts.last,
           let minValue = Int(minString), let maxValue = Int(maxString) {
            plusOneData.maleGuests = minValue
            plusOneData.femaleGuests = maxValue
            _maleSeatTextField.text = "\(minValue)"
            _femaleSeatTextField.text = "\(maxValue)"
        } else {
            plusOneData.maleGuests = 0
            plusOneData.femaleGuests = 0 
        }
    }
    
    func updateGenderSelection(for gender: String) {
        plusOneData.gender = gender
        for button in _genderBtns {
            switch gender {
            case "both":
                button.isSelected = (button.tag == 0)
            case "male":
                button.isSelected = (button.tag == 1)
            case "female":
                button.isSelected = (button.tag == 2)
            default:
                button.isSelected = false
            }
        }
    }
    
    @IBAction func _handleSelectGenderEvent(_ sender: UIButton) {
        for button in _genderBtns {
            button.isSelected = (button.tag == sender.tag)
        }
        switch sender.tag {
        case 0:
            plusOneData.gender = "both"
        case 1:
            plusOneData.gender = "male"
        case 2:
            plusOneData.gender = "female"
        default:
            break
        }
        _seatSplitView.isHidden = plusOneData.gender != "both"
        triggerUpdate()

    }

    
    @IBAction func _handleAllowEvent(_ sender: UIButton) {
        plusOneData.isAllowed.toggle()
        _checkBtn.isSelected = plusOneData.isAllowed
        triggerUpdate()
    }
    
    
    @IBAction func _handleRequirementEvent(_ sender: UIButton) {
        plusOneData.isRequired.toggle()
        _requireBtn.isSelected = plusOneData.isRequired
        triggerUpdate()
    }
    
    func updateSpecificationSelection(for type: String) {
        plusOneData.guestType = type
        for button in _typeBtns {
            switch type {
            case "random":
                button.isSelected = (button.tag == 0)
            case "specific":
                button.isSelected = (button.tag == 1)
            default:
                button.isSelected = false
            }
        }
    }
    
    func updateSpotsAllocationSelection(for type: String) {
        plusOneData.seatAllocationType = type
        for button in _spotSplitType {
            switch type {
            case "random":
                button.isSelected = (button.tag == 0)
            case "specific":
                button.isSelected = (button.tag == 1)
            default:
                button.isSelected = false
            }
        }
    }
    
    @IBAction func _handleSeatSplitypeEvent(_ sender: UIButton) {
        for button in _spotSplitType {
            button.isSelected = (button.tag == sender.tag)
        }
        switch sender.tag {
        case 0:
            plusOneData.seatAllocationType = "random"
        case 1:
            plusOneData.seatAllocationType = "specific"
        default:
            break
        }
        triggerUpdate()
    }
    
    @IBAction func _handleSelectSpecificationEvent(_ sender: UIButton) {
        for button in _typeBtns {
            button.isSelected = (button.tag == sender.tag)
        }
        switch sender.tag {
        case 0:
            plusOneData.guestType = "random"
        case 1:
            plusOneData.guestType = "specific"
        default:
            break
        }
        triggerUpdate()
    }
    
    private func triggerUpdate() {
        updateCallback?(plusOneData)
    }

}


extension PlushOneFeatureCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let totalGuests = Int(_numberOfExtraGuest.text ?? "0") ?? 0
        var maleGuests = Int(_maleSeatTextField.text ?? "0") ?? 0
        var femaleGuests = Int(_femaleSeatTextField.text ?? "0") ?? 0

//        if textField == _numberOfExtraGuest {
//            plusOneData.totalGuests = Int(_numberOfExtraGuest.text ?? "0") ?? 0
//        } else if textField == _maleSeatTextField {
//            plusOneData.maleGuests = Int(_maleSeatTextField.text ?? "0") ?? 0
//        } else if textField == _femaleSeatTextField {
//            plusOneData.femaleGuests = Int(_femaleSeatTextField.text ?? "0") ?? 0
//        }
        
        if textField == _maleSeatTextField {
            maleGuests = min(maleGuests, totalGuests)  // Ensure male guests don't exceed total
            femaleGuests = totalGuests - maleGuests    // Adjust female guests automatically
        } else if textField == _femaleSeatTextField {
            femaleGuests = min(femaleGuests, totalGuests)  // Ensure female guests don't exceed total
            maleGuests = totalGuests - femaleGuests        // Adjust male guests automatically
        }
        _maleSeatTextField.text = "\(maleGuests)"
        _femaleSeatTextField.text = "\(femaleGuests)"
        
        // Update the data model
        plusOneData.totalGuests = totalGuests
        plusOneData.maleGuests = maleGuests
        plusOneData.femaleGuests = femaleGuests


        triggerUpdate()
    }
    

}
