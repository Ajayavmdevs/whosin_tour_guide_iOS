
import UIKit
import FloatRatingView

class MyReviewsTableViewCell: UITableViewCell {

    @IBOutlet weak var _menuBtnView: UIView!
    @IBOutlet private weak var _userImage: UIImageView!
    @IBOutlet private weak var _nameLabel: UILabel!
    @IBOutlet private weak var _ratingView: FloatRatingView!
    @IBOutlet private weak var _dateLabel: UILabel!
    @IBOutlet private weak var _reviewLabel: UILabel!
    @IBOutlet private weak var _typeLabel: UILabel!
    @IBOutlet private weak var _detailView:UIStackView!
    private var ratingModel: RatingModel?
    public var user: UserDetailModel?


    
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
        _typeLabel.textColor = ColorBrand.white.withAlphaComponent(0.75)
        _ratingView.tintColor = ColorBrand.brandPink
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(_openDetail))
        _detailView.isUserInteractionEnabled = true // Required for gesture to work
        _detailView.addGestureRecognizer(tapGesture)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func setUpdata(model: RatingModel) {
        ratingModel = model
        _typeLabel.text = model.type
        _userImage.loadWebImage(model.image, name: model.title)
        _nameLabel.text = "\(model.title)"
        _reviewLabel.text = model.review
        _ratingView.rating = model.stars
        _dateLabel.text = Utils.dateToStringWithTimezone(model.createdAt, format: kFormatDateReview)
    }
    
    private func _editReview() {
        parentBaseController?.checkSession()
        let vc = INIT_CONTROLLER_XIB(WriteReviewBottomSheet.self)
        vc.isEditReview = true
        vc.stars = ratingModel?.stars ?? 0
        vc.reviewText = ratingModel?.review ?? ""
        vc._typeId = ratingModel?.itemId ?? ""
        vc.type = ratingModel?.type ?? ""
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
    private func _deleteReview() {
        guard let id = ratingModel?.ratingId else { return }
        WhosinServices.reviewReplyDelete(reviewId: id) { [weak self] container, error in
            guard let self = self else { return }
            if let message = container?.message { self.parentViewController?.showToast(message) }
            NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
        }
    }
    
    @IBAction func handleMenuEvent(sender: UIButton) {
        let alert = UIAlertController(title: ratingModel?.title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "edit_review".localized(), style: .default, handler: {action in
            self._editReview()
        }))
        
        alert.addAction(UIAlertAction(title: "delete_review".localized(), style: .default, handler: {action in
            self.parentBaseController?.confirmAlert(message: "delete_review_confirmation".localized(), okHandler: { action in
                self._deleteReview()
            })
        }))
                
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })

    }
    
    @objc func alertControllerBackgroundTapped() {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }

    
    @objc func _openDetail() {
        switch ratingModel?.type {
        case "venues":
            let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            vc.venueId = ratingModel?.itemId ?? ""
            parentBaseController?.navigationController?.pushViewController(vc, animated: true)
        case "ticket":
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = ratingModel?.itemId ?? ""
            vc.hidesBottomBarWhenPushed = true
            parentBaseController?.navigationController?.pushViewController(vc, animated: true)
        case "activities":
            let vc = INIT_CONTROLLER_XIB(ActivityDetailVC.self)
            vc._selectedTypeId = ratingModel?.itemId ?? ""
            parentBaseController?.navigationController?.pushViewController(vc, animated: true)
        case "event":
            let vc = INIT_CONTROLLER_XIB(EventDetailVC.self)
            vc.eventId = ratingModel?.itemId ?? ""
            parentBaseController?.navigationController?.pushViewController(vc, animated: true)
        case "events_organizers":
            let vc = INIT_CONTROLLER_XIB(EventDetailVC.self)
            vc.eventId = ratingModel?.itemId ?? ""
            parentBaseController?.navigationController?.pushViewController(vc, animated: true)
        case "yachts":
            let vc = INIT_CONTROLLER_XIB(YachtClubDetailVC.self)
            vc.yachtClubId = ratingModel?.itemId ?? ""
            parentBaseController?.navigationController?.pushViewController(vc, animated: true)

        case "complimentary":
            let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
            vc.id = ratingModel?.itemId ?? ""
            vc.isComplementary = true
            parentBaseController?.navigationController?.pushViewController(vc, animated: true)

        case "promoter":
            let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
            vc.id = ratingModel?.itemId ?? ""
            parentBaseController?.navigationController?.pushViewController(vc, animated: true)

        case .none:
            print("no types matched")
        case .some(_):
            print("no types matched")
        }
    }
    
    
}
