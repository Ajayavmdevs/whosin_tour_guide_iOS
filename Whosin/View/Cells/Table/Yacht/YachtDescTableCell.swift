import UIKit
import ExpandableLabel

class YachtDescTableCell: UITableViewCell {

    @IBOutlet private weak var _cellTitle: UILabel!
    @IBOutlet private weak var _deskStack: UIStackView!
    @IBOutlet private weak var _descLabel: ExpandableLabel!
    @IBOutlet weak var _bottomConstraint: NSLayoutConstraint!
    
    
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
        setupUi()
        disableSelectEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func setupUi() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        _descLabel.isUserInteractionEnabled = true
        _descLabel.addGestureRecognizer(tapGesture)

        _descLabel.delegate = self
        _descLabel.shouldCollapse = true
        _descLabel.numberOfLines = 2
        _descLabel.ellipsis = NSAttributedString(string: "...")
        _descLabel.collapsedAttributedLink = NSAttributedString(string: "more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandSky])
        _descLabel.setLessLinkWith(lessLink: "less".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandSky], position: .left)
    }
    
    @objc private func labelTapped() {
        _descLabel.collapsed.toggle()
        (self.superview as? CustomTableView)?.update()
    }
    
    public func setupabout(_ description: String) {
        _cellTitle.isHidden = true
        _descLabel.text = description
    }
    

    
}

extension YachtDescTableCell:  ExpandableLabelDelegate {
    
    func willExpandLabel(_ label: ExpandableLabel) {
        
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        (self.superview as? CustomTableView)?.update()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        (self.superview as? CustomTableView)?.update()
    }
}
