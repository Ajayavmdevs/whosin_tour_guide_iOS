import UIKit

class ConnectUSTableViewCell: UITableViewCell {

    @IBOutlet private weak var _gallaryView: CustomTicketGalleryView!
    @IBOutlet private weak var _titleText: CustomLabel!
    @IBOutlet weak var _rightconstraint: NSLayoutConstraint!
    @IBOutlet weak var _leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var _heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _descText: CustomLabel!
    @IBOutlet weak var _ctaHeight: NSLayoutConstraint!
    @IBOutlet weak var _customCTAView: CustomCTAView!
    
    class var height: CGFloat { UITableView.automaticDimension }

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    public func setup(_ model: ContactUsModel, screen: ContactBlockScreens) {
        _leftConstraint.constant = screen.rawValue == "homeBlock" || screen.rawValue == "exploreBlock" ? 14 : 20
        _rightconstraint.constant = screen.rawValue == "homeBlock" || screen.rawValue == "exploreBlock" ? 14 : 20
        _titleText.text = model.title
        _descText.text = model.desc
        _gallaryView.cornerRadius = 8
        if model.media?.type == "color" {
            _gallaryView.backgroundColor = UIColor(hexString: model.media?.backgroundColor ?? "#191919")
            _gallaryView.setupData([model.media?.url ?? ""], hidePageControl: true, hide: true, disablePreview: true)
        } else {
            _gallaryView.setupData([model.media?.url ?? ""], hidePageControl: true, disablePreview: true)
        }
        _heightConstraint.constant = CGFloat(model.height(screenName: screen) ?? 400)
        _customCTAView.isHidden = model.cta.isEmpty
        _customCTAView.setupData(model.cta.toArray(ofType: CTAModel.self))
        if model.cta.count <= 2 {
            _ctaHeight.constant = 40
        } else {
            _ctaHeight.constant = 80
        }

    }
    
}
