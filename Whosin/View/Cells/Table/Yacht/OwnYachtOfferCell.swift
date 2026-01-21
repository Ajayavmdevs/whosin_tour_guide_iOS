import UIKit
import Lightbox
import ObjectMapper
import ExpandableLabel

class OwnYachtOfferCell: UITableViewCell {
    
    @IBOutlet weak var _sentTime: UILabel!
    @IBOutlet private weak var _statusImage: UIImageView!
    @IBOutlet weak var _featuresView: CustomFeaturesView!
    @IBOutlet weak var _priceText: UILabel!
    @IBOutlet weak var _priceView: GradientView!
    @IBOutlet weak var _buyNowView: UIView!
    @IBOutlet weak var _offerAbout: UILabel!
    @IBOutlet weak var _offerTitle: UILabel!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet weak var _clubLogo: UIImageView!
    @IBOutlet weak var _clubTitle: UILabel!
    @IBOutlet weak var _clubSubtitle: UILabel!
    private var features: [CommonSettingsModel] = []
    private var offerModel: YachtOfferDetailModel?
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
        disableSelectEffect()
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self._priceView.roundCorners(corners: [.topRight, .bottomLeft], radius: 15)
        }
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
        else if _msg.receivers.contains(APPSESSION.userDetail?.id ?? kEmptyString) {
            _statusImage.image = #imageLiteral(resourceName: "icon_single_check")
            _statusImage.tintColor = .white
        }
        else {
            _statusImage.image = #imageLiteral(resourceName: "icon_sending")
            _statusImage.tintColor = .white
            _sentTime.text = "sending...".localized()
        }
        guard let jsonString = message?.msg else { return }
        guard let model = Mapper<YachtOfferDetailModel>().map(JSONString: _msg.msg) else { return }
        guard let yacht = model.yacht else { return }
        _clubLogo.loadWebImage(yacht.yachtClub?.logo ?? kEmptyString)
        _clubTitle.text = yacht.yachtClub?.name
        _clubSubtitle.text = yacht.yachtClub?.address
        _coverImage.loadWebImage(model.images.first ?? kEmptyString)
        _offerTitle.text = model.title
        _offerAbout.text = model.descriptions
        if !yacht.features.isEmpty {
            _featuresView.setupData(model: yacht.features.toArrayDetached(ofType: CommonSettingsModel.self))
        }
        _priceText.text = "D\(model.startingAmount)/hr"
        _featuresView.isHidden = yacht.features.isEmpty
    }
    
//    @IBAction func _handleInviteEvent(_ sender: UIButton) {
//        let controler = INIT_CONTROLLER_XIB(InviteBottomSheet.self)
//        controler._selectedOffer = offerModel
//        controler.venueModel = offerModel?.venue
//        let navController = NavigationController(rootViewController: controler)
//        navController.modalPresentationStyle = .custom
//        parentBaseController?.present(navController, animated: true)
//    }

    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.isForword = true
        navController.messageModel = self.messageModel
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)

    }
    
}
