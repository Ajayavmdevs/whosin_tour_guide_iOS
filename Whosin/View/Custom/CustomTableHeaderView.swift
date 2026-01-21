import UIKit
import SnapKit

protocol CustomHeaderViewDelegate: class {
    func didSelectTab(at index: Int)
    func notificationType(type: String)
}

class CustomTableHeaderView: UIView {
    weak var delegate: CustomHeaderViewDelegate?
    private var tabLabels: [UILabel] = []
    private var selectIndicator: UIView!
    public var selectedIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlurBackground()
        setupTabLabels()
        setupSelectIndicator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBlurBackground() {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        addSubview(blurView)
    }
    
    private func setupTabLabels() {
        let tabTitles = ["offers".localized(), "activity".localized(), "event".localized()]
        let labelWidth = frame.width / CGFloat(tabTitles.count)
        
        for (index, title) in tabTitles.enumerated() {
            let label = UILabel(frame: CGRect(x: CGFloat(index) * labelWidth, y: 0, width: labelWidth, height: frame.height))
            label.textAlignment = .center
            label.text = title
            label.tag = index
            label.isUserInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
            label.addGestureRecognizer(tapGesture)
            
            addSubview(label)
            tabLabels.append(label)
        }
    }
    
    private func setupSelectIndicator() {
        let indicatorHeight: CGFloat = 3.0
        let indicatorWidth: CGFloat = 30.0
        
        selectIndicator = UIView(frame: CGRect(x: 0, y: frame.height - 10, width: indicatorWidth, height: indicatorHeight))
        selectIndicator.center.x = tabLabels[selectedIndex].center.x
        selectIndicator.backgroundColor = UIColor.init(hex: "#6C7A9C")
        addSubview(selectIndicator)
    }
    
    public func setupData(_ index: Int) {
        selectedIndex = index
        moveSelectIndicator(to: index)
    }

    
    @objc private func tabTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedLabel = sender.view as? UILabel else { return }
        let selectedIndex = selectedLabel.tag
        
        moveSelectIndicator(to: selectedIndex)
        delegate?.didSelectTab(at: selectedIndex)
    }
    
    private func moveSelectIndicator(to index: Int) {
        let label = tabLabels[index]
        
        UIView.animate(withDuration: 0.3) {
            self.selectIndicator.center.x = label.center.x
            self.selectIndicator.frame.size.width = 30
        }
        selectedIndex = index
    }

}


class CustomPromoterPublicHeaderView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var delegate: CustomHeaderViewDelegate?
    private var collectionView: UICollectionView!
    private var tabLabels: [String] = ["explore".localized(), "notifications".localized(), "message".localized(), "my_profile".localized()] //"My Profile", "Explorer", "Message", "Notifications"
    private var tabicons: [String] = ["icon_event", "icon_notify", "icon_message", "tab_profile"] // "tab_profile", "icon_event", "icon_message", "icon_notify"
    public var selectedIndex: Int = 0 {
        didSet {
            collectionView.reloadData()
            buttonsView.isHidden = selectedIndex != 4
        }
    }
    public var selectedType: String = "users" {
        didSet {
            collectionView.reloadData()
            userBtn.backgroundColor = selectedType == "users" ? ColorBrand.brandPink : UIColor(hexString: "#18171D")
            eventsBtn.backgroundColor = selectedType == "events" ? ColorBrand.brandPink : UIColor(hexString: "#18171D")
            userBtn.layer.borderWidth = selectedType == "users" ? 0 : 1
            eventsBtn.layer.borderWidth = selectedType == "events" ? 0 : 1
            delegate?.notificationType(type: selectedType)
        }
    }
    private var buttonsView: UIView!
    private var blurView: UIVisualEffectView!
    private var userBtn: UIButton!
    private var eventsBtn: UIButton!
    private var userBadge: UIView!
    private var eventBadge: UIView!
    private var userBadgeCount: UILabel!
    private var eventBadgeCount: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlurBackground()
        setupCollectionView()
        setUpBadge()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBlurBackground() {
        let mainView = UIStackView()
        mainView.axis = .vertical
        mainView.distribution = .fillEqually
        mainView.spacing = 10
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let usersButton = UIButton(type: .system)
        userBtn = usersButton
        userBtn.setTitle("users".localized(), for: .normal)
        userBtn.setTitleColor(.white, for: .normal)
        userBtn.backgroundColor = UIColor(hexString: "#18171D")
        userBtn.layer.borderColor = UIColor.white.cgColor
        userBtn.layer.borderWidth = 1
        userBtn.layer.cornerRadius = 12.5
        userBtn.frame.size.height = 25
        userBtn.addTarget(self, action: #selector(usersButtonTapped), for: .touchUpInside)
        
        let eventsButton = UIButton(type: .system)
        eventsBtn = eventsButton
        eventsBtn.setTitle("events".localized(), for: .normal)
        eventsBtn.setTitleColor(.white, for: .normal)
        eventsBtn.backgroundColor = UIColor(hexString: "#18171D")
        eventsBtn.layer.borderColor = UIColor.white.cgColor
        eventsBtn.layer.borderWidth = 1
        eventsBtn.layer.cornerRadius = 12.5
        eventsBtn.frame.size.height = 25
        eventsBtn.addTarget(self, action: #selector(eventsButtonTapped), for: .touchUpInside)
        
        buttonStackView.addArrangedSubview(userBtn)
        buttonStackView.addArrangedSubview(eventsBtn)
        
        let blurEffect = UIBlurEffect(style: .regular)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.backgroundColor = UIColor(hexString: "#2A2A2A")
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsView = UIView(frame: bounds)
        buttonsView.backgroundColor = .clear
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.frame = bounds
        buttonsView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        mainView.addArrangedSubview(blurView)
        mainView.addArrangedSubview(buttonsView)
        addSubview(mainView)
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: topAnchor),
            mainView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.heightAnchor.constraint(equalToConstant: 45),
            buttonsView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomTabCell.self, forCellWithReuseIdentifier: "CustomTabCell")
        blurView.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    private func setUpBadge() {
        userBadge = UIView()
        userBadgeCount = UILabel()
        userBadgeCount.font = UIFont.systemFont(ofSize: 10)
        userBadgeCount.textAlignment = .center
        userBadgeCount.text = "0"
        userBadge.layer.cornerRadius = 11
        userBadge.backgroundColor = UIColor.red
        userBadge.addSubview(userBadgeCount)
        userBadgeCount.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(2)
            make.centerY.equalToSuperview()
        }
        
        userBtn.addSubview(userBadge)
        userBadge.snp.makeConstraints { make in
            make.trailing.equalTo(userBtn.snp.trailing).inset(15)
            make.top.equalTo(userBtn.snp.top).inset(-10)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(22)
        }
        
        eventBadge = UIView()
        eventBadgeCount = UILabel()
        eventBadgeCount.font = UIFont.systemFont(ofSize: 10)
        eventBadgeCount.textAlignment = .center
        eventBadgeCount.text = "0"
        eventBadge.layer.cornerRadius = 11
        eventBadge.backgroundColor = UIColor.red
        eventBadge.addSubview(eventBadgeCount)
        eventBadgeCount.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(2)
            make.centerY.equalToSuperview()
        }
        
        eventsBtn.addSubview(eventBadge)
        eventBadge.snp.makeConstraints { make in
            make.trailing.equalTo(eventsBtn.snp.trailing).inset(15)
            make.top.equalTo(eventsBtn.snp.top).inset(-10)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(22)
        }
        
        eventBadge.isHidden = true
        userBadge.isHidden = true
    }
    
    public func setUpBadge(_ user: String, event: String) {
        eventBadge.isHidden = event == "0" || event.isEmpty
        eventBadgeCount.text = event
        userBadgeCount.text = user
        userBadge.isHidden = user == "0" || user.isEmpty
    }
    
    public func setupData(_ index: Int, selectedType: String) {
        selectedIndex = index
        if index == 4 {
            self.selectedType = selectedType
        }
        moveSelectIndicator(to: index)
    }
    
    private func moveSelectIndicator(to index: Int) {
        guard index >= 0 && index < tabLabels.count else { return }
        selectedIndex = index
        collectionView.reloadData()
//        let indexPath = IndexPath(item: selectedIndex, section: 0)
//        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc private func usersButtonTapped() {
        selectedType = "users"
    }
    
    @objc private func eventsButtonTapped() {
        selectedType = "events"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomTabCell", for: indexPath) as! CustomTabCell
        let title = tabLabels[indexPath.item]
        let icon = UIImage(named: tabicons[indexPath.item])
        cell.configure(with: title, icon: icon, isSelected: indexPath.item == selectedIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        moveSelectIndicator(to: indexPath.item)
        delegate?.didSelectTab(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.font = FontBrand.tabbarSelectedTitleFont
        label.text = tabLabels[indexPath.item]
        label.sizeToFit()
        return CGSize(width: (kScreenWidth - 15) / 4, height: collectionView.frame.height)
    }

}


class CustomPromoterHeaderView: UIView {
    weak var delegate: CustomHeaderViewDelegate?
    private var collectionView: UICollectionView!
    private var tabLabels: [String] = ["my_profile".localized(), "my_events".localized(), "event_history".localized(), "message".localized(), "notifications".localized()]
    private var tabicons: [String] = ["tab_profile", "icon_event", "icon_eventHistory", "icon_message", "icon_notify"]
    public var selectedIndex: Int = 0 {
        didSet {
            collectionView.reloadData()
            buttonsView.isHidden = true//selectedIndex != 4
        }
    }
    public var selectedType: String = "users" {
        didSet {
            collectionView.reloadData()
            userBtn.backgroundColor = selectedType == "users" ? ColorBrand.brandPink : UIColor(hexString: "#18171D")
            eventsBtn.backgroundColor = selectedType == "events" ? ColorBrand.brandPink : UIColor(hexString: "#18171D")
            userBtn.borderWidth = selectedType == "users" ? 0 : 1
            eventsBtn.borderWidth = selectedType == "events" ? 0 : 1
            delegate?.notificationType(type: selectedType)
        }
    }
    private var buttonsView: UIView!
    private var blurView: UIVisualEffectView!
    private var userBtn: UIButton!
    private var eventsBtn: UIButton!
    private var userBadge: UIView!
    private var eventBadge: UIView!
    private var userBadgeCount: UILabel!
    private var eventBadgeCount: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlurBackground()
        setupCollectionView()
        setUpBadge()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBlurBackground() {
        let mainView = UIStackView()
        mainView.axis = .vertical
        mainView.distribution = .fillEqually
        mainView.spacing = 10
        mainView.translatesAutoresizingMaskIntoConstraints = false

        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        let usersButton = UIButton(type: .system)
        userBtn = usersButton
        userBtn.setTitle("users".localized(), for: .normal)
        userBtn.setTitleColor(.white, for: .normal)
        userBtn.backgroundColor = UIColor(hexString: "#18171D")
        userBtn.layer.borderColor = UIColor.white.cgColor
        userBtn.layer.borderWidth = 1
        userBtn.layer.cornerRadius = 12.5
        userBtn.frame.size.height = 25
        userBtn.addTarget(self, action: #selector(usersButtonTapped), for: .touchUpInside)

        let eventsButton = UIButton(type: .system)
        eventsBtn = eventsButton
        eventsBtn.setTitle("events".localized(), for: .normal)
        eventsBtn.setTitleColor(.white, for: .normal)
        eventsBtn.backgroundColor = UIColor(hexString: "#18171D")
        eventsBtn.layer.borderColor = UIColor.white.cgColor
        eventsBtn.layer.borderWidth = 1
        eventsBtn.layer.cornerRadius = 12.5
        eventsBtn.frame.size.height = 25
        eventsBtn.addTarget(self, action: #selector(eventsButtonTapped), for: .touchUpInside)

        buttonStackView.addArrangedSubview(userBtn)
        buttonStackView.addArrangedSubview(eventsBtn)

        let blurEffect = UIBlurEffect(style: .regular)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.backgroundColor = UIColor(hexString: "#2A2A2A")
        blurView.translatesAutoresizingMaskIntoConstraints = false

        buttonsView = UIView(frame: bounds)
        buttonsView.backgroundColor = .clear
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.frame = bounds
        buttonsView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        mainView.addArrangedSubview(blurView)
        mainView.addArrangedSubview(buttonsView)
        addSubview(mainView)

        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: topAnchor),
            mainView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.heightAnchor.constraint(equalToConstant: 45),
            buttonsView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomTabCell.self, forCellWithReuseIdentifier: "CustomTabCell")
        blurView.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    private func setUpBadge() {
        let userBadge = UIView(frame: bounds)
        self.userBadge = userBadge
        let userCount = UILabel(frame: bounds)
        userBadgeCount = userCount
        userBadgeCount.font = UIFont.systemFont(ofSize: 10)
        userBadgeCount.textAlignment = .center
        userBadgeCount.text = "0"
        self.userBadge.frame.size.height = 22
        self.userBadge.layer.cornerRadius = 11
        self.userBadge.backgroundColor = UIColor.red
        self.userBadge.addSubview(userBadgeCount)
        userBadgeCount.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(2)
            make.centerY.equalToSuperview()
        }
        
        userBtn.addSubview(self.userBadge)
        self.userBadge.snp.makeConstraints { make in
            make.trailing.equalTo(userBtn.snp.trailing).inset(15)
            make.top.equalTo(userBtn.snp.top).inset(-10)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(22)
        }
        
        let eventBadge = UIView(frame: bounds)
        self.eventBadge = eventBadge
        let eventCount = UILabel()
        eventBadgeCount = eventCount
        eventBadgeCount.font = UIFont.systemFont(ofSize: 10)
        eventBadgeCount.textAlignment = .center
        eventBadgeCount.text = "0"
        self.eventBadge.frame.size.height = 22
        self.eventBadge.layer.cornerRadius = 11
        self.eventBadge.backgroundColor = UIColor.red
        self.eventBadge.addSubview(eventBadgeCount)
        eventBadgeCount.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(2)
            make.centerY.equalToSuperview()
        }
        
        eventsBtn.addSubview(self.eventBadge)
        self.eventBadge.snp.makeConstraints { make in
            make.trailing.equalTo(eventsBtn.snp.trailing).inset(15)
            make.top.equalTo(eventsBtn.snp.top).inset(-10)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(22)
        }
        self.eventBadge.isHidden = true
        self.userBadge.isHidden = true
    }

    public func setUpBadge(_ user: String, event: String) {
        eventBadge.isHidden = event == "0" || event.isEmpty
        eventBadgeCount.text = event
        userBadgeCount.text = user
        userBadge.isHidden = user == "0" || user.isEmpty
    }
    
    public func setupData(_ index: Int, selectedType: String) {
        selectedIndex = index
        if index == 4 {
            self.selectedType = selectedType
        }
        moveSelectIndicator(to: index)
    }
    
    private func moveSelectIndicator(to index: Int) {
        guard index >= 0 && index < tabLabels.count else { return }
        selectedIndex = index
        collectionView.reloadData()
        DISPATCH_ASYNC_MAIN {
                    let indexPath = IndexPath(item: self.selectedIndex, section: 0)
//                    self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                }

    }

    
    @objc private func usersButtonTapped() {
        selectedType = "users"
    }
    
    @objc private func eventsButtonTapped() {
        selectedType = "events"
    }
}

extension CustomPromoterHeaderView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomTabCell", for: indexPath) as! CustomTabCell
        let title = tabLabels[indexPath.item]
        let icon = UIImage(named: tabicons[indexPath.row])
        cell.configure(with: title, icon: icon, isSelected: indexPath.item == selectedIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        moveSelectIndicator(to: indexPath.item)
        delegate?.didSelectTab(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.font = FontBrand.tabbarSelectedTitleFont
        label.text = tabLabels[indexPath.item]
        label.sizeToFit()
        return CGSize(width: (kScreenWidth - 10) / 5, height: collectionView.frame.height)
    }
}


class MainPromoterHeaderView: UIView {
    weak var delegate: CustomHeaderViewDelegate?
    private var tabLabels: [UILabel] = []
    private var tabImages: [UIImageView] = []
    public var selectedIndex: Int = 0
    private var stackView: UIStackView!
    private var blurView: UIVisualEffectView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
        setupTabLabels()
        setupSelectIndicator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStackView() {
        stackView = UIStackView(frame: bounds)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(5)
        }
    }
    
    private func setupTabLabels() {
        let tabTitles = ["profile".localized(),"chat".localized(), "notifications".localized()]
        let tabImagesNames = ["tab_profile","tab_chat", "icon_notification"]
        
        for (index, title) in tabTitles.enumerated() {
            let container = UIView()
            container.tag = index
            container.isUserInteractionEnabled = true
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: tabImagesNames[index])?.withRenderingMode(.alwaysTemplate)
            imageView.frame.size = CGSize(width: 24, height: 24)
            imageView.tintColor = ColorBrand.tabUnselect
            tabImages.append(imageView)
            
            let label = UILabel()
            label.textAlignment = .center
            label.text = title
            label.textColor = ColorBrand.tabUnselect
            label.font = FontBrand.tabbarTitleFont
            label.tag = index
            tabLabels.append(label)
            
            let stack = UIStackView(arrangedSubviews: [imageView, label])
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 2
            
            container.addSubview(stack)
            stack.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
            container.addGestureRecognizer(tapGesture)
            
            stackView.addArrangedSubview(container)
        }
    }
    
    private func setupSelectIndicator() {
        guard selectedIndex < tabLabels.count else { return }
        tabLabels[selectedIndex].textColor = ColorBrand.tabSelectColor
        tabLabels[selectedIndex].font = FontBrand.tabbarSelectedTitleFont
        tabImages[selectedIndex].tintColor = ColorBrand.tabSelectColor
    }
    
    public func setupData(_ index: Int, selectedType: String) {
        selectedIndex = index
        moveSelectIndicator(to: index)
    }
    
    @objc private func tabTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedContainer = sender.view else { return }
        let selectedIndex = selectedContainer.tag
        
        moveSelectIndicator(to: selectedIndex)
        delegate?.didSelectTab(at: selectedIndex)
    }
    
    private func moveSelectIndicator(to index: Int) {
        for (i, label) in tabLabels.enumerated() {
            if i == index {
                UIView.animate(withDuration: 0.3) {
                    label.textColor = ColorBrand.tabSelectColor
                    label.font = FontBrand.tabbarSelectedTitleFont
                    self.tabImages[i].tintColor = ColorBrand.tabSelectColor
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    label.textColor = ColorBrand.tabUnselect
                    label.font = FontBrand.tabbarTitleFont
                    self.tabImages[i].tintColor = ColorBrand.tabUnselect
                }
            }
        }
        selectedIndex = index
    }
}


class CustomTabCell: UICollectionViewCell {
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        iconImageView.contentMode = .scaleAspectFit
        titleLabel.textAlignment = .center
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(0)
            make.bottom.lessThanOrEqualToSuperview().inset(5)
        }
    }
    
    func configure(with title: String, icon: UIImage?, isSelected: Bool) {
        titleLabel.text = title
        titleLabel.textColor = isSelected ? ColorBrand.tabBarSeltectedColor : ColorBrand.tabUnselect
        titleLabel.font = isSelected ? FontBrand.tabbarSelectedTitleFont : FontBrand.tabbarTitleFont
        iconImageView.image = icon
        iconImageView.tintColor = isSelected ? ColorBrand.tabBarSeltectedColor : ColorBrand.tabUnselect
    }
}
