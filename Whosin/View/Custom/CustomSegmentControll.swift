import UIKit

protocol CustomSegmentControlDelegate: AnyObject {
    func didSelectSegment(at index: Int)
}


class CustomSegmentControll: UISegmentedControl {
    
    private var underlineView: UIView!
    weak var delegate: CustomSegmentControlDelegate?

    func setupSegments(_ items: [Any]?) {
        removeAllSegments()
        
        if let segmentItems = items {
            for (index, item) in segmentItems.enumerated() {
                self.insertSegment(withTitle: "\(item)", at: index, animated: false)
                setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
                setBackgroundImage(UIImage(), for: .selected, barMetrics: .default)
                setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
                
                setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
                setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            }
        }
        
        underlineView = UIView()
        underlineView.backgroundColor = UIColor.white
        addSubview(underlineView)
        updateUnderlinePosition(selectedIndex: 0)
    }

    func updateUnderlinePosition(selectedIndex: Int) {
        let segmentWidth = bounds.width / CGFloat(numberOfSegments)
        let underlineX = CGFloat(selectedIndex) * segmentWidth
        let underlineWidth = segmentWidth
        
        UIView.animate(withDuration: 0.3) {
            self.underlineView.frame = CGRect(x: underlineX, y: self.bounds.height - 2, width: underlineWidth, height: 3)
        }
        delegate?.didSelectSegment(at: selectedIndex)
    }

    func selectSegment(at index: Int) {
        setSelectedSegmentIndex(index)
        updateUnderlinePosition(selectedIndex: index)
    }
    
    func setSelectedSegmentIndex(_ index: Int) {
        super.selectedSegmentIndex = index
        updateUnderlinePosition(selectedIndex: index)
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        updateUnderlinePosition(selectedIndex: selectedSegmentIndex)
    }
}
