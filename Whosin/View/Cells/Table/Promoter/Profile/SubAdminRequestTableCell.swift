import UIKit

class SubAdminRequestTableCell: UITableViewCell {
    

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
        if model.subAdminStatus == "pending" {
            _btnsView.isHidden = false
        } else  {
            _btnsView.isHidden = true
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
        WhosinServices.updateSubAdminStatus(id: id, status: status) { [weak self] container, error in
            guard let self = self else { return }
            status == "accepted" ? self._approveBtn.hideActivity() : self._rejectBtn.hideActivity()
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            self.reloadCallback?()
            if data.code == 1 {
                NotificationCenter.default.post(name: .reloadEventNotification , object: nil)
                if status == "accepted" {
                    NotificationCenter.default.post(name: .showAlertForUpgradeProfile, object: nil, userInfo: ["type": "subadmin-approve"])
                }
            }
        }
    }
    
    @IBAction private func _handleRejectEvent(_ sender: CustomActivityButton) {
        self.parentBaseController?.confirmAlert(message: "confirm_reject_sub_admin".localized(), okHandler: { action in
            self.requestUpdateStatus(status: "rejected")
        })
    }
    
    @IBAction private func _handleApproveEvent(_ sender: CustomActivityButton) {
        self.parentBaseController?.confirmAlert(message: "confirm_accept_sub_admin".localized(), okHandler: { action in
            self.requestUpdateStatus(status: "accepted")
        })
    }
}
