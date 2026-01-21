import UIKit

class BottomSheetTableCell: UITableViewCell {
    
    @IBOutlet private weak var _iconImageView: UIImageView!
    @IBOutlet private weak var _titleLabel: UILabel!
    
    private var _tag: Int = 0
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat {
        52
    }
    
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
    
    func setup(tuple: BottomSheetTupple, isWebImage: Bool = false) {
        _tag = tuple.tag
        _titleLabel.text = tuple.title
        _iconImageView.isHidden = Utils.stringIsNullOrEmpty(tuple.icon)
        if isWebImage { _iconImageView.loadWebImage(tuple.icon ?? kEmptyString) }
        else { _iconImageView.image = UIImage(named: tuple.icon ?? kEmptyString) }
    }
    
    func setupTimeSlot(_ slot: String) {
        _titleLabel.text = slot
    }
    
    func setupLogs(_ logs: LogsModel) {
        let att = Utils.setAtributedTitleText(title: "\(logs.subType.uppercased()) - ", subtitle: Utils.dateToString(logs.dateTime, format: kFormatDateWithHourMinuteAM), titleFont: FontBrand.SFboldFont(size: 14.0), subtitleFont: FontBrand.SFregularFont(size: 14.0))
        _titleLabel.attributedText = att
    }
}
