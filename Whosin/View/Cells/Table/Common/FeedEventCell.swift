import UIKit

class FeedEventCell: UITableViewCell {
    
    @IBOutlet weak var _iconEvent: UIImageView!
    @IBOutlet weak var _feedTitle: UILabel!
    @IBOutlet weak var _feedTime: UILabel!
    @IBOutlet weak var _followBtn: UIButton!
    @IBOutlet weak var _eventImage: UIImageView!
    @IBOutlet weak var _eventOrgImg: UIImageView!
    @IBOutlet weak var _eventOrgName: UILabel!
    @IBOutlet weak var _eventOrgSubtitle: UILabel!
    @IBOutlet weak var _venueLogo: UIImageView!
    @IBOutlet weak var _venueAddress: UILabel!
    @IBOutlet weak var _venueName: UILabel!
    @IBOutlet weak var _eventDate: UILabel!
    @IBOutlet weak var _eventTime: UILabel!
    @IBOutlet weak var _eventName: UILabel!
    @IBOutlet weak var _eventDesc: UILabel!
    @IBOutlet weak var _topButton: UIButton!
    private var _venueModel: VenueDetailModel?
    private var _logoHeroId: String = kEmptyString
    private var _id: String = kEmptyString
    
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestFollowUnfollow() {
        parentBaseController?.showHUD(self)
        guard let _venue = _venueModel else { return }
        WhosinServices.venueFollows(id: _venue.id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(self, error: error)
            _venue.isFollowing = !_venue.isFollowing
            self._followBtn.setTitle(_venue.isFollowing ? "following".localized() : "follow".localized())
            self.parentBaseController?.showSuccessMessage(_venue.isFollowing ? "thank_you".localized() : "oh_snap".localized(), subtitle: _venue.isFollowing ? LANGMANAGER.localizedString(forKey: "follow_venue", arguments: ["value": _venue.name]) : LANGMANAGER.localizedString(forKey: "unfollow_venue", arguments: ["value": _venue.name]))
        }
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: UserFeedModel, user: UserDetailModel? = nil, isOtherProfile: Bool = false) {
        
        _topButton.isEnabled = isOtherProfile ? false : true
        
        let checkedInText = "checked_in".localized()
        let attributedText = NSMutableAttributedString(string: "\(isOtherProfile ? user?.fullName ?? kEmptyString : data.user?.fullName ?? kEmptyString)")
        let boldFont = FontBrand.SFboldFont(size: 14, isItalic: true)
        attributedText.append(NSAttributedString(string: checkedInText, attributes: [NSAttributedString.Key.font: boldFont]))

        _feedTitle.attributedText = attributedText
        _id = data.user?.id ?? kEmptyString
        
        _iconEvent.loadWebImage(isOtherProfile ? user?.image ?? kEmptyString : data.user?.image ?? kEmptyString, name: isOtherProfile ? user?.fullName ?? kEmptyString : data.user?.fullName ?? kEmptyString)
        let time = Utils.stringToDate(data.createdAt, format: kStanderdDate)
        _feedTime.text = time?.timeAgoSince
        _venueModel = data.venue
        _followUnfollowToggle()
        if data.event?.eventOrg.first?.logo.isEmpty ?? true && data.event?.eventOrg.first?.name.isEmpty ?? true {
            _eventOrgImg.image = nil
        } else {
            _eventOrgImg.loadWebImage(data.event?.eventOrg.first?.logo ?? kEmptyString, name: data.event?.eventOrg.first?.name ?? kEmptyString)
        }
        _eventOrgName.text = data.event?.eventOrg.first?.name
        _eventOrgSubtitle.text = data.event?.eventOrg.first?.website
        _eventName.text = data.event?.title ?? kEmptyString
        _eventDesc.text = data.event?.descriptions ?? kEmptyString
        _eventImage.loadWebImage(data.event?.image ?? kEmptyString)
        
        if Utils.stringIsNullOrEmpty(data.event?.venueDetail?.logo) && Utils.stringIsNullOrEmpty(data.event?.venueDetail?.name) {
            _venueLogo.image = nil
        } else {
            _venueLogo.loadWebImage(data.event?.venueDetail?.logo ?? kEmptyString)
        }
        _venueName.text = data.event?.venueDetail?.name
        _venueAddress.text = data.event?.venueDetail?.address
        _eventTime.text = data.event?.eventTimeSlot
        _eventDate.text = data.event?._eventDate
    }
    
    private func _followUnfollowToggle() {
        guard let isFollowing = self._venueModel?.isFollowing else { return }
        _followBtn.setTitle( isFollowing ? "following".localized() : "follow".localized())
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func _handleFollowEvent(_ sender: UIButton) {
        _requestFollowUnfollow()
    }

    @IBAction private func _handleTopButtonEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
        vc.contactId = _id
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

}
