import UIKit

public class ColorBrand {
    
    static public let white = UIColor(named: "white")!
    static public let black = UIColor(named: "black")!
    static public let clear = UIColor(named: "clear")!
    static public let brandGray = UIColor(named: "brandGray")!
    static public let brandgradientPink = UIColor(named: "brandgradientPink")!
    static public let BrandgradientDarkBlue = UIColor(named: "BrandgradientDarkBlue")!
    static public let brandPink = UIColor(named: "brandPink")!
    static public let brandDarkPurple = UIColor(named: "brandDarkPurple")!
    static public let brandgradientBlue = UIColor(named: "brandgradientBlue")!
    static public let BrandgradientLightBlack = UIColor(named: "BrandgradientLightBlack")!
    static public let brandLightGreen = UIColor(named: "brandLightGreen")!
    static public let brandBorderOrange = UIColor(named: "brandBorderOrange")!
    static public let brandBorderRed = UIColor(named: "brandBorderRed")!
    static public let brandImageBorder = UIColor(named: "brandImageBorder")!
    static public let brandGreen = UIColor(named: "brandGreen")!
    static public let brandBSColor = UIColor(named: "brandBottomSheetColor")!
    static public let brandBSHeaderColor = UIColor(named: "brandBottomSheetHeaderColor")!
    static public let brandBottomSheetColor = UIColor(named: "brandBottomSheetColor")!
    static public let brandLightGray = UIColor(named: "BrandLightGray")!
    static public let paigerBgColor = UIColor(named: "paigerBgColor")!
    static public let tabUnselect = UIColor(named: "tabUnselect")!
    static public let tabSelectColor = UIColor(named: "tabSelectColor")!
    static public let yellowColor = UIColor(named: "yellow")!
    static public let brandBtnBgColor = UIColor(named: "BrandbtnBgColor")!
    static public let amberColor = UIColor(named: "amberColor")!
    static public let brandAppBgColor = UIColor(named: "brandAppBgColor")!
    static public let claimDiscountColor = UIColor(named: "claimDiscountColor")!
    static public let buyNowColor = UIColor(named: "buyNowColor")!
    static public let cardBgColor = UIColor(named: "cardBgColor")!
    static public let sectionTitleColor = UIColor(named: "sectionTitleColor")!
    static public let discountTagBgColors = UIColor(named: "discountTagBgColors")!
    static public let brandSky = UIColor(named: "brandSky")!
    static public let brandDarkSky = UIColor(named: "brandDarkSky")!


    // --------------------------------------
    // MARK: UINavigationBar
    // --------------------------------------

    class public var navBarBackgroundColor: UIColor {
        clear
    }

    class public var navBarTintColor: UIColor {
        white
    }

    class public var navBarTextColor: UIColor {
        white
    }
    
    // --------------------------------------
    // MARK: UITabBar
    // --------------------------------------

    class public var tabBarBackgroundColor: UIColor {
        brandDarkPurple.withAlphaComponent(0.50)
    }

    class public var tabBarTintColor: UIColor {
        tabSelectColor
    }

    class public var tabBarUnselectedColor: UIColor {
        tabUnselect
    }

    class public var tabBarSeltectedColor: UIColor {
        tabSelectColor
    }
}
