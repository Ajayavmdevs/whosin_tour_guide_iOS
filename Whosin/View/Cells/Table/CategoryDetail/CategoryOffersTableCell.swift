import UIKit
import ExpandableLabel

class CategoryOffersTableCell: UITableViewCell {
    
    @IBOutlet private weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _customMenu: CustomMenuButton!
    @IBOutlet private weak var _customTitleView: CustomOfferTitleView!
    @IBOutlet private weak var _customInfoView: CustomOfferInfoView!
    @IBOutlet private weak var _customPackageView: CustomPackageView!
    @IBOutlet private weak var _customBtnView: CustomOffersBtnView!
    private var _offersModel: OffersModel?
    private var _venueId: String = kEmptyString
    
    
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
    
    override func prepareForReuse() {
        if _offersModel != nil {
        }
    }
        
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        disableSelectEffect()
        NotificationCenter.default.addObserver(self, selector: #selector(openSuccessClaim(_:)), name: .openClaimSuccessCard, object: nil)
    }
    
    @objc func openSuccessClaim(_ notification: Notification) {
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
    
    private func  _generateDynamicLinks() {
        guard let controller = parentViewController else { return }
        let shareMessage = "\(self._offersModel?.venue?.name ?? kEmptyString) \n\n\(self._offersModel?.venue?.about ?? kEmptyString) \n\n\("https://whosin.me/link/\(_offersModel?.venue?.id ?? "")")"
        let items = [shareMessage]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.setValue(kAppName, forKey: "subject")
        activityController.popoverPresentationController?.sourceView = controller.view
        activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
        controller.present(activityController, animated: true, completion: nil)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupCategoryData(_ model: OffersModel) {
        _offersModel = model
        _customPackageView.isHidden = model.packages.isEmpty
        _venueInfoView.setupData(venue: model.venue ?? VenueDetailModel(), isAllowClick: true)
        _customMenu.setupData(model: model, venue: model.venue, offerType: .category)
        _customBtnView.setupData(model: model, venue: model.venue)
        _customInfoView.setupData(model: model, venue: model.venue)
        _customTitleView.setupData(model: model)
        _customPackageView.setupData(model: model.packages.toArrayDetached(ofType: PackageModel.self))
        _customPackageView.isHidden = model.packages.isEmpty
    }
    
}

extension CategoryOffersTableCell: ShowMembershipInfoDelegate {
    func ShowMembershipDetail() {
        let vc = INIT_CONTROLLER_XIB(MembershipDetailVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.present(vc, animated: true)
    }
}
