import UIKit

class SelectAvailbleTimingCell: UITableViewCell {

    @IBOutlet weak var _availbleTitle: CustomLabel!
    @IBOutlet weak var _alwaysAvailableSwitch: UISwitch!
    @IBOutlet weak var _customTimeView: CustomTimeAvailabilities!
    private var isSwitchOn: Bool = false {
        didSet {
            _alwaysAvailableSwitch.isOn = isSwitchOn
            CompletePromoterProfileVC.params["isAlwaysAvailable"] = isSwitchOn
        }
    }
    
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
        CompletePromoterProfileVC.params["isAlwaysAvailable"] = false
    }
    
    // --------------------------------------
    // MARK: public
    // --------------------------------------

    public func setupData(reloadcallback: @escaping () -> Void) {
        _customTimeView.setupData()
        _customTimeView.callback = {
            reloadcallback()
        }
        _customTimeView.updateCallback = { slots in
            CompletePromoterProfileVC.params["availabities"] = slots.map({ $0.toDictionary() })
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _requestUpdate() {
        parentBaseController?.showHUD()
        WhosinServices.updateRingPromoter(params: CompletePromoterProfileVC.params) { [weak self] container, error in
            guard let self = self else {return}
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container?.data else { return }
            parentViewController?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func validations() {
        if CompletePromoterProfileVC.params["preferences"] as? [String] == nil {
            parentBaseController?.alert(message: "please_select_preferences".localized())
            return
        }
        
        if CompletePromoterProfileVC.params["isAlwaysAvailable"] as? Bool == false {
            if CompletePromoterProfileVC.params["availabities"] == nil {
                parentBaseController?.alert(message: "please_select_availabities".localized())
                    return
            }
            
            if let availabilities = CompletePromoterProfileVC.params["availabities"] as? [[String: String]], availabilities.isEmpty {
                parentBaseController?.alert(message: "please_select_availabities".localized())
                    return
            }
        }
        
        if let prefrences = CompletePromoterProfileVC.params["preferences"] as? [String], prefrences.count < 5 {
            parentBaseController?.alert(message: "please_select_minimum_5_preferences".localized())
            return
        }
        
        _requestUpdate()
        
    }

    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction func _handleSwitchEvent(_ sender: UISwitch) {
        isSwitchOn.toggle()
        _availbleTitle.isHidden = isSwitchOn
        _customTimeView.isHidden = isSwitchOn
    }
    
    @IBAction func _handleSubmitEvent(_ sender: Any) {
        validations()
    }
    
}
