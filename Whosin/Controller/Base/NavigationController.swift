import UIKit

public class NavigationController: UINavigationController {

	private let _borderLayer = CALayer()
    private var _popRecognizer: InteractivePopRecognizer?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    public override func viewDidLoad() {
        super.viewDidLoad()
        _setInteractiveRecognizer()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        UIStatusBarStyle.lightContent
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        _borderLayer.backgroundColor = ColorBrand.brandPink.cgColor
        var frame = navigationBar.bounds
        frame.origin.y = frame.size.height - 0.4
        frame.size.height = 0.4
        _borderLayer.frame = frame
        navigationBar.layer.addSublayer(_borderLayer)
    }
    
    private func _setInteractiveRecognizer() {
        _popRecognizer = InteractivePopRecognizer(controller: self)
        interactivePopGestureRecognizer?.delegate = _popRecognizer
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func updateSepratorLine(isHidden: Bool = false) {
        _borderLayer.isHidden = isHidden
    }
}
