import UIKit
import FloatRatingView
import ExpandableLabel
import CountdownLabel
import MapKit

class CustomTicketDetailHeaderCell: UITableViewCell {
    
    @IBOutlet weak var _likeBtn: CustomLikeButton!
    @IBOutlet weak var _gallayView: CustomTicketGalleryView!
    @IBOutlet private weak var _titleText: UILabel!
    @IBOutlet private weak var _descriptionText: ExpandableLabel!
    @IBOutlet private weak var _discountView: GradientView!
    @IBOutlet private weak var _discountPercentage: UILabel!
    @IBOutlet private weak var _descriptionView: UIView!
    @IBOutlet weak var _tagBgView: UIView!
    @IBOutlet weak var _discountedPrice: CustomLabel!
    @IBOutlet private weak var _rattingCount: CustomLabel!
    @IBOutlet weak var _customTagsView: CustomTicketTagsView!
    @IBOutlet private weak var _startingFromAmount: CustomLabel!
    @IBOutlet private weak var _rattingsList: UIButton!
    @IBOutlet private weak var _avgRatingReview: UIStackView!
    @IBOutlet weak var _imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _ratingParentView: UIView!
    @IBOutlet weak var _startingAmountStack: UIStackView!
    
    private var ticketModel: TicketModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _likeBtn.tintColor = _likeBtn.isSelected ? ColorBrand.brandPink : ColorBrand.white.withAlphaComponent(0.8)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        _descriptionText.isUserInteractionEnabled = true
        _descriptionText.addGestureRecognizer(tapGesture)
        _descriptionText.delegate = self
        _descriptionText.shouldCollapse = false
        _descriptionText.shouldExpand = false
        _descriptionText.numberOfLines = 3
        _descriptionText.ellipsis = NSAttributedString(string: "....")
        _descriptionText.collapsedAttributedLink = NSAttributedString(string: "see_more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
        _descriptionText.setLessLinkWith(lessLink: "see_less".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink], position: .left)
        _imageHeightConstraint.constant = kScreenWidth
    }
       
    @objc private func labelTapped() {
        let vc = INIT_CONTROLLER_XIB(DeclaimerBottomSheet.self)
        vc.disclaimerTitle = "description".localized()
        vc.disclaimerdescriptions = ticketModel?.descriptions ?? ""
        parentBaseController?.presentAsPanModal(controller: vc)
    }
    
    deinit {
        _gallayView.pauseVideos()
    }
    
    public func cellDidDisappear() {
        _gallayView.pauseVideos()
    }
    
//    @objc private func handleReloadOnLike(_ notification: Notification) {
//        if let data = notification.object as? [String: Any],
//           let id = data["id"] as? String,
//           let flag = data["flag"] as? Bool {
//            if id == ticketModel?._id {
//                ticketModel?.isFavourite = flag
//            }
//        }
//    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: TicketModel) {
        _imageHeightConstraint.constant = kScreenWidth
        self.ticketModel = model
        _tagBgView.isHidden = model.tags.isEmpty
        if !model.tags.isEmpty {
            _customTagsView.setupData(model.tags.toArray(ofType: String.self))
        }
        _likeBtn.isSelected = model.isFavourite
        _likeBtn.tintColor = _likeBtn.isSelected ? ColorBrand.brandPink : ColorBrand.white.withAlphaComponent(0.8)
        _startingAmountStack.isHidden = model.startingAmount == 0
        let discountedPriceCurrency = NSAttributedString(
            string: " \(Utils.getCurrentCurrencySymbol())",
            attributes: [.foregroundColor: ColorBrand.black, .font: (APPSESSION.userDetail?.currency == "AED" || Utils.getCurrentCurrencySymbol() == "D") ? FontBrand.dirhamText(size: 14) : FontBrand.SFboldFont(size: 14)]
        )
        let discountedPrice = NSAttributedString(
            string: "\(model.startingAmount.formattedDecimal())",
            attributes: [.foregroundColor: ColorBrand.black, .font: FontBrand.SFboldFont(size: 14)]
        )

        let finalText = NSMutableAttributedString()
        finalText.append(discountedPriceCurrency)
        finalText.append(discountedPrice)
        _startingFromAmount.attributedText = finalText
        
        _discountedPrice.isHidden = !model.hasDiscount
        _discountedPrice.attributedText =  "\(Utils.getCurrentCurrencySymbol())\(model.startingAmountWithoutDiscount.hideFloatingValue())".strikethrough()
        _rattingCount.text = String(format: "%.1f", model.avg_ratings)
        _rattingsList.setTitle(LANGMANAGER.localizedString(forKey: "review_count", arguments: ["value": "\(model.reviews.count)"]))
        _gallayView.setupData(model.images.toArray(ofType: String.self))
        _titleText.text = model.title.isEmpty ? model.tourData?.tourName : model.title
        if Utils.stringIsNullOrEmpty(model.descriptions) {
            _descriptionText.text = kEmptyString
            _descriptionView.isHidden = true
        }
        else {
            _descriptionText.text = Utils.convertHTMLToPlainText(from: model.descriptions)
            _descriptionView.isHidden = Utils.stringIsNullOrEmpty(_descriptionText.text)
        }
        _discountView.isHidden = model.discount == 0
        _discountPercentage.text = "\(model.discount)%"
        
        _avgRatingReview.isHidden = model.avg_ratings == 0 || model.avg_ratings == 0.0
//        _rattingView.isHidden = !model.isEnableRating
        _ratingParentView.isHidden = !model.isEnableRating
        _rattingCount.isHidden = !model.isEnableRating
        _rattingsList.isHidden = !(model.isReviewVisible && model.reviews.count > 0)
    }
    
    @IBAction private func _handleLikeEvent(_ sender: CustomLikeButton) {
        guard let model = ticketModel else { return }
        _likeBtn.showActivity()
        WhosinServices.requestAddRemoveFav(id: model._id, type: "ticket") { [weak self] container, error in
            guard let self = self else { return }
            self._likeBtn.hideActivity()
            self.parentBaseController?.showError(error)
            guard let data = container else { return }
            ticketModel?.isFavourite = !(ticketModel?.isFavourite ?? false)
            self._likeBtn.isSelected = ticketModel?.isFavourite ?? false
            NotificationCenter.default.post(name: .reloadOnLike, object: ["id": model._id, "flag": !(ticketModel?.isFavourite ?? false)])
            self.parentBaseController?.showSuccessMessage(ticketModel?.isFavourite == true ?  "thank_you".localized() : "oh_snap".localized(), subtitle: ticketModel?.isFavourite == true ? LANGMANAGER.localizedString(forKey: "add_favourite", arguments: ["value": ticketModel?.title ?? ""]) : LANGMANAGER.localizedString(forKey: "remove_favourite", arguments: ["value": ticketModel?.title ?? ""]))
        }
    }
    
    @IBAction private func _handleViewAllRatings(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(SeeAllReviewVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.myRatingStar = Double(ticketModel?.currentUserReview?.stars ?? 0)
        vc.myReview = ticketModel?.currentUserReview?.review ?? kEmptyString
        vc.ratingId = ticketModel?._id ?? ""
        vc.ratingType = RatingType.ticket.rawValue
        vc.ticketModel = ticketModel
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
}

extension CustomTicketDetailHeaderCell: ExpandableLabelDelegate {
    
    func willExpandLabel(_ label: ExpandableLabel) {
        labelTapped()
        label.collapsed = false
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
    }
}
