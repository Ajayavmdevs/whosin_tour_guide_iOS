import UIKit
import ExpandableLabel

class VenueOffersTableCell: UITableViewCell {
    
    @IBOutlet weak var _customMenu: CustomMenuButton!
    @IBOutlet weak var _customBtnsView: CustomOffersBtnView!
    @IBOutlet weak var _customPackageView: CustomPackageView!
    @IBOutlet weak var _offerTitleView: CustomOfferTitleView!
    @IBOutlet weak var _offerInfoView: CustomOfferInfoView!
    @IBOutlet weak var _bgView: UIView!
    private var offersModel: OffersModel?
    public var venue: VenueDetailModel?
    
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
    
    override func prepareForReuse() {
        if let model = offersModel, offersModel != nil {
            _customPackageView.setupData(model: model.packages.toArrayDetached(ofType: PackageModel.self))
        }
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
    
    public func setupData(_ data: OffersModel) {
        if Utils.isVenueDetailEmpty(data.venue) { data.venue = self.venue }
        offersModel = data
        _customPackageView.isHidden = data.packages.isEmpty
        _offerInfoView.setupData(model: data, venue: venue)
        _offerTitleView.setupData(model: data)
        _customPackageView.setupData(model: data.packages.toArrayDetached(ofType: PackageModel.self))
        _customBtnsView.setupData(model: data, venue: venue)
        _customMenu.setupData(model: data, venue: venue, offerType: .venue)
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
    
}

extension VenueOffersTableCell: ShowMembershipInfoDelegate {
    func ShowMembershipDetail() {
        let vc = INIT_CONTROLLER_XIB(MembershipDetailVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.present(vc, animated: true)
    }
}

