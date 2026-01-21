import UIKit
import SwiftyGif

class LogoAnimationView: UIView {
    
    var didStopCallback: (() -> Void)?
    
    private let _gifImageView: UIImageView = {
        guard let gifImage = try? UIImage(gifName: "LaunchAnimation.gif") else {
            return UIImageView()
        }
        return UIImageView(gifImage: gifImage, loopCount: 1)
    }()
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func commonInit() {
        backgroundColor = ColorBrand.brandGray
        _gifImageView.delegate = self
        addSubview(_gifImageView)
        _gifImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(350)
            make.height.equalTo(350)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func startAnimation() {
        _gifImageView.startAnimatingGif()
    }
}

extension LogoAnimationView: SwiftyGifDelegate {
    
    func gifDidStop(sender: UIImageView) {
        didStopCallback?()
    }
}
