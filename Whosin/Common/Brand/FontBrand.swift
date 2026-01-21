import UIKit

public class FontBrand {
    
    class public func MontserratBlackFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: !isItalic ? "Montserrat-Black" : "Montserrat-BlackItalic", size: size)!
    }
    
    class public func MontserratBoldFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: !isItalic ? "Montserrat-Bold" : "Montserrat-BoldItalic", size: size)!
    }
    
    class public func MontserratExtraBoldFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: !isItalic ? "Montserrat-ExtraBold" : "Montserrat-ExtraBoldItalic", size: size)!
    }
    
    class public func MontserratExtraLightFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: !isItalic ? "Montserrat-ExtraLight" : "Montserrat-ExtraLightItalic", size: size)!
    }
    
    class public func MontserratVariableFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: !isItalic ? "Montserrat-VariableFont_wght" : "Montserrat-Italic-VariableFont_wght", size: size)!
    }
    
    class public func MontserratLightFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: !isItalic ? "Montserrat-Light" : "Montserrat-LightItalic", size: size)!
    }
    
    class public func MontserratMediumFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: !isItalic ? "Montserrat-Medium" : "Montserrat-MediumItalic", size: size)!
    }
    
    class public func MontserratFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: !isItalic ? "Montserrat-Regular" : "Montserrat-Italic", size: size)!
    }
    
    class public func MontserratSemiBoldFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: !isItalic ? "Montserrat-SemiBold" : "Montserrat-SemiBoldItalic", size: size)!
    }
    
    class public func MontserratThinFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: !isItalic ? "Montserrat-Thin" : "Montserrat-ThinItalic", size: size)!
    }
    
    // --------------------------------------
    // MARK: SFUI Font
    // --------------------------------------
    
    class public func SFlightFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: isItalic ? "SFUIText-LightItalic" : "SFUIText-Light", size: size)!
    }
    
    class public func SFregularFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: isItalic ? "SFUIText-RegularItalic" : "SFUIText-Regular", size: size)!
    }
    
    class public func SFmediumFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: isItalic ? "SFUIText-MediumItalic" : "SFUIText-Medium", size: size)!
    }
    
    class public func SFsemiboldFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: isItalic ? "SFUIText-SemiboldItalic" : "SFUIText-Semibold", size: size)!
    }

    class public func SFboldFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: isItalic ? "SFUIText-BoldItalic" : "SFUIText-Bold", size: size)!
    }
    
    class public func SFheavyFont(size: CGFloat, isItalic: Bool = false) -> UIFont {
        UIFont(name: isItalic ? "SFUIText-HeavyItalic" : "SFUIText-Heavy", size: size)!
    }
    
    class public func dirhamText(size: CGFloat) -> UIFont {
        UIFont(name: "aed-Regular", size: size)!
    }

    // --------------------------------------
    // MARK: UINavigationBar
    // --------------------------------------
    
    class public var navBarTitleFont: UIFont {
        SFboldFont(size: 18.0)
    }

    class public var navBarSubtitleFont: UIFont {
        MontserratSemiBoldFont(size: 12.0)
    }

    class public var largeNavBarTitleFont: UIFont {
        SFboldFont(size: 34.0)
    }
    
    // --------------------------------------
    // MARK: UITabBar
    // --------------------------------------
    
    class public var tabbarTitleFont: UIFont {
        SFregularFont(size: 11.0)
    }

    class public var tabbarSelectedTitleFont: UIFont {
        SFsemiboldFont(size: 11.0)
    }
    
    // --------------------------------------
    // MARK: UIButton
    // --------------------------------------
    
    class public var buttonTitleFont: UIFont {
        SFregularFont(size: 15.0)
    }
    
    // --------------------------------------
    // MARK: UILabel
    // --------------------------------------
    
    class public var labelFont: UIFont {
        SFregularFont(size: 15.0)
    }
    
    class public var tableHeaderFont: UIFont {
        SFsemiboldFont(size: 20)
    }
}
