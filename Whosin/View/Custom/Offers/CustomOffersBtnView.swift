import Foundation
import UIKit
import SnapKit


class CustomOffersBtnView: UIView {
    
    @IBOutlet private weak var _btnsStacks: UIStackView!
    @IBOutlet private weak var _inviteBtn: UIButton!
    @IBOutlet private weak var _claimNowBtn: UIButton!
    @IBOutlet private weak var _claimNowView: UIView!
    @IBOutlet private weak var _inviteBtnView: UIView!
    @IBOutlet private weak var _buyNowview: UIView!
    @IBOutlet private weak var _buyNowButton: UIButton!

    private var offersModel: OffersModel?
    private var venueModel: VenueDetailModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomOffersBtnView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    public func setupData(model: OffersModel, venue: VenueDetailModel?) {
        offersModel = model
        venueModel = venue
        if model.isHideBuyButton || model.packages.isEmpty || model.isPackagewithzeroPrice {
            _buyNowview.isHidden = true
        } else {
            _buyNowview.isHidden = false
        }
        if model._isExpired {
            _btnsStacks.isHidden = true
            _inviteBtnView.isHidden = true
        } else {
            if !_buyNowview.isHidden && model.isShowClaim {
                _btnsStacks.isHidden = false

                _claimNowView.isHidden = false
                _claimNowView.backgroundColor = ColorBrand.claimDiscountColor
                _claimNowBtn.setTitle("claim_discount".localized(), for: .normal)
                _claimNowBtn.addTarget(self, action: #selector(_handleClaimNowEvent(_:)), for: .touchUpInside)

                _buyNowview.isHidden = false
                _buyNowview.backgroundColor = ColorBrand.buyNowColor
                _buyNowButton.setTitle("buy_now".localized(), for: .normal)
                _buyNowButton.addTarget(self, action: #selector(_handleBuyNowEvent(_:)), for: .touchUpInside)

                _inviteBtnView.isHidden = true//false
                _inviteBtnView.backgroundColor = ColorBrand.brandPink
                _inviteBtn.setTitle("invite_your_friends".localized(), for: .normal)
                _inviteBtn.addTarget(self, action: #selector(_handleInviteEvent(_:)), for: .touchUpInside)
            } else if _buyNowview.isHidden && model.isShowClaim {
                _btnsStacks.isHidden = false
                _inviteBtnView.isHidden = true

                _buyNowview.isHidden = false
                _buyNowview.backgroundColor = ColorBrand.claimDiscountColor
                _buyNowButton.setTitle("claim_discount".localized(), for: .normal)
                _buyNowButton.addTarget(self, action: #selector(_handleClaimNowEvent(_:)), for: .touchUpInside)

                _claimNowView.isHidden = true//false
                _claimNowView.backgroundColor = ColorBrand.brandPink
                _claimNowBtn.setTitle("invite_your_friends".localized(), for: .normal)
                _claimNowBtn.addTarget(self, action: #selector(_handleInviteEvent(_:)), for: .touchUpInside)
            } else if !_buyNowview.isHidden && !model.isShowClaim {
                _btnsStacks.isHidden = false
                _inviteBtnView.isHidden = true

                _buyNowview.isHidden = false
                _buyNowview.backgroundColor = ColorBrand.buyNowColor
                _buyNowButton.setTitle("buy_now".localized(), for: .normal)
                _buyNowButton.addTarget(self, action: #selector(_handleBuyNowEvent(_:)), for: .touchUpInside)

                _claimNowView.isHidden = true//false
                _claimNowView.backgroundColor = ColorBrand.brandPink
                _claimNowBtn.setTitle("invite_your_friends".localized(), for: .normal)
                _claimNowBtn.addTarget(self, action: #selector(_handleInviteEvent(_:)), for: .touchUpInside)
            }else if _buyNowview.isHidden && !model.isShowClaim {
                _btnsStacks.isHidden = true

                _inviteBtnView.isHidden = true//false
                _inviteBtnView.backgroundColor = ColorBrand.brandPink
                _inviteBtn.setTitle("invite_your_friends".localized(), for: .normal)
                _inviteBtn.addTarget(self, action: #selector(_handleInviteEvent(_:)), for: .touchUpInside)
            }
        }

    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
        
    @objc private func _handleInviteEvent(_ sender: UIButton) {
        let controler = INIT_CONTROLLER_XIB(InviteBottomSheet.self)
        controler._selectedOffer = offersModel
        controler.venueModel = offersModel?.venue
        let navController = NavigationController(rootViewController: controler)
        navController.modalPresentationStyle = .custom
        parentBaseController?.present(navController, animated: true)
    }
    
    @objc private func _handleClaimNowEvent(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(ClaimBrunchVC.self)
        controller.venueModel = offersModel?.venue
        controller.specialOffer = offersModel?.specialOffer
        let navController = NavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overFullScreen
        self.parentViewController?.present(navController, animated: true)
    }
    
    @objc private func _handleBuyNowEvent(_ sender: UIButton) {
        guard let model = offersModel else { return }
        let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
        vc.type = "offers"
        vc.offerModel = model
        vc.venue = self.venueModel
        vc.timingModel = self.venueModel?.timing.toArrayDetached(ofType: TimingModel.self)
        vc.setCallback {
            let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
            controller.modalPresentationStyle = .overFullScreen
            self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
        }
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

}

