import UIKit
import StripeCore
import ExpandableLabel

class OfferSearchTableCell: UITableViewCell {
    

    @IBOutlet private weak var _customBtnsView: CustomOffersBtnView!
    @IBOutlet private weak var _customPackageView: CustomPackageView!
    @IBOutlet private weak var _customTitleView: CustomOfferTitleView!
    @IBOutlet private weak var _customMenuVew: CustomMenuButton!
    @IBOutlet private weak var _customOfferInfoView: CustomOfferInfoView!
    @IBOutlet private weak var _customVenueInfo: CustomVenueInfoView!
    @IBOutlet private weak var _venueView: UIView!
    @IBOutlet weak var _offerDuarationStack: UIStackView!
    @IBOutlet weak var _createDate: UILabel!
    private var _offerModel: OffersModel?



    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let _offerModel = _offerModel else { return }

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: OffersModel) {
        _offerModel = data
        if let venue = data.venue {
            _customVenueInfo.setupData(venue: venue, isAllowClick: true)
        }
        _customTitleView.setupData(model: data)
        _customPackageView.isHidden = data.packages.isEmpty ? true : data.isPackagewithzeroPrice
        _customMenuVew.setupData(model: data, venue: data.venue, offerType: .explore)
        _customPackageView.setupData(model: data.packages.toArrayDetached(ofType: PackageModel.self))
        _customOfferInfoView.setupData(model: data, venue: data.venue)
        _customBtnsView.setupData(model: data, venue: data.venue)
    }
        
}

