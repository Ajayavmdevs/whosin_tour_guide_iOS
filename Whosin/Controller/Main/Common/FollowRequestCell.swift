import UIKit

class FollowRequestCell: UITableViewCell {

    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _rejectBtn: CustomActivityButton!
    @IBOutlet weak var _approveBtn: CustomActivityButton!
    @IBOutlet weak var _userName: UILabel!
    @IBOutlet weak var _userImage: UIImageView!
    public var callback: (() -> Void)?
    private var userId: String = kEmptyString
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    class var height: CGFloat {
        75
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setup(_ model: UserDetailModel) {
        _userName.text = model.fullName
        _userImage.loadWebImage(model.image, name: model.firstName)
        userId = model.id
        _rejectBtn.setTitle("delete".localized())
        _approveBtn.setTitle("confirm".localized())
    }
    
    private func _acceptRejectEvent(_ status: String) {
        WhosinServices.acceptRejectReques(id: userId, status: status) { [weak self] container, error in
            guard let self = self else { return }
            self._approveBtn.hideActivity()
            self._rejectBtn.hideActivity()
            guard let data = container else { return }
            print(data)
            self.callback?()
        }
    }
    
    @IBAction func _handleReject(_ sender: UIButton) {
        _rejectBtn.showActivity()
        _acceptRejectEvent("rejected")
    }
    
    @IBAction func _handleAproveEvent(_ sender: UIButton) {
        _approveBtn.showActivity()
        _acceptRejectEvent("approved")
    }
    
}
