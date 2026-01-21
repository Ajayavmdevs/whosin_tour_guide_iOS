import UIKit
import SnapKit

class CustomPublicRingsView: UIView {
    
    @IBOutlet private var _imageViews: [UIImageView]!
    @IBOutlet private weak var _galaryCountView: UIView!
    @IBOutlet private weak var _galaryImageCount: UILabel!

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomPublicRingsView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    private func configureImageViews(imageViews: [UIImageView], galaryImages: [UserDetailModel], total: Int) {
        let totalImageViews = imageViews.count
        for i in 0..<totalImageViews {
            if i < galaryImages.count {
                imageViews[i].isHidden = false
                imageViews[i].loadWebImage(galaryImages[i].image, name: galaryImages[i].firstName) {
                    do {
                        imageViews[i].borderColor = try imageViews[i].image?.averageColor() ?? ColorBrand.brandImageBorder
                        imageViews[i].borderWidth = 1
                    } catch {}
                }
            } else {
                imageViews[i].isHidden = true
            }
        }
        
        if galaryImages.count > totalImageViews {
            let remainingCount = total - totalImageViews
            _galaryCountView.isHidden = false
            _galaryImageCount.text = "+\(remainingCount)"
        } else {
            _galaryCountView.isHidden = true
        }
    }
    
    // --------------------------------------
    // MARK: public
    // --------------------------------------

    public func setupData(_ imagesArray: [UserDetailModel], totalUsers: Int) {
        configureImageViews(imageViews: _imageViews, galaryImages: imagesArray, total: totalUsers)
    }

    
}


