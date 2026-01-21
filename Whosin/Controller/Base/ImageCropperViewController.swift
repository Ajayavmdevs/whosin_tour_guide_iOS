import UIKit

protocol ImageCropperViewControllerDelegate: class {
    func cancelImageCropper(imageCropperViewController: ImageCropperViewController)
    func handleCroppedImage(imageCropperViewController: ImageCropperViewController, image: UIImage)
}

class ImageCropperViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var cropAreaView: UIView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    
    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    weak var delegate: ImageCropperViewControllerDelegate?
    var imageToCrop: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10
        
        imageView.image = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        maskCropArea()
        setImageToCrop(image: imageToCrop)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        delegate?.cancelImageCropper(imageCropperViewController: self)
    }
    
    @IBAction func _handleRotateEvent(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let rotatedImage = image.rotate(radians: .pi / 2)
        setImageToCrop(image: rotatedImage)
    }
    
    @IBAction func crop(_ sender: UIButton) {
        guard let image = imageView.image?.fixOrientation() else { return }
        let cropRect = getImageCropRect()
        let scaledCropRect = CGRect(x: cropRect.origin.x * image.scale,
                                    y: cropRect.origin.y * image.scale,
                                    width: cropRect.size.width * image.scale,
                                    height: cropRect.size.height * image.scale)

        guard let croppedCGImage = image.cgImage?.cropping(to: scaledCropRect) else { return }
        let croppedImage = UIImage(cgImage: croppedCGImage)
        delegate?.handleCroppedImage(imageCropperViewController: self, image: croppedImage)
    }
    
    func setImageToCrop(image: UIImage) {
        imageView.image = image
        let scale = max(cropAreaView.frame.size.width/image.size.width, cropAreaView.frame.size.height/image.size.height)
        
        imageWidthConstraint.constant = image.size.width * scale
        imageHeightConstraint.constant = image.size.height * scale
        
        scrollView.zoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        
        let inset = (scrollView.frame.height - cropAreaView.frame.height) / 2
        scrollView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        scrollView.contentOffset = CGPoint(x: (imageWidthConstraint.constant - scrollView.frame.width) / 2, y: (imageHeightConstraint.constant - scrollView.frame.height) / 2)
    }
    
    func maskCropArea() {
        let outerPath = UIBezierPath(rect: maskView.frame)
        let circlePath = UIBezierPath(rect: cropAreaView.frame)
        outerPath.usesEvenOddFillRule = true
        outerPath.append(circlePath)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = outerPath.cgPath
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        maskLayer.fillColor = UIColor.black.withAlphaComponent(0.66).cgColor
        maskView.layer.addSublayer(maskLayer)
    }
    
    func getImageCropRect() -> CGRect {
        guard let image = imageView.image else { return CGRect.zero }
        let imageScale: CGFloat = min(image.size.width/cropAreaView.frame.width, image.size.height/cropAreaView.frame.height)
        let zoomFactor = 1/scrollView.zoomScale
        let x = (scrollView.contentOffset.x + cropAreaView.frame.origin.x) * zoomFactor * imageScale
        let y = (scrollView.contentOffset.y  + cropAreaView.frame.origin.y) * zoomFactor * imageScale
        let width = cropAreaView.frame.size.width * zoomFactor * imageScale
        let height = cropAreaView.frame.size.height * zoomFactor * imageScale
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

extension ImageCropperViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
    
    func rotate(radians: CGFloat) -> UIImage {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size)
            .applying(CGAffineTransform(rotationAngle: radians)).size
        // Trim off the extremely small float value to prevent core graphics issues
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move the origin to the middle so we rotate and scale around the center
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate the image context
        context.rotate(by: radians)
        // Now, draw the rotated/scaled image into the context
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage ?? self
    }
}
