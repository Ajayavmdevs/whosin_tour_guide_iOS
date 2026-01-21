import UIKit

class ChatWallpaperVc: ChildViewController {
    
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let kCellIdentifierStory = String(describing: ImageViewCell.self)
    private let wallpapers:[String] = ["img_chat_wallpaper_1", "img_chat_wallpaper_2", "img_chat_wallpaper_3", "img_chat_wallpaper_4", "img_chat_wallpaper_5", "img_chat_wallpaper_6", "img_chat_wallpaper_7", "img_chat_wallpaper_8", "img_chat_wallpaper_9", "img_chat_wallpaper_10", "img_chat_wallpaper_11", "img_chat_wallpaper_12", "img_chat_wallpaper_13", "img_chat_wallpaper_14", "img_chat_wallpaper_15", "img_chat_wallpaper_16", "img_chat_wallpaper_17", "img_chat_wallpaper_18", "img_chat_wallpaper_19", "img_chat_wallpaper_20", "img_chat_wallpaper_21"]
    private let _imagePicker = UIImagePickerController()
    
    public var chatId:String = kEmptyString
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        _collectionView.setup(cellPrototypes: _storyPrototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 3,
                              rows: 4,
                              edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0),
                              spacing: CGSize(width: 10, height: 10),
                              scrollDirection: .vertical,
                              emptyDataText: "Somthing went wrong!",
                              emptyDataIconImage: UIImage(named: "icon_empty_data"),
                              delegate: self)
        _loadData()
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        wallpapers.forEach { contact in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierStory,
                kCellTagKey: contact,
                kCellObjectDataKey: contact,
                kCellClassKey: ImageViewCell.self,
                kCellHeightKey: ImageViewCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private var _storyPrototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierStory, kCellNibNameKey: kCellIdentifierStory, kCellClassKey: ImageViewCell.self, kCellHeightKey: ImageViewCell.height]]
    }
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        if self.isPresented {
            dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func _handleImageSelectionEvent(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            _imagePicker.delegate = self
            _imagePicker.sourceType = .savedPhotosAlbum
            _imagePicker.allowsEditing = true
            present(_imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func _handleColorSelectionEvent(_ sender: UIButton) {
        if #available(iOS 14.0, *) {
            let colorPicker = UIColorPickerViewController()
            colorPicker.delegate = self
            present(colorPicker, animated: true, completion: nil)
        } else {
        }
    }
    
}

extension ChatWallpaperVc: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ImageViewCell,
              let object = cellDict?[kCellObjectDataKey] as? String else { return }
        cell.setupData(object)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ImageViewCell,
              let object = cellDict?[kCellObjectDataKey] as? String else { return }
        let controller = INIT_CONTROLLER_XIB(WallpaperPreviewVC.self)
        controller.chatId = chatId
        controller.image = UIImage(named: object)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension ChatWallpaperVc: UIColorPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        let hexColor = selectedColor.toImage()
        let controller = INIT_CONTROLLER_XIB(WallpaperPreviewVC.self)
        controller.chatId = chatId
        controller.image = hexColor
        controller.view.backgroundColor = selectedColor
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
    }
    
}

extension ChatWallpaperVc: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        _imagePicker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                let controller = INIT_CONTROLLER_XIB(WallpaperPreviewVC.self)
                controller.chatId = self.chatId
                controller.image = image
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
