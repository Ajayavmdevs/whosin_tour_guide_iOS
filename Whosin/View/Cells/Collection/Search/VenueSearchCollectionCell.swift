import UIKit

class VenueSearchCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _venueAddress: UILabel!
    @IBOutlet private weak var _cuisinesText: UILabel!
    @IBOutlet private weak var _followLabel: UILabel!
    @IBOutlet private weak var _locationLabel: UILabel!
    @IBOutlet weak var _venueLocationStack: UIStackView!
    private var _venueDetailModel: VenueDetailModel?
    private var _logoHeroId: String = kEmptyString

    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        175
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: VenueDetailModel) {
        _venueDetailModel = data
        _venueInfoView.setupData(venue: data)
        _coverImage.loadWebImage(data.cover)
        _cuisinesText.text = data.cuisine.joined(separator: ", ")
        _followLabel.text = data.isFollowing ? "following".localized() : "follow".localized()
        if data.distance == 0.0 || data.distance.isZero {
            _venueLocationStack.isHidden = true
        } else {
            _venueLocationStack.isHidden = false
            _locationLabel.text = String(format: "%.1f", data.distance) + " km"
        }
    }
        
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestFollowUnfollow() {
        parentBaseController?.showHUD()
        guard let _venue = _venueDetailModel else { return }
        WhosinServices.venueFollows(id: _venue.id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD()
            _venue.isFollowing = !_venue.isFollowing
            self._followLabel.text = _venue.isFollowing ? "following".localized() : "follow".localized()
            self.parentBaseController?.showSuccessMessage(_venue.isFollowing ?  "thank_you".localized() : "oh_snap".localized(), subtitle: _venue.isFollowing ? LANGMANAGER.localizedString(forKey: "following_toast", arguments: ["value": _venue.name]) : LANGMANAGER.localizedString(forKey: "unfollow_toast", arguments: ["value": _venue.name]))
            
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleFollowUnfollowEvent(_ sender: UIButton) {
        _requestFollowUnfollow()
    }
    
    
    @IBAction func _handleBookEvent(_ sender: UIButton) {
    }
    
}
