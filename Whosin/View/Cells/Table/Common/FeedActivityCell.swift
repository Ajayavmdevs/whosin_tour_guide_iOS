import UIKit

class FeedActivityCell: UITableViewCell {

    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet weak var _feedTitle: UILabel!
    @IBOutlet weak var _feedTime: UILabel!
    @IBOutlet weak var _customProviderInfo: CustomVenueInfoView!
    @IBOutlet weak var _activityCoverImg: UIImageView!
    @IBOutlet weak var _activityName: UILabel!
    @IBOutlet weak var _activityAddress: UILabel!
    @IBOutlet weak var _activityStartDate: UILabel!
    @IBOutlet weak var _activityEndDate: UILabel!
    
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: UserFeedModel, user: UserDetailModel? = nil) {
        
        let checkedInText = "recommended".localized()
        let attributedText = NSMutableAttributedString(string: user?.fullName ?? kEmptyString)
        let boldFont = FontBrand.SFboldFont(size: 14, isItalic: true)
        attributedText.append(NSAttributedString(string: checkedInText, attributes: [NSAttributedString.Key.font: boldFont]))

        _feedTitle.attributedText = attributedText
        _userImg.loadWebImage(user?.image ?? kEmptyString, name: user?.firstName ?? kEmptyString)
        let time = Utils.stringToDate(data.createdAt, format: kStanderdDate)
        _feedTime.text = time?.timeAgoSince
        
        _customProviderInfo.setupProviderData(venue: data.activity?.provider ?? ProviderModel())
        _activityCoverImg.loadWebImage(data.activity?.coverImage ?? kEmptyString)
        _activityName.text = data.activity?.name
        _activityAddress.text = data.activity?.descriptions
        _activityStartDate.text = "start_date".localized() + (data.activity?._startDate ?? "")
        _activityEndDate.text = "end_date".localized() + (data.activity?._endDate ?? "")
    }
    
}
