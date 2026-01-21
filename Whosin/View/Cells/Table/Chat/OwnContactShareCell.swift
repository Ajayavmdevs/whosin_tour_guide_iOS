import UIKit
import ObjectMapper
import Lightbox

class OwnContactShareCell: UITableViewCell {
    
    @IBOutlet weak var _heightConstriant: NSLayoutConstraint!
    @IBOutlet weak var _followBtn: CustomFollowButton!
//    @IBOutlet weak var _followBtn: CustomActivityButton!
    @IBOutlet weak var _sentTime: UILabel!
    @IBOutlet weak var _userImage: UIImageView!
    @IBOutlet weak var _userName: UILabel!
    @IBOutlet private weak var _statusImage: UIImageView!
    private var userId: String = kEmptyString
    private var messageModel: MessageModel?
    @IBOutlet weak var _replyByName: CustomLabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func setup(_ message: MessageModel?) {
        guard let _msg = message else { return }
        messageModel = _msg
        let timeStamp = Double(_msg.date )
        let date = timeStamp?.getDateStringFromUTC()
        _sentTime.text = date
        if _msg.seenBy.count >= _msg.members.count - 1 {
            _statusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _statusImage.tintColor = .green
        }
        else if _msg.receivers.count >= _msg.members.count {
            _statusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _statusImage.tintColor = .white
        }
        else if _msg.receivers.contains(Preferences.isSubAdmin ? APPSESSION.userDetail?.promoterId ?? kEmptyString : APPSESSION.userDetail?.id ?? kEmptyString) {
            _statusImage.image = #imageLiteral(resourceName: "icon_single_check")
            _statusImage.tintColor = .white
        }
        else {
            _statusImage.image = #imageLiteral(resourceName: "icon_sending")
            _statusImage.tintColor = .white
            _sentTime.text = "sending...".localized()
        }
        guard let model = Mapper<UserDetailModel>().map(JSONString: _msg.msg) else { return }
        _userImage.loadWebImage(model.image, name: model.fullName)
        _userName.text = model.fullName
        userId = model.id
        _followBtn.isHidden = APPSESSION.userId == model.id 
        _heightConstriant.constant = APPSESSION.userId == model.id ? 0 : 24
        if let user = APPSETTING.followingList?.first(where: { $0.id == model.id }) {
            _followBtn.setupData(user, isFillColor: true) { isFollowing in
                user.follow = isFollowing
            }
        } else {
            model.follow = "cancelled"
            _followBtn.setupData(model) { isFollowing in
                model.follow = isFollowing
            }
        }

        if let user = APPSESSION.userDetail {
                guard user.isPromoter, user.id != message?.replyBy, !Utils.stringIsNullOrEmpty(message?.replyBy) else {
                    _replyByName.text = kEmptyString
                    return
                }
                let replyUser = APPSETTING.subAdmins.first(where: { $0.id == message?.replyBy })
                _replyByName.text = "~ " + (replyUser?.fullName ?? kEmptyString)
            }
    }
    
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.isForword = true
        navController.messageModel = self.messageModel
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)
    }
    

}
