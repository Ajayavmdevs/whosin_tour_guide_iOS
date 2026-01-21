
import UIKit

public extension UIButton {
    
	func dropShadow() {
		Graphics.dropShadow(self, opacity: 0.5, radius: 1.0, offset: CGSize.zero)
	}

    func setRoundCorner(_ cornerRadius: CGFloat) {
		layer.cornerRadius = cornerRadius
		clipsToBounds = true
	}

	func setBorder(_ borderWidth: CGFloat) {
		layer.borderWidth = borderWidth
		layer.borderColor = backgroundColor?.darkerColor().cgColor
	}
    
    func setBorder(_ borderWidth: CGFloat,_ color: UIColor) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
    }
    
    func setImageTintColor(_ color: UIColor) {
        let tintedImage = imageView?.image?.withRenderingMode(.alwaysTemplate)
        setImage(tintedImage, for: .normal)
        tintColor = color
    }

    func alignImageRight (){
        if let imageWidth = imageView?.frame.width {
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: 0, right: imageWidth)
        }

        if let titleWidth = titleLabel?.frame.width {
            let spacing = titleWidth + 20
            imageEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        }
    }
}
