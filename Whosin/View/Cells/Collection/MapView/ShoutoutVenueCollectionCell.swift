import UIKit
import CollectionViewPagingLayout

class ShoutoutVenueCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _mainContainerView: UIView!
    @IBOutlet private weak var _logoBgView: UIView!
    @IBOutlet private weak var _venueLogoImage: UIImageView!
    @IBOutlet private weak var _venueName: UILabel!
    @IBOutlet private weak var _venueAddress: UILabel!
    
    private var _venueId: String = kEmptyString
    private var _logoHeroId: String = kEmptyString


    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        272
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)
      isTouched = true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesEnded(touches, with: event)
      isTouched = false
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesCancelled(touches, with: event)
      isTouched = false
    }
    
    public var isTouched: Bool = false {
      didSet {
        var transform = CGAffineTransform.identity
        if isTouched { transform = transform.scaledBy(x: 0.96, y: 0.96) }
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
          self.transform = transform
        }, completion: nil)
      }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self._mainContainerView.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 10)
            self._logoBgView.layer.cornerRadius = self._logoBgView.frame.size.height / 2
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self._imageBgTap))
            self._logoBgView.addGestureRecognizer(gesture)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: VenueDetailModel) {
        _coverImage.loadWebImage(data.cover) { [weak self] in
            if let img  = self?._coverImage.image {
                DispatchQueue.global(qos: .userInitiated).async {
                    let color = try? img.averageColor()
                    DISPATCH_ASYNC_MAIN { 
                        self?._mainContainerView.borderColor = color ?? .red
                    }
                }
            }
        }
        _venueName.text = data.name
        _venueAddress.text = data.address
        _venueLogoImage.loadWebImage(data.logo,name: data.name)
        _venueId = data.id
        _showStoryRing()
        _logoHeroId = _venueId + data.id + "_story_"
        _logoBgView.hero.id = _venueId + data.id + "_story_"
        _logoBgView.hero.modifiers = HeroAnimationModifier.stories
        _mainContainerView.hero.id = _venueId+"_open_detail_from_large_venue_cell"
        _mainContainerView.hero.modifiers = HeroAnimationModifier.stories
    }
    
    private func _showStoryRing() {
        
        let storyModel = HomeRepository.getStoryByVenueId(_venueId)
        if storyModel != nil {
            let viewedIds = Utils.getViewedStories()
            if viewedIds.contains(_venueId) {
                self._logoBgView.addGradientBorder(cornerRadius: self._logoBgView.frame.size.height/2, 4, true)
            } else {
                self._logoBgView.addGradientBorderWithColor(cornerRadius: self._logoBgView.frame.size.height/2, 4, [UIColor(named: "storyRingColor")!.cgColor, UIColor(named: "storyRingColor")!.cgColor])
            }
        }
        else {
            self._logoBgView.removeGradientBorders()
            _logoBgView.borderColor = .clear
            _logoBgView.borderWidth = 0
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
        controller.view.hero.id = _logoHeroId
        controller.view.hero.modifiers = HeroAnimationModifier.stories
        parentViewController?.present(controller, animated: true)
    }
}

extension ShoutoutVenueCollectionCell:StackTransformView {
    var stackOptions: StackTransformViewOptions {
        StackTransformViewOptions(scaleFactor: 0.10, maxStackSize: 3, spacingFactor: 0.02, popAngle: 0, popOffsetRatio: .init(width: -1.3, height: 0.0),stackPosition: CGPoint(x: 1, y: 0))
    }
}
