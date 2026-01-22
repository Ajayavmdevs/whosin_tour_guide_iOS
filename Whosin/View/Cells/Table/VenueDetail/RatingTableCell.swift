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
    private var isPublic:Bool = false
    private var _ratings: [RatingModel] = []
    private var _venueModel: VenueDetailModel?
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
    
    public func setupRattings(_ model: RatingListModel,id: String = kEmptyString) {
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
    
    public func setupPublicRattings(_ model: RatingListModel,user: UserDetailModel?) {
        _typeId = user?.userId ?? kEmptyString
        _userModel = user
        ratingsListModel = model
        self.isPublic = true
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
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: review.ratingId,
                        kCellObjectDataKey: review,
                        kCellClassKey: RatingViewCollectionCell.self,
                        kCellHeightKey: RatingViewCollectionCell.height
                    ])
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
        vc._venueId = _venueId
        vc.stars = _ratingView.rating
        vc.reviewText = review
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
    @IBAction func _handleSeeAllReviewEvent(_ sender: UIButton) {
        parentBaseController?.checkSession()
        let vc = INIT_CONTROLLER_XIB(SeeAllReviewVC.self)
        vc.modalPresentationStyle = .overFullScreen
            vc.myRatingStar = _venueModel?.currentUserRating?.stars ?? 0.0
            vc.myReview = _venueModel?.currentUserRating?.review ?? kEmptyString
            vc.ratingId = _venueId
            vc.ratingType = RatingType.venue.rawValue
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
}

extension RatingTableCell: FloatRatingViewDelegate {
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        delegate?.desableScrollEffect()
            _ratingSubmit(id: _venueId, type: RatingType.venue.rawValue, star: "\(Int(rating))")
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
                cell.setupRatingData(object, userModel: _venueModel?.users.toArrayDetached(ofType: UserModel.self) ?? [])
        }
        
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? RatingModel else { return }
        let vc = INIT_CONTROLLER_XIB(ReviewDetailScreen.self)
        vc.model = object
        vc.userList = _venueModel?.users.toArrayDetached(ofType: UserModel.self) ?? []
        parentBaseController?.presentAsPanModal(controller: vc)

    }
}

extension RatingTableCell: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}
