import UIKit

class PlusUserTableCell: UITableViewCell {
    
    @IBOutlet weak var _plusOneView: UIView!
    @IBOutlet weak var _statusBgView: UIView!
    @IBOutlet weak var _statusLabel: CustomLabel!
    @IBOutlet weak var _viewProfileBtn: CustomButton!
    @IBOutlet private weak var _subTitleText: UILabel!
    @IBOutlet private weak var _userName: UILabel!
    @IBOutlet private weak var _imageView: UIImageView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 64 }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            self._plusOneView.layer.maskedCorners = [.layerMinXMaxYCorner]
            self._plusOneView.layer.cornerRadius = 6
            self._plusOneView.layer.masksToBounds = true
        }
    }
    
    // --------------------------------------
    // MARK: setup
    // --------------------------------------
    
    public func setupEventData(_ model: InvitedUserModel, isConfirmation: Bool = false) {
        _userName.text = model.user?.fullName
        _stautsBadge(inviteStatus: model.inviteStatus)
        _imageView.loadWebImage(model.user?.image ?? kEmptyString, name: model.user?.fullName ?? kEmptyString)
        _subTitleText.text = "invite_event_plusOne".localized()
    }
    
    private func _stautsBadge(inviteStatus: String) {
        if inviteStatus == "in" {
            _statusLabel.text = "in".localized()
            _statusBgView.backgroundColor = ColorBrand.brandGreen
            _statusBgView.isHidden = false
        } else if inviteStatus == "out" {
            _statusLabel.text = "out".localized()
            _statusBgView.backgroundColor = UIColor(hexString: "#E32A2A")
            _statusBgView.isHidden = false
        } else {
            _statusLabel.text = "pending".localized()
            _statusBgView.isHidden = true
        }
    }
    
}
