import UIKit

class SignInVerificationVC: ChildViewController {

    @IBOutlet weak var _deviceName: UILabel!
    @IBOutlet weak var _loaction: UILabel!
    @IBOutlet weak var _timeLabel: UILabel!
    public var approvalModel: LoginApprovalModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _deviceName.text = "\(approvalModel?.metadata?.deviceName ?? kEmptyString) \(approvalModel?.metadata?.deviceModel ?? kEmptyString)"
        _loaction.text = approvalModel?.metadata?.deviceLocation
        _timeLabel.text = "Just Now"
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------

    private func _requestLoginAprroval(status: String, reqId: String) {
        WhosinServices.approveLoginRequest(status: status, reqId: reqId) { [weak self] container, error in
            guard let self = self else { return }
            self.showError(error)
            if self.isVCPresented {
                dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }

    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction func _handleNotMeEvent(_ sender: UIButton) {
        guard let approveModel = approvalModel else { return }
        let requestId = approveModel.reqId.isEmpty ? approveModel.id : approveModel.reqId
        _requestLoginAprroval(status: "reject", reqId: requestId)
    }
    
    @IBAction func _handleYesEvent(_ sender: UIButton) {
        guard let approveModel = approvalModel else { return }
        let requestId = approveModel.reqId.isEmpty ? approveModel.id : approveModel.reqId
        _requestLoginAprroval(status: "approved", reqId: requestId)
    }
}
