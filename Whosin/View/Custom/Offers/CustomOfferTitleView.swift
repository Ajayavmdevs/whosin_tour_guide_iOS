import Foundation
import UIKit
import SnapKit
import ExpandableLabel


class CustomOfferTitleView: UIView {
    
    @IBOutlet private weak var _offerTitle: UILabel!
    @IBOutlet private weak var _descriptionLabel: ExpandableLabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setExpandableLbl(_ description: String) {
            _descriptionLabel.isUserInteractionEnabled = false
            _descriptionLabel.delegate = self
            _descriptionLabel.shouldCollapse = true
            _descriptionLabel.numberOfLines = 2
            _descriptionLabel.ellipsis = NSAttributedString(string: "....")
        _descriptionLabel.collapsedAttributedLink = NSAttributedString(string: "more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
            _descriptionLabel.text = description
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomOfferTitleView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }

    }
    
    public func setupData(model: OffersModel) {
        setExpandableLbl(model.descriptions)
        _offerTitle.text = model.title
    }
  
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
}


extension CustomOfferTitleView:  ExpandableLabelDelegate {

    func willExpandLabel(_ label: ExpandableLabel) {
    }

    func didExpandLabel(_ label: ExpandableLabel) {
        _descriptionLabel.superview?.setNeedsLayout()
        _descriptionLabel.superview?.layoutIfNeeded()
    }

    func willCollapseLabel(_ label: ExpandableLabel) {
    }

    func didCollapseLabel(_ label: ExpandableLabel) {
        _descriptionLabel.superview?.setNeedsLayout()
        _descriptionLabel.superview?.layoutIfNeeded()
    }
}
