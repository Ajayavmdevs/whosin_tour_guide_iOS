import UIKit

class ProfileDetailTableCell: UITableViewCell {
    
    @IBOutlet private weak var _userImage: UIImageView!
    @IBOutlet private weak var _userName: UILabel!
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _eventName: UILabel!
    @IBOutlet private weak var _followersCount: UILabel!
    @IBOutlet private weak var _followingCount: UILabel!
    @IBOutlet weak var _followStack: UIStackView!
    private var _userId: String = kEmptyString
    private var _venueId: String = kEmptyString
    private var _eventId: String = kEmptyString
    private var _type: String = kEmptyString
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
//        if !Preferences.isSubAdmin {
            let tap = UITapGestureRecognizer(target: self, action: #selector(openDetails(_:)))
            _userImage.addGestureRecognizer(tap)
            
            let tapEvent = UITapGestureRecognizer(target: self, action: #selector(openEventDetailsTap(_:)))
            _eventName.addGestureRecognizer(tapEvent)
            
            let tapUser = UITapGestureRecognizer(target: self, action: #selector(openUserDetails(_:)))
            _userName.addGestureRecognizer(tapUser)
//        }
        _venueInfoView.isHidden = true
        _eventName.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    @objc func openEventDetailsTap(_ g: UITapGestureRecognizer) -> Void {
        print("\(_type): \(_userId)")
        if _type == "event" {
            openOrganizarDetails(_userId)
        } else if _type == "outing" {
            openUserDetail(_eventId)
        }
    }

    @objc func openUserDetails(_ g: UITapGestureRecognizer) -> Void {
        print("\(_type): \(_userId)")
        if _type == "user" {
            openUserDetail(_userId)
        } else if _type == "bucket" {
            openBucketDetails(_userId)
        } else if _type == "event" {
            openEventDetails(_eventId)
        } else if _type == "outing" {
            openOutingDetails(_userId)
        }
    }

    @objc func openDetails(_ g: UITapGestureRecognizer) -> Void {
        print("\(_type): \(_userId)")
        if _type == "user" {
            openUserDetail(_userId)
        } else if _type == "bucket" {
            openBucketDetails(_userId)
        } else if _type == "event" {
            openEventDetails(_eventId)
        } else if _type == "outing" {
            openOutingDetails(_userId)
        }
    }
    
    public func setup(_ userModel: UserDetailModel) {
        _venueInfoView.isHidden = true
        _eventName.isHidden = true
        _type = "user"
        _userId = userModel.id
        _userName.text = userModel.fullName
        _userImage.loadWebImage(userModel.image, name: userModel.fullName)
        _followersCount.text = "\(userModel.follower)"
        _followingCount.text = "\(userModel.following)"
    }
    
    public func setupBucket(_ bucketModel: BucketDetailModel) {
        _venueInfoView.isHidden = true
        _eventName.isHidden = true
        _type = "bucket"
        _userId = bucketModel.id
        _userName.text = bucketModel.name
        _userImage.loadWebImage(bucketModel.coverImage, name: bucketModel.name)
    }
    
    public func setupEvent(_ model: EventModel) {
        _venueInfoView.isHidden = false
        _eventName.isHidden = false
        _type = "event"
        _userId = model.chatOrgId
        _eventId = model.id
        _userName.text = model.title
        if let venue = model.venueDetail {
            _venueInfoView.setupData(venue: venue.detached(), isAllowClick: true)
        } else {
            _venueInfoView.isHidden = true
        }

        _eventName.text = model.chatHomeOrgName
        _userImage.loadWebImage(model.image, name: model.title)
    }
    
    public func setupOuting(_ model: OutingListModel) {
        _venueInfoView.isHidden = true
        _eventName.isHidden = false
        _type = "outing"
        _userId = model.id
        _eventId = model.owner?.id ?? kEmptyString
        _eventName.text = model.chatHomeOrgName
        _userName.text = model.chatHomeEventName
        _userImage.loadWebImage(model.venue?.cover ?? kEmptyString , name: model.title )
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func openOrganizarDetails(_ orgId: String) {
        let vc = INIT_CONTROLLER_XIB(EventOrganisierVC.self)
        vc.orgId = orgId
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

    private func openVenueDetails(_ venueId: String) {
        let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        vc.venueId = venueId
        vc.venueDetailModel = Utils.getModelFromId(model: APPSETTING.venueModel, id: venueId)
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openEventDetails(_ eventId: String) {
        let vc = INIT_CONTROLLER_XIB(EventDetailVC.self)
        vc.eventId = eventId
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openOutingDetails(_ outingId: String) {
        let vc = INIT_CONTROLLER_XIB(OutingDetailVC.self)
        vc.outingId = outingId
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

    private func openBucketDetails(_ bucketId: String) {
        let vc = INIT_CONTROLLER_XIB(BucketDetailVC.self)
        vc.bucketId = bucketId
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

    private func openUserDetail(_ userId: String) {
        guard let userDetail = APPSESSION.userDetail else { return }
        if userId != userDetail.id {
            let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
            vc.contactId = userId
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleFollowersEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(FollowListVC.self)
        vc.isFollowerList = true
        vc.followId = _userId
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func _handleFollowingEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(FollowListVC.self)
        vc.isFollowerList = false
        vc.followId = _userId
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
