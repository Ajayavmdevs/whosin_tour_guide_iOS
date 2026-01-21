import UIKit
import Hero

class OffersDetailVC: ChildViewController {
    
    var heroId: String = kEmptyString

    @IBOutlet private weak var _topShadow: GradientView!
    @IBOutlet private weak var _bottomShadow: GradientView!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _mainContainerView: UIView!
    @IBOutlet private weak var _backGroundImage: UIImageView!
    @IBOutlet private weak var _inviteButton: UIButton!
    @IBOutlet private weak var _venueDetailView: CustomVenueInfoView!
    @IBOutlet private weak var _venueDetailDescription: UILabel!
    @IBOutlet private weak var _venueDetailTitle: UILabel!
    @IBOutlet private weak var _description: UILabel!
    @IBOutlet private weak var _offersButton: UIButton!
    @IBOutlet private weak var _venueName: UILabel!
    public var isOffers: Bool = false
    public var customVenueModel: CustomVenuesModel?
    
    public var callback: (() -> Void)?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func setupUi() {
        self._offersButton.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
        _visualEffectView.hero.modifiers = HeroAnimationModifier.visualEffect
        _mainContainerView.hero.id = heroId
        _mainContainerView.hero.modifiers = HeroAnimationModifier.sourceView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(_handleOpenVenueGestureEvent(_:)))
        _venueDetailView.addGestureRecognizer(tapGesture)

        var venue = customVenueModel?.venueModel
        if venue == nil {
            venue = customVenueModel?.offerModel?.venue
        }
        
        let offer = customVenueModel?.offerModel
        if offer == nil {
            _backGroundImage.loadWebImageWithoutSkeleton(venue?.cover ?? "")
        } else {
            _backGroundImage.loadWebImageWithoutSkeleton(offer?.image ?? "")
        }
        
        _venueName.text = customVenueModel?.title
        _venueDetailTitle.text = customVenueModel?.info
        _venueDetailDescription.text = customVenueModel?.descriptions
        _description.setFontWieght(customVenueModel?.subTitle ?? "", 0.85)
        _offersButton.isHidden = customVenueModel?.badge == "0"
        if customVenueModel?.badge.hasSuffix("%") ?? true {
            _offersButton.setTitle("\(customVenueModel?.badge ?? kEmptyString)")
        } else {
            _offersButton.setTitle("\(customVenueModel?.badge ?? kEmptyString)%")
        }
        
        if let _venue = venue {
            _venueDetailView.setupData(venue: _venue, showSkeleton: false)
        }
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(_handlePanGestureEvent(_ :))))
        let tapGestureImage = UITapGestureRecognizer(target: self, action: #selector(_handleTapGestureEvent(_:)))
        tapGestureImage.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureImage)
        
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc private func _handlePanGestureEvent(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        switch sender.state {
        case .began:
            dismiss(animated: true, completion: nil)
        case .changed:
            Hero.shared.update(translation.y / view.bounds.height)
        default:
            let velocity = sender.velocity(in: view)
            if ((translation.y + velocity.y) / view.bounds.height) > 0.5 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }
    
    @objc private func _handleOpenVenueGestureEvent(_ gesture: UIGestureRecognizer) {
        if var venue = customVenueModel?.venueModel == nil ? customVenueModel?.offerModel?.venue : customVenueModel?.venueModel {
            dismiss(animated: true) {
                self.callback?()
            }
        }
    }
    
    @objc private func _handleTapGestureEvent(_ gesture: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func _viewButtonEvent() {
        if var venue = customVenueModel?.venueModel == nil ? customVenueModel?.offerModel?.venue : customVenueModel?.venueModel {
            dismiss(animated: true) {
                self.callback?()
            }
        }
    }
}
