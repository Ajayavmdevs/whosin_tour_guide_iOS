import UIKit

class PaymentBottomSheet: UIView {
    
    // MARK: - Properties
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBrand.brandAppBgColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("pay_with_card".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setImageTintColor(.white)
        button.backgroundColor = ColorBrand.brandPink
        button.layer.cornerRadius = 8
        button.titleLabel?.font = FontBrand.SFsemiboldFont(size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "select_payment_options".localized()
        label.font = FontBrand.SFboldFont(size: 16)
        label.textColor = ColorBrand.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var isTabbyDisable: Bool = false {
        didSet {
            updateTabbyState()
        }
    }
    var creditCardAction: (() -> Void)?
    var applePayAction: (() -> Void)?
    var viaLinkAction: (() -> Void)?
    var tabbyAction: (() -> Void)?
    var learnMore: (() -> Void)?
//    var ngeniusAction: (() -> Void)?
    
    private var selectedOption: Int = 0 { // 0 for Credit Card, 1 for Apple Pay, 2 for Via Link, 3 for Tabby (if allowed)
        didSet {
            updateRadioButtonStates()
            updatePayButtonTitle()
        }
    }
    
    private var radioButtons: [UIImageView] = []
    private var tabbyMinAmountLabel: UILabel? // Minimum amount label for Tabby
    private var tabbyContainer: UIView? // Store reference to Tabby container for graying out
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(stackView)
        containerView.addSubview(closeButton)
        containerView.addSubview(payButton)
        	
        // Add payment options
        let creditCardOption = createPaymentOption(
            icon: UIImage(systemName: "creditcard")!,
            title: "pay_with_card".localized(),
            description: "pay_with_credit_or_debit_card".localized(),
            tag: 0
        )
        
        let applePayOption = createPaymentOption(
            icon: UIImage(systemName: "applelogo")!,
            title: "apple_pay".localized(),
            description: "secure_payment_with_apple_pay".localized(),
            tag: 1
        )
        
//        let ngeniusOption = createPaymentOption(
//            icon: UIImage(named: "ngenius_icon") ?? UIImage(systemName: "creditcard")!,
//            title: "pay_with_ngenius".localized(),
//            description: "secure_payment_ngenius_gateway".localized(),
//            tag: 2
//        )
        
//        let viaLinkOption = createPaymentOption(
//            icon: UIImage(named: "link_pay")!,
//            title: "pay_with_link".localized(),
//            description: "secure_payment_with_link".localized(),
//            tag: 2
//        )
        
        stackView.addArrangedSubview(creditCardOption)
        stackView.addArrangedSubview(applePayOption)
//        stackView.addArrangedSubview(ngeniusOption)
//        stackView.addArrangedSubview(viaLinkOption)
        
        // Conditionally add Tabby option based on APPSETTING.appSetiings?.allowTabbyPayments
        if APPSETTING.appSetiings?.allowTabbyPayments == true {
            let tabbyOption = createPaymentOption(
                icon: UIImage(named: "tabby_icon") ?? UIImage(systemName: "creditcard")!,
                title: "tabby".localized(),
                description: "pay_in_4_no_interest_no_fees".localized(),
                tag: 3,
                isTabby: true
            )
            tabbyContainer = tabbyOption // Store Tabby container reference
            stackView.addArrangedSubview(tabbyOption)
        }
        
        // Constraints
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            payButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            payButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            payButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30),
            payButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        addGestureRecognizer(tapGesture)
        closeButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        payButton.addTarget(self, action: #selector(executePayment), for: .touchUpInside)
        
        // Set initial state
        updateRadioButtonStates()
        updatePayButtonTitle()
        updateTabbyState()
    }
    
    // MARK: - Create Payment Option View
    private func createPaymentOption(icon: UIImage, title: String, description: String, tag: Int, isTabby: Bool = false) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionSelected(_:)))
        container.isUserInteractionEnabled = true
        tapGesture.cancelsTouchesInView = false
        container.tag = tag
        container.addGestureRecognizer(tapGesture)
        
//        let button = PassthroughButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
//        button.tag = tag
        
        let radioButton = UIImageView()
        radioButton.contentMode = .scaleAspectFit
        radioButton.image = UIImage(named: "icon_radio")
        radioButton.tintColor = ColorBrand.white.withAlphaComponent(0.8)
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButtons.append(radioButton)
        
        let iconImageView = UIImageView(image: icon)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = ColorBrand.white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = FontBrand.SFregularFont(size: 16)
        titleLabel.textColor = ColorBrand.white
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = FontBrand.SFregularFont(size: 14)
        descriptionLabel.textColor = ColorBrand.white.withAlphaComponent(0.7)
        descriptionLabel.numberOfLines = 0

        // Optional views
        var learnMoreButton: PassthroughButton?
        var minAmountLabel: UILabel?

        let contentStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        contentStack.axis = .vertical
        contentStack.spacing = 2
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        if isTabby {
            // Add Learn More
            let learnBtn = PassthroughButton(type: .system)
            let learnText = NSAttributedString(
                string: "learn_more".localized(),
                attributes: [
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: ColorBrand.brandPink,
                    .font: FontBrand.SFregularFont(size: 12)
                ]
            )
            learnBtn.setAttributedTitle(learnText, for: .normal)
            learnBtn.contentHorizontalAlignment = .left
            learnBtn.addTarget(self, action: #selector(learnMoreTapped(_:)), for: .touchUpInside)
            learnBtn.tag = tag
            learnBtn.translatesAutoresizingMaskIntoConstraints = false
            contentStack.addArrangedSubview(learnBtn)
            learnMoreButton = learnBtn
            
            // Add Min Label
            let minLabel = UILabel()
            let currency = APPSESSION.userDetail?.currency.lowercased() ?? "AED"
            minLabel.text = LANGMANAGER.localizedString(forKey: "minimum_amount_is", arguments: ["value": "\(currency.isEmpty ? "AED" : currency)"])
            minLabel.font = FontBrand.SFregularFont(size: 12)
            minLabel.textColor = .red
            minLabel.isHidden = true
            minLabel.translatesAutoresizingMaskIntoConstraints = false
            contentStack.addArrangedSubview(minLabel)
            minAmountLabel = minLabel
            tabbyMinAmountLabel = minLabel
        }

        let separator = UIView()
        separator.backgroundColor = ColorBrand.white.withAlphaComponent(0.2)
        separator.translatesAutoresizingMaskIntoConstraints = false

//        container.addSubview(button)
        container.addSubview(iconImageView)
        container.addSubview(radioButton)
        container.addSubview(contentStack)
        container.addSubview(separator)

        NSLayoutConstraint.activate([
//            button.topAnchor.constraint(equalTo: container.topAnchor),
//            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),

            radioButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            radioButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            radioButton.widthAnchor.constraint(equalToConstant: 24),
            radioButton.heightAnchor.constraint(equalToConstant: 24),

            contentStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
            contentStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 15),
            contentStack.trailingAnchor.constraint(equalTo: radioButton.leadingAnchor, constant: -15),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -15),

            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])

        return container
    }


    
    @objc private func learnMoreTapped(_ sender: UIButton) {
        learnMore?()
        dismiss()
    }

    
    // MARK: - Actions
    @objc private func optionSelected(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }
        let tag = tappedView.tag
        if tag == 3 && (isTabbyDisable || APPSETTING.appSetiings?.allowTabbyPayments == false) {
            return // Prevent selection of Tabby when disabled or not allowed
        }
        selectedOption = tag
    }
    
    @objc private func executePayment() {
        switch selectedOption {
        case 0:
            creditCardAction?()
        case 1:
            applePayAction?()
//        case 2:
//            print("")
//            ngeniusAction?()
//            viaLinkAction?()
        case 3:
            if !isTabbyDisable && APPSETTING.appSetiings?.allowTabbyPayments == true {
                tabbyAction?()
            }
        case 4:
            viaLinkAction?()
        default:
            break
        }
        dismiss()
    }
    
    private func updateRadioButtonStates() {
        for (index, radioButton) in radioButtons.enumerated() {
            if index == 3 && (isTabbyDisable || APPSETTING.appSetiings?.allowTabbyPayments == false) {
                radioButton.image = UIImage(named: "icon_radio") // Keep unselected when disabled or not allowed
                radioButton.alpha = 0.5 // Dim to indicate disabled
            } else {
                radioButton.image = UIImage(named: index == selectedOption ? "icon_radioPink" : "icon_radio")
                radioButton.alpha = 1.0
            }
        }
    }
    
    private func updatePayButtonTitle() {
        let title: String
        let iconImage: UIImage
        var imageSize = CGSize(width: 20, height: 20)
        switch selectedOption {
        case 0:
            title = "pay_with_card".localized()
            iconImage = UIImage(systemName: "creditcard")?.withTintColor(ColorBrand.white) ?? UIImage()
            imageSize = CGSize(width: 30, height: 20)
        case 1:
            title = "pay_with_apple_pay".localized()
            iconImage = UIImage(systemName: "applelogo")?.withTintColor(ColorBrand.white) ?? UIImage()
//        case 2:
//            print("")
//            title = "pay_via_link".localized()
//            iconImage = UIImage(named: "link_pay_white")!
//            title = "pay_with_ngenius".localized()
//            iconImage = UIImage(named: "ngenius_icon") ?? UIImage()
//            imageSize = CGSize(width: 40, height: 20)

        case 3 where APPSETTING.appSetiings?.allowTabbyPayments == true:
            title = "pay_with_tabby".localized()
            iconImage = UIImage(named: "tabby_icon_white")!
            imageSize = CGSize(width: 60, height: 20)
        default:
            iconImage = UIImage(systemName: "creditcard")!
            title = "pay".localized()
        }
        let resizedImage = resizeImage(image: iconImage, targetSize: imageSize)
            
        payButton.setTitle(title, for: .normal)
        payButton.setImage(resizedImage.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage
    }
    
    private func updateTabbyState() {
        if let tabbyLabel = tabbyMinAmountLabel {
            tabbyLabel.isHidden = !isTabbyDisable
        }
        if let tabbyContainer = tabbyContainer, APPSETTING.appSetiings?.allowTabbyPayments == true {
            // Gray out the Tabby option when disabled (only if Tabby is allowed)
            if isTabbyDisable {
                for subview in tabbyContainer.subviews {
                    if let imageView = subview as? UIImageView, imageView != radioButtons.last { // Icon
                        imageView.tintColor = .gray
                    } else if let label = subview as? UILabel, label != tabbyMinAmountLabel { // Title and Description
                        label.textColor = label.textColor.withAlphaComponent(0.5) // Reduce opacity
                    }
                }
            } else {
                for subview in tabbyContainer.subviews {
                    if let imageView = subview as? UIImageView, imageView != radioButtons.last { // Icon
                        imageView.tintColor = ColorBrand.white
                    } else if let label = subview as? UILabel, label != tabbyMinAmountLabel { // Title and Description
                        if label.font == FontBrand.SFregularFont(size: 16) { // Title
                            label.textColor = ColorBrand.white
                        } else { // Description
                            label.textColor = ColorBrand.white.withAlphaComponent(0.7)
                        }
                    }
                }
            }
        }
        if (isTabbyDisable || APPSETTING.appSetiings?.allowTabbyPayments == false) && selectedOption == 3 {
            selectedOption = 0 // Reset to default if Tabby is disabled or not allowed
        }
        updateRadioButtonStates()
        updatePayButtonTitle()
    }
    
    @objc private func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Show Method
    func show(in viewController: UIViewController) {
        frame = viewController.view.bounds
        viewController.view.addSubview(self)
        
        containerView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
        alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.containerView.transform = .identity
        }
    }
}

class PassthroughButton: UIButton {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in subviews {
            let convertedPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }
        return super.hitTest(point, with: event)
    }
}

