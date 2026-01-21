import UIKit

class PickupListVC: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _searchBar: UISearchBar!
    private var kCellIdentifier = String(describing: PickupListTableViewCell.self)
    private var kCellIdentifierLoading = String(describing: LoadingCell.self)
    public var _pickupList: [PickupListModel] = []
    public var optionId: String = kEmptyString
    private var _selectedItem: PickupListModel?
    public var callback: ((_ selected: PickupListModel) -> Void)?
    public var originalPickupList: [PickupListModel] = []
    private let otherOption = PickupListModel(name: "Other Location", id: -1)
    private var customText: String = ""
    public var optionDetail: TourOptionDetailModel?
    public var isDirectReporting: Bool = true
    public var isOctoType: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        _searchBar.delegate = self
    }

    // --------------------------------------
    // MARK: SetUp
    // --------------------------------------
    
    private func setupUI() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "empty_pickup".localized(),
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 120, right: 0)
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white
        if let model = optionDetail {
            let pickup = PickupListModel()
            pickup.id = model.hotelId
            pickup.name = model.pickup
            _selectedItem = pickup
        }
        if isOctoType {
            _pickupList = originalPickupList
         _loadData()
        } else {
            _loadData(true)
            _requestPickupList()
        }
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------

    private func _requestPickupList() {
        let params: [String : Any] = ["tourOptionId": optionId]
        WhosinServices.travelDeskPickupList(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.originalPickupList = data
//            self._pickupList = isDirectReporting ? [self.otherOption] + data : data
            self._pickupList = [self.otherOption] + data
            self._loadData()
        }
    }
    
    private func filterPickupList(with searchText: String) {
        if searchText.isEmpty {
            _pickupList = isOctoType ? originalPickupList : [otherOption] + originalPickupList
//            _pickupList = isOctoType ? originalPickupList : isDirectReporting ? [otherOption] + originalPickupList : originalPickupList
        } else {
            _pickupList = isOctoType ? originalPickupList.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            } : [otherOption] + originalPickupList.filter {
                           $0.name.lowercased().contains(searchText.lowercased())
                       } 
//            _pickupList = isOctoType ? originalPickupList.filter {
//                $0.name.lowercased().contains(searchText.lowercased())
//            } : isDirectReporting ? [otherOption] + originalPickupList.filter {
//                           $0.name.lowercased().contains(searchText.lowercased())
//                       } : originalPickupList.filter {
//                           $0.name.lowercased().contains(searchText.lowercased())
//                       }
        }
        _loadData()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierLoading,
                kCellTagKey: kCellIdentifierLoading,
                kCellObjectDataKey: true,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        }
        
        if !_pickupList.isEmpty && !isLoading{
            _pickupList.forEach { policies in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: policies,
                    kCellClassKey: PickupListTableViewCell.self,
                    kCellHeightKey: PickupListTableViewCell.height
                ])
            }
        }
            
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: PickupListTableViewCell.self, kCellHeightKey: PickupListTableViewCell.height],
                 [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]
        ]
    }
    
    private func showOtherOptionTextField() {
        let vc = INIT_CONTROLLER_XIB(LocationPickerVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.isRestricted = true
        vc.completion = { [weak self] location in
            guard let self = self else { return }
            self.customText = location?.address ?? ""
            let customPickup = PickupListModel(name: self.customText, id: -1)
            self.dismiss(customPickup)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    private func dismiss(_ address: PickupListModel) {
        self.dismissAllPresentedControllers(animated: true) {
            self.callback?(address)
        }
    }
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction func _handleSelectHotel(_ sender: CustomActivityButton) {
        guard let _selectedItem = _selectedItem else {
            alert(message: "alert_pickup_hotel".localized())
            return
        }

        if _selectedItem.id == -1 {
            showOtherOptionTextField()
        } else {
            dismiss(animated: true) {
                self.callback?(_selectedItem)
            }
        }
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismissOrBack()
    }
    
}

extension PickupListVC: CustomNoKeyboardTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PickupListTableViewCell {
            if let object = cellDict?[kCellObjectDataKey] as? PickupListModel {
                cell.setupData(object, Utils.stringIsNullOrEmpty(object.pickupId) ? _selectedItem?.id == object.id : _selectedItem?.pickupId == object.pickupId)
            }
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PickupListTableViewCell {
            if let object = cellDict?[kCellObjectDataKey] as? PickupListModel {
                _selectedItem = object
            }
        }
        _tableView.reload()
    }

    
}

extension PickupListVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterPickupList(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        _searchBar.text = ""
        filterPickupList(with: "")
    }
}

class TextViewAlertController: UIViewController {
    
    var onSubmit: ((String) -> Void)?

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let textView = UITextView()
    private let cancelButton = UIButton(type: .system)
    private let submitButton = UIButton(type: .system)
    private let buttonSeparator = UIView()
    private let topSeparator = UIView()
    public var text: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        // Setup Blur
        blurView.layer.cornerRadius = 14
        blurView.clipsToBounds = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)

        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(containerView)

        // Title
        titleLabel.text = "entre_pickup_location".localized()
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // TextView
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = ColorBrand.white.withAlphaComponent(0.7).cgColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = text
        containerView.addSubview(textView)

        // Separator above buttons
        topSeparator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(topSeparator)

        // Buttons
        cancelButton.setTitle("cancel".localized(), for: .normal)
        cancelButton.titleLabel?.font = FontBrand.SFmediumFont(size: 16)
        submitButton.titleLabel?.font = FontBrand.SFmediumFont(size: 16)
        submitButton.setTitle("submit".localized(), for: .normal)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)

        buttonSeparator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        buttonSeparator.translatesAutoresizingMaskIntoConstraints = false

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, submitButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 0
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonStack)
        buttonStack.addSubview(buttonSeparator)

        // Constraints
        NSLayoutConstraint.activate([
            blurView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            blurView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blurView.widthAnchor.constraint(equalToConstant: 300),

            containerView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 100),

            topSeparator.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 12),
            topSeparator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 0.5),

            buttonStack.topAnchor.constraint(equalTo: topSeparator.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
            buttonStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            buttonSeparator.widthAnchor.constraint(equalToConstant: 0.5),
            buttonSeparator.centerXAnchor.constraint(equalTo: buttonStack.centerXAnchor),
            buttonSeparator.topAnchor.constraint(equalTo: buttonStack.topAnchor),
            buttonSeparator.bottomAnchor.constraint(equalTo: buttonStack.bottomAnchor)
        ])
    }

    @objc private func didTapCancel() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func didTapSubmit() {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            self.dismiss(animated: true) {
                self.onSubmit?(text)
            }
        }
    }
}
