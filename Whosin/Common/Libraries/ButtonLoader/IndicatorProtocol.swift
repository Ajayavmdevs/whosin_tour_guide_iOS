import UIKit

public protocol IndicatorProtocol {
    var radius: CGFloat { get set }
    var color: UIColor { get set }
    var isAnimating: Bool { get }
    func startAnimating()
    func stopAnimating()
    func setupAnimation(in layer: CALayer, size: CGSize)
}
