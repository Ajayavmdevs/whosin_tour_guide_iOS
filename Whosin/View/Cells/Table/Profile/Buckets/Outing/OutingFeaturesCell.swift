import UIKit
import ExpandableLabel

class OutingFeaturesCell: UITableViewCell {

    @IBOutlet private weak var _featuresLabel: UILabel!
    @IBOutlet private weak var _cuisineLabel: UILabel!
    @IBOutlet private weak var _musicLabel: UILabel!
    @IBOutlet private weak var _themeLabel: UILabel!
    @IBOutlet private weak var _dressCodeLabel: UILabel!
    @IBOutlet private weak var _featuresStack: UIStackView!
    @IBOutlet private weak var _cusineStack: UIStackView!
    @IBOutlet private weak var _musicStack: UIStackView!
    @IBOutlet private weak var _dressCodeStack: UIStackView!
    @IBOutlet private weak var _themeStack: UIStackView!
    @IBOutlet weak var _discriptionLabel: ExpandableLabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

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
        _discriptionLabel.isUserInteractionEnabled = true
        _discriptionLabel.addGestureRecognizer(tapGesture)

        _discriptionLabel.delegate = self
        _discriptionLabel.shouldCollapse = true
        _discriptionLabel.numberOfLines = 2
        _discriptionLabel.ellipsis = NSAttributedString(string: "....")
        _discriptionLabel.collapsedAttributedLink = NSAttributedString(string: " ⬇︎ ", attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
        _discriptionLabel.setLessLinkWith(lessLink: " ⬆︎ ", attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink], position: .left)
    }
    
    @objc private func labelTapped() {
        _discriptionLabel.collapsed.toggle()
        (self.superview as? CustomTableView)?.update()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: OutingListModel) {
        
        guard let venueModel = model.venue else { return }
        _discriptionLabel.text = model.venue?.about
        
        _featuresStack.isHidden = venueModel.feature.isEmpty
        _featuresLabel.text = venueModel.feature.joined(separator: ", ")
        
        _cusineStack.isHidden = venueModel.cuisine.isEmpty
        _cuisineLabel.text = venueModel.cuisine.joined(separator: ", ")
        
        _musicStack.isHidden = venueModel.music.isEmpty
        _musicLabel.text = venueModel.music.joined(separator: ", ")
        
        _themeStack.isHidden = venueModel.theme.isEmpty
        _themeLabel.text = venueModel.theme.joined(separator: ", ")
    }
}

extension OutingFeaturesCell:  ExpandableLabelDelegate {
    
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
