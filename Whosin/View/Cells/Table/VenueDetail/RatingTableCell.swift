import UIKit
import LinearProgressBar
import FloatRatingView

protocol desableScrollWhenRatingDelegate: AnyObject {
    func desableScrollEffect()
    func enableScrollEffect()
}


class RatingTableCell: UITableViewCell {
    
    @IBOutlet weak var _cellTitle: UILabel!
    @IBOutlet private weak var _writeReviewBtn: UIButton!
    @IBOutlet private weak var _ratingStack: UIStackView!
    @IBOutlet private weak var _ratingView: FloatRatingView!
    @IBOutlet private weak var _reviewStackView: UIStackView!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _avgRatingLabel: UILabel!
    @IBOutlet private weak var _avgRatingView: UIView!
    @IBOutlet weak var _seeAllBtn: UIButton!
    @IBOutlet weak var _writeReviewView: GradientView!
    @IBOutlet weak var _starImage: UIImageView!
    
    private var  _venueId: String = kEmptyString
    private var _activityId: String = kEmptyString
    private var _eventOrgId: String = kEmptyString
    private var _yachId: String = kEmptyString
    private var _userId: String = kEmptyString
    private var _typeId: String = kEmptyString
    private var isFromActivity: Bool = false
    private var isFromEvent: Bool = false
    private var isFromPromoter: Bool = false
    private var isFromComlimentry: Bool = false
    private var isFromYach: Bool = false
    private var isPublic:Bool = false
    private var _ratings: [RatingModel] = []
    private var _venueModel: VenueDetailModel?
    private var _activityModel: ActivitiesModel?
    private var _eventOrganizerModel: OrganizaitionDetailModel?
    private var _yachClubModel: YachtClubModel?
    private let kCellIdentifier = String(describing: RatingViewCollectionCell.self)
    private var review: String = kEmptyString
    private var ratingsListModel: RatingListModel?
    private var _userModel: UserDetailModel?
    public var delegate: desableScrollWhenRatingDelegate?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        parentBaseController?.checkSession()
        _setupUi()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func _setupUi() {
        disableSelectEffect()
        _ratingView.delegate = self
        
        let spacing = 0
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: .zero, left: 0, bottom: .zero, right: 0),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    func setupData(_ model: VenueDetailModel) {
        _venueId = model.id
        _venueModel = model
        _avgRatingLabel.text = String(format: "%.1f", model.avgRatings)
        _avgRatingView.isHidden = model.avgRatings == 0.0
        _ratingView.rating = model.currentUserRating?.stars ?? 0.0
        review = model.currentUserRating?.review ?? kEmptyString
        if Utils.stringIsNullOrEmpty(model.currentUserRating?.review) {
            _writeReviewBtn.setTitle("write_review".localized())
        } else {
            _writeReviewBtn.setTitle("edit_review".localized())
        }
        _reviewStackView.isHidden = !model.isAllowReview
        _collectionView.isHidden = model.reviews.isEmpty
        _ratingStack.isHidden = !model.isAllowRatting
        _collectionView.reload()
        _loadData()
    }
    
    public func setupRattings(_ model: RatingListModel,id: String = kEmptyString, isFromPromoter: Bool = false, isFromComplementry: Bool = false) {
        self.isFromPromoter = isFromPromoter
        self.isFromComlimentry = isFromComplementry
        ratingsListModel = model
        _typeId = id
        _cellTitle.text = "rating_and_reviews".localized()
        _cellTitle.font = FontBrand.SFboldFont(size: 22)
        _avgRatingView.isHidden = true
        _ratings = model.review.toArrayDetached(ofType: RatingModel.self)
        _ratingView.rating = Double(model.avgRating)
        _ratingView.isUserInteractionEnabled = false
        _writeReviewView.isHidden = true
        _reviewStackView.isHidden = false
        _collectionView.isHidden = model.review.isEmpty
        _ratingStack.isHidden = false
        _collectionView.reload()
        _loadData()
    }
    
    public func setupPublicRattings(_ model: RatingListModel,user: UserDetailModel?, isFromPromoter: Bool = false, isFromComplementry: Bool = false) {
        _typeId = user?.userId ?? kEmptyString
        _userModel = user
        ratingsListModel = model
        self.isPublic = true
        self.isFromPromoter = isFromPromoter
        self.isFromComlimentry = isFromComplementry
        _cellTitle.text = "rating_and_reviews".localized()
        _cellTitle.font = FontBrand.SFboldFont(size: 19)
        _avgRatingView.isHidden = true
        _ratings = model.review.toArrayDetached(ofType: RatingModel.self)
        _ratingView.rating = Double(model.avgRating)
        _ratingView.isUserInteractionEnabled = false
        _writeReviewView.isHidden = false
        _reviewStackView.isHidden = false
        _ratingStack.isHidden = false
        _collectionView.isHidden = model.review.isEmpty
        _collectionView.reload()
        review = model.currentUserReview?.review ?? kEmptyString
        if Utils.stringIsNullOrEmpty(model.currentUserReview?.review) {
            _writeReviewBtn.setTitle("write_review".localized())
        } else {
            _writeReviewBtn.setTitle("edit_review".localized())
        }
        _loadData()
    }
    
    func setupActivityData(_ model: ActivitiesModel, isFromActivity: Bool = false) {
        self.isFromActivity = isFromActivity
        _activityId = model.id
        _reviewStackView.isHidden = false
        _collectionView.isHidden = model.activityRating.isEmpty
        _avgRatingLabel.text = String(format: "%.1f", model.avgRating)
        _avgRatingView.isHidden = model.avgRating == 0.0
        _ratingView.rating = model.currentUserRating?.stars ?? 0.0
        review = model.currentUserRating?.review ?? kEmptyString
        if Utils.stringIsNullOrEmpty(model.currentUserRating?.review) {
            _writeReviewBtn.setTitle("write_review".localized())
        } else {
            _writeReviewBtn.setTitle("edit_review".localized())
        }
        _collectionView.isHidden = model.activityRating.isEmpty
        _activityModel = model
        _collectionView.reload()
        _loadData()
    }
    
    func setupYachtData(_ model: YachtClubModel) {
        _starImage.tintColor = ColorBrand.brandDarkSky
        _ratingView.tintColor = ColorBrand.brandDarkSky
        _writeReviewView.startColor = ColorBrand.brandDarkSky
        _writeReviewView.endColor = ColorBrand.brandDarkSky
        _seeAllBtn.setTitleColor(ColorBrand.brandDarkSky, for: .normal)
        self.isFromYach = true
        _yachId = model.id
        _ratings = model.reviews.toArrayDetached(ofType: RatingModel.self)
        _yachClubModel = model
        _reviewStackView.isHidden = !model.isAllowReview
        _collectionView.isHidden = model.reviews.isEmpty
        _ratingStack.isHidden = !model.isAllowRating
        _collectionView.reload()
        _loadData()
    }
    
    func setupEventData(_ model: OrganizaitionDetailModel, isFromEvent: Bool = false) {
        self.isFromEvent = isFromEvent
        _eventOrgId = model.id
        _eventOrganizerModel = model
        _reviewStackView.isHidden = false
        _collectionView.isHidden = model.reviews.isEmpty
        _ratingView.rating = model.currentUserReview?.stars ?? 0.0
        review = model.currentUserReview?.review ?? kEmptyString
        if Utils.stringIsNullOrEmpty(model.currentUserReview?.review) {
            _writeReviewBtn.setTitle("write_review".localized())
        } else {
            _writeReviewBtn.setTitle("edit_review".localized())
        }
        _avgRatingLabel.text = String(format: "%.1f",model.avgRating)
        _avgRatingView.isHidden = model.avgRating == 0.0
        _loadData()
    }
    
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _ratingSubmit(id: String, type: String, star: String, review: String = kEmptyString) {
        parentBaseController?.checkSession()
        WhosinServices.ratingSubmit(id: id, type: type, stars: star, review: review, status: kEmptyString) { [weak self] container, error in
            guard let self = self else { return }
            if let message = container?.message { self.parentViewController?.showToast(message) }
            self.delegate?.enableScrollEffect()
            NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
        }
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if !(_venueModel?.reviews.isEmpty ?? true) {
            _venueModel?.reviews.forEach({ rating in
                let users = _venueModel?.users.toArrayDetached(ofType: UserModel.self) ?? []
                let user = Utils.getUserFromId(userModels: users, userId: rating.userId)
                if Preferences.blockedUsers.contains(rating.userId) { return }
                if user != nil {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: rating.ratingId,
                        kCellObjectDataKey: rating,
                        kCellClassKey: RatingViewCollectionCell.self,
                        kCellHeightKey: RatingViewCollectionCell.height
                    ])
                }
            })
        }
        
        if !(_activityModel?.activityRating.isEmpty ?? true) {
            _activityModel?.activityRating.forEach({ rating in
                let users = _activityModel?.user.toArrayDetached(ofType: UserModel.self) ?? []
                let user = Utils.getUserFromId(userModels: users, userId: rating.userId)
                if Preferences.blockedUsers.contains(rating.userId) { return }
                if user != nil {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: rating.activityId,
                        kCellObjectDataKey: rating,
                        kCellClassKey: RatingViewCollectionCell.self,
                        kCellHeightKey: RatingViewCollectionCell.height
                    ])
                }
            })
        }
        
        if !(_eventOrganizerModel?.reviews.isEmpty ?? true) {
            _eventOrganizerModel?.reviews.forEach({ rating in
                let users = _eventOrganizerModel?.users.toArrayDetached(ofType: UserModel.self) ?? []
                let user = Utils.getUserFromId(userModels: users, userId: rating.userId)
                if Preferences.blockedUsers.contains(rating.userId) { return }
                if user != nil {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: rating.eventOrgId,
                        kCellObjectDataKey: rating,
                        kCellClassKey: RatingViewCollectionCell.self,
                        kCellHeightKey: RatingViewCollectionCell.height
                    ])
                }
            })
        }
        
        if !(_yachClubModel?.reviews.isEmpty ?? true) {
            _yachClubModel?.reviews.forEach({ rating in
                //                let users = _yachClubModel?.users.toArrayDetached(ofType: UserModel.self) ?? []
                //                let user = Utils.getUserFromId(userModels: users, userId: rating.userId)
                //                if user != nil {
                if Preferences.blockedUsers.contains(rating.userId) { return }
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: rating.eventOrgId,
                    kCellObjectDataKey: rating,
                    kCellClassKey: RatingViewCollectionCell.self,
                    kCellHeightKey: RatingViewCollectionCell.height
                ])
                //                }
            })
        }
        
        if !_ratings.isEmpty {
            let currentUserId = Preferences.userId
            var currentUserReview: RatingModel?
            var otherReviews: [RatingModel] = []

            for review in _ratings {
                if Preferences.blockedUsers.contains(review.userId) { continue }

                if review.userId == currentUserId {
                    currentUserReview = review
                } else {
                    otherReviews.append(review)
                }
            }

            let orderedReviews = (currentUserReview != nil) ? [currentUserReview!] + otherReviews : otherReviews

            orderedReviews.forEach { review in
                if isFromPromoter || isFromComlimentry {
                    if ratingsListModel?.user.contains(where: { $0.id == review.userId }) == true {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifier,
                            kCellTagKey: review.ratingId,
                            kCellObjectDataKey: review,
                            kCellClassKey: RatingViewCollectionCell.self,
                            kCellHeightKey: RatingViewCollectionCell.height
                        ])
                    }
                } else {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: review.ratingId,
                        kCellObjectDataKey: review,
                        kCellClassKey: RatingViewCollectionCell.self,
                        kCellHeightKey: RatingViewCollectionCell.height
                    ])
                }
            }
        }

        
        _collectionView.isHidden = cellData.isEmpty
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: RatingViewCollectionCell.self), kCellClassKey: RatingViewCollectionCell.self, kCellHeightKey: RatingViewCollectionCell.height] ]
    }
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleWriteReviewEvent(_ sender: UIButton) {
        parentBaseController?.checkSession()
        let vc = INIT_CONTROLLER_XIB(WriteReviewBottomSheet.self)
        if isFromActivity {
            vc._activityId = _activityId
            vc.isFromActivity = true
            vc.stars = _ratingView.rating
            vc.reviewText = review
        } else if isFromEvent {
            vc.isFromEvent = true
            vc._eventOrgId = _eventOrgId
            vc.stars = _ratingView.rating
            vc.reviewText = review
        }  else if isFromYach {
            vc.isFromYacht = true
            vc._yachtId = _yachId
            vc.stars = _ratingView.rating
            vc.reviewText = review
        } else if isFromPromoter {
            vc.isFromPromoter = isFromPromoter
            vc._typeId = _typeId
            vc.stars = ratingsListModel?.currentUserReview?.stars ?? 0.0
            vc.reviewText = review
        } else if isFromComlimentry {
            vc.isFromComplimentry = isFromComlimentry
            vc._typeId = _typeId
            vc.stars = ratingsListModel?.currentUserReview?.stars ?? 0.0
            vc.reviewText = review
        } else {
            vc._venueId = _venueId
            vc.stars = _ratingView.rating
            vc.reviewText = review
        }
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
    @IBAction func _handleSeeAllReviewEvent(_ sender: UIButton) {
        parentBaseController?.checkSession()
        let vc = INIT_CONTROLLER_XIB(SeeAllReviewVC.self)
        vc.modalPresentationStyle = .overFullScreen
        if isFromActivity {
            vc.isFromActivity = true
            vc.myRatingStar = _activityModel?.currentUserRating?.stars ?? 0.0
            vc.myReview = _activityModel?.currentUserRating?.review ?? kEmptyString
            vc.ratingId = _activityId
            vc.ratingType = RatingType.activity.rawValue
        } else if isFromEvent {
            vc.isFromEvent = true
            vc.myRatingStar = _eventOrganizerModel?.currentUserReview?.stars ?? 0.0
            vc.myReview = _eventOrganizerModel?.currentUserReview?.review ?? kEmptyString
            vc.ratingId = _eventOrgId
            vc.ratingType = RatingType.eventsOrganizers.rawValue
        }  else if isFromYach {
            vc.isFromYach = true
            vc.myRatingStar =  0.0
            vc.myReview = kEmptyString
            vc.ratingId = _yachId
            vc.ratingType = RatingType.eventsOrganizers.rawValue
        } else if isFromPromoter {
            vc.isFromPromoter = true
            vc.myRatingStar =  ratingsListModel?.currentUserReview?.stars ?? 0.0
            vc.myReview = ratingsListModel?.currentUserReview?.review ?? kEmptyString
            vc.ratingId = _typeId
            vc.isPublic = isPublic
            vc.ratingType = RatingType.promoter.rawValue
            vc.currentUser = _userModel
        } else if isFromComlimentry {
            vc.isFromComplementry = true
            vc.myRatingStar =  ratingsListModel?.currentUserReview?.stars ?? 0.0
            vc.myReview = ratingsListModel?.currentUserReview?.review ?? kEmptyString
            vc.ratingId = _typeId
            vc.isPublic = isPublic
            vc.ratingType = RatingType.complimentary.rawValue
            vc.currentUser = _userModel
        } else {
            vc.myRatingStar = _venueModel?.currentUserRating?.stars ?? 0.0
            vc.myReview = _venueModel?.currentUserRating?.review ?? kEmptyString
            vc.ratingId = _venueId
            vc.ratingType = RatingType.venue.rawValue
        }
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
}

extension RatingTableCell: FloatRatingViewDelegate {
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        delegate?.desableScrollEffect()
        if isFromActivity {
            _ratingSubmit(id: _activityId, type: RatingType.activity.rawValue, star: "\(Int(rating))")
        } else if isFromEvent {
            _ratingSubmit(id: _eventOrgId, type: RatingType.eventsOrganizers.rawValue, star: "\(Int(rating))")
        } else if isFromYach {
            _ratingSubmit(id: _yachId, type: RatingType.eventsOrganizers.rawValue, star: "\(Int(rating))")
        }  else if isFromPromoter {
            _ratingSubmit(id: _yachId, type: RatingType.promoter.rawValue, star: "\(Int(rating))")
        }  else if isFromComlimentry {
            _ratingSubmit(id: _yachId, type: RatingType.complimentary.rawValue, star: "\(Int(rating))")
        } else {
            _ratingSubmit(id: _venueId, type: RatingType.venue.rawValue, star: "\(Int(rating))")
        }
        
    }
}

extension RatingTableCell: CustomCollectionViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomCollectionViewDelegate>
    // --------------------------------------
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width-2, height: RatingViewCollectionCell.height)
    }
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? RatingViewCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? RatingModel else { return }
            if isFromActivity {
                cell.setupRatingData(object, userModel: _activityModel?.user.toArrayDetached(ofType: UserModel.self) ?? [])
            } else if isFromEvent {
                cell.setupRatingData(object, userModel: _eventOrganizerModel?.users.toArrayDetached(ofType: UserModel.self) ?? [])
            } else if isFromPromoter || isFromComlimentry {
                cell.user = _userModel
                cell.setupRatingProfileData(object, userModel: ratingsListModel?.user.toArrayDetached(ofType: UserModel.self) ?? [], isPublic: isPublic)
            } else {
                cell.setupRatingData(object, userModel: _venueModel?.users.toArrayDetached(ofType: UserModel.self) ?? [])
            }
        }
        
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? RatingModel else { return }
        let vc = INIT_CONTROLLER_XIB(ReviewDetailScreen.self)
        vc.model = object
        if isFromActivity {
            vc.userList = _activityModel?.user.toArrayDetached(ofType: UserModel.self) ?? []
        } else if isFromEvent {
            vc.userList = _eventOrganizerModel?.users.toArrayDetached(ofType: UserModel.self) ?? []
        } else if isFromPromoter || isFromComlimentry {
            vc.userList = ratingsListModel?.user.toArrayDetached(ofType: UserModel.self) ?? []
        } else {
            vc.userList = _venueModel?.users.toArrayDetached(ofType: UserModel.self) ?? []
        }
        parentBaseController?.presentAsPanModal(controller: vc)

    }
}

extension RatingTableCell: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}
