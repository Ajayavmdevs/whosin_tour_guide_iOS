import UIKit
import Device

class RaisedTabBarController: UITabBarController {
    
    private var _badgeLabel = UILabel()
    private var kBadgeLabelWidth: CGFloat = 20

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        BrandManager.setDefaultTabTheam()
        _badgeLabel.backgroundColor = .red
        _badgeLabel.layer.cornerRadius = kBadgeLabelWidth/2
        _badgeLabel.clipsToBounds = true
        _badgeLabel.textColor = ColorBrand.brandBorderRed
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func addRaisedButton(_ buttonImage: UIImage?, buttonSize: CGSize = CGSize(width: 56, height: 56), highlightImage: UIImage?) {
        guard let buttonImage = buttonImage else { return }
        if let existingButton = tabBar.subviews.first(where: { $0 is UIButton }) as? UIButton {
            existingButton.setImage(buttonImage, for: .normal)
        } else {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0.0, y: 0.0, width: buttonSize.width, height: buttonSize.height)
            button.setImage(buttonImage, for: .normal)

            var center = tabBar.center
            let safeAreaInset: CGFloat = APP.window?.safeAreaInsets.bottom != .zero ? (((APP.window?.safeAreaInsets.bottom ?? 0.0)/2) - buttonSize.height/2) : -(buttonSize.height/2)
            center.y = (tabBar.subviews.last?.center.y ?? tabBar.center.y) + safeAreaInset

            button.center = center
            button.addTarget(self, action: #selector(onRaisedButton(_:)), for: .touchUpInside)
            tabBar.addSubview(button)

            let xPos = center.x - (kBadgeLabelWidth / 2)
            _badgeLabel.frame = CGRect(x: xPos + kDefaultSpacing, y: button.frame.origin.y, width: kBadgeLabelWidth, height: kBadgeLabelWidth)
            tabBar.addSubview(_badgeLabel)
        }
    }

    
    func insertEmptyTabItem(_ title: String, atIndex: Int) {
        let vc = UIViewController()
        vc.tabBarItem = UITabBarItem(title: title, image: nil, tag: 0)
        vc.tabBarItem.isEnabled = false
        self.viewControllers?.insert(vc, at: atIndex)
    }
    
    @objc func onRaisedButton(_ sender: UIButton) { }
    
    func updateBadgeView(isHidden: Bool) {
        _badgeLabel.isHidden = isHidden
    }
}
