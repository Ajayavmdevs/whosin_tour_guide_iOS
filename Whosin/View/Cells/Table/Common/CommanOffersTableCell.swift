import UIKit
import ExpandableLabel

class CommanOffersTableCell: UITableViewCell {
    
    @IBOutlet weak var _feedInfoView: UIView!
    @IBOutlet weak var _mainContainerView: GradientView!
    @IBOutlet weak var _trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var _leadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _customTopTitleView: CustomOfferTitleView!
    @IBOutlet private weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _customMenu: CustomMenuButton!
    @IBOutlet private weak var _customTitleView: CustomOfferTitleView!
    @IBOutlet private weak var _customInfoView: CustomOfferInfoView!
    @IBOutlet private weak var _customPackageView: CustomPackageView!
    @IBOutlet private weak var _customBtnView: CustomOffersBtnView!
    @IBOutlet weak var _offerDuarationStack: UIStackView!
    @IBOutlet weak var _createDate: UILabel!
    @IBOutlet private weak var _iconOffer: UIImageView!
    @IBOutlet private weak var _title: UILabel!
    @IBOutlet private weak var _feedTime: UILabel!
    @IBOutlet private weak var _topButton: UIButton!
    private var _id: String = kEmptyString
    private var _offersModel: OffersModel?
    
    
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
        if let model = _offersModel, _offersModel != nil {
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

    private func configureUI(forType type: OffersType) {
        switch type {
        case .category, .explore, .search:
            _customTitleView.isHidden = false
            _offerDuarationStack.isHidden = type == .category || type == .search ? true : false
            _venueInfoView.isHidden = false
            _customTopTitleView.isHidden = true
            _leadingConstraint.constant = type == .explore || type == .feed || type == .search ? 10 : 0
            _trailingConstraint.constant = type == .explore || type == .feed || type == .search ? 10 : 0
            _mainContainerView.cornerRadius = type == .explore || type == .feed || type == .search ? 10 : 0
        case .venue:
            _customTitleView.isHidden = true
            _offerDuarationStack.isHidden = true
            _venueInfoView.isHidden = true
            _customTopTitleView.isHidden = false
            _leadingConstraint.constant = 0
            _trailingConstraint.constant = 0
            _mainContainerView.cornerRadius = 0
        case .feed:
            _customTitleView.isHidden = true
            _offerDuarationStack.isHidden = true
            _venueInfoView.isHidden = true
            _customTopTitleView.isHidden = false
            _leadingConstraint.constant = 10
            _trailingConstraint.constant = 10
            _mainContainerView.cornerRadius = 10
            _mainContainerView.startColor = UIColor(hexString: "E6007E").withAlphaComponent(0.10)
            _mainContainerView.endColor = UIColor(hexString: "000000").withAlphaComponent(0)
            _mainContainerView.diagonalMode = true
            _mainContainerView.endLocation = 0.75
        case .yacht:
           print("yach")
        }
    }

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setup(_ model: OffersModel, type: OffersType, _ data: UserFeedModel? = nil, _ isRecommended: Bool = false, user: UserDetailModel? = nil) {
        
        if type != .venue, type != .feed {
            _venueInfoView.setupData(venue: model.venue ?? VenueDetailModel(), isAllowClick: true)
            _customTitleView.setupData(model: model)
        } else {
            _customTopTitleView.setupData(model: model)
        }
        _customMenu.setupData(model: model, venue: model.venue, offerType: type)
        _customBtnView.setupData(model: model, venue: model.venue)
        _customInfoView.setupData(model: model, venue: model.venue)
        if !model.packages.isEmpty {
            _customPackageView.isHidden = false
            _customPackageView.setupData(model: model.packages)
        } else {
            _customPackageView.isHidden = true
        }
        configureUI(forType: type)
        
        if type == .feed {
            _topButton.isEnabled = !isRecommended
            let checkedInText = isRecommended ? "recommended".localized() : "added_a_new_offer".localized()
            let titleText = isRecommended ? user?.fullName ?? kEmptyString : data?.venue?.name ?? kEmptyString
            _title.attributedText = Utils.setAtributedTitleText(title: titleText, subtitle: checkedInText, titleFont: FontBrand.SFboldFont(size: 14.0, isItalic: true), subtitleFont: FontBrand.SFregularFont(size: 13.0, isItalic: true))
                    
            _iconOffer.loadWebImage(isRecommended ? user?.image ?? kEmptyString : data?.venue?.logo ?? kEmptyString, name: isRecommended ? user?.firstName ?? kEmptyString : data?.venue?.name ?? kEmptyString)
            _id = data?.venue?.id ?? kEmptyString
            
            let time = Utils.stringToDate(data?.createdAt, format: kStanderdDate)
            _feedTime.text = time?.timeAgoSince
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction private func _handleTopButtonEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        vc.venueId = _id
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

}
