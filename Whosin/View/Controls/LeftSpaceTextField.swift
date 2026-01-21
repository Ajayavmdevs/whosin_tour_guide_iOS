import UIKit

class LeftSpaceTextField: UITextField {
    
    enum FontStyle: Int {
        case regular = 1
        case medium = 2
        case semibold = 3
        case bold = 4
        case light = 5
        case extraBold = 6
    }
    
    @IBInspectable var isItalic: Bool = false {
        didSet {
            updateFont()
        }
    }
    
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
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customize()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func customize() {
        let spaceContainerView: UIView = UIView(frame:
                                                    CGRect(x: 0, y: 0, width: kDefaultSpacing, height: kDefaultSpacing))
        leftView = spaceContainerView
        leftViewMode = .always
        autocapitalizationType = .sentences
    }
    
    private func updateFont() {
        guard let style = FontStyle(rawValue: fontStyle) else {
            fatalError("Invalid font style specified: \(fontStyle)")
        }
        
        switch style {
        case .regular:
            self.font = FontBrand.SFregularFont(size: fontSize, isItalic: isItalic)
        case .medium:
            self.font =  FontBrand.SFmediumFont(size: fontSize, isItalic: isItalic)
        case .semibold:
            self.font =  FontBrand.MontserratSemiBoldFont(size: fontSize, isItalic: isItalic)
        case .bold:
            self.font = FontBrand.SFboldFont(size: fontSize, isItalic: isItalic)
        case .light:
            self.font = FontBrand.SFlightFont(size: fontSize, isItalic: isItalic)
        case .extraBold:
            self.font = FontBrand.SFheavyFont(size: fontSize, isItalic: isItalic)
        }
    }
}


class CustomTextView: UITextView, UITextViewDelegate {
    
    enum FontStyle: Int {
        case regular = 1
        case medium = 2
        case semibold = 3
        case bold = 4
        case light = 5
        case extraBold = 6
    }
    
    @IBInspectable var isItalic: Bool = false {
        didSet {
            updateFont()
        }
    }
    
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
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.autocapitalizationType = .sentences
        updateFont()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    
    private func updateFont() {
        guard let style = FontStyle(rawValue: fontStyle) else {
            fatalError("Invalid font style specified: \(fontStyle)")
        }
        
        switch style {
        case .regular:
            self.font = FontBrand.SFregularFont(size: fontSize, isItalic: isItalic)
        case .medium:
            self.font = FontBrand.SFmediumFont(size: fontSize, isItalic: isItalic)
        case .semibold:
            self.font = FontBrand.MontserratSemiBoldFont(size: fontSize, isItalic: isItalic)
        case .bold:
            self.font = FontBrand.SFboldFont(size: fontSize, isItalic: isItalic)
        case .light:
            self.font = FontBrand.SFlightFont(size: fontSize, isItalic: isItalic)
        case .extraBold:
            self.font = FontBrand.SFheavyFont(size: fontSize, isItalic: isItalic)
        }
    }
    
}

