import UIKit
import DeviceKit

class TwoStepEmailOptionVc: PanBaseViewController {
    
    @IBOutlet private weak var _emailTextField: UITextField!
    @IBOutlet private weak var _submitBtn: CustomActivityButton!
    
    var delegate: ActionButtonDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func _handleNextEvent(_ sender: CustomGradientBorderButton) {
        if Utils.stringIsNullOrEmpty(_emailTextField.text!) {
            alert(title: kAppName, message: "please_enter_email".localized())
            return
        }
        
        if !Utils.isEmail(emailString: _emailTextField.text!) {
            alert(title: kAppName, message: "invalid_email".localized())
            return
        }
        
        _requestSentTwoAuthInEmail(_emailTextField.text ?? kEmptyString)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestSentTwoAuthInEmail(_ email: String) {
        guard let userDetail = APPSESSION.userDetail else { return }
        let device = Device.current
        _submitBtn.showActivity()
        LOCATIONSERVICE.getCurrentCityAndCountry { city, country in
            let metadata: [String: Any] = ["device_id": Utils.getDeviceID(),
                                           "device_name": device.name ?? UIDevice.current.name,
                                           "device_model": device.description ,
                                           "device_location": "\(city ?? " "), \(country ?? "Dubai")"]
            let params: [String: Any] = ["email": email, "userId": userDetail.id,  "metadata": metadata]
            
            WhosinServices.userEmailTwoFactorAuth(params: params) { [weak self] container , error in
                guard let self = self else { return }
                self._submitBtn.hideActivity()
                guard let model = container, model.isSuccess else {
                    self.showError(error)
                    return
                }
                self.view.makeToast(model.message)
                DISPATCH_ASYNC_MAIN_AFTER(2) {
                    self.dismiss(animated: true) {
                        self.delegate?.buttonClicked?(tag: model.data?.id ?? kEmptyString, type: .none)
                    }
                }
            }
        }
    }
}
