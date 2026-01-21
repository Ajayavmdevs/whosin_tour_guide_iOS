import UIKit
import LinearProgressBar
import FloatRatingView

class CustomTicketRatingTableCell: UITableViewCell {
    
    @IBOutlet weak var _ratingReviewView: UIStackView!
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
    
    private let kCellIdentifier = String(describing: RatingViewCollectionCell.self)
    private var review: String = kEmptyString
    private var ratingsListModel: [TicketReviewModel] = []
    private var _userModel: [UserModel] = []
    public var delegate: desableScrollWhenRatingDelegate?
    private var ticketModel: TicketModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    
    public func setupPublicRattings(_ model: TicketModel) {
        ticketModel = model
        _userModel = model.users.toArrayDetached(ofType: UserModel.self)
        ratingsListModel = model.reviews.toArrayDetached(ofType: TicketReviewModel.self)
        _cellTitle.text = "rating_and_reviews".localized()
        _cellTitle.font = FontBrand.SFboldFont(size: 19)
        _avgRatingView.isHidden = true
        _ratingView.rating = Double(model.currentUserReview?.stars ?? 0)

        _reviewStackView.isHidden = false
        _ratingStack.isHidden = false
        _seeAllBtn.isHidden = !(model.isReviewVisible && model.reviews.count > 0)
        _collectionView.isHidden = !(model.isReviewVisible && model.reviews.count > 0)
        _ratingView.isUserInteractionEnabled = model.isEnableRating
        _ratingReviewView.isHidden = !model.isEnableReview
        _ratingView.isHidden = !model.isEnableRating
        _collectionView.reload()
        review = model.currentUserReview?.review ?? ""
        if Utils.stringIsNullOrEmpty(model.currentUserReview?.review ?? "") {
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
        
        if !ratingsListModel.isEmpty {
            ratingsListModel.forEach { review in
                if _userModel.contains(where: { user in review.userId == user.id }) {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: review._id,
                        kCellObjectDataKey: review,
                        kCellClassKey: RatingViewCollectionCell.self,
                        kCellHeightKey: RatingViewCollectionCell.height
                    ])
                }
            }
        }
        
        _collectionView.isHidden = !(ticketModel?.isReviewVisible == true && cellData.count > 0)
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
        if Preferences.isGuest {
            parentBaseController?.alert(message: "login_required_for_review".localized(), okActionTitle: "cancel".localized(), cancelActionTitle: "login".localized(),okHandler: { alert in
                self.parentBaseController?.dismiss(animated: true)
            }) { alert in
                let vc = INIT_CONTROLLER_XIB(LoginVC.self)
                self.parentBaseController?.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = INIT_CONTROLLER_XIB(WriteReviewBottomSheet.self)
            vc._ticketId = ticketModel?._id ?? kEmptyString
            vc.stars = _ratingView.rating
            vc.reviewText = review
            parentViewController?.presentAsPanModal(controller: vc)
        }
    }
    
    @IBAction func _handleSeeAllReviewEvent(_ sender: UIButton) {
        parentBaseController?.checkSession()
        let vc = INIT_CONTROLLER_XIB(SeeAllReviewVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.myRatingStar = Double(ticketModel?.currentUserReview?.stars ?? 0)
        vc.myReview = ticketModel?.currentUserReview?.review ?? kEmptyString
        vc.ratingId = ticketModel?._id ?? ""
        vc.ratingType = RatingType.ticket.rawValue
        vc.isRayna = true
        vc.isFromTicket = true
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
}

extension CustomTicketRatingTableCell: FloatRatingViewDelegate {
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        delegate?.desableScrollEffect()
        _ratingSubmit(id: ticketModel?._id ?? "", type: RatingType.ticket.rawValue, star: "\(Int(rating))")
    }
}

extension CustomTicketRatingTableCell: CustomCollectionViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomCollectionViewDelegate>
    // --------------------------------------
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width-2, height: 135)
    }
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? RatingViewCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketReviewModel else { return }
            cell.setupCustomTicketReview(object, userModel: _userModel, isCurrentUserReview: object.userId == APPSESSION.userDetail?.id)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? RatingViewCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketReviewModel else { return }
            let vc = INIT_CONTROLLER_XIB(ReviewDetailScreen.self)
            vc.ticketModel = object
            vc.userList = _userModel
            parentBaseController?.presentAsPanModal(controller: vc)
        }
    }
}

extension CustomTicketRatingTableCell: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}
