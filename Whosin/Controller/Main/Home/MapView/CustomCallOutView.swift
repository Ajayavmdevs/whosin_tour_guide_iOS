import UIKit
import MapKit

class CustomCallOutView: UIView {
    
    @IBOutlet weak var _infoButton: UIButton!
    @IBOutlet weak var _titleView: UILabel!
    @IBOutlet weak var _imageView: UIImageView!
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    public class func initFromNib() -> CustomCallOutView {
        UINib(nibName: "CustomCallOutView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! CustomCallOutView
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._imageView.roundCorners(corners: [.allCorners], radius: 5)
        }
    }
        
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    var viewHeight: CGFloat {
        return 60
    }
    
    var viewWidth: CGFloat {
        return 200
    }
    
    func setupData(_ data: UserAnnotation) {
        _imageView.loadWebImage(data.image, name: data.title ?? kEmptyString)
        _titleView.text = data.title
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleInfoEvent(_ sender: UIButton) {
    }
}
