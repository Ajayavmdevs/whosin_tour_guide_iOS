import Foundation
import UIKit

protocol SegmentedProgressBarDelegate: AnyObject {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarFinished()
    func segmentedProgressBarContentType(index: Int) -> String
}

class SegmentedProgressBar: UIView {
    
    weak var delegate: SegmentedProgressBarDelegate?
    var topColor = UIColor.gray {
        didSet {
            self.updateColors()
        }
    }
    var bottomColor = UIColor.gray.withAlphaComponent(0.25) {
        didSet {
            self.updateColors()
        }
    }
    var padding: CGFloat = 5.0
    var isPaused: Bool = false {
        didSet {
            if isPaused {
                for segment in segments {
                    let layer = segment.topSegmentView.layer
                    let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                    layer.speed = 0.0
                    layer.timeOffset = pausedTime
                }
            } else {
                currentAnimationIndex = segments.count == currentAnimationIndex ? currentAnimationIndex - 1 : currentAnimationIndex
                let segment = segments[currentAnimationIndex]
                let layer = segment.topSegmentView.layer
                let pausedTime = layer.timeOffset
                layer.speed = 1.0
                layer.timeOffset = 0.0
                layer.beginTime = 0.0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
        }
    }
    
    private var segments = [Segment]()
    var duration: TimeInterval
    private var hasDoneLayout = false
    var currentAnimationIndex = 0
    
    public var isAnimationStarted: Bool = false
    
    init(numberOfSegments: Int, duration: TimeInterval = 5.0) {
        self.duration = duration
        super.init(frame: CGRect.zero)
        
        for _ in 0..<numberOfSegments {
            let segment = Segment()
            addSubview(segment.bottomSegmentView)
            segment.bottomSegmentView.addSubview(segment.topSegmentView)
            segments.append(segment)
        }
        self.updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout {
            return
        }
        let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding), y: 0, width: width, height: frame.height)
            segment.bottomSegmentView.frame = segFrame
            segment.topSegmentView.frame = segment.bottomSegmentView.bounds
            segment.topSegmentView.frame.size.width = 0
            
            let cr = frame.height / 2
            segment.bottomSegmentView.layer.cornerRadius = cr
            segment.topSegmentView.layer.cornerRadius = cr
            
        }
        hasDoneLayout = true
    }
    
    func startAnimation() {
        layoutSubviews()
        isAnimationStarted = true
        animate()
    }
    
    func animate(animationIndex: Int = 0) {
        if segments.isEmpty { return }
        let nextSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        self.isPaused = false
        
        nextSegment.topSegmentView.frame.origin.x = 0
        
        if let contentType = delegate?.segmentedProgressBarContentType(index: animationIndex) {
            if contentType.lowercased() == "image" {
                UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
                    nextSegment.topSegmentView.frame.size.width = nextSegment.bottomSegmentView.frame.width
                }) { (finished) in
                    if !finished {
                        return
                    }
                    self.next()
                }
            }
        }
        
    }
    
    func updateProgress(progress: Float) {
        currentAnimationIndex = segments.count == currentAnimationIndex ? currentAnimationIndex - 1 : currentAnimationIndex
        let nextSegment = segments[currentAnimationIndex]
        let newWidth = Float(nextSegment.bottomSegmentView.frame.size.width) * progress
        if newWidth > Float(nextSegment.bottomSegmentView.frame.size.width) {
            nextSegment.topSegmentView.frame.origin.x = 0
            nextSegment.topSegmentView.frame.size.width = nextSegment.bottomSegmentView.frame.size.width
        } else {
            nextSegment.topSegmentView.frame.origin.x = 0
            nextSegment.topSegmentView.frame.size.width = CGFloat(newWidth)
        }
        
        if (progress >= 1) {
            self.next()
        }
    }
    
    private func updateColors() {
        for segment in segments {
            segment.topSegmentView.backgroundColor = topColor
            segment.bottomSegmentView.backgroundColor = bottomColor
        }
    }
    
    private func next() {
        let newIndex = currentAnimationIndex + 1

        if newIndex < segments.count {
            currentAnimationIndex = newIndex
            delegate?.segmentedProgressBarChangedIndex(index: newIndex)
            animate(animationIndex: newIndex)
        } else {
            currentAnimationIndex = segments.count
            delegate?.segmentedProgressBarFinished()
        }
    }


    
    func skip() {
        guard currentAnimationIndex < segments.count else { return }

        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.layer.removeAllAnimations()

        // Fill width completely to mark as completed
        currentSegment.topSegmentView.frame = CGRect(
            x: 0,
            y: 0,
            width: currentSegment.bottomSegmentView.frame.width,
            height: currentSegment.topSegmentView.frame.height
        )

        // Proceed to next
        next()
    }


    
    func rewind() {
        guard !segments.isEmpty else { return }

        // Reset current segment's animation and progress
        if currentAnimationIndex < segments.count {
            let currentSegment = segments[currentAnimationIndex]
            currentSegment.topSegmentView.layer.removeAllAnimations()
            currentSegment.topSegmentView.frame = CGRect(x: 0, y: 0, width: 0, height: currentSegment.topSegmentView.frame.height)
        }

        // Go to previous segment
        let newIndex = max(currentAnimationIndex - 1, 0)
        currentAnimationIndex = newIndex

        // Reset previous segment's animation and progress
        let prevSegment = segments[newIndex]
        prevSegment.topSegmentView.layer.removeAllAnimations()
        prevSegment.topSegmentView.frame = CGRect(x: 0, y: 0, width: 0, height: prevSegment.topSegmentView.frame.height)

        // Notify and animate
        delegate?.segmentedProgressBarChangedIndex(index: newIndex)
        animate(animationIndex: newIndex)
    }


    
    func cancel() {
        for segment in segments {
            segment.topSegmentView.layer.removeAllAnimations()
            segment.bottomSegmentView.layer.removeAllAnimations()
        }
    }
}

fileprivate class Segment {
    let bottomSegmentView = UIView()
    let topSegmentView = UIView()
    init() {
    }
}
