import UIKit
//import QCropper

class UploadPicturesCell: UITableViewCell {
    
    @IBOutlet weak var _editProfileImage: UIImageView!
    @IBOutlet weak var _uploadPicture: UIView!
    @IBOutlet weak var _profilePicture: UIImageView!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let _imagePicker = UIImagePickerController()
    private var imageString: [String] = [] {
        didSet {
            PromoterApplicationVC.promoterParams["images"] = imageString
        }
    }
    private let kCellIdentifier = String(describing: ImageViewCell.self)
    private var images: [UIImage] = [] {
        didSet {
            imageCallback?(images)
        }
    }
    private var isEdit: Bool = false
    public var imageCallback: (([UIImage]) -> Void)?
    public var profileImageCallback: ((UIImage) -> Void)?
    private var isUploadProfile:Bool = false
    private var profileModel: UserDetailModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _setupCollectionView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(_openImagePicker))
        _profilePicture.isUserInteractionEnabled = true
        _profilePicture.addGestureRecognizer(tap)
        if Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.image) {
            _profilePicture.image = UIImage(named: "icon_coverRound")
            _editProfileImage.isHidden = true
        } else {
            _profilePicture.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
            _editProfileImage.isHidden = false
            _editProfileImage.addGestureRecognizer(tap)
        }
    }
    
    private func _setupCollectionView() {
        let spacing = 10
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 10,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: "There is no data available",
                              emptyDataIconImage: UIImage(named: "empty_following"),
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifier,
            kCellTagKey: true,
            kCellObjectDataKey: "icon_coverSquare",
            kCellClassKey: ImageViewCell.self,
            kCellHeightKey: ImageViewCell.height
        ])
        
        if !images.isEmpty {
            images.forEach { img in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: img,
                    kCellClassKey: ImageViewCell.self,
                    kCellHeightKey: ImageViewCell.height
                ])
            }
        }
        
        if !imageString.isEmpty {
            imageString.forEach { img in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: img,
                    kCellClassKey: ImageViewCell.self,
                    kCellHeightKey: ImageViewCell.height
                ])
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ImageViewCell.self, kCellHeightKey: ImageViewCell.height]]
    }

    public func setupData(_ images: [String], isEdit: Bool = false, profile: UserDetailModel? = nil, profileImage: UIImage?)  {
        profileModel = profile
        self.isEdit = isEdit
        _uploadPicture.isHidden = false
        if isEdit, !images.isEmpty {
            PromoterApplicationVC.promoterParams["images"] = images
            imageString = images
        }
        if Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.image) && Utils.stringIsNullOrEmpty(profile?.image) {
            if profileImage != nil {
                _profilePicture.image = profileImage
            } else {
                _profilePicture.image = UIImage(named: "icon_coverRound")
            }
            _editProfileImage.isHidden = true
        } else if profile == nil || Utils.stringIsNullOrEmpty(profile?.image) {
            _profilePicture.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
            _editProfileImage.isHidden = false
        } else if profileImage != nil {
            _profilePicture.image = profileImage
            _editProfileImage.isHidden = false
        } else {
            _profilePicture.loadWebImage(profile?.image ?? kEmptyString, name: profile?.fullName ?? kEmptyString)
            _editProfileImage.isHidden = false
        }
        _loadData()
    }
    
    @objc func _openImagePicker() {
        endEditing(true)
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            _imagePicker.delegate = self
            _imagePicker.sourceType = .savedPhotosAlbum
            _imagePicker.allowsEditing = true
            isUploadProfile = true
            parentViewController?.present(_imagePicker, animated: true, completion: nil)
        }
    }
    
    private func _requestUploadProfileImage(_ image: UIImage) {
        self.parentBaseController?.showHUD()
        WhosinServices.uploadProfileImage(image: image) { [weak self] model, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            guard let photoUrl = model?.data else { return }
            var params: [String: Any] = [:]
            params["image"] = photoUrl.url
            self._requestUpdateProfile(params: params)
        }
    }
    
    private func _requestUpdateProfile(params: [String: Any], isShowEmailDialog: Bool = false ) {
        parentBaseController?.showHUD()
        APPSESSION.updateProfile(param: params) { [weak self] isSuccess, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            guard isSuccess else { return }
            self.parentBaseController?.showToast("image updated")
            NotificationCenter.default.post(name: .changeUserUpdateState, object: nil)
        }
    }
}

extension UploadPicturesCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ImageViewCell {
            if indexPath.row == 0, let isFirstCell = cellDict?[kCellTagKey] as? Bool, isFirstCell {
                cell._closeBtn.isHidden = true
                cell._imageView.backgroundColor = .clear
                cell._imageView.tintColor = ColorBrand.brandGray.withAlphaComponent(0.7)
                cell._imageView.image = UIImage(named: "icon_coverSquare")
            } else if let object = cellDict?[kCellObjectDataKey] as? String {
                cell._closeBtn.isHidden = false
                cell._imageView.loadWebImage(object)
            } else if let images = cellDict?[kCellObjectDataKey] as? UIImage {
                cell._closeBtn.isHidden = false
                cell._imageView.image = images
            }
            cell._closeBtn.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
            cell._closeBtn.tag = indexPath.row - 1
            
        }
    }
    
    @objc func closeButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        if index < images.count {
            images.remove(at: index)
        }
        
        if images.isEmpty {
            if index < imageString.count {
                imageString.remove(at: index - images.count)
            }
        } else {
            if (index - images.count) < imageString.count, index >= images.count {
                imageString.remove(at: index - images.count)
            }
        }
        _loadData()
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        let index = indexPath.row
        if index == 0 {
            endEditing(true)
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                _imagePicker.delegate = self
                _imagePicker.sourceType = .savedPhotosAlbum
                _imagePicker.allowsEditing = false
                isUploadProfile = false
                parentViewController?.present(_imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 70, height: 70)
    }
    
}

extension UploadPicturesCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if isUploadProfile {
            _imagePicker.dismiss(animated: true) {
                if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    if self.isUploadProfile {
                        self.profileImageCallback?(image)
                        self._profilePicture.image = image
                    } else {
                        self.images.insert(image, at: 0)
                        self.imageCallback?(self.images)
                    }
                }
            }
        } else {
            _imagePicker.dismiss(animated: true) {
                guard let pickedImage = info[.originalImage] as? UIImage else { return }
                self.showImageCropper(for: pickedImage)
            }
        }
    }
    
    private func showImageCropper(for image: UIImage) {
        let imageCropperViewController = ImageCropperViewController()
        imageCropperViewController.delegate = self
        imageCropperViewController.imageToCrop = image
        parentViewController?.present(imageCropperViewController, animated: true, completion: nil)
    }

}


extension UploadPicturesCell: ImageCropperViewControllerDelegate {
    func cancelImageCropper(imageCropperViewController: ImageCropperViewController) {
        imageCropperViewController.dismiss(animated: true, completion: nil)
    }
    
    func handleCroppedImage(imageCropperViewController: ImageCropperViewController, image: UIImage) {
        if self.isUploadProfile {
            self._profilePicture.image = image
            self._requestUploadProfileImage(image)
        } else {
            self.images.insert(image, at: 0)
            self.imageCallback?(self.images)
        }
        imageCropperViewController.dismiss(animated: true, completion: nil)
    }
}
