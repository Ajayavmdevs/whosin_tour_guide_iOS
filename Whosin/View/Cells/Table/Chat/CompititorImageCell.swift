import UIKit
import Lightbox

class CompititorImageCell: UITableViewCell {
    
    @IBOutlet weak var _sentTime: UILabel!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _senderName: UILabel!
    
    private var _msgModel: MessageModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        _imageView.isUserInteractionEnabled = true
        _imageView.addGestureRecognizer(tapGesture)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(userTapped))
        _senderName.isUserInteractionEnabled = true
        _senderName.addGestureRecognizer(tapGesture2)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        // Handle the tap event here
        var images: [LightboxImage] = []
        if sender.state == .ended, let image = _imageView.image {
            images.append(LightboxImage(image: image))
        } else if sender.state == .ended{
            images.append(LightboxImage(imageURL: URL(string: _msgModel?.msg ?? kEmptyString)!))
        }
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        parentBaseController?.present(controller, animated: true, completion: nil)
    }
    
    @objc func userTapped(sender: UITapGestureRecognizer) {
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setup(_ message: MessageModel?) {
        _msgModel = message
        let timeStamp = Double(message?.date ?? "")
        let date = timeStamp?.getDateStringFromUTC()
        _senderName.text = message?.authorName
        _sentTime.text = date
        _imageView.loadWebImage(message?.msg ?? "")
    }
    
}
