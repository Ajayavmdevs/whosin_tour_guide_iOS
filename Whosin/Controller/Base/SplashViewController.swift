import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet private weak var _imageView: UIImageView!
    private var didAnimateLogo = false
    fileprivate let indicator = MLTontiatorView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !didAnimateLogo, _imageView.image == nil, let localURL = Bundle.main.url(forResource: "logo-animation", withExtension: "gif") {
            _imageView.sd_setImage(with: localURL, completed: nil)
            didAnimateLogo = true
        }
        DISPATCH_ASYNC_MAIN_AFTER(1) {
            APPSESSION._moveToLogin()
        }
    }
    

}
