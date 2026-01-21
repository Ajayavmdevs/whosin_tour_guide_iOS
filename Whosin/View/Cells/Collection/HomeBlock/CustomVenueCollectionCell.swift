import UIKit
import Hero
import StripeCore

class CustomVenueCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet weak var _btnView: UIView!
    @IBOutlet weak var _mainContainerview: UIView!
    @IBOutlet private weak var _offerButtun: UIButton!
    @IBOutlet private weak var _bgImageView: UIImageView!
    @IBOutlet private weak var _venueNameLabel: UILabel!
    @IBOutlet private weak var _venueDescLabel: UILabel!
    private var _venueId: String = kEmptyString
    private var _venueDetailModel: VenueDetailModel?
    private var _heroId: String = kEmptyString
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }

    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 380 }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.3) {
            self._mainContainerview.roundCorners(corners: .allCorners, radius: 10)
            self._offerButtun.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
            
            self._btnView.cornerRadius = self._btnView.frame.size.height / 2
            
        }
    }
    
    private func _addHeroAnimation(heroId: String) {
        _heroId = heroId
        _mainContainerview.hero.id = heroId
        _mainContainerview.hero.modifiers = HeroAnimationModifier.sourceView
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: CustomVenuesModel) {
        if let venueModel = data.venueModel {
            _venueDetailModel = venueModel
            _bgImageView.loadWebImage(venueModel.cover )
            _venueId = venueModel.id
            _venueInfoView.setupData(venue: venueModel)
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self._clickToOpenVenue))
            _venueInfoView.addGestureRecognizer(gesture)
        }
        _offerButtun.isHidden =  data.badge == "0"
        _offerButtun.setTitle(data._badge)
        _venueDescLabel.text = data.subTitle
        _venueNameLabel.text = data.title
        _addHeroAnimation(heroId: data.id)
    }
    
    public func setUpOffersdata(_ data: CustomVenuesModel) {
        _offerButtun.isHidden = data.badge == "0"
        _offerButtun.setTitle(data._badge)
        let offerModel = data.offerModel
        _venueDetailModel = offerModel?.venue
        _venueInfoView.setupData(venue: offerModel?.venue ?? VenueDetailModel(), isAllowClick: true)
        _venueDescLabel.text = data.subTitle
        _venueNameLabel.text = data.title
        _bgImageView.image = nil
        _bgImageView.loadWebImage(offerModel?.image ?? "")
        _offerButtun.isHidden = false
        _addHeroAnimation(heroId: data.id)
        _venueId = offerModel?.venue?.id ?? kEmptyString
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc func _clickToOpenVenue(sender : UITapGestureRecognizer) {
    }

    @IBAction private func _handleBookEvent(_ sender: UIButton) {
    }
    
}
