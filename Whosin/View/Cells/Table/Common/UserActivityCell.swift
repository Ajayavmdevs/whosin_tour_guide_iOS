import UIKit
import StripeCore

class UserActivityCell: UITableViewCell {

    @IBOutlet weak var _userImage: UIImageView!
    @IBOutlet weak var _musics: UILabel!
    @IBOutlet weak var _cuisine: UILabel!
    @IBOutlet weak var _features: UILabel!
    @IBOutlet weak var _description: UILabel!
    @IBOutlet weak var _coverImage: UIImageView!
    @IBOutlet weak var _customVenueInfo: CustomVenueInfoView!
    @IBOutlet weak var _timeLabel: UILabel!
    @IBOutlet weak var _activityTitle: UILabel!
    @IBOutlet weak var _followBtn: UIButton!
    @IBOutlet weak var _topButton: UIButton!
    private var _venueId: String = kEmptyString
    private var _logoHeroId: String = kEmptyString
    private var _venueModel: VenueDetailModel?
    private var _id: String = kEmptyString
    var musicTitle: [String] = []
    var featuresTitle: [String] = []
    var cuisineTitle: [String] = []

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
    // MARK: Service
    // --------------------------------------
    
    private func _requestFollowUnfollow() {
        parentBaseController?.showHUD(self)
        guard let _venue = _venueModel else { return }
        WhosinServices.venueFollows(id: _venue.id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(self, error: error)
            _venue.isFollowing = !_venue.isFollowing
            self._followBtn.setTitle( _venue.isFollowing ? "following".localized() : "follow".localized() )
            self.parentBaseController?.showSuccessMessage(_venue.isFollowing ? "thank_you".localized() : "oh_snap".localized(), subtitle: _venue.isFollowing ? LANGMANAGER.localizedString(forKey: "follow_venue", arguments: ["value": _venue.name]) : LANGMANAGER.localizedString(forKey: "unfollow_venue", arguments: ["value": _venue.name]))
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _followUnfollowToggle() {
        guard let isFollowing = self._venueModel?.isFollowing else { return }
        _followBtn.setTitle(isFollowing ? "following".localized() : "follow".localized() )
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: UserFeedModel, isRecommended: Bool = false, user: UserDetailModel? = nil, isOtherProfile: Bool = false) {
        
        _topButton.isEnabled = isOtherProfile ? false : true
        
        let checkedInText = isRecommended ? "recommended".localized() : "followed".localized()
        let attributedText = NSMutableAttributedString(string: isRecommended ? user?.fullName ?? kEmptyString : data.user?.fullName ?? kEmptyString)
        let boldFont = FontBrand.SFboldFont(size: 14, isItalic: true)
        attributedText.append(NSAttributedString(string: checkedInText, attributes: [NSAttributedString.Key.font: boldFont]))
        _activityTitle.attributedText = attributedText
        _userImage.loadWebImage(isRecommended ? user?.image ?? kEmptyString : data.user?.image ?? kEmptyString, name: isRecommended ? user?.firstName ?? kEmptyString : data.user?.fullName ?? kEmptyString)
        _id = data.user?.id ?? kEmptyString
        let time = Utils.stringToDate(data.createdAt, format: kStanderdDate)
        _timeLabel.text = time?.timeAgoSince
        _customVenueInfo.setupData(venue: data.venue ?? VenueDetailModel(), isAllowClick: true)
        _coverImage.loadWebImage(data.venue?.cover ?? kEmptyString)
        _description.attributedText = Utils.setAtributedTitleText(title: "dress_code".localized(), subtitle: data.venue?.dressCode ?? kEmptyString, titleFont: FontBrand.SFmediumFont(size: 12.0), subtitleFont: FontBrand.SFregularFont(size: 12.0))
        _description.isHidden = data.venue?.dressCode.isEmpty == true || data.venue?.dressCode == "undefined"
        //TODO : Need to fix
        musicTitle.removeAll()
        let musicIds = data.venue?.music.toArray(ofType: String.self) ?? []
        if let musics = Utils.getModelsFromIds(model: APPSETTING.music, ids: musicIds) {
            musics.forEach({ music in
                musicTitle.append(music.title)
            })
        }
        
        if musicTitle.isEmpty && !musicIds.isEmpty {
            musicTitle.append(contentsOf: musicIds)
        }
        
        featuresTitle.removeAll()
        let featureIds = data.venue?.feature.toArray(ofType: String.self) ?? []
        let features = Utils.getModelsFromIds(model: APPSETTING.feature, ids: featureIds)
        features?.forEach({ feature in
            featuresTitle.append(feature.title)
        })
        
        if featuresTitle.isEmpty && !featureIds.isEmpty {
            featuresTitle.append(contentsOf: featureIds)
        }
        
        cuisineTitle.removeAll()
        let cuisineIds = data.venue?.cuisine.toArray(ofType: String.self) ?? []
        let cuisines =  Utils.getModelsFromIds(model: APPSETTING.cuisine, ids: cuisineIds)
        cuisines?.forEach({ cuisine in
            cuisineTitle.append(cuisine.title)
        })
        if cuisineTitle.isEmpty && !cuisineIds.isEmpty {
            cuisineTitle.append(contentsOf: cuisineIds)
        }
        
        if !musicTitle.isEmpty {
            _musics.isHidden = false
            _musics.attributedText = Utils.setAtributedTitleText(title: "music".localized(), subtitle: musicTitle.joined(separator: ", "), titleFont: FontBrand.SFmediumFont(size: 12.0), subtitleFont: FontBrand.SFregularFont(size: 12.0))
        } else { _musics.isHidden = true }
        if !cuisineTitle.isEmpty {
            _cuisine.isHidden = false
            _cuisine.attributedText = Utils.setAtributedTitleText(title: "cuisine".localized(), subtitle: cuisineTitle.joined(separator: ", "), titleFont: FontBrand.SFmediumFont(size: 12.0), subtitleFont: FontBrand.SFregularFont(size: 12.0))
        } else { _cuisine.isHidden = true }
        if !featuresTitle.isEmpty {
            _features.isHidden = false
            _features.attributedText = Utils.setAtributedTitleText(title: "features".localized(), subtitle: featuresTitle.joined(separator: ", "), titleFont: FontBrand.SFmediumFont(size: 12.0), subtitleFont: FontBrand.SFregularFont(size: 12.0))
        } else { _features.isHidden = true }
        
        _venueModel = data.venue
        _venueId = data.venue?.id ?? kEmptyString
        print("feed follow state ============ \(data.venue?.isFollowing)")
        _followUnfollowToggle()
        
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func _handleFollowEvent(_ sender: UIButton) {
        _requestFollowUnfollow()
    }

    @IBAction private func _handleTopButtonEvent(_ sender: UIButton) {
    }
    
}
