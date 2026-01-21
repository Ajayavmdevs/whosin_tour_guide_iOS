import Foundation
import UIKit

class CustomLabel: UILabel {
    
    enum FontStyle: Int {
        case regular = 1
        case medium = 2
        case semibold = 3
        case bold = 4
        case light = 5
        case extraBold = 6
        case derham = 7
    }
    
    enum FontColor: Int {
        case titleColor = 1
        case subTitleColor = 2
        case brandColor = 3
        case white = 4
    }
    
    // MARK: - Inspectable Properties
    
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
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateFont()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateFont()
    }
    
    // MARK: - Helper Methods
    
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
        case .derham:
            self.font = FontBrand.dirhamText(size: fontSize)
        }
    }

}
