import UIKit

public class CustomButton: UIButton {

    enum FontStyle: Int {
        case regular = 1
        case medium = 2
        case semibold = 3
        case bold = 4
        case light = 5
        case extraBold = 6
        case dirham = 7
    }
    
	private var _hasShadow: Bool!
	private var _hasBorder: Bool!
    
    @IBInspectable var fontStyle: Int = FontStyle.regular.rawValue {
        didSet {
            updateFont()
        }
    }
    
    @IBInspectable var fontSize: CGFloat = 16 {
        didSet {
            updateFont()
        }
    }

    @IBInspectable var isItalic: Bool = false {
        didSet {
            updateFont()
        }
    }

	// --------------------------------------
	// MARK: Life Cycle
	// --------------------------------------

    public init(_ frame: CGRect) {
		super.init(frame: frame)
		customize()
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customize()
	}

	// --------------------------------------
	// MARK: Public
	// --------------------------------------

	public var hasShadow : Bool {
		get {
			return _hasShadow
		}
		set {
			dropShadow()
			_hasShadow = newValue
		}
	}

	public var hasBorder : Bool {
		get {
			return _hasBorder
		} set {
			setBorder(0.5)
			_hasBorder = newValue
		}
	}

	public func customize() {
		setRoundCorner(kCornerRadius)
	}

    private func updateFont() {
        guard let style = FontStyle(rawValue: fontStyle) else {
            fatalError("Invalid font style specified: \(fontStyle)")
        }
        
        switch style {
        case .regular:
            self.titleLabel?.font = FontBrand.SFregularFont(size: fontSize, isItalic: isItalic)
        case .medium:
            self.titleLabel?.font =  FontBrand.SFmediumFont(size: fontSize, isItalic: isItalic)
        case .semibold:
            self.titleLabel?.font =  FontBrand.MontserratSemiBoldFont(size: fontSize, isItalic: isItalic)
        case .bold:
            self.titleLabel?.font = FontBrand.SFboldFont(size: fontSize, isItalic: isItalic)
        case .light:
            self.titleLabel?.font = FontBrand.SFlightFont(size: fontSize, isItalic: isItalic)
        case .extraBold:
            self.titleLabel?.font = FontBrand.SFheavyFont(size: fontSize, isItalic: isItalic)
        case .dirham:
            self.titleLabel?.font = FontBrand.dirhamText(size: fontSize)
        }
    }
}

public class UnderlinedButton: CustomButton {
    
    @IBInspectable var underlineColor: UIColor = .systemBlue {
        didSet {
            updateAppearance()
        }
    }
    
    @IBInspectable var underlineThickness: CGFloat = 1.0 {
        didSet {
            updateAppearance()
        }
    }
    
    @IBInspectable var textColor: UIColor = .systemBlue {
        didSet {
            updateAppearance()
        }
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override public init(_ frame: CGRect) {
        super.init(frame)
        customizeLinkStyle()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        customizeLinkStyle()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func customizeLinkStyle() {
        backgroundColor = .clear
        setTitleColor(textColor, for: .normal)
        updateAppearance()
    }

    private func updateAppearance() {
        guard let title = self.title(for: .normal) else { return }

        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: underlineColor,
                .foregroundColor: textColor,
                .font: self.titleLabel?.font ?? FontBrand.SFregularFont(size: fontSize)
            ]
        )
        self.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    // --------------------------------------
    // MARK: Override
    // --------------------------------------
    
    override public func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        updateAppearance()
    }
}
