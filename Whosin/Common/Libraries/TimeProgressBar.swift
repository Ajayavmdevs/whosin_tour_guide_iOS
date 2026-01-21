import UIKit

@IBDesignable
class TimeProgressBar: UIView {

    private let progressView = UIView()
    private let stripeLayer = CALayer()

    private var progress: CGFloat = 0.0

    // MARK: - Inspectable (Optional)
    @IBInspectable var barCornerRadius: CGFloat = 6 {
        didSet {
            layer.cornerRadius = barCornerRadius
            progressView.layer.cornerRadius = barCornerRadius
        }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup
    private func setup() {
        backgroundColor = UIColor.systemGray5
        layer.cornerRadius = barCornerRadius
        clipsToBounds = true

        progressView.backgroundColor = .clear
        progressView.layer.cornerRadius = barCornerRadius
        progressView.clipsToBounds = true
        addSubview(progressView)

        // Setup stripe layer
        stripeLayer.contents = makeStripedPatternImage().cgImage
        stripeLayer.frame = bounds
        stripeLayer.masksToBounds = true
        progressView.layer.addSublayer(stripeLayer)

        animateStripes()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let newWidth = bounds.width * progress
        progressView.frame = CGRect(x: 0, y: 0, width: newWidth, height: bounds.height)
        stripeLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * 2, height: bounds.height)
    }

    // MARK: - Public Method
    func setProgress(_ value: CGFloat, animated: Bool = true) {
        progress = min(max(value, 0.0), 1.0)
        let newWidth = bounds.width * progress

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.progressView.frame.size.width = newWidth
            }
        } else {
            progressView.frame.size.width = newWidth
        }
    }

    // MARK: - Stripe pattern
    private func makeStripedPatternImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!

        ColorBrand.brandPink.setFill()
        context.fill(CGRect(origin: .zero, size: size))

        ColorBrand.brandPink.withAlphaComponent(0.3).setStroke()
        context.setLineWidth(10)
        context.move(to: CGPoint(x: -10, y: 30))
        context.addLine(to: CGPoint(x: 30, y: -10))
        context.strokePath()

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    private func animateStripes() {
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.byValue = -40
        animation.duration = 1
        animation.repeatCount = .infinity
        stripeLayer.add(animation, forKey: "stripeMove")
    }
}
