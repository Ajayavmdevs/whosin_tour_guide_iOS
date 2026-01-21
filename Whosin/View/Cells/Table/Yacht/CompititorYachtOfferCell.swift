import UIKit
import Lightbox
import ObjectMapper
import ExpandableLabel

class CompititorYachtOfferCell: UITableViewCell {
    
    @IBOutlet private weak var _sentTime: UILabel!
    @IBOutlet private weak var _senderName: UILabel!
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
        let timeStamp = Double(message?.date ?? "")
        let date = timeStamp?.getDateStringFromUTC()
        _senderName.text = _msg.authorName
        _sentTime.text = date
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

