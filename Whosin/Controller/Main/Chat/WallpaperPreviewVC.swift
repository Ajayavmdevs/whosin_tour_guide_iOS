import UIKit

class WallpaperPreviewVC: UIViewController {

    @IBOutlet weak var _wallpaperImage: UIImageView!
    
    public var image: UIImage?
    public var chatId: String = kEmptyString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _wallpaperImage.image = image

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
    
    @IBAction func _handleSetWallpaperEvent(_ sender: UIButton) {
        var list  = Preferences.chatWallpapers
        list.removeAll(where: {$0.keys.contains(chatId)})
        if let img = image?.jpegData(compressionQuality: 1) {
            list.append([chatId: img])
            Preferences.chatWallpapers = list
        }
        if self.presentingViewController != nil {
            dismiss(animated: true)
        } else {
            if let vc = self.navigationController?.viewControllers.first(where: { $0 is ChatDetailVC }) {
                self.navigationController?.popToViewController(vc, animated: true)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
}
