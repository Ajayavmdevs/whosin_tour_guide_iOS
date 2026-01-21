import UIKit
import ExpandableLabel

class VenueDescTableCell: UITableViewCell {

    @IBOutlet weak var _heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _cellTitle: UILabel!
    @IBOutlet private weak var _deskStack: UIStackView!
    @IBOutlet private weak var _venueDescLabel: ExpandableLabel!
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
        _venueDescLabel.isUserInteractionEnabled = true
        _venueDescLabel.addGestureRecognizer(tapGesture)

        _venueDescLabel.delegate = self
        _venueDescLabel.shouldCollapse = true
        _venueDescLabel.numberOfLines = 2
        _venueDescLabel.ellipsis = NSAttributedString(string: "...")
        _venueDescLabel.collapsedAttributedLink = NSAttributedString(string: " ⬇︎ ", attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
        _venueDescLabel.setLessLinkWith(lessLink: " ⬆︎ ", attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink], position: .left)
    }
    
    @objc private func labelTapped() {
        _venueDescLabel.collapsed.toggle()
        (self.superview as? CustomTableView)?.update()
    }
    
    public func setupData(_ data: VenueDetailModel, isShowTitle: Bool = false) {
        _cellTitle.isHidden = !isShowTitle
        _venueDescLabel.text = data.about
    }
    
    public func setupActivityData(_ data: ActivitiesModel, isShowTitle: Bool = false) {
        _cellTitle.isHidden = !isShowTitle
        _venueDescLabel.text = data.descriptions
    }
    
    public func setupDescriptionData(_ description: String, title: String = kEmptyString) {
        _cellTitle.isHidden = true//title.isEmpty
        _cellTitle.text = title
        _venueDescLabel.text = description
    }
    
    public func setupabout(_ description: String) {
        _cellTitle.isHidden = true//title.isEmpty
        _venueDescLabel.text = description
    }
    
    public func setupDiscription(_ disc: String) {
        _cellTitle.isHidden = false
        _cellTitle.font = FontBrand.SFregularFont(size: 12)
        _venueDescLabel.isHidden = true
        _cellTitle.text = disc
        _heightConstraint.constant = _cellTitle.sizeThatFits(CGSize(width: _cellTitle.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        (self.superview as? CustomTableView)?.update()
    }

    
}

extension VenueDescTableCell:  ExpandableLabelDelegate {
    
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
