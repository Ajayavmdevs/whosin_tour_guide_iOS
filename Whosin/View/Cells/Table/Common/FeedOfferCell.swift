import UIKit
import ExpandableLabel

class FeedOfferCell: UITableViewCell {

    @IBOutlet private weak var _customBtnView: CustomOffersBtnView!
    @IBOutlet private weak var _customPackgeView: CustomPackageView!
    @IBOutlet private weak var _customInfoView: CustomOfferInfoView!
    @IBOutlet private weak var _customMenuView: CustomMenuButton!
    @IBOutlet private weak var _customTitleView: CustomOfferTitleView!
    @IBOutlet private weak var _iconOffer: UIImageView!
    @IBOutlet private weak var _title: UILabel!
    @IBOutlet private weak var _feedTime: UILabel!
    @IBOutlet private weak var _topButton: UIButton!
    private var _offerData: OffersModel?
    private var _id: String = kEmptyString
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        disableSelectEffect()
        NotificationCenter.default.addObserver(self, selector: #selector(openSuccessClaim(_:)), name: .openClaimSuccessCard, object: nil)
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: UserFeedModel, isRecommended: Bool = false, user: UserDetailModel? = nil) {
        _topButton.isEnabled = isRecommended ? false : true
        let checkedInText = isRecommended ? "recommended".localized() : "added_a_new_offer".localized()
        let titleText = isRecommended ? user?.fullName ?? kEmptyString : data.venue?.name ?? kEmptyString
        _title.attributedText = Utils.setAtributedTitleText(title: titleText, subtitle: checkedInText, titleFont: FontBrand.SFboldFont(size: 14.0, isItalic: true), subtitleFont: FontBrand.SFregularFont(size: 13.0, isItalic: true))
                
        _iconOffer.loadWebImage(isRecommended ? user?.image ?? kEmptyString : data.venue?.logo ?? kEmptyString, name: isRecommended ? user?.firstName ?? kEmptyString : data.venue?.name ?? kEmptyString)
        _id = data.venue?.id ?? kEmptyString
        
        let time = Utils.stringToDate(data.createdAt, format: kStanderdDate)
        _feedTime.text = time?.timeAgoSince
        _offerData = data.offer
        if let model = _offerData {
            _customPackgeView.isHidden = model.packages.isEmpty
            _customTitleView.setupData(model: model)
            _customBtnView.setupData(model: model, venue: model.venue)
            _customInfoView.setupData(model: model, venue: model.venue)
            _customMenuView.setupData(model: model, venue: model.venue, offerType: .feed)
            _customPackgeView.setupData(model: model.packages.toArrayDetached(ofType: PackageModel.self))
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @objc private func openSuccessClaim(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any],
           let data = userInfo["data"] as? ClaimHistoryModel,
           let isFromBrunch = userInfo["isFromBrunch"] as? Bool, let specialOffer = userInfo["specialOffer"] as? SpecialOffersModel, let venue = userInfo["venue"] as? VenueDetailModel {
            let vc = INIT_CONTROLLER_XIB(ClaimSuccessfullVC.self)
            vc.modalPresentationStyle = .overFullScreen
            vc.isFromBrunch = isFromBrunch
            vc.model = data
            vc.venueModel = venue
            vc.specialOffer = specialOffer
            self.parentViewController?.present(vc, animated: true)
        }
    }

    @IBAction private func _handleTopButtonEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        vc.venueId = _id
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

