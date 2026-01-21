import UIKit
import Lightbox
import ObjectMapper

class CompititorContactShareCell: UITableViewCell {
    
    @IBOutlet weak var _heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var _customFollowBtn: CustomFollowButton!
    @IBOutlet private weak var _userName: UILabel!
    @IBOutlet private weak var _sentTime: UILabel!
//    @IBOutlet private weak var _followBtn: CustomActivityButton!
    @IBOutlet private weak var _userImage: UIImageView!
    @IBOutlet private weak var _senderName: UILabel!
    private var _msgModel: MessageModel?
    private var userId: String = kEmptyString
    
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
        _msgModel = _msg
        let timeStamp = Double(message?.date ?? "")
        let date = timeStamp?.getDateStringFromUTC()
        _senderName.text = message?.authorName
        _sentTime.text = date
        guard let model = Mapper<UserDetailModel>().map(JSONString: _msg.msg) else { return }
        _userImage.loadWebImage(model.image, name: model.fullName)
        _userName.text = model.fullName
        userId = model.id
        _customFollowBtn.isHidden = APPSESSION.userId == model.id
        _heightConstraint.constant = APPSESSION.userId == model.id ? 0 : 24
        if let user = APPSETTING.followingList?.first(where: { $0.id == model.id }) {
            _customFollowBtn.setupData(user, isFillColor: true) { isFollowing in
                user.follow = isFollowing
            }
        } else {
            model.follow = "cancelled"
            _customFollowBtn.setupData(model) { isFollowing in
                model.follow
            }
        }
    }
    
    
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.isForword = true
        navController.messageModel = self._msgModel
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)

    }
}
