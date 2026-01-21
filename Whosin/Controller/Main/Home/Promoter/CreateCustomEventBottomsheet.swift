import UIKit
import IQKeyboardManagerSwift

class CreateCustomEventBottomsheet: PanBaseViewController {
    
    @IBOutlet weak var _createBtn: CustomButton!
    @IBOutlet weak var _venueNameField: CustomFormField!
    @IBOutlet weak var _eventDescription: CustomFormField!
    @IBOutlet weak var _coverImg: UIImageView!
    @IBOutlet weak var _locationText: LeftSpaceTextField!
    private let _imagePicker = UIImagePickerController()
    public var customCallback: (( _ customModel: [String: Any], _ lat: Double, _ long: Double) -> Void)?
    public var params: [String: Any] = [:]
    public var isEdit: Bool = false
    private var latitude: Double = 0.0
    private var longtitude: Double = 0.0
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
        setupUi()
    }
    
    override func setupUi() {
        let customVenue = params["customVenue"] as? [String: Any]
        if isEdit {
            self.params["name"] = customVenue?["name"] as? String ?? ""
            _venueNameField.setupEdit("venue_name".localized(), text: self.params["name"] as? String ?? "", subtitle: "name your Venue")
        } else {
            _venueNameField.setupData("venue_name".localized(), subtitle: "name_your_venue".localized())
        }
        _venueNameField.fieldType = FormFieldType.name.rawValue
        _venueNameField.callback = { text in
            self.params["name"] = text
        }
        if isEdit {
            self.params["address"] = customVenue?["address"] as? String ?? ""
            _locationText.text = customVenue?["address"] as? String ?? ""
        }
//        if isEdit {
//            self.params["address"] = customVenue?["address"] as? String ?? ""
//            _locationLbl.setupEdit("Location", text: self.params["address"] as? String ?? "", subtitle: "add_your_address".localized())
//        }else {
//            _locationLbl.setupData("Location", subtitle: "add_your_address".localized())
//        }
//        _locationLbl.fieldType = FormFieldType.name.rawValue
//        _locationLbl.callback = { text in
//            self.params["address"] = text
//        }
        if isEdit {
            self.params["description"] = customVenue?["description"] as? String ?? ""
            _eventDescription.setupEdit("venue_description".localized(), text:  self.params["description"] as? String ?? "", subtitle: "add_your_description".localized())
        } else {
            _eventDescription.setupData("venue_description".localized(), subtitle: "add_your_description".localized())
        }
        _eventDescription.fieldType = FormFieldType.name.rawValue
        _eventDescription.callback = { text in
            self.params["description"] = text
        }
        if isEdit {
            self.params["image"] = customVenue?["image"] as? String ?? ""
            _coverImg.loadWebImage(self.params["image"]  as? String ?? "")
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openImagePicket))
        _coverImg.isUserInteractionEnabled = true
        _coverImg.addGestureRecognizer(tapGesture)
        _createBtn.setTitle(isEdit ? "update".localized() : "create".localized())
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
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
            if Utils.stringIsNullOrEmpty(photoUrl.url) {
                alert(message: "try_again_image_upload".localized())
                return
            }
            self.view.makeToast("image_updated_successfully".localized())
            self.params["image"] = photoUrl.url
            DISPATCH_ASYNC_MAIN_AFTER(0.3) {
                self.dismiss(animated: true) {
                    self.customCallback?(self.params, self.latitude, self.longtitude)
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
    
    @IBAction func _handleCreateEvent(_ sender: CustomButton) {
        if Utils.stringIsNullOrEmpty(params["name"] as? String) {
            alert(message: "please_enter_venue_name".localized())
            return
        }
        
        if Utils.stringIsNullOrEmpty(params["address"] as? String) {
            alert(message: "please_enter_venue_address".localized())
            return
        }
        
        if _coverImg.image == nil {
            alert(message: "please_select_venue_logo".localized())
            return
        }
        
        self._requestUploadProfileImage(_coverImg.image)
        
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func _handleLocationEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(LocationPickerVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.completion = { location in
            self.params["address"] = location?.address
            self._locationText.text = location?.address ?? ""
            if let coordinate = location?.coordinate {
                self.latitude = coordinate.latitude
                self.longtitude = coordinate.longitude
            }
        }
        present(vc, animated: true,
                completion: nil)
    }
}

// --------------------------------------
// MARK: Image Picker
// --------------------------------------

extension CreateCustomEventBottomsheet: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        _imagePicker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self._coverImg.image = image
            }
        }
    }
}
