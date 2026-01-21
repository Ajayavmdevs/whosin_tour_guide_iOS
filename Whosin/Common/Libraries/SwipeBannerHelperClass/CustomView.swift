import UIKit

class CustomView: UIView {
    
    @IBOutlet private var cardView: UIView!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet weak var _cardClickButton: UIButton!
    
    // --------------------------------------
    // MARK: Model initialization
    // --------------------------------------

    var cardModel : BannerModel! {
        didSet{
            self._imageView.loadWebImage(cardModel.image)
        }
    }
    
    // --------------------------------------
    // MARK: Lyfe Cycle
    // --------------------------------------

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(CustomView.className, owner: self, options: nil)
        cardView.fixInView(self)
    }
        
    private func setImageToCard(_ imgUrlString: String) -> UIImage? {
        let image = UIImageView()
        image.loadWebImage(imgUrlString)
        return image.image
    }
    
}

extension UIView{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.bounds;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
}
