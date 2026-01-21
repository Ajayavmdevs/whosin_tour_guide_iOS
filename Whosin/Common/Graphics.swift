import Foundation
import UIKit

class Graphics: NSObject {

    // --------------------------------------
    // MARK: Images
    // --------------------------------------

    public class func resizeImageWith(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.alwaysTemplate)
    }
    
    // --------------------------------------
    // MARK: Buttons
    // --------------------------------------
    
    public class func dropShadow(_ view: UIView, opacity: CGFloat, radius: CGFloat, offset: CGSize) {
        dropShadow(view, color: UIColor.black, opacity: opacity, radius: radius, offset: offset)
    }
    
    public class func dropShadow(_ view: UIView, color: UIColor?, opacity: CGFloat, radius: CGFloat, offset: CGSize) {
        view.layer.masksToBounds = false
        view.layer.rasterizationScale = UIScreen.main.scale
        view.layer.shouldRasterize = true
        view.layer.shadowColor = color?.cgColor
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = Float(opacity)
    }
    
    public class func createBrandLogo(image: String) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: kDefaultSpacing, y: 10, width: 16, height: 24))
        imageView.image = UIImage(named: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    public class func createBarButton(image: String) -> CustomGradientBorderButton {
        let button = CustomGradientBorderButton(frame: CGRect(x: 40, y: 0, width: 24, height: 24))
        button.buttonImage = UIImage(named: image)
        button.tintColor = ColorBrand.white.withAlphaComponent(0.13)
        return button
    }
    
    public class func createBadgeBarButton(image: String) -> BadgeButton {
        let button = BadgeButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        button.setImage(UIImage(named: image), for: .normal)
        button.tintColor = ColorBrand.white
        return button
    }

    public class func createBarButton(_ title: String?) -> UIButton {
        let size = title?.size(withAttributes: [NSAttributedString.Key.font: FontBrand.buttonTitleFont])
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: size?.width ?? 0, height: size?.height ?? 0)
        button.setTitle(title, for: .normal)
        button.setTitle(title, for: .highlighted)
        button.setTitle(title, for: .selected)
        button.setTitleColor(ColorBrand.white, for: .normal)
        button.setTitleColor(ColorBrand.brandGray, for: .disabled)
        button.titleLabel?.font = FontBrand.buttonTitleFont
        return button
    }

    public class func createActivityBarButton() -> UIButton {
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: kBarButtonDefaultWidth, height: kBarButtonDefaultWidth))
        let activity = UIActivityIndicatorView(style: .medium)
        activity.tintColor = ColorBrand.white
        activity.color = ColorBrand.white
        let halfButtonHeight = button.bounds.size.height/2
        let buttonWidth = button.bounds.width
        activity.center = CGPoint(x: buttonWidth - halfButtonHeight, y: halfButtonHeight)
        button.addSubview(activity)
        activity.startAnimating()
        return button
    }
    
    public class func alert(title: String = kAppName, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: {action in
            DISPATCH_ASYNC_MAIN { handler?(action) }
        }))
        DISPATCH_ASYNC_MAIN {
            guard let rootVc = APP.window?.rootViewController else { return }
            if let visibleVc = Utils.getVisibleViewController(from: rootVc) {
                visibleVc.present(alert, animated: true)
            }
        }
    }
}

