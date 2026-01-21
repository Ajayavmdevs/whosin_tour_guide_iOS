import UIKit
import Lightbox
import ObjectMapper

class CompititorVenueCell: UITableViewCell {
    
    @IBOutlet weak var _sentTime: UILabel!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _senderName: UILabel!
    @IBOutlet weak var _venueLogo: UIImageView!
    @IBOutlet weak var _venueTitle: UILabel!
    @IBOutlet weak var _venueAddress: UILabel!
    
    private var _msgModel: MessageModel?
    private var _venueModel: VenueDetailModel?
    
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
        _msgModel = message
        let timeStamp = Double(message?.date ?? "")
        let date = timeStamp?.getDateStringFromUTC()
        _senderName.text = message?.authorName
        _sentTime.text = date
        guard let jsonString = message?.msg else { return }
        guard let model = Mapper<ChatVenueModel>().map(JSONString: jsonString) else { return }
        _imageView.loadWebImage(model.cover)
        _venueLogo.loadWebImage(model.logo)
        _venueTitle.text = model.name
        _venueAddress.text = model.address
        _venueModel = Utils.getModelFromId(model: APPSETTING.venueModel, id: model.id)
    }
    
    @IBAction func _handleInviteEvent(_ sender: UIButton) {
        let controler = INIT_CONTROLLER_XIB(InviteBottomSheet.self)
        controler.venueModel = _venueModel
        let navController = NavigationController(rootViewController: controler)
        navController.modalPresentationStyle = .custom
        parentBaseController?.present(navController, animated: true)
    }
    
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.isForword = true
        navController.messageModel = self._msgModel
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)
    }
}
