import UIKit

class ProfileImageViewVC: UIViewController {

    @IBOutlet weak var _profileImage: UIImageView!
    public var profileImg: String = kEmptyString
    public var userName: String = kEmptyString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _profileImage.loadWebImage(profileImg, name: userName)
    }

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
