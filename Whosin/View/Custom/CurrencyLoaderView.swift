import UIKit

class CurrencyLoaderView: UIView {

    // MARK: - Subviews
    private let backgroundView = UIView()
    private let loaderIcon = UIActivityIndicatorView(style: .large)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // MARK: - Static Instance
    private static var sharedInstance: CurrencyLoaderView?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup UI
    private func setupView() {
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor.white.withAlphaComponent(0.2)

        // Background container
        backgroundView.backgroundColor = ColorBrand.brandBSHeaderColor
        backgroundView.layer.cornerRadius = 16
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)

        // Loader
        loaderIcon.color = ColorBrand.brandPink
        loaderIcon.translatesAutoresizingMaskIntoConstraints = false
        loaderIcon.startAnimating()
        backgroundView.addSubview(loaderIcon)

        // Title
        titleLabel.text = "updating_currency".localized()
        titleLabel.textColor = ColorBrand.white
        titleLabel.font = FontBrand.SFboldFont(size: 18)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(titleLabel)

        // Subtitle
        subtitleLabel.text = "pleaseWait".localized()
        subtitleLabel.textColor = ColorBrand.white.withAlphaComponent(0.7)
        subtitleLabel.font = FontBrand.SFregularFont(size: 15)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(subtitleLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 240),
            backgroundView.heightAnchor.constraint(equalToConstant: 160),

            loaderIcon.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            loaderIcon.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 24),

            titleLabel.topAnchor.constraint(equalTo: loaderIcon.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Show
    static func show(title: String = "updating_currency".localized(), subtitle: String = "pleaseWait".localized()) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        if sharedInstance != nil { return }
        let loader = CurrencyLoaderView()
        loader.setTexts(title: title, subtitle: subtitle)
        sharedInstance = loader
        window.addSubview(loader)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            hide {
                showToast(title == "updating_currency".localized() ? "currency_updated".localized() : "language_updated".localized())
                navigateToMainTabBar()
            }
        }
    }
    
    private func setTexts(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    // MARK: - Hide
    static func hide(completion: (() -> Void)? = nil) {
        guard let loader = sharedInstance else {
            completion?()
            return
        }

        UIView.animate(withDuration: 0.5, animations: {
            loader.alpha = 0
        }) { _ in
            loader.removeFromSuperview()
            sharedInstance = nil
            completion?()
        }
    }

    // MARK: - Toast Method
    private static func showToast(_ message: String) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        let toast = UILabel()
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toast.textColor = .white
        toast.font = UIFont.systemFont(ofSize: 14)
        toast.textAlignment = .center
        toast.text = message
        toast.numberOfLines = 0
        toast.alpha = 0
        toast.layer.cornerRadius = 8
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false

        window.addSubview(toast)

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -100),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: window.leadingAnchor, constant: 40),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: window.trailingAnchor, constant: -40),
        ])

        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                toast.alpha = 0
            }) { _ in
                toast.removeFromSuperview()
            }
        }
    }

    // MARK: - Navigation
    private static func navigateToMainTabBar() {
        if APP.window == nil {
            APP.window = UIWindow(frame: UIScreen.main.bounds)
        }

        guard let window = APP.window else { return }
        window.backgroundColor = ColorBrand.brandAppBgColor

        let controller = INIT_CONTROLLER_XIB(MainTabBarVC.self)
        window.setRootViewController(controller, options: .init(direction: .fade, style: .easeInOut))
    }
}


class LangguageLoaderView: UIView {

    // MARK: - Subviews
    private let backgroundView = UIView()
    private let loaderIcon = UIActivityIndicatorView(style: .large)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // MARK: - Static Instance
    private static var sharedInstance: LangguageLoaderView?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup UI
    private func setupView() {
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor.white.withAlphaComponent(0.2)

        // Background container
        backgroundView.backgroundColor = ColorBrand.brandBSHeaderColor
        backgroundView.layer.cornerRadius = 16
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)

        // Loader
        loaderIcon.color = ColorBrand.brandPink
        loaderIcon.translatesAutoresizingMaskIntoConstraints = false
        loaderIcon.startAnimating()
        backgroundView.addSubview(loaderIcon)

        // Title
        titleLabel.text = "updating_language".localized()
        titleLabel.textColor = ColorBrand.white
        titleLabel.font = FontBrand.SFboldFont(size: 18)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(titleLabel)

        // Subtitle
        subtitleLabel.text = "pleaseWait".localized()
        subtitleLabel.textColor = ColorBrand.white.withAlphaComponent(0.7)
        subtitleLabel.font = FontBrand.SFregularFont(size: 15)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(subtitleLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 240),
            backgroundView.heightAnchor.constraint(equalToConstant: 160),

            loaderIcon.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            loaderIcon.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 24),

            titleLabel.topAnchor.constraint(equalTo: loaderIcon.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Show
    static func show(title: String = "updating_language".localized(), subtitle: String = "pleaseWait".localized()) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        if sharedInstance != nil { return }
        let loader = LangguageLoaderView()
        loader.setTexts(title: title, subtitle: subtitle)
        sharedInstance = loader
        window.addSubview(loader)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            hide {
                showToast(title == "updating_language".localized() ? "language_updated".localized() : "language_updated".localized())
                navigateToMainTabBar()
            }
        }
    }
    
    private func setTexts(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    // MARK: - Hide
    static func hide(completion: (() -> Void)? = nil) {
        guard let loader = sharedInstance else {
            completion?()
            return
        }

        UIView.animate(withDuration: 0.5, animations: {
            loader.alpha = 0
        }) { _ in
            loader.removeFromSuperview()
            sharedInstance = nil
            completion?()
        }
    }

    // MARK: - Toast Method
    private static func showToast(_ message: String) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        let toast = UILabel()
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toast.textColor = .white
        toast.font = UIFont.systemFont(ofSize: 14)
        toast.textAlignment = .center
        toast.text = message
        toast.numberOfLines = 0
        toast.alpha = 0
        toast.layer.cornerRadius = 8
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false

        window.addSubview(toast)

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -100),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: window.leadingAnchor, constant: 40),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: window.trailingAnchor, constant: -40),
        ])

        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                toast.alpha = 0
            }) { _ in
                toast.removeFromSuperview()
            }
        }
    }

    // MARK: - Navigation
    private static func navigateToMainTabBar() {
        if APP.window == nil {
            APP.window = UIWindow(frame: UIScreen.main.bounds)
        }

        guard let window = APP.window else { return }
        window.backgroundColor = ColorBrand.brandAppBgColor
        let controller = INIT_CONTROLLER_XIB(MainTabBarVC.self)
        window.setRootViewController(controller, options: .init(direction: .fade, style: .easeInOut))
    }
}


