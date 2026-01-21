import UIKit

class ActivityImageTableCell: UITableViewCell {

    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet weak var _badgeView: CustomBadgeView!
    @IBOutlet weak var _activityName: UILabel!
    @IBOutlet private weak var _recommededIcon: UIImageView!
    private var _activityModel: ActivitiesModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._badgeView.roundCorners(corners: [.topRight, .bottomLeft], radius: 10)
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func _requestAddRecommendation() {
        parentBaseController?.showHUD()
        guard let activity = self._activityModel else { return }
        WhosinServices.addRecommendation(id: activity.id, type: "activity") { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD()
            guard let data = container else { return }
            activity.isRecommendation = !activity.isRecommendation
            self._recommededIcon.tintColor =  activity.isRecommendation ? ColorBrand.brandBtnBgColor : ColorBrand.white
            let msg = activity.isRecommendation ? LANGMANAGER.localizedString(forKey: "recommending_toast", arguments: ["value": activity.name]) : LANGMANAGER.localizedString(forKey: "recommending_remove_toast", arguments: ["value": activity.name])
            self.parentBaseController?.showSuccessMessage(activity.isRecommendation ? "thank_you".localized() : "oh_snap".localized(), subtitle: msg)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(data: ActivitiesModel) {
        _activityModel = data
        _recommededIcon.tintColor =  data.isRecommendation ? ColorBrand.brandBtnBgColor : ColorBrand.white
        _coverImage.loadWebImage(data.cover)
        _badgeView.setupData(originalPrice: data.price, discountedPrice: data._disocuntedPrice, isNoDiscount: data._isNoDiscount)
    }
    
    @IBAction private func _handleAddRecommedationEvent(_ sender: UIButton) {
        _requestAddRecommendation()
    }
}
