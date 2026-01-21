import UIKit

protocol ImagePreviewVCDelegate: class {
    func cancelImageCropper(imagePreviewVC: ImagePreviewVC)
    func handleCroppedImage(imagePreviewVC: ImagePreviewVC, image: UIImage)
}

class ImagePreviewVC: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    weak var delegate: ImagePreviewVCDelegate?
    var imageToCrop: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setImageToCrop(image: imageToCrop)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        delegate?.cancelImageCropper(imagePreviewVC: self)
    }
    
    @IBAction func _handleRotateEvent(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let rotatedImage = image.rotate(radians: .pi / 2)
        setImageToCrop(image: rotatedImage)
    }
    
    @IBAction func crop(_ sender: UIButton) {
        guard let image = imageView.image?.fixOrientation() else { return }
        delegate?.handleCroppedImage(imagePreviewVC: self, image: image)
    }
    
    func setImageToCrop(image: UIImage) {
        imageView.image = image
    }
}

extension ImagePreviewVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
