
import UIKit

class CreateCirclebottomsheet: PanBaseViewController {
    
    @IBOutlet weak var _sheetTitle: CustomLabel!
    @IBOutlet weak var _addusersView: UIView!
    @IBOutlet weak var _createBtn: CustomActivityButton!
    @IBOutlet weak var _descirptionField: CustomFormField!
    @IBOutlet weak var _circleNameField: CustomFormField!
    @IBOutlet weak var addUserCollectionView: CustomCollectionView!
    @IBOutlet weak var _coverImg: UIImageView!
    private let _imagePicker = UIImagePickerController()
    private var userIds: String = kEmptyString
    private var imageString: String = kEmptyString
    private var selectedContacts: [UserDetailModel] = []
    private let kCollectionCellIdentifier = String(describing: SharedUserNoMarginCell.self)
    private var params: [String: Any] = [:]
    public var isUpdate: Bool = false
    public var circleModel: UserDetailModel?
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func setupUi() {
        _sheetTitle.text = isUpdate ? "edit_your_circle".localized() : "create_your_circle".localized()
        if isUpdate {
            if !Utils.stringIsNullOrEmpty(circleModel?.avatar) {
                _coverImg.loadWebImage(circleModel?.avatar ?? kEmptyString)
            }
            params["id"] = circleModel?.id ?? kEmptyString
            self.params["title"] = circleModel?.title ?? kEmptyString
            self.params["description"] = circleModel?.descriptions ?? kEmptyString
            self.params["avatar"] = circleModel?.avatar
            _circleNameField.setupEdit("circle_name".localized(),text: circleModel?.title ?? kEmptyString, subtitle: "name_your_circle".localized())
            self.params["title"] = circleModel?.title ?? kEmptyString
        } else {
            _createBtn.setTitle("create".localized())
            _circleNameField.setupData("circle_name".localized(), subtitle: "name_your_circle".localized())
        }
        _circleNameField.fieldType = FormFieldType.name.rawValue
        _circleNameField.callback = { text in
            self.params["title"] = text
        }
        
        if isUpdate {
            _descirptionField.setupEdit("description".localized(),text: circleModel?.descriptions ?? kEmptyString, subtitle: "add_your_description".localized())
        } else {
            _descirptionField.setupData("description".localized(), subtitle: "add_your_description".localized())
        }
        _descirptionField.fieldType = FormFieldType.name.rawValue
        _descirptionField.callback = { text in
            self.params["description"] = text
        }
        _addusersView.isHidden = isUpdate
        _createBtn.setTitle( isUpdate ? "update".localized() : "create".localized())
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openImagePicket))
        _coverImg.isUserInteractionEnabled = true
        _coverImg.addGestureRecognizer(tapGesture)
        
        addUserCollectionView.setup(cellPrototypes: _prototype,
                                    hasHeaderSection: false,
                                    enableRefresh: false,
                                    columns: 10,
                                    rows: 1,
                                    edgeInsets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18),
                                    spacing: CGSize(width: 0, height: 0),
                                    scrollDirection: .horizontal,
                                    emptyDataText: "There is no data available",
                                    emptyDataIconImage: UIImage(named: "empty_follower"),
                                    delegate: self)
        addUserCollectionView.showsVerticalScrollIndicator = false
        addUserCollectionView.showsHorizontalScrollIndicator = false
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        cellData.removeAll()
        cellData.append([
            kCellIdentifierKey: kCollectionCellIdentifier,
            kCellTagKey: kCollectionCellIdentifier,
            kCellObjectDataKey: true,
            kCellClassKey: SharedUserNoMarginCell.self,
            kCellHeightKey: SharedUserNoMarginCell.height
        ])
        
        if !selectedContacts.isEmpty {
            selectedContacts.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCollectionCellIdentifier,
                    kCellTagKey: kCollectionCellIdentifier,
                    kCellObjectDataKey: contact,
                    kCellClassKey: SharedUserNoMarginCell.self,
                    kCellHeightKey: SharedUserNoMarginCell.height
                ])
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        addUserCollectionView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCollectionCellIdentifier, kCellNibNameKey: String(describing: SharedUserNoMarginCell.self), kCellClassKey: SharedUserNoMarginCell.self, kCellHeightKey: SharedUserNoMarginCell.height]]
    }
    
    private func _requestUploadProfileImage(_ image: UIImage?) {
        guard let image = image else {
            alert(title: kAppName, message: "please_select_image".localized())
            return
        }
        self.showHUD()
        WhosinServices.uploadProfileImage(image: image) { [weak self] model, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let photoUrl = model?.data else { return }
            self.view.makeToast("image_updated_successfully".localized())
            self.imageString = photoUrl.url
            self.params["avatar"] = imageString
        }
    }
    
    private func _requestCreateCircle() {
        _createBtn.setTitle("")
        _createBtn.showActivity()
        WhosinServices.createCircle(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self._createBtn.hideActivity()
            self._createBtn.setTitle("create".localized())
            self.hideHUD(error: error)
            guard let data = container else { return }
            showToast(container?.message ?? kEmptyString)
            NotificationCenter.default.post(name: .reloadPromoterProfileNotifier, object: nil)
            DISPATCH_ASYNC_MAIN_AFTER(0.3) {
                self.showSuccessMessage("circle_created_successfully".localized(), subtitle: kEmptyString)
                self.dismiss(animated: true)
            }
        }
    }
    
    private func _requestUpdateCircle() {
        _createBtn.setTitle("")
        _createBtn.showActivity()
        WhosinServices.updateCircle(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self._createBtn.hideActivity()
            self._createBtn.setTitle("update".localized())
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            showToast(container?.message ?? kEmptyString)
            DISPATCH_ASYNC_MAIN_AFTER(0.1) {
                self.dismiss(animated: true) {
                    self.showSuccessMessage("circle_updated_successfully".localized(), subtitle: kEmptyString)
                    NotificationCenter.default.post(name: .reloadPromoterProfileNotifier, object: nil, userInfo: ["circleModel": data, "isDelete": false])
                }
            }
        }
    }
    
    @objc func openImagePicket(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            _imagePicker.delegate = self
            _imagePicker.sourceType = .savedPhotosAlbum
            _imagePicker.allowsEditing = true
            present(_imagePicker, animated: true, completion: nil)
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    
    @IBAction func _handleCloseEvent(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func _handleCreateEvent(_ sender: CustomActivityButton) {
        if Utils.stringIsNullOrEmpty(params["title"] as? String) {
            alert(message: "please_enter_title".localized())
            return
        }
        
        if Utils.stringIsNullOrEmpty(params["avatar"] as? String) {
            alert(message: "please_upload_cover_image".localized())
            return
        }
        
        if !isUpdate {
            params["members"] = selectedContacts.map({ $0.userId })
            _requestCreateCircle()
        } else if isUpdate {
            _requestUpdateCircle()
        }
    }
}

// --------------------------------------
// MARK: Colleciton delegate
// --------------------------------------


extension CreateCirclebottomsheet: CustomCollectionViewDelegate  {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SharedUserNoMarginCell {
            if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
                cell.setupContactData(data: object)
            } else if let object = cellDict?[kCellObjectDataKey] as? Bool {
                cell.setupContactData(islastIndex: object)
            }
        }
    }
    
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 60, height: SharedUserNoMarginCell.height)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        self.view.endEditing(true)
        let index = indexPath.row
        if index == 0 {
            let presentedViewController = INIT_CONTROLLER_XIB(ContactShareBottomSheet.self)
            presentedViewController.onShareButtonTapped = { [weak self] selectedContacts in
                self?.selectedContacts.removeAll()
                let sharedContactIds = selectedContacts.map { $0.userId }
                self?.selectedContacts = selectedContacts
                self?.userIds = sharedContactIds.joined(separator: ",")
                self?._loadData()
                self?.addUserCollectionView.reload()
            }
            presentedViewController.isFromCircle = true
            presentedViewController.sharedContactId = selectedContacts.map { $0.userId }
            presentedViewController.isFromCreateBucket = true
            
            presentedViewController.modalPresentationStyle = .overFullScreen
            present(presentedViewController, animated: true)
        }
    }
    
}

// --------------------------------------
// MARK: Image Picker
// --------------------------------------

extension CreateCirclebottomsheet: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        _imagePicker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self._requestUploadProfileImage(image)
                self._coverImg.image = image
            }
        }
    }
}
