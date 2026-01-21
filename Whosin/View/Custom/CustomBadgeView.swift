import Foundation
import UIKit
import SnapKit


class CustomBadgeView: UIView {
    
    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _originalPrice: UILabel!
    @IBOutlet weak var _discountedPrice: UILabel!
    @IBOutlet weak var _textLabel: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        return 26
    }
    
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
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            self._bgView.layer.maskedCorners = [.layerMinXMaxYCorner]
            self._bgView.layer.cornerRadius = 10
            self._bgView.snp.makeConstraints { make in
                make.height.equalTo(CustomBadgeView.height)
                make.leading.trailing.top.bottom.equalToSuperview()
            }

        }
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if let view = Bundle.main.loadNibNamed("CustomBadgeView", owner: self, options: nil)?.first as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(CustomBadgeView.height)
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    public func setupData(originalPrice: Int, discountedPrice: String, isNoDiscount: Bool, text: String? = kEmptyString) {
        _originalPrice.isHidden = isNoDiscount
        _bgView.backgroundColor = isNoDiscount ? .clear : ColorBrand.brandPink
        _originalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(originalPrice)".strikethrough().withCurrencyFont(18)
        _textLabel.text = text
        _textLabel.isHidden = Utils.stringIsNullOrEmpty(text)
        _discountedPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(discountedPrice)".withCurrencyFont(18)
        self._bgView.snp.makeConstraints { make in
            make.height.equalTo(CustomBadgeView.height)
            make.leading.trailing.top.bottom.equalToSuperview()
        }

    }
    
    public func setupData(originalPrice: Double, discountedPrice: Double, isNoDiscount: Bool) {
        _originalPrice.isHidden = isNoDiscount
        _bgView.backgroundColor = isNoDiscount ? .clear : ColorBrand.brandPink
        _originalPrice.attributedText = String(format: "\(Utils.getCurrentCurrencySymbol())%.2f", originalPrice).strikethrough().withCurrencyFont(18)
        _textLabel.isHidden = true
        _discountedPrice.attributedText = String(format: "\(Utils.getCurrentCurrencySymbol())%.2f", discountedPrice).withCurrencyFont(18)
        self._bgView.snp.makeConstraints { make in
            make.height.equalTo(CustomBadgeView.height)
            make.leading.trailing.top.bottom.equalToSuperview()
        }

    }
    
    public func setupWithoutDecimalData(originalPrice: Double, discountedPrice: Double, isNoDiscount: Bool) {
        _originalPrice.isHidden = isNoDiscount
        _bgView.backgroundColor = isNoDiscount ? .clear : ColorBrand.brandPink
        _originalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(originalPrice.formattedDecimal())".strikethrough().withCurrencyFont(18)
        _textLabel.isHidden = true
        _discountedPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(discountedPrice.formattedDecimal())".withCurrencyFont(18)
        self._bgView.snp.makeConstraints { make in
            make.height.equalTo(CustomBadgeView.height)
            make.leading.trailing.top.bottom.equalToSuperview()
        }

    }
    
}

