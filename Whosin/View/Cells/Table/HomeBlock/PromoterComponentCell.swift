import UIKit

class PromoterComponentCell: UITableViewCell {

    @IBOutlet weak var _applyButton: CustomButton!
    @IBOutlet weak var _bgImage: UIImageView!
    @IBOutlet weak var _bgView: GradientView!
    @IBOutlet private weak var _titleLbl: CustomLabel!
    @IBOutlet private weak var _subTitleLbl: CustomLabel!

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 250 }

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
    
    public func setup(_ title: String, subTitle: String, image: String, status: String) {
        _bgImage.loadWebImage(image)
        _titleLbl.text = status == "pending" ? "your_application_is_pending".localized() : title
        _subTitleLbl.text = status == "pending" ? "please_wait_for_confirmation_before_taking_further_action".localized() : subTitle
    }

}
