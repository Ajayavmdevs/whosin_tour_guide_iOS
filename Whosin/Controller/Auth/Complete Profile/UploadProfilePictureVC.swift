import UIKit

class UploadProfilePictureVC: ChildViewController {
    
    @IBOutlet private weak var _plushButton: GradientBorderButton!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _backButton: CustomGradientBorderButton!
    @IBOutlet private weak var _nextButton: CustomGradientBorderButton!
    public var params: [String:Any] = [:]
    private let _imagePicker = UIImagePickerController()
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        
    }
    
    override func setupUi() {
        _nextButton.buttonImage = UIImage(named: "icon_btnNext")
        _backButton.buttonImage = UIImage(named: "icon_backArrow")
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestUploadProfileImage(_ image: UIImage) {
        self.showHUD()
        WhosinServices.uploadProfileImage(image: image) { [weak self] model, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let photoUrl = model?.data else { return }
            self.view.makeToast("Image Updated Successfully")
            self.params["image"] = photoUrl.url
        }
    }
    
    private func _requestUpdateProfile() {
        showHUD()
        APPSESSION.updateProfile(param: params) { [weak self] isSuccess, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard isSuccess else { return }
            let vc = INIT_CONTROLLER_XIB(SelectPrefrencesVC.self)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleBackButton(_ sender: CustomGradientBorderButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func _handleImagePicker(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            _imagePicker.delegate = self
            _imagePicker.sourceType = .savedPhotosAlbum
            _imagePicker.allowsEditing = true
            present(_imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction private func _handleNextButtonEvent(_ sender: CustomGradientBorderButton) {
        if _imageView.image == nil {
            alert(title: kAppName, message: "Please select image")
            return
        }
        _requestUpdateProfile()
    }
    
}

// --------------------------------------
// MARK: ImagePickerController Delegate, NavigationController Delegate
// --------------------------------------

extension UploadProfilePictureVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        _imagePicker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self._imageView.image = image
                self._plushButton.isHidden = true
                self._requestUploadProfileImage(image)
            }
        }
    }
}
