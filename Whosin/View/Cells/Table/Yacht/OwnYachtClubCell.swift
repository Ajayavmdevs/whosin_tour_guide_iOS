import UIKit
import Lightbox
import ObjectMapper

class OwnYachtClubCell: UITableViewCell {
    
    @IBOutlet weak var _sentTime: UILabel!
    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet private weak var _statusImage: UIImageView!
    @IBOutlet weak var _yachtLogo: UIImageView!
    @IBOutlet weak var _yachtTitle: UILabel!
    @IBOutlet weak var _yachtAddress: UILabel!
    private var messageModel: MessageModel?
    private var _yachtClubModel: YachtClubModel?
    
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
        guard let jsonString = message?.msg else { return }
        guard let model = Mapper<YachtClubModel>().map(JSONString: jsonString) else { return }
        _imageView.loadWebImage(model.cover)
        _yachtLogo.loadWebImage(model.logo)
        _yachtTitle.text = model.name
        _yachtAddress.text = model.address
        _yachtClubModel = model
        if _msg.seenBy.count >= _msg.members.count - 1 {
            _statusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _statusImage.tintColor = .green
        }
        else if _msg.receivers.count >= _msg.members.count {
            _statusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _statusImage.tintColor = .white
        }
        else if _msg.receivers.contains(APPSESSION.userDetail?.id ?? kEmptyString) {
            _statusImage.image = #imageLiteral(resourceName: "icon_single_check")
            _statusImage.tintColor = .white
        }
        else {
            _statusImage.image = #imageLiteral(resourceName: "icon_sending")
            _statusImage.tintColor = .white
            _sentTime.text = "sending...".localized()
        }
        
    }
    
    @IBAction func _handleInviteEvent(_ sender: UIButton) {
//        let controler = INIT_CONTROLLER_XIB(InviteBottomSheet.self)
//        controler.venueModel = _venueModel
//        let navController = NavigationController(rootViewController: controler)
//        navController.modalPresentationStyle = .custom
//        parentBaseController?.present(navController, animated: true)
    }
    
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.isForword = true
        navController.messageModel = self.messageModel
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)
    }
}
