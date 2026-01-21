import UIKit
import LinearProgressBar
import FloatRatingView

protocol WriteReviewBottomSheetDelegate: AnyObject {
    func didUpdateRating(_ rating: Double, _ review: String)
}

class WriteReviewBottomSheet: PanBaseViewController {

    @IBOutlet private weak var _ratingView: FloatRatingView!
    @IBOutlet private weak var _reviewTextView: UITextView!
    var starRating: String = kEmptyString
    var _venueId: String = kEmptyString
    var _ticketId: String = kEmptyString
    var _eventOrgId: String = kEmptyString
    var _yachtId: String = kEmptyString
    var _activityId: String = kEmptyString
    var _typeId: String = kEmptyString
    var isFromActivity: Bool = false
    var isFromEvent: Bool = false
    var isFromYacht: Bool = false
    var isFromPromoter: Bool = false
    var isFromComplimentry: Bool = false
    var stars: Double = 0.0
    var reviewText: String = kEmptyString
    var isEditReview: Bool = false
    var type: String = RatingType.venue.rawValue
    weak var delegate: WriteReviewBottomSheetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public func setupUI() {
        _ratingView.delegate = self
        _reviewTextView.delegate = self
        _ratingView.rating = stars
        _reviewTextView.text = reviewText.isEmpty ? kEmptyString : reviewText
        if isFromYacht {
            _ratingView.tintColor = ColorBrand.brandDarkSky
        }
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _ratingSubmit(id: String, type: String, star: String, review: String = kEmptyString) {
        WhosinServices.ratingSubmit(id: id, type: type, stars: star, review: review == "write_review_placeholder".localized() ? kEmptyString : review , status: kEmptyString) { [weak self] container, error in
            guard let self = self else { return }
            if let message = container?.message {
                NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
                self.showToast(message)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true) {
            NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
        }
    }
    
    @IBAction private func _handleSendReviewEvent(_ sender: UIButton) {
        guard let review = _reviewTextView.text else { return }
        if _ratingView.rating.isZero {
            alert(title: kAppName, message: "please_give_rating".localized())
            return
        }
        if isFromActivity {
            _ratingSubmit(id: _activityId, type: RatingType.activity.rawValue, star: "\(stars)", review: review)
        } else if isFromEvent {
            _ratingSubmit(id: _eventOrgId, type: RatingType.eventsOrganizers.rawValue, star: "\(stars)", review: review)
        } else if isFromYacht {
            _ratingSubmit(id: _yachtId, type: RatingType.yachts.rawValue, star: "\(stars)", review: review)
        } else if isFromPromoter {
            _ratingSubmit(id: _typeId, type: RatingType.promoter.rawValue, star: "\(stars)", review: review)
        } else if isFromComplimentry {
            _ratingSubmit(id: _typeId, type: RatingType.complimentary.rawValue, star: "\(stars)", review: review)
        } else if !Utils.stringIsNullOrEmpty(_ticketId) {
            _ratingSubmit(id: _ticketId, type: RatingType.ticket.rawValue, star: "\(stars)", review: review)
        } else if isEditReview {
            _ratingSubmit(id: _typeId, type: type, star: "\(stars)", review: review)
        } else {
            _ratingSubmit(id: _venueId, type: RatingType.venue.rawValue, star: "\(stars)", review: review)
        }
        delegate?.didUpdateRating(stars, review)
        dismiss(animated: true) {
            NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
        }
    }
}

extension WriteReviewBottomSheet: FloatRatingViewDelegate {
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        stars = rating
    }
}

extension WriteReviewBottomSheet: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "write_review_placeholder".localized() {
            textView.text = kEmptyString
        }
        textView.textColor = UIColor.lightGray
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "write_review_placeholder".localized()
        }
    }
}
