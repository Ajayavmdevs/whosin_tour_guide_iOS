import UIKit

class Loader: NSObject {

    fileprivate let indicator = MLTontiatorView()
    fileprivate let baseView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
    fileprivate let loadingLabel = UILabel()
    public static var shared: Loader = { return Loader() }()
    
    override init() {
        super.init()
        baseView.backgroundColor = ColorBrand.white.withAlphaComponent(0.1)
        indicator.spinnerSize = .MLSpinnerSizeSmall
        indicator.spinnerColor = ColorBrand.brandPink
        baseView.addSubview(indicator)
        
        loadingLabel.font = FontBrand.SFmediumFont(size: 14.0)
        loadingLabel.textColor = ColorBrand.brandPink
        loadingLabel.textAlignment = .center
        loadingLabel.numberOfLines = 0
        baseView.addSubview(loadingLabel)
    }
    
    func show(loadingText: String = kEmptyString) {
        indicator.startAnimating()
        indicator.frame = CGRect(x: (kScreenWidth/2)-25, y: (kScreenHeight/2)-25, width: 50, height: 50)
                       
        if !loadingText.isEmpty {
            loadingLabel.text = loadingText
            loadingLabel.isHidden = false
            loadingLabel.frame = CGRect(x: 20, y: indicator.frame.maxY + 5, width: kScreenWidth - 40, height: 50)
        } else {
            loadingLabel.isHidden = true
        }
        
        APP.window?.addSubview(baseView)
    }
    
    func hide() {
        indicator.stopAnimating()
        baseView.removeFromSuperview()
    }
}
