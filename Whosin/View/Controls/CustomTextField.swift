import Foundation
import UIKit

class CustomTextField: LeftSpaceTextField {

    // MARK: - Initializers
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        autocapitalizationType = .sentences
        let spaceContainerView: UIView = UIView(frame:
            CGRect(x: 0, y: 0, width: kDefaultSpacing, height: kDefaultSpacing))
        leftView = spaceContainerView
        leftViewMode = .always
        clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =  CGRect(origin: .zero, size: bounds.size)
        gradientLayer.startPoint = CGPoint(x: .zero, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = [ColorBrand.brandgradientPink.cgColor,ColorBrand.clear.cgColor, ColorBrand.brandgradientBlue.cgColor,ColorBrand.brandgradientPink.cgColor, ColorBrand.brandgradientBlue.cgColor]
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = borderWidth
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        borderWidth = .zero
        layer.addSublayer(gradientLayer)
    }
}

