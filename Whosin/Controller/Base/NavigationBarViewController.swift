import UIKit

class NavigationBarViewController: BaseViewController {

	private var _leftBarBtn: UIButton?
	private var _rightBarBtn: UIButton?
    private var _brandLogoImgView: UIImageView?
    var chainData: [String: Any] = [:]

	// --------------------------------------
	// MARK: Life Cycle
	// --------------------------------------

    override func viewDidLoad() {
		super.viewDidLoad()
		updateLeftBarButton(leftBarButton)
		updateRightBarButton(rightBarButton)
        updateBrandLogo(brandLogoImgView)
	}

	// --------------------------------------
	// MARK: Templates
	// --------------------------------------

    var leftBarButton: UIButton? {
		// Implement at subclass
		nil
	}

    var rightBarButton: UIButton? {
		nil
	}
    
    var brandLogoImgView: UIImageView? {
        nil
    }

	@objc func handleLeftBarButtonEvent() {
		// Implement at subclass
	}

	@objc func handleRightBarButtonEvent() {
		// Implement at subclass
	}
    
    @objc func handleTitleBarButtonEvent() {
        // Implement at subclass
    }

	// --------------------------------------
	// MARK: Public
	// --------------------------------------

    func updateLeftBarButton(_ button: UIButton?) {
		_leftBarBtn = button
		if _leftBarBtn != nil {
			_leftBarBtn!.addTarget(self, action: #selector(handleLeftBarButtonEvent), for: .touchUpInside)
			navigationItem.leftBarButtonItem = UIBarButtonItem(customView: _leftBarBtn!)
		}
	}

    func enableLeftBarButton(_ enabled: Bool) {
		_leftBarBtn?.isEnabled = enabled
	}
    
    func hideLeftBarButton(_ enabled: Bool) {
        _leftBarBtn?.isHidden = enabled
    }

    func updateRightBarButton(_ button: UIButton?) {
		_rightBarBtn = button
		if _rightBarBtn != nil {
			_rightBarBtn!.addTarget(self, action: #selector(handleRightBarButtonEvent), for: .touchUpInside)
			navigationItem.rightBarButtonItem = UIBarButtonItem(customView: _rightBarBtn!)
		} else {
			navigationItem.rightBarButtonItem = nil
		}
	}

    func enableRightBarButton(_ enabled: Bool) {
		_rightBarBtn?.isEnabled = enabled
	}
    
    func hideRightBarButton(_ enabled: Bool) {
        _rightBarBtn?.isHidden = enabled
    }
    
    func toggleRightBarButton(enabled: Bool) {
        _rightBarBtn?.isEnabled = enabled
        _rightBarBtn?.alpha = enabled ? 1.0 : 0.66
    }
    
    func updateBrandLogo(_ brandLogo: UIImageView?) {
        _brandLogoImgView = brandLogo
        if _brandLogoImgView != nil {
            let logoView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: kScreenWidth, height: kNavigationBarHeight)))
            logoView.backgroundColor = .clear
            logoView.addSubview(_brandLogoImgView!)
            
            navigationItem.titleView = logoView
        }
    }

    func setTitle(title: String, subtitle: String) {
		let titleLabel = UILabel(frame: CGRect(x: 0, y: -5, width: 0, height: 0))

		titleLabel.backgroundColor = .clear
		titleLabel.textColor = ColorBrand.white
		titleLabel.font = FontBrand.navBarTitleFont
		titleLabel.text = title
		titleLabel.sizeToFit()

		let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 16, width: 0, height: 0))
		subtitleLabel.backgroundColor = .clear
		subtitleLabel.textColor = ColorBrand.white
		subtitleLabel.font = FontBrand.navBarTitleFont
		subtitleLabel.text = subtitle
		subtitleLabel.sizeToFit()

		let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 36))
		titleView.addSubview(titleLabel)
		titleView.addSubview(subtitleLabel)

		let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
		if widthDiff < 0 {
			let newX = widthDiff / 2
			subtitleLabel.frame.origin.x = abs(newX)
		} else {
			let newX = widthDiff / 2
			titleLabel.frame.origin.x = newX
		}

		navigationItem.titleView = titleView
	}

    func setTitle(title: String) {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -5, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = ColorBrand.white
        titleLabel.font = FontBrand.navBarTitleFont
        titleLabel.text = title
        titleLabel.sizeToFit()

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, .zero), height: 36))
        titleView.addSubview(titleLabel)
        titleLabel.center = titleView.center
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTitleBarButtonEvent)))

        navigationItem.titleView = titleView
    }
}
