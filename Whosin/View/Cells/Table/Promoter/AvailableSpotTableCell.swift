import UIKit
import ContextMenuSwift

class AvailableSpotTableCell: UITableViewCell {

    @IBOutlet private weak var _femaleSeatsCount: LeftSpaceTextField!
    @IBOutlet private weak var _maleSeatsCount: LeftSpaceTextField!
    @IBOutlet private weak var _maleFemaleSeatsView: UIStackView!
    @IBOutlet private weak var _genderView: UIView!
    @IBOutlet private weak var _spotsField: LeftSpaceTextField!
    @IBOutlet private weak var _visibilitySwitch: UISwitch!
    @IBOutlet private weak var _segement: UISegmentedControl!
    @IBOutlet var _genderBtns: [UIButton]!
    @IBOutlet weak var _categoryText: CustomLabel!
    @IBOutlet weak var _categoryView: UIView!
    private var selectGender: String = "both"
    public var callBack: ((_ spots: Int, _ visibility: Bool, _ confirmation: Bool, _ gender: String, _ category: String) -> Void)?
    public var seatSplitCallBack: ((_ male: Int, _ female: Int) -> Void)?
    private var category: String = "none"
    private var _maleSeats: Int = 0
    private var _femaleSeats: Int = 0
    
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
        _spotsField.delegate = self
        _maleSeatsCount.delegate = self
        _femaleSeatsCount.delegate = self
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

    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ params: [String: Any]) {
        if let spots = params["maxInvitee"] as? Int { _spotsField.text = spots == 0 ? "" : "\(spots)" }
        if let isPrivate = params["type"] as? String {
            _visibilitySwitch.isOn = isPrivate == "public"
        }
        if let isConfirm = params["isConfirmationRequired"] as? Bool { _segement.selectedSegmentIndex = isConfirm ? 0 : 1}

        if let gender = params["invitedGender"] as? String {
            selectGender = gender
            updateGenderSelection(for: gender.localized())
        } else {
            selectGender = "both"
            updateGenderSelection(for: selectGender.localized())
        }

        if let category = params["category"] as? String {
            _categoryText.text = category.isEmpty ? "None" : category
            self.category = category.isEmpty ? "none" : category
        } else {
            _categoryText.text = "None"
            category = "none"
        }
        if selectGender == "both" {
            if let male = params["maleSeats"] as? Int, let female = params["femaleSeats"] as? Int {
                _maleSeatsCount.text = "\(male)"
                _femaleSeatsCount.text = "\(female)"
            } else {
                _maleSeatsCount.text = kEmptyString
                _femaleSeatsCount.text = kEmptyString
            }
        }
        _genderView.isHidden = !_visibilitySwitch.isOn
    }

    func updateGenderSelection(for gender: String) {
        for button in _genderBtns {
            switch gender {
            case "both".localized():
                button.titleLabel?.text = "both".localized()
                button.isSelected = (button.tag == 0)
                _maleFemaleSeatsView.isHidden = !_visibilitySwitch.isOn
            case "male".localized():
                button.titleLabel?.text = "male".localized()
                button.isSelected = (button.tag == 1)
                _maleFemaleSeatsView.isHidden = true
            case "female".localized():
                button.titleLabel?.text = "female".localized()
                button.isSelected = (button.tag == 2)
                _maleFemaleSeatsView.isHidden = true
            default:
                button.isSelected = false
                _maleFemaleSeatsView.isHidden = true
            }
        }
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleSwitchEvent(_ sender: UISwitch) {
        let spots = Int(_spotsField.text ?? "0") ?? 0
        callBack?(spots, sender.isOn, _segement.selectedSegmentIndex == 0, selectGender, category)
    }
    
    @IBAction func _handleConfirmationRequiredEvent(_ sender: UISegmentedControl) {
        let spots = Int(_spotsField.text ?? "0") ?? 0
        callBack?(spots, _visibilitySwitch.isOn, _segement.selectedSegmentIndex == 0, selectGender, category)
    }
    
    @IBAction func _handleSelectGenderEvent(_ sender: UIButton) {
        for button in _genderBtns {
            button.isSelected = (button.tag == sender.tag)
        }
        switch sender.tag {
        case 0:
            selectGender = "both"
            let spots = Int(_spotsField.text ?? "0") ?? 0
            callBack?(spots, _visibilitySwitch.isOn, _segement.selectedSegmentIndex == 0, selectGender, category)
        case 1:
            selectGender = "male"
            let spots = Int(_spotsField.text ?? "0") ?? 0
            callBack?(spots, _visibilitySwitch.isOn, _segement.selectedSegmentIndex == 0, selectGender, category)
        case 2:
            selectGender = "female"
            let spots = Int(_spotsField.text ?? "0") ?? 0
            callBack?(spots, _visibilitySwitch.isOn, _segement.selectedSegmentIndex == 0, selectGender, category)
        default:
            break
        }
        updateGenderSelection(for: selectGender.localized())
    }
    
    private func _requestGetCustomCaetegory() {
        WhosinServices.getCustomCategory { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            CreateEventVC.categories = data.data
            CreateEventVC.categories.append("Custom")
        }
    }
    
    @IBAction func _handleSelectCategoryEvent(_ sender: UIButton) {
        if CreateEventVC.categories.isEmpty {
            _requestGetCustomCaetegory()
            CreateEventVC.categories.append("Custom")
        }
        CM.items = CreateEventVC.categories
        CM.MenuConstants.MenuMarginSpace = 10.0
        CM.MenuConstants.TopMarginSpace = 80.0
        CM.MenuConstants.BottomMarginSpace = 80.0
        CM.showMenu(viewTargeted: _categoryView, delegate: self, animated: true)

    }
    
}

extension AvailableSpotTableCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let totalSpots = Int(_spotsField.text ?? "0") ?? 0

        if textField == _maleSeatsCount {
            _maleSeats = min(Int(_maleSeatsCount.text ?? "0") ?? 0, totalSpots)

            _femaleSeats = max(0, totalSpots - _maleSeats)
            _femaleSeatsCount.text = "\(_femaleSeats)"

            seatSplitCallBack?(_maleSeats, _femaleSeats)

        } else if textField == _femaleSeatsCount {
            _femaleSeats = min(Int(_femaleSeatsCount.text ?? "0") ?? 0, totalSpots)

            // Adjust male seats based on the total and female seats entered
            _maleSeats = max(0, totalSpots - _femaleSeats)
            _maleSeatsCount.text = "\(_maleSeats)"

            seatSplitCallBack?(_maleSeats, _femaleSeats)

        } else if textField == _spotsField {
            // Update the total spots and adjust the male/female seats if necessary
            let spots = totalSpots

            if _maleSeats + _femaleSeats > spots {
                _femaleSeats = max(0, spots - _maleSeats)
                _femaleSeatsCount.text = "\(_femaleSeats)"
            }
            callBack?(spots, _visibilitySwitch.isOn, _segement.selectedSegmentIndex == 0, selectGender, category)

        }
    }
}



// --------------------------------------
// MARK: DropDown Delegate
// --------------------------------------

extension AvailableSpotTableCell : ContextMenuDelegate {
    func contextMenuDidAppear(_ contextMenu: ContextMenuSwift.ContextMenu) {
        print("contextMenuDidAppear")
    }
    
    func contextMenuDidDisappear(_ contextMenu: ContextMenuSwift.ContextMenu) {
        print("contextMenuDidDisappear")
    }
    
    func contextMenuDidSelect(_ contextMenu: ContextMenuSwift.ContextMenu, cell: ContextMenuSwift.ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuSwift.ContextMenuItem, forRowAt index: Int) -> Bool {
        if item.title == "Custom" {
            openRequirementSheet()
        } else {
            _categoryText.text = item.title
            _categoryView.layoutIfNeeded()
            category = item.title
            let spots = Int(_spotsField.text ?? "0") ?? 0
            callBack?(spots, _visibilitySwitch.isOn, _segement.selectedSegmentIndex == 0, selectGender, category)
        }
//        PromoterApplicationVC.promoterParams["category"] = item.title
        return true //should dismiss on tap

    }
    
    private func openRequirementSheet(_ text: String = kEmptyString, index: Int = 0, isEdit: Bool = false) {
        let vc = INIT_CONTROLLER_XIB(RequirementsBottomSheet.self)
        vc.requireTitle = "enter_custom_category_type".localized()
        vc.requirementText = text
        vc.isEdit = isEdit
        vc.callback = { inputText in
            self._categoryText.text = inputText
            self._categoryView.layoutIfNeeded()
            self.category = inputText
            let spots = Int(self._spotsField.text ?? "0") ?? 0
            self.callBack?(spots, self._visibilitySwitch.isOn, self._segement.selectedSegmentIndex == 0, self.selectGender, self.category)
        }
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
    func contextMenuDidDeselect(_ contextMenu: ContextMenuSwift.ContextMenu, cell: ContextMenuSwift.ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuSwift.ContextMenuItem, forRowAt index: Int) {
        print("")
    }
 
}
