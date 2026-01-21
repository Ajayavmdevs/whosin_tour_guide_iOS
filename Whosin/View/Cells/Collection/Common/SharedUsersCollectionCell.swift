import UIKit

class SharedUsersCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var _avatarImageView: UIImageView!
    @IBOutlet private weak var _nameLabel: UILabel!
    @IBOutlet weak var _button: UIButton!
    @IBOutlet weak var _inviteStatusImg: UIImageView!
    private var _contacts: UserDetailModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        60
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        guard let contact = _contacts else { return }
//        _avatarImageView.sd_cancelCurrentImageLoad()
//        _avatarImageView.loadWebImage(contact.image, name: contact.firstName)
//        _nameLabel.text = contact.firstName
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setupData(_ model: UserDetailModel, isLastIndex: Bool = false, inviteStatus: Bool = false) {
        _contacts = model
        _inviteStatusImg.isHidden = inviteStatus
        _inviteStatusImg.image = model.statusImage
        _avatarImageView.image = nil
        if isLastIndex {
            _avatarImageView.image = UIImage(named: "icon_coverRound")
            _nameLabel.text = "add".localized()
            _button.isHidden = true
        } else {
            _avatarImageView.loadWebImage(model.image, name: model.firstName)
            _nameLabel.text = model.firstName
            _button.isHidden = false
        }
    }
    
    func setupEventData(_ model: InvitationModel, inviteStatus: String) {
        _contacts = model.user
        _inviteStatusImg.isHidden = false
        _inviteStatusImg.image = model.statusImage
        _avatarImageView.loadWebImage(model.user?.image ?? "", name: model.user?.firstName ?? "")
        _nameLabel.text = model.user?.firstName
        _button.isHidden = false
    }
    
    private func _manageStatus(_ status: String) {
        if status == "in" {
            _inviteStatusImg.image = UIImage(named: "icon_inviteIn")
        } else if status == "pending" {
            _inviteStatusImg.image = UIImage(named: "icon_invitePending")
        } else if status == "out" {
            _inviteStatusImg.image = UIImage(named: "icon_inviteOut")
        }
    }
    
    @IBAction private func _handleClcikEvent(_ sender: UIButton) {
        guard let contacts = _contacts else {
            return
        }
        guard let userDetail = APPSESSION.userDetail else { return }
        if contacts.id != userDetail.id {
            NotificationCenter.default.post(name:Notification.Name("openuser"), object: nil, userInfo: ["contact": contacts])
        }
    }
}
