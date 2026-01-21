import UIKit

class PlusOneRequestTableCell: UITableViewCell {
    

    @IBOutlet weak var _notifyView: UIView!
    @IBOutlet weak var _rejectedLable: CustomLabel!
    @IBOutlet weak var _btnsView: UIView!
    @IBOutlet private weak var _approveBtn: CustomActivityButton!
    @IBOutlet private weak var _rejectBtn: CustomActivityButton!
    @IBOutlet private weak var _subTitleText: UILabel!
    @IBOutlet private weak var _userName: UILabel!
    @IBOutlet private weak var _imageView: UIImageView!
    private var memberId:String = kEmptyString
    private var _model: NotificationModel?
    private var _user: UserDetailModel?
    public var reloadCallback: (()->Void)?
    
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
    }
    
    // --------------------------------------
    // MARK: setup
    // --------------------------------------
    
    public func setupData(_ model: NotificationModel) {
        _model = model
        _notifyView.isHidden = model.readStatus
        _btnsView.isHidden = model.plusOneStatus == "rejected" || (model.plusOneStatus == "accepted" && model.adminStatusOnPlusOne == "accepted")
        _rejectedLable.isHidden = !(model.plusOneStatus == "rejected")
        if (model.plusOneStatus == "accepted" && model.adminStatusOnPlusOne == "pending") {
            _approveBtn.setTitle("waiting_for_admin_approval".localized(), for: .normal)
            _approveBtn.backgroundColor = .clear
            _rejectBtn.isHidden = true
            _approveBtn.isUserInteractionEnabled = false
            _approveBtn.titleLabel?.textColor = ColorBrand.amberColor
            _approveBtn.setTitleColor(ColorBrand.amberColor, for: .normal)
        } else if model.plusOneStatus == "accepted" && model.adminStatusOnPlusOne == "rejected" {
            _approveBtn.setTitle("rejected_by_admin".localized(), for: .normal)
            _approveBtn.backgroundColor = .clear
            _rejectBtn.isHidden = true
            _approveBtn.isUserInteractionEnabled = false
            _approveBtn.titleLabel?.textColor = .red
            _approveBtn.setTitleColor(ColorBrand.amberColor, for: .normal)
        } else if model.plusOneStatus == "accepted" && model.adminStatusOnPlusOne == "accepted" {
            _btnsView.isHidden = true
        } else {
            _btnsView.isHidden = false
            _approveBtn.setTitle("approve".localized(), for: .normal)
            _approveBtn.backgroundColor = UIColor(hexString: "#00B929")
            _rejectBtn.isHidden = false
            _approveBtn.isUserInteractionEnabled = true
            _approveBtn.titleLabel?.textColor = ColorBrand.white
            _approveBtn.setTitleColor(ColorBrand.white, for: .normal)
        }
        _userName.text = model.title
        _subTitleText.text = model.descriptions
        _imageView.loadWebImage(model.image, name: model.title)
        if !model.readStatus {
            readNotification(model.id)
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    private func readNotification(_ id: String) {
        WhosinServices.notificationRead(notificationId: id) { [weak self] container, error in
            guard let self = self else { return }
            guard let message = container?.message else { return }
            if message == "success" {
                self._notifyView.isHidden = true
                NOTIFICATION.getUnreadCount()
            }
        }
    }
    
    private func requestUpdateStatus(status: String) {
        guard let id = _model?.typeId else { return }
        status == "accepted" ? _approveBtn.showActivity() : _rejectBtn.showActivity()
        var params: [String: Any] = ["status": status]
        WhosinServices.updatePlusOneStatus(id: id, status: status) { [weak self] container, error in
            guard let self = self else { return }
            status == "accepted" ? self._approveBtn.hideActivity() : self._rejectBtn.hideActivity()
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            self.reloadCallback?()
            if data.code == 1 {
                NotificationCenter.default.post(name: .reloadEventNotification , object: nil)
            }
        }
    }
    
    @IBAction private func _handleRejectEvent(_ sender: CustomActivityButton) {
        self.parentBaseController?.confirmAlert(message: "are_you_sure_reject_plus_one_request".localized(), okHandler: { action in
            self.requestUpdateStatus(status: "rejected")
        })
    }
    
    @IBAction private func _handleApproveEvent(_ sender: CustomActivityButton) {
        guard let id = _model?.typeId else { return }

        if let (isEmpty, missingFields) = APPSESSION.userDetail?.requiredFieldsForPlusOne(), isEmpty {
            let missingFieldsText = missingFields.joined(separator: ", ")
            let alertMessage = LANGMANAGER.localizedString(forKey: "plusone_incomplete_profile_alert", arguments: ["value": missingFieldsText])
            self.parentBaseController?.showCustomAlert(title: "cancellation_not_allowed".localized(), message: alertMessage, yesButtonTitle: "edit_profile".localized(), noButtonTitle: "no".localized(), okHandler: { UIAlertAction in
                let vc = INIT_CONTROLLER_XIB(EditProfileVC.self)
                vc.hidesBottomBarWhenPushed = true
                self.parentBaseController?.navigationController?.pushViewController(vc, animated: true)
            }, noHandler:  { UIAlertAction in
            })

        }
        self.parentBaseController?.confirmAlert(message: "are_you_sure_accept_plus_one_request".localized(), okHandler: { action in
            self.requestUpdateStatus(status: "accepted")
        })
    }
}
