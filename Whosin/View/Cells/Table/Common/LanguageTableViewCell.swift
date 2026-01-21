import UIKit

class LanguageTableViewCell: UITableViewCell {

    @IBOutlet weak var _flagImage: UIImageView!
    @IBOutlet private weak var _title: CustomLabel!
    @IBOutlet private weak var _subTitle: CustomLabel!
    @IBOutlet weak var _radioSelection: UIImageView!
    @IBOutlet weak var _stackView: UIStackView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 52 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    public func setupData(_ data: LanguagesModel, _ isSelected: Bool = false) {
        _stackView.axis = .horizontal
        _title.text = data.name
        _subTitle.text = " (\(data.native_name) - \(data.code))"
        _flagImage.loadWebImage(data.flag)
        _radioSelection.image = UIImage(named: isSelected ? "icon_radio_selected" : "icon_radio")

    }
    
    public func setupData(_ data: CurrenciesModel, _ isSelected: Bool = false) {
        _stackView.axis = .vertical
        _title.text = data.currency
        if data.currency.lowercased() == "aed" {
            _subTitle.font = FontBrand.dirhamText(size: 11)
            _subTitle.text = "\(data.symbol)\(data.rate)"
        } else {
            _subTitle.font = FontBrand.SFregularFont(size: 11)
            _subTitle.text = "\(data.symbol)\(data.rate)"
        }
        _flagImage.loadWebImage(data.flag)
        _radioSelection.image = UIImage(named: isSelected ? "icon_radio_selected" : "icon_radio")
    }
    
}
