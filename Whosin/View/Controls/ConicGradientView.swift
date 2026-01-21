import UIKit

@IBDesignable
public class ConicalGradientView: UIControl {
    
    @IBInspectable var color1: UIColor = .clear { didSet { updateColors() }}
    @IBInspectable var color2: UIColor = .clear { didSet { updateColors() }}
    @IBInspectable var color3: UIColor = .clear { didSet { updateColors() }}
    @IBInspectable var color4: UIColor = .clear { didSet { updateColors() }}
    @IBInspectable var color5: UIColor = .clear { didSet { updateColors() }}
    
    public var colors: [CGColor] {
        return [color1.cgColor, color2.cgColor, color3.cgColor, color4.cgColor, color4.cgColor]
    }
    
    override public class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateColors()
    }
    
    func updatePoints() {
        gradientLayer.type = .conic
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }
    
    func updateColors() {
        gradientLayer.colors = colors
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        updatePoints()
        updateColors()
    }
}
