import UIKit
import Contacts

class ProfileSettingCell: UITableViewCell {

    @IBOutlet weak var _buttonIcon: BadgeButton!
    @IBOutlet private weak var _titleMenu: UILabel!
    @IBOutlet weak var _settingIcon: UIImageView!
    @IBOutlet weak var _iconView: UIView!
    @IBOutlet weak var _switchButton: UISwitch!
    @IBOutlet weak var _nextButton: UIButton!
    @IBOutlet weak var _seperatorView: UIView!
    @IBOutlet weak var _selectedCurrency: CustomLabel!
    private var _switchText: String = kEmptyString
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        55.0
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Public SetupData
    // --------------------------------------
    
    public func setupData(_ data : [String : Any], switchText: String = kEmptyString, isSwitchOn: Bool = false) {
        _titleMenu.text = data["title"] as? String
        _settingIcon.image = UIImage(named: data["icon"] as! String)
        _iconView.backgroundColor = UIColor(hex: data["color"] as? String ?? kEmptyString)
        _switchButton.isHidden = switchText != "permission"
        _nextButton.isHidden = switchText == "permission"
        _switchButton.isOn = isSwitchOn
        if _titleMenu.text == "change_currency".localized() {
            _selectedCurrency.isHidden = false
            _selectedCurrency.text =  APPSESSION.userDetail?.currency 
        } else if _titleMenu.text == "change_language".localized() {
            _selectedCurrency.isHidden = false
            _selectedCurrency.text = LANGMANAGER.currentLanguage
        } else {
            _selectedCurrency.isHidden = true
        }
        if switchText == "permission" {
            _switchText = data["title"] as? String ?? kEmptyString
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _checkAuthorizationNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    print("Notification access granted.")
                case .denied, .provisional:
                    self.presentPermissionAlert(true)
                case .notDetermined:
                    self.presentPermissionAlert(true)
                case .ephemeral:
                    self.presentPermissionAlert(true)
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
    }
    
    private func _checkAuthorization() {
        let contactStore = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            print("Notification access granted.")
        case .denied, .restricted:
            presentPermissionAlert()
        case .notDetermined:
            contactStore.requestAccess(for: .contacts) { [weak self] success, error in
                guard let self = self else { return }
                if !success {
                    self.presentPermissionAlert()
                }
            }
        @unknown default:
            print("Unknown authorization status")
        }
    }
    
    private func presentPermissionAlert(_ isNotification: Bool = false) {
        self.parentBaseController?.showCustomAlert(title: isNotification ? "notification_access".localized() : "access_contacts".localized(), message: isNotification ? "allow_notifications_text".localized() : contactsPermissionMessage, yesButtonTitle: "open_settings".localized(), noButtonTitle: "cancel".localized(), okHandler: { UIAlertAction in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
                self.parentViewController?.dismiss(animated: true)
            }
        }, noHandler:  { UIAlertAction in
            self._switchButton.isOn = false
        })
    }
    
    private func _requestPrivateAccount(_ status: Bool) {
        self.parentBaseController?.showCustomAlert(title: kAppName, message: status ? "switch_public_account_confirmation".localized() : "switch_private_account_confirmation".localized(), yesButtonTitle: "yes".localized().localized(), noButtonTitle: "cancel".localized(), okHandler: { UIAlertAction in
            APPSESSION.updateProfileStatus(["isProfilePrivate": !(APPSESSION.userDetail?.isProfilePrivate ?? status)]) { [weak self] bool, error in
                guard let self = self else { return }
                self._switchButton.isOn = bool
            }
        }, noHandler:  { UIAlertAction in
            self._switchButton.isOn = status
        })
    }
    
    private func _requestTwoFactorAuthentication(_ status: Bool) {
        self.parentBaseController?.showCustomAlert(title: kAppName, message: status ? "enable_2fa_confirmation".localized() : "disable_2fa_confirmation".localized(), yesButtonTitle: "yes".localized().localized(), noButtonTitle: "cancel".localized(), okHandler: { UIAlertAction in
            APPSESSION.updateProfileStatus(["isTwoFactorActive": !(APPSESSION.userDetail?.isTwoFactorActive ?? status)]) { [weak self] bool, error in
                guard let self = self else { return }
                self._switchButton.isOn = status
            }
        }, noHandler:  { UIAlertAction in
            self._switchButton.isOn = APPSESSION.userDetail?.isTwoFactorActive == true
        })
    }
    
    private func _openEditProfile() {
        parentBaseController?.confirmAlert(message: "profile_required_for_2fa".localized(), okHandler: { [weak self] action in
            let vc = INIT_CONTROLLER_XIB(EditProfileVC.self)
            self?.parentBaseController?.navigationController?.pushViewController(vc, animated: true)
        }) { [weak self] action in
            self?._switchButton.isOn = APPSESSION.userDetail?.isTwoFactorActive == true
            self?.parentViewController?.dismiss(animated: true)
        }
        
    }
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleSwitchEvent(_ sender: UISwitch) {
        if _switchText == "private_account".localized() {
            _requestPrivateAccount(!sender.isOn)
        } else if _switchText == "two_factor_authentication".localized() {
            if APPSESSION.userDetail?.requiredFields() == true || APPSESSION.userDetail?.isEmailVerified == 0 {
                _openEditProfile()
            } else {
                _requestTwoFactorAuthentication(sender.isOn)
            }
        } else {
            if sender.isOn {
                if _switchText == "allow_notification".localized() {
                    _checkAuthorizationNotification()
                } else {
                    _checkAuthorization()
                }
            } else {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                    self.parentViewController?.dismiss(animated: true)
                }
            }
        }

    }
}
