import UIKit

class NotificationTableCell: UITableViewCell {
    
    @IBOutlet weak var _unReadView: UIView!
    @IBOutlet private weak var _userActionStack: UIStackView!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subtitleLabel: UILabel!
    @IBOutlet private weak var _timeLabel: UILabel!
    @IBOutlet weak var _userTime: UILabel!
    private var userId: String = kEmptyString
    private var userName: String = kEmptyString
    private var avtarImage: String = kEmptyString

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }
    
    override func prepareForReuse() {
        _imageView.sd_cancelCurrentImageLoad()
        _imageView.image = nil
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------

    private func readNotification(_ id: String) {
        WhosinServices.notificationRead(notificationId: id) { [weak self] container, error in
            guard let self = self else { return }
            guard let message = container?.message else { return }
            if message == "success" {
                self._unReadView.isHidden = true
                NOTIFICATION.getUnreadCount()
            }
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: NotificationModel, listData: NotificationListModel?) {
        _unReadView.isHidden = data.readStatus
        _updateNotificationReadStatus(data: data)
        if data.type == "follow" {
            _imageView.cornerRadius = _imageView.frame.height / 2
            _userActionStack.isHidden = false
            _timeLabel.isHidden = true
            _userTime.isHidden = false
            _userTime.text = data.updatedAt.timeAgoSince
            userId = data.typeId
            _subtitleLabel.isHidden = true
        } else {
            _imageView.cornerRadius = 10
            _subtitleLabel.isHidden = false
            _userActionStack.isHidden = true
            _subtitleLabel.text = data.descriptions
            _subtitleLabel.isHidden = false
            _userTime.isHidden = true
            _timeLabel.isHidden = false
        }
        _timeLabel.text = data.updatedAt.timeAgoSince
        _titleLabel.text = data.title.trimmingCharacters(in: .whitespaces)
        if data.type == "add-to-ring" {
            _imageView.image = UIImage(named: "ic_ring_invite")
        } else {
            if !data.image.isEmpty {
                _imageView.loadWebImage(data.image, name: data.title.trimmingCharacters(in: .whitespaces))
                avtarImage = data.image
            } else {
                _imageView.loadWebImage(data.image, name: data.title.trimmingCharacters(in: .whitespaces))
            }
        }
    }

    func _updateNotificationReadStatus(data: NotificationModel) {
        if !data.readStatus {
            readNotification(data.id)
            data.readStatus = !data.readStatus
        }
    }

}
