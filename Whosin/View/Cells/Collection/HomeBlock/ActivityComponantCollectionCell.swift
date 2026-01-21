import UIKit
import CollectionViewPagingLayout
import StripeCore

class ActivityComponantCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _ratingLabel: UILabel!
    @IBOutlet private weak var _ratingView: UIView!
    @IBOutlet private weak var _buyNowBg: GradientView!
    @IBOutlet weak var _mainContainerView: UIView!
    @IBOutlet private weak var _badgeView: CustomBadgeView!
    @IBOutlet private weak var _titleLabel: UILabel!
    private var _activityId: String = kEmptyString
    private var _activityName: String = kEmptyString
    private var _venueId: String = kEmptyString
    private var activityModel: ActivitiesModel?
    @IBOutlet weak var _mainTrailing: NSLayoutConstraint!

    // --------------------------------------
    // MARK: Class1
    // --------------------------------------
    
    class var height: CGFloat { 295 }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._mainContainerView.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 10)
            
            self._buyNowBg.roundCorners(corners: [.topLeft, .bottomLeft], radius: 8)
            self._buyNowBg.hero.id = self._activityId+"_open_buy_package_info"
            self._buyNowBg.hero.modifiers = HeroAnimationModifier.stories
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ model: ActivitiesModel) {
        _venueInfoView.setupProviderData(venue: model.provider ?? ProviderModel())
        activityModel = model
        _venueId = model.provider?.id ?? ""
        _activityId = model.id
        _activityName = model.name
        _titleLabel.text = model.name
        _ratingLabel.text = String(format: "%.1f", model.avgRating)
        _ratingView.isHidden = model.avgRating == 0.0
        _coverImage.loadWebImage(model.cover) { [weak self] in
            if let img  = self?._coverImage.image {
                DispatchQueue.global(qos: .userInitiated).async {
                    let color = try? img.averageColor()
                    DISPATCH_ASYNC_MAIN {
                        self?._mainContainerView.borderColor = color ?? .red
                    }
                }
            }
        }

        _badgeView.setupData(originalPrice: model.price, discountedPrice: model._disocuntedPrice, isNoDiscount: model._isNoDiscount)
        _buyNowBg.isHidden = model.isPriceZero
        UIView.animate(withDuration: 0.3) {
            self._badgeView.layoutIfNeeded()
            self._badgeView.roundCorners(corners: [.bottomLeft, .topRight], radius: 8)
        }
        
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc func _imageBgTap(sender : UITapGestureRecognizer) {
        
        guard let venues = HomeRepository.getStoryArrayByVenueId(self._venueId) else { return }
        let controller = INIT_CONTROLLER_XIB(ContentViewVC.self)
        controller.modalPresentationStyle = .overFullScreen
        controller.pages = venues
        controller.currentIndex = 0
        controller.hero.isEnabled = true
        controller.hero.modalAnimationType = .none
        controller.view.hero.id = _venueId
        controller.view.hero.modifiers = HeroAnimationModifier.stories
        parentViewController?.present(controller, animated: true)
    }
    
    @IBAction private func _handleBuyNowEvent(_ sender: UIButton) {
    }
}

extension ActivityComponantCollectionCell: ScaleTransformView {
    var scaleOptions: ScaleTransformViewOptions {
        ScaleTransformViewOptions(
            minScale: 0.99,
            scaleRatio: 0.4 ,
            translationRatio: CGPoint(x: 1.023, y: 0.0),
            maxTranslationRatio: CGPoint(x: 2, y: 0)
        )
    }
}
