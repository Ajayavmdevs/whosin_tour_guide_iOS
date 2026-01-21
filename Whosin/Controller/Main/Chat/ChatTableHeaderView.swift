import UIKit
import SnapKit

protocol ChatTableHeaderViewDelegate: class {
    func didSelectTab(at index: Int)
}

protocol NotificationHeaderViewDelegate: class {
    func didSelectType(_ type: String)
}

class ChatTableHeaderView: UIView {
    weak var delegate: ChatTableHeaderViewDelegate?
    private var tabLabels: [UILabel] = []
    private var tabbgView: [GradientView] = []
    private var selectIndicator: GradientView!
    private let containerView = UIView()
    private let stackView = UIStackView()
    public var selectedIndex: Int = 0
    public var isShowUnread: Bool = false
    private var unreadIndicators: [UIView] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGrayBackground()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGrayBackground() {
        containerView.backgroundColor = UIColor(hexString: "22222C")
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 9
        addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    public func setupTabLabels(_ list:[String] = []) {
        var tabTitles = list
        if list.isEmpty {
            if APPSESSION.userDetail?.isRingMember == true {
                tabTitles = ["friends".localized(), "complimentary".localized() , "group_chat".localized()]
            } else if APPSESSION.userDetail?.isPromoter == true {
                tabTitles = ["friends".localized(), "promoter".localized() , "group_chat".localized()]
            } else {
                tabTitles = ["friends".localized(), "group_chat".localized()]
            }
        }
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10

        for (index, title) in tabTitles.enumerated() {
            let gradientBackground = GradientView()
            gradientBackground.diagonalMode = true
            gradientBackground.translatesAutoresizingMaskIntoConstraints = false
            gradientBackground.startColor = .clear
            gradientBackground.endColor = .clear
            gradientBackground.layer.cornerRadius = 9

            let label = ExtendedTapAreaLabel()
            label.textAlignment = .center
            label.text = title
            label.textColor = ColorBrand.white
            label.font = FontBrand.SFsemiboldFont(size: 14)//MontserratSemiBoldFont(size: 14)
            label.tag = index
            label.isUserInteractionEnabled = true

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
            label.addGestureRecognizer(tapGesture)

            gradientBackground.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.centerXAnchor.constraint(equalTo: gradientBackground.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: gradientBackground.centerYAnchor).isActive = true

            stackView.addArrangedSubview(gradientBackground)
            tabLabels.append(label)
            tabbgView.append(gradientBackground)
        }


        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
                stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5)
            ])
        
        for label in tabLabels {
            let unreadIndicator = UIView()
            unreadIndicator.backgroundColor = .red
            unreadIndicator.layer.cornerRadius = 4
            unreadIndicator.translatesAutoresizingMaskIntoConstraints = false
            unreadIndicator.isHidden = true
            label.addSubview(unreadIndicator)
            unreadIndicators.append(unreadIndicator)

            NSLayoutConstraint.activate([
                unreadIndicator.widthAnchor.constraint(equalToConstant: 8),
                unreadIndicator.heightAnchor.constraint(equalToConstant: 8),
                unreadIndicator.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5),
                unreadIndicator.topAnchor.constraint(equalTo: label.topAnchor, constant: 5)
            ])
        }
        setupSelectIndicator()
    }


    private func setupSelectIndicator() {
        tabbgView[selectedIndex].startColor =  UIColor.init(hexString: "#1333DE")
        tabbgView[selectedIndex].endColor = UIColor.init(hexString: "#8F55EE")
        tabbgView[selectedIndex].diagonalMode = true
    }
    
    public func setupData(_ index: Int) {
        selectedIndex = index
        moveSelectIndicator(to: index)
    }
    
    public func hideShowUnreadIndicator(at index: Int, isHide:Bool = false) {
        guard index >= 0, index < unreadIndicators.count else { return }
        unreadIndicators[index].isHidden = isHide
    }

    public func showUnreadIndicator(at index: Int) {
        guard index >= 0, index < unreadIndicators.count else { return }
        unreadIndicators[index].isHidden = false
    }
    
    public func hideUnreadIndicator(at index: Int ) {
        guard index >= 0, index < unreadIndicators.count else { return }
        unreadIndicators[index].isHidden = true
    }

    @objc private func tabTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedLabel = sender.view as? UILabel else { return }
        let selectedIndex = selectedLabel.tag

        moveSelectIndicator(to: selectedIndex)
        delegate?.didSelectTab(at: selectedIndex)
    }

    public func moveSelectIndicator(to index: Int) {
        for (i, bgView) in tabbgView.enumerated() {
            if i == index {
                bgView.startColor = UIColor(hexString: "#1333DE")
                bgView.endColor = UIColor(hexString: "#8F55EE")
                bgView.diagonalMode = true
            } else {
                bgView.startColor = .clear
                bgView.endColor = .clear
                bgView.diagonalMode = true
            }
        }
        selectedIndex = index
    }

}

class ExtendedTapAreaLabel: UILabel {
    private var touchInsets: UIEdgeInsets = UIEdgeInsets(top: -50, left: -50, bottom: -50, right: -50)

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let extendedBounds = bounds.inset(by: touchInsets)
        return extendedBounds.contains(point)
    }
}

class CustomNotificationHeaderView: UIView {
    weak var delegate: NotificationHeaderViewDelegate?
    public var isNotification: Bool = false
    public var selectedType: String = "users" {
        didSet {
            userBtn.backgroundColor = selectedType == "users" ? ColorBrand.brandPink : UIColor(hexString: "#18171D")
            eventsBtn.backgroundColor = selectedType == "events" ? ColorBrand.brandPink : UIColor(hexString: "#18171D")
            userBtn.borderWidth = selectedType == "users" ? 0 : 1
            eventsBtn.borderWidth = selectedType == "events" ? 0 : 1
            searchContainerView.isHidden = isNotification ? true : selectedType != "users"
            delegate?.didSelectType(selectedType)
        }
    }
    
    private var buttonsView: UIView!
    private var userBtn: UIButton!
    private var eventsBtn: UIButton!
    public var searchBar: UISearchBar!
    public var filterBtn: UIButton!
    private var searchContainerView: UIView!
    private var filterDot: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlurBackground()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBlurBackground() {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false

        let mainView = UIStackView()
        mainView.axis = .vertical
        mainView.spacing = 0
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        userBtn = createButton(withTitle: "users".localized(), action: #selector(usersButtonTapped))
        eventsBtn = createButton(withTitle: "events".localized(), action: #selector(eventsButtonTapped))
        
        buttonStackView.addArrangedSubview(userBtn)
        buttonStackView.addArrangedSubview(eventsBtn)
        
        buttonsView = UIView(frame: bounds)
        buttonsView.backgroundColor = .clear
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.frame = bounds
        buttonsView.addSubview(buttonStackView)
        
        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(3)
        }
        
        searchContainerView = UIView()
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.backgroundColor = ColorBrand.clear
        
        searchBar = UISearchBar()
        searchBar.placeholder = "search".localized() + "..."
        searchBar.setSearchFieldBackgroundImage(UIImage(named: "ic_searchBg"), for: .normal)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        
        filterBtn = UIButton(type: .custom)
        filterBtn.setImage(UIImage(named: "icon_filter"), for: .normal)
        filterBtn.backgroundColor = UIColor(hexString: "#151516")
        filterBtn.layer.cornerRadius = 8
        
        filterDot = UIView()
        filterDot.backgroundColor = .red
        filterDot.layer.cornerRadius = 6
        filterDot.isHidden = true
        
        searchContainerView.addSubview(searchBar)
        searchContainerView.addSubview(filterBtn)
        searchContainerView.addSubview(filterDot)
        
        searchBar.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.leading.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.trailing.equalTo(filterBtn.snp.leading).offset(-5)
        }
        
        filterBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(searchBar)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        filterDot.snp.makeConstraints { make in
            make.trailing.equalTo(filterBtn.snp.trailing)
            make.top.equalTo(filterBtn.snp.top).offset(-5)
            make.height.equalTo(12)
            make.width.equalTo(12)
        }
        
        mainView.addArrangedSubview(buttonsView)
        mainView.addArrangedSubview(searchContainerView)
        
        visualEffectView.contentView.addSubview(mainView)
        addSubview(visualEffectView)

//        addSubview(mainView)
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        // Main view constraints
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: topAnchor),
            mainView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchContainerView.heightAnchor.constraint(equalToConstant: 70),
            buttonsView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func createButton(withTitle title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hexString: "#18171D")
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 12.5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    public func setupData(selectedType: String, filter: Bool = false) {
        filterDot.isHidden = !filter
        self.selectedType = selectedType
    }
    
    @objc private func usersButtonTapped() {
        selectedType = "users"
    }
    
    @objc private func eventsButtonTapped() {
        selectedType = "events"
    }
}

protocol CustomPromoterEventDelegate: AnyObject {
    func didTapButton(at index: Int)
}

class CustomHeaderView: UIView {
    weak var delegate: CustomPromoterEventDelegate?

    private var buttons: [UIButton] = []
    private var buttonTitles: [String] = []
    private var selectedButton: UIButton?

    init(buttonTitles: [String]) {
        self.buttonTitles = buttonTitles
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        for title in buttonTitles {
            let button = createButton(title: title)
            buttons.append(button)
            addSubview(button)
        }

        layoutButtons()
    }

    public func setUpSelected(_ index: Int) {
        guard index >= 0 && index < buttons.count else { return }
        
        if let previouslySelected = selectedButton, previouslySelected == buttons[index] {
            unselectButton(previouslySelected)
            selectedButton = nil
            delegate?.didTapButton(at: -1)
        } else {
            if let selected = selectedButton {
                unselectButton(selected)
            }
            updateButtonSelection(selectedButton: buttons[index])
            selectedButton = buttons[index]
            delegate?.didTapButton(at: index)
        }
    }
    
    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor(hexString: "#282828")
        button.setTitleColor(ColorBrand.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }

    private func layoutButtons() {
        for (index, button) in buttons.enumerated() {
            button.translatesAutoresizingMaskIntoConstraints = false
            if index == 0 {
                button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
            } else {
                button.leadingAnchor.constraint(equalTo: buttons[index - 1].trailingAnchor, constant: 10).isActive = true
            }
            button.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 120).isActive = true
        }

        buttons.last?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let index = buttons.firstIndex(of: sender) else { return }

        if sender == selectedButton {
            unselectButton(sender)
            selectedButton = nil
            delegate?.didTapButton(at: -1)
        } else {
            updateButtonSelection(selectedButton: sender)
            selectedButton = sender
            delegate?.didTapButton(at: index)
        }
    }

    private func updateButtonSelection(selectedButton: UIButton) {
        for button in buttons {
            button.backgroundColor = UIColor(hexString: "#282828")
        }
        selectedButton.backgroundColor = ColorBrand.brandPink
    }

    private func unselectButton(_ button: UIButton) {
        button.backgroundColor = UIColor(hexString: "#282828")
    }
}



