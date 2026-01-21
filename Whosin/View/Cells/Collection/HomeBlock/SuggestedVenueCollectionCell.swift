import UIKit

class SuggestedVenueCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _mainView: UIView!
    @IBOutlet weak var _venueImage: UIImageView!
    @IBOutlet weak var _nameLabel: UILabel!
    @IBOutlet weak var _distance: UILabel!
    @IBOutlet weak var _followBtn: CustomActivityButton!
    private var venueDetailModel: VenueDetailModel?
    public var closeVenueCallBack: ((_ id: String) -> Void)?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 170 }

    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: VenueDetailModel) {
        _venueImage.loadWebImage(model.logo, name: model.name)
        _nameLabel.text = model.name
        _distance.text = String(format: "%.2f km", model.distance)
        btnStateChange(model.isFollowing)
        venueDetailModel =  model
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _requestFollowUnfollow() {
        _followBtn.setTitle(kEmptyString)
        _followBtn.showActivity()
        guard let _venue = venueDetailModel else { return }
        WhosinServices.venueFollows(id: _venue.id) { [weak self] container, error in
            guard let self = self else { return }
            self._followBtn.hideActivity()
            _venue.isFollowing = !_venue.isFollowing
            btnStateChange(_venue.isFollowing)
            NotificationCenter.default.post(name: .changeVenueFollowState, object: nil)
            self.parentBaseController?.showSuccessMessage(_venue.isFollowing ? "thank_you".localized() : "oh_snap".localized(), subtitle: _venue.isFollowing ? LANGMANAGER.localizedString(forKey: "follow_venue", arguments: ["value": _venue.name]) : LANGMANAGER.localizedString(forKey: "unfollow_venue", arguments: ["value": _venue.name]))
        }
    }
    
    private func _requestRemove(_ id: String) {
        WhosinServices.removeSuggested(type: "venue", typeId: id) { [weak self] container, error in
            guard let self = self else { return }
        }
    }
    
    private func btnStateChange(_ isFollow: Bool) {
        _followBtn.setTitle(isFollow ? "following".localized() : "follow".localized())
        _followBtn.backgroundColor = isFollow ? .clear : ColorBrand.brandPink
        _followBtn.borderColor = .white
        _followBtn.borderWidth = isFollow ? 1 : 0
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleFollowEvent(_ sender: CustomActivityButton) {
        _requestFollowUnfollow()
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        guard let id = venueDetailModel?.id else { return }
        _requestRemove(id)
        closeVenueCallBack?(id)
    }
}
