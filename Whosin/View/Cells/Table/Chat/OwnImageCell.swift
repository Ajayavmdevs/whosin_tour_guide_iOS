import UIKit
import Lightbox

class OwnImageCell: UITableViewCell {
    
    @IBOutlet weak var _sentTime: UILabel!
    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet private weak var _statusImage: UIImageView!
    @IBOutlet weak var _replyByName: CustomLabel!
    
    private var _imageUrl: String = kEmptyString
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        _imageView.isUserInteractionEnabled = true
        _imageView.addGestureRecognizer(tapGesture)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        var images: [LightboxImage] = []
        if sender.state == .ended, let image = _imageView.image {
            images.append(LightboxImage(image: image))
        } else if sender.state == .ended{
            images.append(LightboxImage(imageURL: URL(string: _imageUrl)!))
        }
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        parentBaseController?.present(controller, animated: true, completion: nil)
    }
    
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func setup(_ message: MessageModel?) {
        guard let _msg = message else { return }
        let timeStamp = Double(_msg.date )
        let date = timeStamp?.getDateStringFromUTC()
        _sentTime.text = date
        _imageUrl = _msg.msg
        if let imageName = _imageUrl.toURL?.lastPathComponent {
            let fileUrl = Utils.getDocumentsUrl().appendingPathComponent(imageName)
            if Utils.isFileExist(atPath: fileUrl.path) {
                _imageUrl = fileUrl.absoluteString
            }
        }
        _imageView.loadWebImage(_imageUrl)
        
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
        if let user = APPSESSION.userDetail {
            guard user.isPromoter, user.id != message?.replyBy, !Utils.stringIsNullOrEmpty(message?.replyBy) else {
                _replyByName.text = kEmptyString
                return
            }
            let replyUser = APPSETTING.subAdmins.first(where: { $0.id == message?.replyBy })
            _replyByName.text = "~ " + (replyUser?.fullName ?? kEmptyString)
        }
    }
    
    
}
