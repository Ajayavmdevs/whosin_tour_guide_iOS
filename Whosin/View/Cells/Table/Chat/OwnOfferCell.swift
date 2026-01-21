import UIKit
import Lightbox
import ObjectMapper
import ExpandableLabel

class OwnOfferCell: UITableViewCell {
    
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
    @IBOutlet weak var _sentTime: UILabel!
    @IBOutlet private weak var _statusImage: UIImageView!
    @IBOutlet weak var _replyByName: CustomLabel!
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
        guard let jsonString = message?.msg else { return }
        guard let model = Mapper<OffersModel>().map(JSONString: jsonString) else { return }
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
        
        if let user = APPSESSION.userDetail {
            guard user.isPromoter, user.id != message?.replyBy, !Utils.stringIsNullOrEmpty(message?.replyBy) else {
                _replyByName.text = kEmptyString
                return
            }
            let replyUser = APPSETTING.subAdmins.first(where: { $0.id == message?.replyBy })
            _replyByName.text = "~ " + (replyUser?.fullName ?? kEmptyString)
        }
    }
    
    @IBAction func _handleInviteEvent(_ sender: UIButton) {
        let controler = INIT_CONTROLLER_XIB(InviteBottomSheet.self)
        controler._selectedOffer = offerModel
        controler.venueModel = offerModel?.venue
        let navController = NavigationController(rootViewController: controler)
        navController.modalPresentationStyle = .custom
        parentBaseController?.present(navController, animated: true)
    }

    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.isForword = true
        navController.messageModel = self.messageModel
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)

    }
    
}
