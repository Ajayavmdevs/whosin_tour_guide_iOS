import Foundation
import UIKit
import QuartzCore
import SnapKit

class CustomGradientBorderButton: UIButton {
    var buttonImage: UIImage? {
        didSet {
            buttonImageView.image = buttonImage
        }
    }
    var buttonBorder: CAGradientLayer? {
        didSet {
            layer.insertSublayer(buttonBorder!, at: 0)
        }
    }
    private let buttonImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createGradientLayer()
        addImageView(frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createGradientLayer()
        addImageView(self.bounds)
    }
    
    private func addImageView(_ frame: CGRect) {
        buttonImageView.frame = frame
        buttonImageView.contentMode = .scaleAspectFit
        addSubview(buttonImageView)
        buttonImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.45)
            make.height.equalToSuperview().multipliedBy(0.45)
        }
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createGradientLayer()
    }
    
    func createGradientLayer() {
        clipsToBounds = true
        layer.cornerRadius = self.frame.height / 2
        layer.masksToBounds = true
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
