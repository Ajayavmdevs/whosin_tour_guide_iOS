import UIKit

class BrandManager {

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private class func _setDefaultNavBarTheme() {
        let appearance = UINavigationBar.appearance()
        appearance.setBackgroundImage(UIImage(), for: .default)
        appearance.shadowImage = nil
        appearance.isTranslucent = true
        appearance.barStyle = .default
        appearance.barTintColor = ColorBrand.navBarBackgroundColor
        appearance.tintColor = ColorBrand.navBarTintColor
        appearance.prefersLargeTitles = false
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: ColorBrand.navBarTextColor,
                NSAttributedString.Key.font: FontBrand.navBarTitleFont
            ]
            navBarAppearance.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: ColorBrand.navBarTextColor,
                NSAttributedString.Key.font: FontBrand.largeNavBarTitleFont
            ]
            navBarAppearance.backgroundColor = ColorBrand.navBarBackgroundColor
            appearance.standardAppearance = navBarAppearance
            appearance.scrollEdgeAppearance = navBarAppearance
            navBarAppearance.shadowColor = .clear
        } else {
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: ColorBrand.navBarTextColor,
                NSAttributedString.Key.font: FontBrand.navBarTitleFont
            ]
            appearance.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: ColorBrand.navBarTextColor,
                NSAttributedString.Key.font: FontBrand.largeNavBarTitleFont
            ]
        }
    }
    
    private class func _setTabBarTheme() {
        let tabBarAppearance = UITabBar.appearance()
        let tabBarItemAppearance = UITabBarItem.appearance()

        tabBarAppearance.tintColor = ColorBrand.tabBarTintColor
        tabBarAppearance.unselectedItemTintColor = ColorBrand.tabBarUnselectedColor
        
        // Make tabbar translucent so background image shows through
        tabBarAppearance.isTranslucent = true
        tabBarAppearance.barTintColor = .clear
        tabBarAppearance.backgroundColor = .clear
        tabBarAppearance.backgroundImage = UIImage(named: "tab_bg")
        tabBarAppearance.shadowImage = UIImage() // remove default shadow line

        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()

            // Apply your custom image as background
            if let bg = UIImage(named: "tab_bg") {
                appearance.backgroundImage = bg
            }
            appearance.backgroundColor = .clear
            appearance.shadowColor = .clear

            // Normal state
            appearance.stackedLayoutAppearance.normal.iconColor = ColorBrand.tabBarUnselectedColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: ColorBrand.tabBarUnselectedColor,
                .font: FontBrand.tabbarTitleFont
            ]

            // Selected state
            appearance.stackedLayoutAppearance.selected.iconColor = ColorBrand.tabBarSeltectedColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: ColorBrand.tabBarSeltectedColor,
                .font: FontBrand.tabbarSelectedTitleFont
            ]

            tabBarAppearance.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBarAppearance.scrollEdgeAppearance = appearance
            }
        } else {
            tabBarItemAppearance.setTitleTextAttributes([
                .foregroundColor: ColorBrand.tabBarUnselectedColor,
                .font: FontBrand.tabbarTitleFont
            ], for: .normal)
            tabBarItemAppearance.setTitleTextAttributes([
                .foregroundColor: ColorBrand.tabBarSeltectedColor,
                .font: FontBrand.tabbarSelectedTitleFont
            ], for: .selected)
        }
    }

    
    // --------------------------------------
    // MARK: Public Class
    // --------------------------------------

    class func setDefaultTheme() {
        _setDefaultNavBarTheme()
       // _setTabBarTheme()
    }

    class func setDefaultTabTheam() {
        _setTabBarTheme()
    }
}
