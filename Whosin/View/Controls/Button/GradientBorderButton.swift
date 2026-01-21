import UIKit

class GradientBorderButton: UIButton {

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        customize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func customize() {
        clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =  CGRect(origin: .zero, size: bounds.size)
        gradientLayer.startPoint = CGPoint(x: .zero, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = [ColorBrand.brandgradientPink.cgColor,ColorBrand.BrandgradientLightBlack.cgColor, ColorBrand.brandgradientBlue.cgColor,ColorBrand.brandgradientPink.cgColor, ColorBrand.brandgradientBlue.cgColor]

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
