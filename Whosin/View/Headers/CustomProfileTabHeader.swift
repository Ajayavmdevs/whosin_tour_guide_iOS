import UIKit

class CustomProfileTabHeader: UIView {
    weak var delegate: ProfileTableHeaderViewDelegate?

    private var tabLabels: [UILabel] = []
    private var underlineView: UIView!
    private let containerView = UIView()
    private let stackView = UIStackView()

    public var selectedIndex: Int = 0 {
        didSet {
            updateTabAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGrayBackground()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGrayBackground() {
        containerView.backgroundColor = UIColor(hexString: "18171D")
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    public func setupTabLabels(_ list: [String] = []) {
        var tabTitles = list
        if list.isEmpty {
            tabTitles = ["feed".localized(), "my_plan".localized(), "my_event".localized(), "friends".localized()]
        }

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10

        for (index, title) in tabTitles.enumerated() {
            let label = UILabel()
            label.setupLabel(text: title, textColor: ColorBrand.white, font: FontBrand.SFsemiboldFont(size: 14))
            label.tag = index
            label.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
            label.addGestureRecognizer(tapGesture)
            stackView.addArrangedSubview(label)
            tabLabels.append(label)
        }

        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5)
        ])

        underlineView = UIView()
        underlineView.backgroundColor =  UIColor(hexString: "6C7A9C")
        containerView.addSubview(underlineView)
        updateTabAppearance()
        updateUnderlinePosition(selectedTab: 0)
    }

    @objc private func tabTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedLabel = sender.view as? UILabel else { return }
        let selectedIndex = selectedLabel.tag
        self.selectedIndex = selectedIndex
        delegate?.didSelectTab(at: selectedIndex)
        updateUnderlinePosition(selectedTab: selectedIndex)
    }

    private func updateUnderlinePosition(selectedTab: Int) {
        let selectedLabel = tabLabels[selectedTab]
        UIView.animate(withDuration: 0.3) {
            self.underlineView.frame.origin.x = selectedLabel.frame.origin.x
            self.underlineView.frame.size.width = selectedLabel.frame.size.width
        }
    }

    private func updateTabAppearance() {
        for (index, label) in tabLabels.enumerated() {
            if index == selectedIndex {
                label.textColor = ColorBrand.white 
            } else {
                label.textColor = ColorBrand.brandLightGray
            }
        }
        updateUnderlinePosition(selectedTab: selectedIndex)
    }
}

extension UILabel {
    func setupLabel(text: String, textColor: UIColor, font: UIFont) {
        self.text = text
        self.textColor = textColor
        self.font = font
        self.textAlignment = .center
    }
}
