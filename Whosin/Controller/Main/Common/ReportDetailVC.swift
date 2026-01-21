import UIKit
import FloatRatingView

class ReportDetailVC: ChildViewController {
    
    @IBOutlet weak var _mainView: UIView!
    @IBOutlet weak var _dateTime: UILabel!
    @IBOutlet weak var _title: UILabel!
    @IBOutlet weak var _reportId: UILabel!
    @IBOutlet weak var _reason: UILabel!
    @IBOutlet weak var _message: UILabel!
    @IBOutlet weak var _reportUserImage: UIImageView!
    @IBOutlet weak var _reportUserName: UILabel!
    @IBOutlet weak var _reportUserEmail: UILabel!
    @IBOutlet weak var _reviewUserImage: UIImageView!
    @IBOutlet weak var _reviewUserName: UILabel!
    @IBOutlet weak var _review: UILabel!
    @IBOutlet weak var _reviewTime: UILabel!
    @IBOutlet weak var _ratingView: FloatRatingView!
    @IBOutlet weak var _reviewView: UIView!
    public var reportId: String = kEmptyString

    override func viewDidLoad() {
        super.viewDidLoad()
        _mainView.isHidden = true
        _requestReportDetail()
    }

    private func _requestReportDetail() {
        showHUD()
        WhosinServices.reportDetail(id: reportId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            guard let data = container?.data else { return }
            self.setupData(data: data)
        }
    }
    
    private func setupData(data: ReportedUserListModel) {
        _mainView.isHidden = false
        let titleFont = FontBrand.SFmediumFont(size: 14.0)
        let subtitleFont = FontBrand.SFregularFont(size: 14.0)
        _dateTime.text = Utils.dateToString(data.createdAt, format: kFormatEventDate)
        _title.text = data.title
        _reportId.attributedText = Utils.setAtributedTitleText(title: "reportID".localized(), subtitle: data.reporterId, titleFont: titleFont, subtitleFont: subtitleFont)
        _reason.attributedText = Utils.setAtributedTitleText(title: "reason".localized() + ": ", subtitle: data.reason, titleFont: titleFont, subtitleFont: subtitleFont)
        _message.attributedText = Utils.setAtributedTitleText(title: "message".localized() + ": ", subtitle: data.message, titleFont: titleFont, subtitleFont: subtitleFont)
        _reviewView.isHidden = data.type != "review"
        _reportUserImage.loadWebImage(data.user?.image ?? "")
        _reportUserName.text = data.user?.fullName
        _reportUserEmail.text = data.user?.email
        _reviewUserName.text = data.review?.title
        _reviewUserImage.loadWebImage(data.review?.image ?? "")
        _review.text = data.review?.review
        _reviewTime.text = Utils.dateToString(data.review?.createdAt, format: kFormatEventDate)
        _ratingView.rating = data.review?.stars ?? 0.0
        _ratingView.tintColor = ColorBrand.brandPink
    }
    
    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
