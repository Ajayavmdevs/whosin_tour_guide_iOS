import UIKit
import LinearProgressBar
import FloatRatingView


class WriteTicketReview: ChildViewController {

    @IBOutlet private weak var _ratingView: FloatRatingView!
    @IBOutlet private weak var _reviewTextView: UITextView!
    @IBOutlet weak var _ticketImage: UIImageView!
    @IBOutlet weak var _popupTitle: UILabel!
    var starRating: String = kEmptyString
    var _ticketId: String = kEmptyString
    var stars: Double = 0.0
    var reviewText: String = kEmptyString
    var type: String = RatingType.ticket.rawValue
    var ticketModel: TicketModel?
    public var showToast:((_ msg: String)-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupUI()
        _requestTicketDetail()
    }
    
    public func setupUI() {
        _ratingView.delegate = self
        _ratingView.type = .wholeRatings
        _reviewTextView.delegate = self
        _ratingView.rating = stars
        _reviewTextView.text = reviewText.isEmpty ? "write_review_placeholder".localized() : reviewText
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestTicketDetail() {
        _loadData(isLoading: true)
        if let model = APPSETTING.ticketList?.first(where: { $0._id == _ticketId }) {
            ticketModel = model
            _loadData()
        } else {
            WhosinServices.getTicketDetail(id: _ticketId) { [weak self] container, error in
                guard let self = self else {
                    self?._loadData(isLoading: false)
                    return
                }
                if error != nil {
                    self._loadData(isLoading: false)
                }
                self.hideHUD(error: error)
                guard let data = container?.data else {
                    return
                }
                self.ticketModel = data
                self._loadData()
            }
        }
    }

    
    private func _ratingSubmit(id: String, type: String, star: String, review: String = kEmptyString) {
        WhosinServices.ratingSubmit(id: id, type: type, stars: star, review: review, status: kEmptyString) { [weak self] container, error in
            guard let self = self else { return }
            if let message = container?.message {
                NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
                dismiss(animated: true) {
                    self.showToast?(message)
                }
            }
        }
    }
    
    private func raynaReviewUpdate() {
        WhosinServices.updateRaynaReviewStatus(customTicketId: _ticketId, status: "skipped") { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else {
                dismiss(animated: true)
                return
            }
            self.showToast(container?.message ?? "")
            dismiss(animated: true) {
                self.showToast?(container?.message ?? "")
                NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
            }
        }
    }
    
    private func _loadData(isLoading: Bool = false) {
        if let data = ticketModel, !isLoading {
            _ticketId = data._id
            _popupTitle.text = "enjoyed_your_experience_at".localized() + " \(data.title)?"
            _ticketImage.loadWebImage(data.images.first(where: { !Utils.isVideo($0) }) ?? "")
        } else {
            _popupTitle.text = "enjoyed_your_experience".localized()
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        showCustomAlert(message: "would_you_like_to_skip_the_review_for".localized() + "\(ticketModel?.title ?? "")?", noButtonTitle: "no".localized(), okHandler: { action in
            self.raynaReviewUpdate()
        })
    }
    
    @IBAction private func _handleSendReviewEvent(_ sender: UIButton) {
        guard let review = _reviewTextView.text  else {
            alert(title: kAppName, message: "please_give_some_review_here".localized())
            return
        }
        if _reviewTextView.text == "write_review_placeholder".localized() {
            alert(title: kAppName, message: "please_give_some_review_here".localized())
            return
        }
        if _ratingView.rating.isZero {
            alert(title: kAppName, message: "please_give_rating".localized())
            return
        }
        _ratingSubmit(id: _ticketId, type: RatingType.ticket.rawValue, star: "\(stars)", review: review)
    }
}

extension WriteTicketReview: FloatRatingViewDelegate {
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        stars = rating
    }
}


extension WriteTicketReview: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "write_review_placeholder".localized() {
            textView.text = kEmptyString
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "write_review_placeholder".localized()
        }
    }
}
