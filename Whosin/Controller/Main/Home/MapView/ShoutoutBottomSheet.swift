import UIKit
import IQKeyboardManagerSwift

class ShoutoutBottomSheet: PanBaseViewController {
    
    @IBOutlet private weak var _venueAddress: UILabel!
    @IBOutlet private weak var _venueName: UILabel!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _slideActionButton: SlideToActionButton!
    @IBOutlet private weak var _invitationText: UITextField!
    @IBOutlet private weak var _captionText: UITextField!
    @IBOutlet private weak var _venueImage: UIImageView!
    @IBOutlet private weak var _venueBtn: UIButton!
    private let kCellIdentifierShareWith = String(describing: ShareWithCollectionCell.self)
    public var homeblockModel: HomeBlockModel?
    public var venues: [VenueDetailModel] = []
    public var shoutoutModel: [ShoutoutListModel] = []
    private var userIds: [String] = []
    private var selectedVenue: VenueDetailModel?
    private var selectedContacts: [UserDetailModel] = [] {
        didSet {
            _collectionView.reloadData()
        }
    }
    
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _slideActionButton.delegate = self
        setupConatctUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestInvite() {
        guard let venueId = selectedVenue?.id else { return }
        WhosinServices.addShoutout(venueId: venueId, userIds: userIds, time: 60, title: _invitationText.text!, caption: _captionText.text!) { [weak self] container, error in
            guard let self = self else { return }
            if container?.code == 1 {
                self.view.makeToast(container?.message)
            }
            DISPATCH_ASYNC_MAIN_AFTER(0.8) {
                NotificationCenter.default.post(name: .reloadShoutouts, object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupConatctUi() {
        let spacing = 0
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: .zero, left: 0, bottom: .zero, right: 0),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: "There is no data available",
                              emptyDataIconImage: UIImage(named: "empty_offers"),
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _captionText.delegate = self
        _invitationText.delegate = self
        _loadData()
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        cellData.removeAll()
        
        if !selectedContacts.isEmpty {
            selectedContacts.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierShareWith,
                    kCellTagKey: kCellIdentifierShareWith,
                    kCellObjectDataKey: contact,
                    kCellClassKey: ShareWithCollectionCell.self,
                    kCellHeightKey: ShareWithCollectionCell.height
                ])
            }
        }
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierShareWith,
            kCellTagKey: kCellIdentifierShareWith,
            kCellObjectDataKey: true,
            kCellClassKey: ShareWithCollectionCell.self,
            kCellHeightKey: ShareWithCollectionCell.height
        ])
        
        _venueImage.loadWebImage(selectedVenue?.logo ?? "")
        _venueName.text = selectedVenue?.name
        _venueAddress.text = selectedVenue?.address
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: ShareWithCollectionCell.self), kCellNibNameKey: String(describing: ShareWithCollectionCell.self), kCellClassKey: ShareWithCollectionCell.self, kCellHeightKey: ShareWithCollectionCell.height]]
    }
    
    @IBAction func _handleSelectVenueEVent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(VenueListBottomSheet.self)
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController._homeBlock = homeblockModel
        presentedViewController.venueListModel = venues
        presentedViewController.onShareButtonTapped = { [weak self] selectedVenue in
            self?.selectedVenue = selectedVenue
            self?._loadData()
            self?._collectionView.reload()
        }
        presentedViewController.transitioningDelegate = self
        parent?.presentAsPanModal(controller: PanNavigationController(rootViewController: presentedViewController))
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == _captionText {
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            return newText.count <= 20
        } else if textField == _invitationText {
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            return newText.count <= 50
        }
        return true
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}


extension ShoutoutBottomSheet: CustomCollectionViewDelegate {
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 76, height: 76)
    }
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ShareWithCollectionCell {
            if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
                cell.setupContactData(data: object)
            } else if let object = cellDict?[kCellObjectDataKey] as? Bool {
                cell.setupContactData(islastIndex: object)
            }
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        let index = indexPath.row
        let cell = cell as? ShareWithCollectionCell
        if index == selectedContacts.count {
            let presentedViewController = INIT_CONTROLLER_XIB(ContactShareBottomSheet.self)
            presentedViewController.onShareButtonTapped = { [weak self] selectedContacts in
                self?.selectedContacts.removeAll()
                let sharedContactIds = selectedContacts.map { $0.id }
                self?.selectedContacts = selectedContacts
                self?.userIds = sharedContactIds
                self?._loadData()
                self?._collectionView.reload()
            }
            presentedViewController.sharedContactId = selectedContacts.map { $0.id }
            presentedViewController.isFromCreateBucket = true
            presentedViewController.modalPresentationStyle = .overFullScreen
            present(presentedViewController, animated: true)
//            presentAsPanModal(controller: presentedViewController)
        }
    }
    
}

extension ShoutoutBottomSheet: SlideToActionButtonDelegate {
    
    func didFinish() {
        
        if Utils.stringIsNullOrEmpty(_captionText.text) {
            alert(title: kAppName, message: "Please enter caption")
            _slideActionButton.reset()
            return
        }
        
        if Utils.stringIsNullOrEmpty(_invitationText.text) {
            alert(title: kAppName, message: "Please enter invite message")
            _slideActionButton.reset()
            return
        }
                
        if Utils.stringIsNullOrEmpty(selectedVenue?.id) {
            alert(title: kAppName, message: "Please select venue")
            _slideActionButton.reset()
            return
        }
        
        if !shoutoutModel.isEmpty {
            alert(title: kAppName, message: "A shoutout has already been created. If you proceed, the old shoutout will be removed. Are you sure you want to create a new one?", okActionTitle: "yes") { UIAlertAction in
                self._requestInvite()
            } cancelHandler: { UIAlertAction in
                self.dismiss(animated: true)
            }
        } else {
            _requestInvite()
        }
        
    }
}

extension ShoutoutBottomSheet: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}


extension ShoutoutBottomSheet: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() 
        return true
    }
}


