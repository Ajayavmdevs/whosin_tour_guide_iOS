import UIKit
import IQKeyboardManagerSwift

class CreateBucketBottomSheet: PanBaseViewController {
    
    @IBOutlet weak var _titleBottomSheet: UILabel!
    @IBOutlet private weak var _slideActionButton: SlideToActionButton!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _listName: UITextField!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let _imagePicker = UIImagePickerController()
    private var imageString: String = kEmptyString
    private var userIds: String = kEmptyString
    private let kCellIdentifierShareWith = String(describing: SharedUserNoMarginCell.self)
    public var bucketDetail: BucketDetailModel?
    private var selectedContacts: [UserDetailModel] = []
    private var isUpdateBucket: Bool = false
    private var bucketId: String = kEmptyString
    public var isFromEdit: Bool = false

    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _slideActionButton.delegate = self
        setupConatctUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupConatctUi() {
        let spacing = 0
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 10,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: "There is no data available",
                              emptyDataIconImage: UIImage(named: "empty_follower"),
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        if bucketDetail != nil {
            guard let bucketDetail = bucketDetail else { return }
            selectedContacts = bucketDetail.sharedWith.toArrayDetached(ofType: UserDetailModel.self)
            _coverImage.loadWebImage(bucketDetail.coverImage)
            _listName.text = bucketDetail.name
            isUpdateBucket = true
            bucketId = bucketDetail.id
            let ids = selectedContacts.map { $0.id }
            userIds = ids.joined(separator: ",")
        }
        if isFromEdit {
            _titleBottomSheet.text = "Update Bucket"
            _slideActionButton.titleLabel.text = "Swipe to Update"
        }
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
                    kCellClassKey: SharedUserNoMarginCell.self,
                    kCellHeightKey: SharedUserNoMarginCell.height
                ])
            }
        }
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierShareWith,
            kCellTagKey: kCellIdentifierShareWith,
            kCellObjectDataKey: true,
            kCellClassKey: SharedUserNoMarginCell.self,
            kCellHeightKey: SharedUserNoMarginCell.height
        ])
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    


    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: SharedUserNoMarginCell.self), kCellNibNameKey: String(describing: SharedUserNoMarginCell.self), kCellClassKey: SharedUserNoMarginCell.self, kCellHeightKey: SharedUserNoMarginCell.height]]
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestCreateBucket(name: String, image: String, userIds: String) {
        showHUD()
        WhosinServices.createBucket(name: name, userIds: userIds, image: image) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else {
                self._slideActionButton.reset()
                return
            }
    
            self.view.makeToast(data.message)
            let bucketId = data.data?.id
            NotificationCenter.default.post(name:kReloadBucketList, object: bucketId, userInfo: nil)
            self.dismiss(animated: true)
        }
    }
    
    private func _requestUpdateBucket(name: String, image: String, userIds: String) {
        showHUD()
        WhosinServices.updateBucket(id: bucketId, name: name,userIds: userIds, image: image ) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else {
                self._slideActionButton.reset()
                return
            }
            self.view.makeToast(data.message)
            NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
            self.dismiss(animated: true)
        }
    }
    
    private func _requestUploadProfileImage(_ image: UIImage?) {
        guard let image = image else {
            alert(title: kAppName, message: "Please select image")
            _slideActionButton.reset()
            return
        }
        self.showHUD()
        WhosinServices.uploadProfileImage(image: image) { [weak self] model, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let photoUrl = model?.data else { return }
            self.view.makeToast("Image Updated Successfully")
            self.imageString = photoUrl.url
            if self.isUpdateBucket {
                self._requestUpdateBucket(name: self._listName.text!, image: self.imageString, userIds: self.userIds)
            } else {
                self._requestCreateBucket(name: self._listName.text!, image: self.imageString, userIds: self.userIds)
            }

        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleCoverImgPicker(_ sender: UIButton) {
        self.view.endEditing(true)
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            _imagePicker.delegate = self
            _imagePicker.sourceType = .savedPhotosAlbum
            _imagePicker.allowsEditing = true
            present(_imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
}


// --------------------------------------
// MARK: ImagePickerController Delegate, NavigationController Delegate
// --------------------------------------

extension CreateBucketBottomSheet: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateBucketBottomSheet: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        _imagePicker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self._coverImage.image = image
            }
        }
    }
}

extension CreateBucketBottomSheet: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}

extension CreateBucketBottomSheet: SlideToActionButtonDelegate {
    
    func didFinish() {
        if Utils.stringIsNullOrEmpty(_listName.text) {
            alert(title: kAppName, message: "Please enter bucket name")
            _slideActionButton.reset()
            return
        }
        self._requestUploadProfileImage(_coverImage.image)
    }
    
}


extension CreateBucketBottomSheet: CustomCollectionViewDelegate {
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 60, height: SharedUserNoMarginCell.height)
    }
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SharedUserNoMarginCell {
            if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
                    cell.setupContactData(data: object)
            } else if let object = cellDict?[kCellObjectDataKey] as? Bool {
                cell.setupContactData(islastIndex: object)
            }
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        self.view.endEditing(true)
        let index = indexPath.row
        if index == selectedContacts.count {
            let presentedViewController = INIT_CONTROLLER_XIB(ContactShareBottomSheet.self)
            presentedViewController.onShareButtonTapped = { [weak self] selectedContacts in
                self?.selectedContacts.removeAll()
                let sharedContactIds = selectedContacts.map { $0.id }
                self?.selectedContacts = selectedContacts
                self?.userIds = sharedContactIds.joined(separator: ",")
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
