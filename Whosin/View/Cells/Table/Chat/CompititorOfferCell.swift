import UIKit
import Lightbox
import ObjectMapper
import ExpandableLabel

class CompititorOfferCell: UITableViewCell {
    
    @IBOutlet weak var _venueDisc: UILabel!
    @IBOutlet weak var _venueName: UILabel!
    @IBOutlet weak var _venueLogo: UIImageView!
    @IBOutlet weak var _bgImage: UIImageView!
    @IBOutlet weak var _inviteBtn: UIButton!
    @IBOutlet weak var _offerDisc: ExpandableLabel!
    @IBOutlet weak var _offerTitle: UILabel!
    @IBOutlet weak var _coverImage: UIImageView!
    @IBOutlet weak var _tillDate: UILabel!
    @IBOutlet weak var _fromDate: UILabel!
    @IBOutlet weak var _offerDays: UILabel!
    @IBOutlet weak var _offerTime: UILabel!
    @IBOutlet private weak var _sentTime: UILabel!
    @IBOutlet private weak var _senderName: UILabel!
    
    private var offerModel: OffersModel?
    private var messageModel: MessageModel?
    
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
        let timeStamp = Double(message?.date ?? "")
        let date = timeStamp?.getDateStringFromUTC()
        _senderName.text = _msg.authorName
        _sentTime.text = date
        guard let model = Mapper<OffersModel>().map(JSONString: _msg.msg) else { return }
        offerModel = model
        _venueDisc.text = model.venue?.address
        _venueLogo.loadWebImage(model.venue?.logo ?? kEmptyString, name: model.venue?.name ?? kEmptyString)
        _venueName.text = model.venue?.name
        _offerDays.text = model.days
        _offerTitle.text = model.title
        _offerDisc.text = model.descriptions
        _coverImage.loadWebImage(model.image)
        _bgImage.loadWebImage(model.image)
        _tillDate.text = model.endDate?.display ?? kEmptyString
        _fromDate.text = model.startDate?.display ?? kEmptyString
        _offerTime.text = model.timeSloat
    }
    
    @IBAction func _handleInviteEvent(_ sender: UIButton) {
    }
    
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.isForword = true
        navController.messageModel = self.messageModel
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)
    }
}
