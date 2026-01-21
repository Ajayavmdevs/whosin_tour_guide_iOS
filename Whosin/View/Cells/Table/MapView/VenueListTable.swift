import UIKit

class VenueListTable: UITableViewCell {

    @IBOutlet private weak var _customGallaryView: CustomGallaryView!
    @IBOutlet private weak var _addressLabel: UILabel!
    @IBOutlet private weak var _nameLabel: UILabel!
    @IBOutlet private weak var _locationLabel: UILabel!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _imageBgView: UIView!
    private var _venueId: String = kEmptyString
    private var _logoHeroId: String = kEmptyString
    @IBOutlet weak var _button: UIButton!
    
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
        disableSelectEffect()
        self._imageBgView.layer.cornerRadius = self._imageBgView.frame.size.height / 2
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self._imageBgTap))
        self._imageBgView.addGestureRecognizer(gesture)
        self._customGallaryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self._customGallaryView.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setUpdata(_ data: VenueDetailModel, isSelected: Bool) {
        _button.setImage( isSelected ? UIImage(named: "icon_radio_selected"): UIImage(named: "icon_radio"))
        _imageView.loadWebImage(data.slogo)
        _customGallaryView.isHidden = data.galleries.isEmpty
        _customGallaryView.setupHeader(data.galleries, isPreview: false)
        _venueId = data.id
        _nameLabel.text = data.name
        _locationLabel.text = String(format: "%.2f", data.distance ) + " km away"
        _addressLabel.text = data.address
        
        _showStoryRing()
        _logoHeroId = _venueId + data.id + "_story_"
        _imageBgView.hero.id = _venueId + data.id + "_story_"
        _imageBgView.hero.modifiers = HeroAnimationModifier.stories
        
    }
    
    public func setOffersUpdata(_ data: OffersModel, isSelected: Bool) {
        _customGallaryView.isHidden = true
        _button.setImage( isSelected ? UIImage(named: "icon_radio_selected"): UIImage(named: "icon_radio"))
        _imageView.loadWebImage(data.image)
        _venueId = data.venueId
        _nameLabel.text = data.title
        _addressLabel.text = data.descriptions
        
        _showStoryRing()
        _logoHeroId = _venueId + data.id + "_story_"
        _imageBgView.hero.id = _venueId + data.id + "_story_"
        _imageBgView.hero.modifiers = HeroAnimationModifier.stories
    }
    
    private func _showStoryRing() {
        _imageBgView.setupStoryRing(id: _venueId)
    }
    
    @IBAction private func _handleViewEvent(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
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
