import UIKit

class PendingRequestTableCell: UITableViewCell {

    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _notifyView: UIView!
    @IBOutlet weak var _pendingRequests: UILabel!
    @IBOutlet weak var _titleText: UILabel!
    @IBOutlet weak var _userImage: UIImageView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
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
    // MARK: Public
    // --------------------------------------

    public func setupData(_ models: [UserDetailModel]) {
        if models.isEmpty {
            _notifyView.isHidden = true
            _titleText.text = "follow_requests".localized()
            _userImage.image = UIImage(named: "user_follow")
            _pendingRequests.text = "approve_or_reject_requests".localized()
        } else {
            _notifyView.isHidden = false
            if models.count == 1 {
                _pendingRequests.text = "\(models[0].fullName)"
                _userImage.loadWebImage(models[0].image, name: models[0].fullName)
            } else {
                _pendingRequests.text = "\(models[0].fullName) and \(models.count - 1) others"
                _userImage.loadWebImage(models[0].image, name: models[0].fullName)
            }
        }
    }
    
    public func setupData(_ models: NotificationModel) {
        _notifyView.isHidden = models.readStatus
        _titleText.text = models.title
        _pendingRequests.text = models.descriptions
        if models.type == "promoter-request-accepted" || models.type == "ring-request-accepted" {
            _userImage.image = UIImage(named: "ic_congratulation")
            _bgView.backgroundColor = UIColor(hexString: "#2AD200").withAlphaComponent(0.1)
        } else if models.type == "promoter-request-rejected" || models.type == "ring-request-rejected" {
            _userImage.image = UIImage(named: "ic_reject")
            _bgView.backgroundColor = UIColor(hexString: "#D80074").withAlphaComponent(0.1)
        }
        if !models.readStatus {
            readNotification(models.id)
        }
    }
    
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
}
