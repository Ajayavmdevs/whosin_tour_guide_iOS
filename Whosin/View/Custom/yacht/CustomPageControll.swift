import UIKit

class CustomPageControll: UIPageControl {
    
    private var customPageControlDots: [UIView] = []
    private let selectedDotWidth: CGFloat = 20.0
    private let selectedDotHeight: CGFloat = 8.0
    
    @IBInspectable var selectedDotColor: UIColor = ColorBrand.brandSky // Default color
    @IBInspectable var unselectedDotColor: UIColor = ColorBrand.brandLightGray // Default color

    
    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }
    
    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateDots()
    }
    
    private func updateDots() {
        customPageControlDots.forEach { $0.removeFromSuperview() }
        customPageControlDots.removeAll()
        
        var totalWidth: CGFloat = 0.0

        for i in 0..<numberOfPages {
            let dot = UIView()
            dot.backgroundColor = i == currentPage ? selectedDotColor : unselectedDotColor
            let dotWidth = i == currentPage ? selectedDotWidth : 8.0
            dot.frame = CGRect(x: totalWidth, y: 0, width: dotWidth, height: 8.0)
            dot.layer.cornerRadius = 4.0
            addSubview(dot)
            customPageControlDots.append(dot)

            totalWidth += dotWidth + 4.0  // Adjust the spacing between dots
        }

        // Center the dots
        let startX = (bounds.width - totalWidth + 5.0) / 2.0
        for dot in customPageControlDots {
            dot.frame.origin.x += startX
        }
    }
}
