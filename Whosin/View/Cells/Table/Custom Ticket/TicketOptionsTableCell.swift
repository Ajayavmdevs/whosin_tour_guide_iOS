import UIKit

class TicketOptionsTableCell: UITableViewCell {

    @IBOutlet private weak var _tourTitle: CustomLabel!
    @IBOutlet private weak var _tourDesc: CustomLabel!
    @IBOutlet private weak var _duration: CustomLabel!
    @IBOutlet private weak var _minPax: CustomLabel!
    @IBOutlet private weak var _maxPax: CustomLabel!
    @IBOutlet private weak var _cancellationPolcy: CustomLabel!
    @IBOutlet private weak var _startingPrice: CustomLabel!
    @IBOutlet private weak var _childAge: CustomLabel!
    @IBOutlet private weak var _infantAge: CustomLabel!
    @IBOutlet private weak var _durationStack: UIStackView!
    @IBOutlet private weak var _childAgeStack: UIStackView!
    @IBOutlet private weak var _infantAgeStack: UIStackView!
    @IBOutlet private weak var _paxDetail: UIStackView!
    @IBOutlet private weak var _maxPaxStack: UIStackView!
    @IBOutlet private weak var _minPaxStack: UIStackView!
    @IBOutlet private weak var _cancellationPolicyStack: UIStackView!
    @IBOutlet weak var _customGallaryView: CustomGallaryView!
    
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
    

    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: TicketModel, option: TourOptionDataModel) {
        _customGallaryView.setupHeader(option.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0)}), pageControl: true)
        _tourDesc.text = option.optionDescription
        _tourTitle.text = option.optionName
        _duration.text = option.duration
        _minPax.text = option.minPax
        _maxPax.text = option.maxPax
        _cancellationPolcy.text = option.cancellationPolicy
        
        _startingPrice.attributedText = "\(Utils.getCurrentCurrencySymbol()) \(data.getTotalPrice(Double(data.startingAmount)))".withCurrencyFont(14)
        _durationStack.isHidden = Utils.stringIsNullOrEmpty(option.duration)
        _minPaxStack.isHidden = option.minPax == "0"
        _maxPaxStack.isHidden = option.maxPax == "0"
        _paxDetail.isHidden = option.minPax == "0" && option.maxPax == "0"
        _infantAge.text = option.infantAge
        _childAge.text = option.childAge
        _childAgeStack.isHidden = Utils.stringIsNullOrEmpty(option.childAge)
        _infantAgeStack.isHidden = Utils.stringIsNullOrEmpty(option.infantAge)
        _cancellationPolicyStack.isHidden = Utils.stringIsNullOrEmpty(option.cancellationPolicy)
    }
    
}
