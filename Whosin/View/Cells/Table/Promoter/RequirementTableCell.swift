import UIKit

class RequirementTableCell: UITableViewCell {
    
    @IBOutlet private weak var _titleLabel: CustomLabel!
    @IBOutlet private weak var _customView: CustomRequirementView!
    public var callback: ((_ model: [String], _ type: RequirementType) -> Void)?
    
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
    
    public func setupData(_ title: String?, isAllow: Bool, list: [String]) {
        _titleLabel.isHidden = !isAllow
        if title == "requirementsAllowed" || title == "requirementsNotAllowed" {
            _customView.setupData(list, titleText: isAllow ? "add_the_requirements_allowed".localized() : "add_the_requirements_that_are_not_allowed".localized() , isAllow: isAllow, type: title == "requirementsAllowed" ? .requirementsAllowed : .requirementsNotAllowed)
        } else if title == "benefitsIncluded" || title == "benefitsNotIncluded" {
            _customView.setupData(list, titleText: isAllow ? "add_the_benefits_that_are_included".localized() : "add_the_benefits_that_are_not_included".localized(), isAllow: isAllow, type: title == "benefitsIncluded" ? .benefitsIncluded : .benefitsNotIncluded)
        }
        _customView.updateCallback = { [weak self] list , type in
            guard let self = self else { return }
            self.callback?(list, type)
        }
        _titleLabel.text = title == "requirementsAllowed" || title == "requirementsNotAllowed" ? "requirements".localized() : "benefits".localized()
        
    }
}
