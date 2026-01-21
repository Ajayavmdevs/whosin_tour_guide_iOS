import Foundation
import UIKit
import SDWebImage


extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func fadeIn(duration: TimeInterval = 0.4, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.isHidden = false
        }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval = 0.4, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.isHidden = true
        }, completion: completion)
    }
    
    func removeGradientBorders() {
       if let sublayers = self.layer.sublayers {
           for sublayer in sublayers {
               if sublayer is CAGradientLayer {
                   sublayer.removeFromSuperlayer()
               }
           }
       }
   }
    
    func addRoundedRectGradientStrokeAnimation(strokeWidth: CGFloat, duration: CFTimeInterval) {
        layer.sublayers?.removeAll(where: {$0.name == "gradientLayer"})
        
        let gradient = CAGradientLayer()
        gradient.name = "gradientLayer"
        gradient.frame = self.bounds
        gradient.colors = [ColorBrand.brandgradientPink.cgColor,
                           ColorBrand.brandgradientBlue.cgColor,
                           ColorBrand.brandGray.cgColor,
                           ColorBrand.brandgradientPink.cgColor,
                           ColorBrand.brandgradientBlue.cgColor,
                           ColorBrand.brandGray.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        let strokeLayer = CAShapeLayer()
        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.strokeColor = UIColor.black.cgColor
        strokeLayer.lineWidth = strokeWidth
        strokeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: frame.width / 2.0).cgPath
        
        gradient.mask = strokeLayer
        self.layer.addSublayer(gradient)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = CGFloat(0.0)
        animation.toValue = CGFloat(1.0)
        animation.duration = duration
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        strokeLayer.add(animation, forKey: "strokeAnimation")
    }
    
    func addRoundedRectGradientStrokeAnimationChat(strokeWidth: CGFloat, duration: CFTimeInterval) {
        layer.sublayers?.removeAll(where: {$0.name == "gradientLayer"})
        
        let gradient = CAGradientLayer()
        gradient.name = "gradientLayer"
        gradient.frame = self.bounds
        gradient.colors = [UIColor.init(hexString: "F048FF").cgColor,UIColor.init(hexString: "4865FF").cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        let strokeLayer = CAShapeLayer()
        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.strokeColor = UIColor.black.cgColor
        strokeLayer.lineWidth = strokeWidth
        strokeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: frame.width / 2.0).cgPath
        
        gradient.mask = strokeLayer
        self.layer.addSublayer(gradient)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = CGFloat(0.0)
        animation.toValue = CGFloat(1.0)
        animation.duration = duration
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        strokeLayer.add(animation, forKey: "strokeAnimation")
    }
    
    func addGradientBorderWithColor(cornerRadius: CGFloat, _ borderWidth: CGFloat, _ colors: [CGColor]) {
        layer.sublayers?.removeAll(where: {$0.name == "gradientBorderColorLayer"})
        
        clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradientBorderColorLayer"
        gradientLayer.frame =  CGRect(origin: .zero, size: bounds.size)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: .zero)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.colors = colors
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = borderWidth
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        layer.addSublayer(gradientLayer)
    }
    
    func addGradientBorder(cornerRadius: CGFloat, _ borderWidth: CGFloat, _ isGrayBorder: Bool) {
        layer.sublayers?.removeAll(where: {$0.name == "gradientBorderLayer"})
        
        clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradientBorderLayer"
        gradientLayer.frame =  CGRect(origin: .zero, size: bounds.size)
        gradientLayer.startPoint = CGPoint(x: .zero, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        if isGrayBorder{
            gradientLayer.colors = [ColorBrand.brandGray.cgColor, ColorBrand.brandGray.cgColor]
        }else {
            gradientLayer.colors = [ColorBrand.brandgradientPink.cgColor,
                                    ColorBrand.brandgradientBlue.cgColor,
                                    ColorBrand.brandGray.cgColor,
                                    ColorBrand.brandgradientPink.cgColor,
                                    ColorBrand.brandgradientBlue.cgColor,
                                    ColorBrand.brandGray.cgColor]
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = borderWidth
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        layer.addSublayer(gradientLayer)
    }
    
    func setGradientViewBackground(_ topColor: UIColor, _ bottomColor: UIColor) {
        layer.sublayers?.removeAll(where: {$0.name == "gradientBackgroundLayer"})
        
        let colorTop =  topColor.cgColor
        let colorBottom = bottomColor.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradientBackgroundLayer"
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        gradientLayer.masksToBounds = true
        gradientLayer.cornerRadius = 10
        self.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview.map { $0.superview(of: type)! }
    }
    
    func touchStartedAnimation(touched: Bool) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .allowUserInteraction,
            animations: {
                if touched {
                    self.layer.shadowRadius = 8
                    self.transform = CGAffineTransform.identity.scaledBy(x: 0.93, y: 0.93)
                } else {
                    self.layer.shadowRadius = 16
                    self.transform = .identity
                }
            }
        )
    }
    
    func setUpAudioRecordButton(slideToCancelTextColor: UIColor? = nil, durationTimerColor: UIColor? = nil, view: UIView? = nil, delegate: RecordViewDelegate) -> RecordButton {
        guard let sender = self as? UIButton, let btnAudioRecorderSuperView: UIView = sender.superview else { return RecordButton() }
        let recordButton = RecordButton()
        recordButton.setImage(sender.image(for: .normal), for: .normal)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        let recordView = RecordView()
        recordView.offset = 5
        recordView.isSoundEnabled = true
        recordView.timerLabelFont = FontBrand.SFmediumFont(size: 12)
        recordView.slideLabelFont = FontBrand.SFmediumFont(size: 14)
        if let slideToCancelTextColor = slideToCancelTextColor, let durationTimerColor = durationTimerColor {
            recordView.slideToCancelTextColor = slideToCancelTextColor
            recordView.durationTimerColor = durationTimerColor
        }
        recordView.translatesAutoresizingMaskIntoConstraints = false
        btnAudioRecorderSuperView.addSubview(recordButton)
        btnAudioRecorderSuperView.addSubview(recordView)
        recordButton.widthAnchor.constraint(equalTo: sender.widthAnchor, constant: 1).isActive = true
        recordButton.heightAnchor.constraint(equalTo: sender.heightAnchor, constant: 1).isActive = true
        recordButton.centerXAnchor.constraint(equalTo: sender.centerXAnchor).isActive = true
        recordButton.centerYAnchor.constraint(equalTo: sender.centerYAnchor).isActive = true
        recordView.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        
        if let view = view {
            recordView.layer.borderWidth = 1
            recordView.layer.borderColor = UIColor.lightGray.cgColor
            recordView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            recordView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        } else {
            recordView.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -50).isActive = true
            recordView.leadingAnchor.constraint(equalTo: btnAudioRecorderSuperView.leadingAnchor, constant: 10).isActive = true
        }
        
        recordButton.recordView = recordView
        recordView.delegate = delegate
        return recordButton
    }
    
    
    func setupStoryRing(id: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let storyModel = HomeRepository.getStoryByVenueId(id)
            if storyModel != nil {
                let viewedIds = Utils.getViewedStories()
                DispatchQueue.main.async {
                    self.borderColor = (viewedIds.contains(id) ? ColorBrand.brandGray : UIColor(named: "storyRingColor")) ?? .gray
                    self.borderWidth = 2
                }
            }
            else {
                DispatchQueue.main.async {
                    self.borderColor = .clear
                    self.borderWidth = 0
                }
            }
        }
    }

    func setupStoryRing(venue: VenueDetailModel) {
        DispatchQueue.global(qos: .userInitiated).async {
            if venue.hasStories() {
                let viewedIds = Utils.getViewedStories()
                DispatchQueue.main.async {
                    self.borderColor = (viewedIds.contains(venue.id) ? ColorBrand.brandGray : UIColor(named: "storyRingColor")) ?? .gray
                    self.borderWidth = 1.5
                }
            }
            else {
                DispatchQueue.main.async {
                    self.borderColor = .clear
                    self.borderWidth = 0
                }
            }
        }
    }

}

public extension Double {
    func roundedValue(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return floor(self * divisor) / divisor
    }

    
    func getDateStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: self/1000)
        let dateFormatter = DateFormatter(withFormat: date.isToday ? kFormatDateTimeUS : kFormatDateWith24Hour, locale: Locale.current.identifier)
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
         return localDate
     }
    
    func getDateStringFromGMT(_ format:String = kStanderdDate) -> String {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter(withFormat: format, locale: Locale.current.identifier)
        if #available(iOS 16, *) {
            dateFormatter.timeZone = TimeZone(identifier: "GMT")
        } else {
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        }
        let localDate = dateFormatter.string(from: date)
         return localDate
     }
}

public extension String {
    static func format(decimal:Float, _ maximumDigits:Int = 1, _ minimumDigits:Int = 1) ->String? {
        let number = NSNumber(value: decimal)
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = maximumDigits
        numberFormatter.minimumFractionDigits = minimumDigits
        return numberFormatter.string(from: number)
    }
}

public extension URL {
    /// Adds the scheme prefix to a copy of the receiver.
    func convertToRedirectURL(scheme: String) -> URL? {
        var components = URLComponents.init(url: self, resolvingAgainstBaseURL: false)
        let schemeCopy = components?.scheme ?? ""
        components?.scheme = schemeCopy + scheme
        return components?.url
    }
}

extension UIColor {
    static var border = UIColor {
        $0.userInterfaceStyle == .dark ? .black : .white
    }
}

extension CALayer {
    /// function to add animation to layer without key
    func add<A: CAAnimation>(animation: A, forKey: String? = nil) {
        self.add(animation, forKey: forKey)
    }
}

extension UILabel {
    
    func setFontWieght(_ text: String, _ lineSpace: CGFloat) {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineSpace
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        self.attributedText = attributedString
    }
    
}
