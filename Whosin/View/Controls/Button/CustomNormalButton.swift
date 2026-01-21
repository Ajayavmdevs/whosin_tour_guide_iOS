import Foundation
import UIKit
import MHLoadingButton

class CustomNormalButton: LoadingButton {
    
    private var _label: UILabel = UILabel()
    private var _activityIndicator = UIActivityIndicatorView()
    
    var buttonImage: UIImage? {
        didSet {
            setBackgroundImage(buttonImage, for: .normal)
        }
    }

    public var buttonTitle: String = "" {
        didSet {
            _updateLabel()
        }
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
      
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
      
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setupUI()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
      
    private func _setupUI() {
        self.indicator = _activityIndicator
        self.indicator = BallBeatIndicator(radius: bounds.height/2 , color: ColorBrand.brandGray)
        _label.font = FontBrand.MontserratSemiBoldFont(size: 14)
        _label.backgroundColor = .clear
        _label.alpha = 1
        _label.clipsToBounds = true
        _label.isUserInteractionEnabled = false
        _label.translatesAutoresizingMaskIntoConstraints = false
        _label.textAlignment = .center
        _label.textColor = .white
        _label.layer.zPosition = 1
        self.addSubview(_label)
        NSLayoutConstraint.activate([
            _label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            _label.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
    }
    
    private func _updateLabel() {
        _label.text = buttonTitle
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func startLoading() {
        self.startLoading()
        _label.isHidden = true
    }
    
    func stopLoading() {
        self.stopLoading()
        _label.isHidden = false
    }
}

