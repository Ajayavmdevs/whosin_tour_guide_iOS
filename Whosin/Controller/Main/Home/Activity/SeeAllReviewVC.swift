import UIKit
import FloatRatingView
import LinearProgressBar

class SeeAllReviewVC: PanBaseViewController {
    
    @IBOutlet weak var _publicReviewStack: UIStackView!
    @IBOutlet weak var _ratingsStack: UIStackView!
    @IBOutlet private weak var _writeReviewBtn: UIButton!
    @IBOutlet private weak var _ratingView: FloatRatingView!
    @IBOutlet private weak var _fiveStarLinebar: LinearProgressBar!
    @IBOutlet private weak var _fourStarLinebar: LinearProgressBar!
    @IBOutlet private weak var _threeStarLinebar: LinearProgressBar!
    @IBOutlet private weak var _twoStarLinebar: LinearProgressBar!
    @IBOutlet private weak var _oneStarLinebar: LinearProgressBar!
    @IBOutlet private weak var _starRatingLabel: UILabel!
    @IBOutlet private weak var _allRatingsLabel: UILabel!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet weak var _summeryView: UIView!
    @IBOutlet weak var _ratting5Star: FloatRatingView!
    @IBOutlet weak var _ratting4Star: FloatRatingView!
    @IBOutlet weak var _ratting3Star: FloatRatingView!
    @IBOutlet weak var _ratting2Star: FloatRatingView!
    @IBOutlet weak var _ratting1Star: FloatRatingView!
    @IBOutlet weak var _line5StarView: LinearProgressBar!
    @IBOutlet weak var _line4StarView: LinearProgressBar!
    @IBOutlet weak var _line3StarView: LinearProgressBar!
    @IBOutlet weak var _line2StarView: LinearProgressBar!
    @IBOutlet weak var _line1StarView: LinearProgressBar!
    @IBOutlet weak var _writeReviewView: GradientView!
    
    var ticketModel: TicketModel? = nil
    var ratingId: String = kEmptyString
    var ratingType: String = kEmptyString
    var isFromActivity: Bool = false
    var isFromEvent: Bool = false
    var isFromYach: Bool = false
    var isFromPromoter: Bool = false
    var isFromComplementry: Bool = false
    var isFromTicket: Bool = false
    var isPublic: Bool = false
    var isRayna: Bool = false
    private var review: String = kEmptyString
    var myRatingStar: Double = 0.0
    var myReview: String = kEmptyString
    private let kCellIdentifier = String(describing: RatingViewCollectionCell.self)
    private let kLoadingCellIdentifier = String(describing: LoadingCollectionCell.self)
    private var _ratingSummary: RatingSummaryModel?
    private var _allRatingList: RatingListModel?
    public var currentUser: UserDetailModel?
    private var _page : Int = 1
    private var isPaginating = false
    private var isChanged: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _requestRatingSummary()
        setupUi()
    }
    
    override func setupUi() {
        showNavigationBar()
        if isFromYach {
            _ratting1Star.tintColor = ColorBrand.brandDarkSky
            _ratting2Star.tintColor = ColorBrand.brandDarkSky
            _ratting3Star.tintColor = ColorBrand.brandDarkSky
            _ratting4Star.tintColor = ColorBrand.brandDarkSky
            _ratting5Star.tintColor = ColorBrand.brandDarkSky
            _line1StarView.barColor = ColorBrand.brandDarkSky
            _line2StarView.barColor = ColorBrand.brandDarkSky
            _line3StarView.barColor = ColorBrand.brandDarkSky
            _line4StarView.barColor = ColorBrand.brandDarkSky
            _line5StarView.barColor = ColorBrand.brandDarkSky
            _line1StarView.borderColor = ColorBrand.brandDarkSky
            _line2StarView.borderColor = ColorBrand.brandDarkSky
            _line3StarView.borderColor = ColorBrand.brandDarkSky
            _line4StarView.borderColor = ColorBrand.brandDarkSky
            _line5StarView.borderColor = ColorBrand.brandDarkSky
            _writeReviewView.startColor = ColorBrand.brandDarkSky
            _writeReviewView.endColor = ColorBrand.brandDarkSky
            _ratingView.tintColor = ColorBrand.brandDarkSky
        }
        _ratingView.delegate = self
        let margin = kCollectionDefaultMargin
        let spacing = kCollectionDefaultSpacing
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: .zero, left: margin, bottom: .zero, right: margin),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .vertical,
                              isDummyLoad: false,
                              emptyDataText: "there_is_no_review_available".localized(),
                              emptyDataIconImage: UIImage(named: "empty_bucketChat"),
                              delegate: self)
        _collectionView.contentInset = .zero
        _collectionView.proxyDelegate = self
        if (isFromPromoter || isFromComplementry), !isPublic {
            _publicReviewStack.isHidden = true
        } else {
            _publicReviewStack.isHidden = false
        }
        if isFromPromoter || isFromComplementry {
            self.view.backgroundColor = UIColor(hexString: "#18171D")
        }
        _ratingListAll()
        _loadData(true)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReload), name: kRelaodActivitInfo, object: nil)
        if ticketModel != nil {
            _writeReviewView.isHidden = ticketModel?.isEnableReview == false
            _ratingView.isUserInteractionEnabled = ticketModel?.isEnableRating == true
        }
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    
    private func _requestRatingSummary() {
        WhosinServices.ratingReviewSummary(id: ratingId) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self._ratingSummary = data
            self._updateRating()
        }
    }
    
    private func _ratingListAll() {
        WhosinServices.getRatingList(id: ratingId, type: ratingType, page: _page, limit: 30) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self._allRatingList = data
            self._loadData(false)
            self.isPaginating = false
        }
    }
    
    private func _ratingSubmit(id: String, type: String, star: String, review: String = kEmptyString) {
        WhosinServices.ratingSubmit(id: id, type: type, stars: star, review: review, status: kEmptyString) { [weak self] container, error in
            guard let self = self else { return }
            if let message = container?.message { self.showToast(message) }
            self.isChanged = true
        }
    }
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifier,
                kCellTagKey: kLoadingCellIdentifier,
                kCellObjectDataKey: "Loading....",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            if let allRatings = _allRatingList?.review {
                let currentUserId = Preferences.userId
                var otherRatings: [RatingModel] = []
                var currentUserRating: RatingModel?

                allRatings.forEach { rating in
                    if Preferences.blockedUsers.contains(rating.userId) { return }
                    
                    if rating.userId == currentUserId {
                        currentUserRating = rating
                    } else {
                        otherRatings.append(rating)
                    }
                }

                let orderedRatings = (currentUserRating != nil) ? [currentUserRating!] + otherRatings : otherRatings

                orderedRatings.forEach { rating in
                    if isRayna {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifier,
                            kCellTagKey: rating.ratingId,
                            kCellObjectDataKey: rating,
                            kCellClassKey: RatingViewCollectionCell.self,
                            kCellHeightKey: RatingViewCollectionCell.height
                        ])
                    } else {
                        let users = _allRatingList?.user.toArrayDetached(ofType: UserModel.self) ?? []
                        let user = Utils.getUserFromId(userModels: users, userId: rating.userId)
                        if user != nil {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifier,
                                kCellTagKey: rating.ratingId,
                                kCellObjectDataKey: rating,
                                kCellClassKey: RatingViewCollectionCell.self,
                                kCellHeightKey: RatingViewCollectionCell.height
                            ])
                        }
                    }
                }
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: RatingViewCollectionCell.self), kCellClassKey: RatingViewCollectionCell.self, kCellHeightKey: RatingViewCollectionCell.height],
                 [kCellIdentifierKey: kLoadingCellIdentifier, kCellNibNameKey: kLoadingCellIdentifier, kCellClassKey:  LoadingCollectionCell.self, kCellHeightKey: LoadingCollectionCell.height]]
    }
    
    private func _updateRating() {
        if let ratingString = _ratingSummary?.avgRating,
           let ratingDouble = Double(ratingString) {
            let formattedRating = String(format: "%.1f", ratingDouble)
            _starRatingLabel.text = formattedRating // Output: "3.7"
        } else {
            _starRatingLabel.text = _ratingSummary?.avgRating
        }
        _allRatingsLabel.text = "\(_ratingSummary?.totalRating ?? 0) Ratings"
        _ratingView.rating = myRatingStar
        review = myReview
        if Utils.stringIsNullOrEmpty(myReview) {
            _writeReviewBtn.setTitle("write_review".localized())
        } else {
            _writeReviewBtn.setTitle("edit_review".localized())
        }

        guard let ratingSummary = _ratingSummary?.summary else { return }
        let starPercentages = [ratingSummary.one?.percentage, ratingSummary.two?.percentage, ratingSummary.three?.percentage, ratingSummary.four?.percentage, ratingSummary.five?.percentage]
        let lineBars = [_oneStarLinebar, _twoStarLinebar, _threeStarLinebar, _fourStarLinebar, _fiveStarLinebar]
        for (index, percentage) in starPercentages.enumerated() {
            guard let trimmedPercentage = percentage?.replacingOccurrences(of: "%", with: ""),
                  let doubleValue = Double(trimmedPercentage) else {
                return
            }
            lineBars[index]?.progressValue = doubleValue
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleWriteReviewEvent(_ sender: UIButton) {
        if Preferences.isGuest {
            alert(message: "login_required_for_review".localized(), okActionTitle: "cancel".localized(), cancelActionTitle: "login",okHandler: { alert in
                self.dismiss(animated: true)
            }) { alert in
                let vc = INIT_CONTROLLER_XIB(LoginVC.self)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = INIT_CONTROLLER_XIB(WriteReviewBottomSheet.self)
            if isFromActivity {
                vc._activityId = ratingId
                vc.isFromActivity = true
                vc.stars = _ratingView.rating
                vc.reviewText = review
            } else if isFromEvent {
                vc._eventOrgId = ratingId
                vc.isFromEvent = true
                vc.stars = _ratingView.rating
                vc.reviewText = review
            }  else if isFromYach {
                vc._yachtId = ratingId
                vc.isFromYacht = true
                vc.stars = _ratingView.rating
                vc.reviewText = review
            } else if isFromPromoter {
                vc.isFromPromoter = isFromPromoter
                vc._typeId = ratingId
                vc.stars = _ratingView.rating
                vc.reviewText = review
            } else if isFromComplementry {
                vc.isFromComplimentry = isFromComplementry
                vc._typeId = ratingId
                vc.stars = _ratingView.rating
                vc.reviewText = review
            } else if isFromTicket {
                vc._ticketId = ratingId
                vc.stars = _ratingView.rating
                vc.reviewText = review
            } else {
                vc._venueId = ratingId
                vc.stars = _ratingView.rating
                vc.reviewText = review
            }
            vc.delegate = self
            presentAsPanModal(controller: vc)
        }
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true) {
            if self.isChanged { NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil) }
        }
    }
    
    @objc func handleReload() {
        _requestRatingSummary()
        _ratingListAll()
    }
    
}

extension SeeAllReviewVC: FloatRatingViewDelegate {
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        myRatingStar = rating
        if isFromActivity {
            _ratingSubmit(id: ratingId, type: RatingType.activity.rawValue, star: "\(myRatingStar)", review: review)
        } else if isFromEvent {
            _ratingSubmit(id: ratingId, type: RatingType.eventsOrganizers.rawValue, star: "\(myRatingStar)", review: review)
        } else if isFromYach {
            _ratingSubmit(id: ratingId, type: RatingType.yachts.rawValue, star: "\(myRatingStar)", review: review)
        } else if isFromPromoter {
            _ratingSubmit(id: ratingId, type: RatingType.promoter.rawValue, star: "\(myRatingStar)", review: review)
        }  else if isFromComplementry {
            _ratingSubmit(id: ratingId, type: RatingType.complimentary.rawValue, star: "\(myRatingStar)", review: review)
        } else if isFromTicket {
            _ratingSubmit(id: ratingId, type: RatingType.ticket.rawValue, star: "\(myRatingStar)", review: review)
        } else {
            _ratingSubmit(id: ratingId, type: RatingType.venue.rawValue, star: "\(myRatingStar)", review: review)
        }
        NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
    }
}

extension SeeAllReviewVC: CustomCollectionViewDelegate, UICollectionViewDelegate, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height * 0.8
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isPaginating {
            performPagination()
        }
    }
    
    
    // --------------------------------------
    // MARK: <CustomCollectionViewDelegate>
    // --------------------------------------
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        guard let object = cellDict?[kCellObjectDataKey] as? RatingModel else { return CGSize(width: _collectionView.cellSize.width, height: RatingViewCollectionCell.height)}
        return CGSize(width: _collectionView.cellSize.width, height: RatingViewCollectionCell.height(text: object.review))
    }
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? RatingViewCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? RatingModel else { return }
            if isFromPromoter || isFromComplementry {
                cell.user = currentUser
                cell.setupRatingProfileData(object, userModel: _allRatingList?.user.toArrayDetached(ofType: UserModel.self) ?? [], isPublic: isPublic)
            } else {
                cell.setupRatingData(object, userModel: _allRatingList?.user.toArrayDetached(ofType: UserModel.self) ?? [], isFromYach: isFromYach, isFromTicket: isFromTicket)
            }
        } else if let cell = cell as? LoadingCollectionCell {
            cell.setupUi()
        }
    }
    
    private func performPagination() {
        guard !isPaginating else { return }
        isPaginating = true
        _page += 1
        _ratingListAll()
    }
}

extension SeeAllReviewVC: WriteReviewBottomSheetDelegate {
    func didUpdateRating(_ rating: Double, _ review: String) {
        myRatingStar = rating
        myReview = review
    }
}
