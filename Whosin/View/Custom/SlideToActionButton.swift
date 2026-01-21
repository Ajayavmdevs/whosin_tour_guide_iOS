import UIKit

protocol SlideToActionButtonDelegate: AnyObject {
    func didFinish()
}

class SlideToActionButton: UIView {
    
    let handleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    let handleViewImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "icon_slideTint")
        view.contentMode = .center
        return view
    }()
    
    @IBInspectable var startColor: UIColor = UIColor(hexString: "#90FF4D") {
        didSet {
            updateGradientColors()
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor(hexString: "#348A00") {
        didSet {
            updateGradientColors()
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    @IBInspectable var titleLabelText: String = "Create New →" {
        didSet {
            titleLabel.text = titleLabelText
        }
    }

    private let dimmingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.alpha = 0
        return view
    }()
    
    private var leadingThumbnailViewConstraint: NSLayoutConstraint?
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var gradientLayer: CAGradientLayer!

    weak var delegate: SlideToActionButtonDelegate?
    
    private var xEndingPoint: CGFloat {
        return (bounds.width - handleView.bounds.width)
    }
    
    private var isFinished = false
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        layer.cornerRadius = 25
        layer.masksToBounds = true

        gradientLayer = CAGradientLayer()
        updateGradientColors()
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(gradientLayer)

        addSubview(titleLabel)
        addSubview(handleView)
        addSubview(dimmingView)
        handleView.addSubview(handleViewImage)
        
        leadingThumbnailViewConstraint = handleView.leadingAnchor.constraint(equalTo: leadingAnchor)
        
        NSLayoutConstraint.activate([
            leadingThumbnailViewConstraint!,
            handleView.topAnchor.constraint(equalTo: topAnchor),
            handleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 80),
            handleViewImage.topAnchor.constraint(equalTo: handleView.topAnchor, constant: 10),
            handleViewImage.bottomAnchor.constraint(equalTo: handleView.bottomAnchor, constant: -10),
            handleViewImage.centerXAnchor.constraint(equalTo: handleView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmingView.topAnchor.constraint(equalTo: topAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        handleView.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if isFinished { return }
        let translatedPoint = sender.translation(in: self).x
        
        switch sender.state {
        case .changed:
            if translatedPoint <= 0 {
                updateHandleXPosition(0)
            } else if translatedPoint >= xEndingPoint {
                updateHandleXPosition(xEndingPoint)
            } else {
                updateHandleXPosition(translatedPoint)
            }
            
            let progress = translatedPoint / xEndingPoint
            dimmingView.alpha = progress
            animateColorChange(progress: progress)
        case .ended:
            if translatedPoint >= xEndingPoint {
                self.updateHandleXPosition(xEndingPoint)
                isFinished = true
                delegate?.didFinish()
            } else {
                UIView.animate(withDuration: 1) {
                    self.reset()
                }
            }
        default:
            break
        }
    }
    
    private func updateHandleXPosition(_ x: CGFloat) {
        leadingThumbnailViewConstraint?.constant = x
    }
    
    func reset() {
        isFinished = false
        updateHandleXPosition(0)
        dimmingView.alpha = 0
        animateColorChange(progress: 0)
    }
    
    private func updateGradientColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    private func animateColorChange(progress: CGFloat) {
        let startTextColor = UIColor.white
        let endTextColor = UIColor.gray
        titleLabel.textColor = interpolateColor(from: startTextColor, to: endTextColor, with: progress)
    }
    
    private func interpolateColor(from startColor: UIColor, to endColor: UIColor, with progress: CGFloat) -> UIColor {
        var startRed: CGFloat = 0, startGreen: CGFloat = 0, startBlue: CGFloat = 0, startAlpha: CGFloat = 0
        var endRed: CGFloat = 0, endGreen: CGFloat = 0, endBlue: CGFloat = 0, endAlpha: CGFloat = 0
        
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)
        
        let interpolatedRed = startRed + (endRed - startRed) * progress
        let interpolatedGreen = startGreen + (endGreen - startGreen) * progress
        let interpolatedBlue = startBlue + (endBlue - startBlue) * progress
        let interpolatedAlpha = startAlpha + (endAlpha - startAlpha) * progress
        
        return UIColor(red: interpolatedRed, green: interpolatedGreen, blue: interpolatedBlue, alpha: interpolatedAlpha)
    }
}
