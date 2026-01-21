import UIKit

let inset : CGFloat = 10

public protocol SwipeCardViewDelegate: AnyObject {
    func dummyAnimationDone()
    func currentCardStatus(card: Any, distance: CGFloat)
    func fallbackCard(model:Any)
    func didSelectCard(model:Any)
    func cardGoesLeft(model: Any)
    func cardGoesRight(model: Any)
    func undoCardsDone(model: Any)
    func endOfCardsReached()
}

public class SwipeCardView <Element>: UIView {
    
    var bufferSize: Int = 10 {
        didSet {
            bufferSize = 10
        }
    }
    public var sepeatorDistance : CGFloat = 8
    var index = 0
    
    fileprivate var allCards = [Element]()
    fileprivate var loadedCards = [SwipeCard]()
    fileprivate var currentCard : SwipeCard!
    
    public weak var delegate: SwipeCardViewDelegate?
    
    fileprivate let contentView: ContentView?
    public typealias ContentView = ( _ index: Int,  _ frame: CGRect, _ element:Element) -> (UIView)
    
    public init(frame: CGRect,
                contentView: @escaping ContentView, bufferSize : Int = 3) {
        self.contentView = contentView
        self.bufferSize = bufferSize
        super.init(frame: frame)
    }
    
    override private init(frame: CGRect) {
        fatalError("Please use init(frame:,overlayGenerator)")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Please use init(frame:,overlayGenerator)")
    }
    
    public func showSwipeCards(with elements: [Element] ,isDummyShow: Bool = true) {
        
        if elements.isEmpty {
            return
        }
        
        allCards.append(contentsOf: elements)
        
        for (i,element) in elements.enumerated() {
            
            if loadedCards.count < bufferSize {
                
                let cardView = self.createSwipeCard(index: i, element: element)
                if loadedCards.isEmpty {
                    self.addSubview(cardView)
                } else {
                    self.insertSubview(cardView, belowSubview: loadedCards.last!)
                }
                loadedCards.append(cardView)
            }
        }
        
        animateCardAfterSwiping()
        
        if isDummyShow{
            perform(#selector(loadAnimation), with: nil, afterDelay: 1.0)
        }
    }
    
    public func appendSwipeCards(with elements: [Element]) {
        
        if elements.isEmpty {
            return
        }
    }
    
    fileprivate func createSwipeCard(index:Int,element: Element) -> SwipeCard {
        
        let card = SwipeCard(frame: CGRect(x: inset, y: inset + (CGFloat(loadedCards.count) * self.sepeatorDistance), width: bounds.width - (inset * 2), height: bounds.height - (CGFloat(bufferSize) * sepeatorDistance) - (inset * 2) ))
        card.delegate = self
        card.model = element
        card.addContentView(view: (self.contentView?(index, card.bounds, element)))
        return card
    }
    
    fileprivate func animateCardAfterSwiping() {
        
        if loadedCards.isEmpty{
            self.delegate?.endOfCardsReached()
            return
        }
        
        for (i,card) in loadedCards.enumerated() {
            
            UIView.animate(withDuration: 0.5, animations: {
                card.isUserInteractionEnabled = i == 0 ? true : false
                var frame = card.frame
                frame.origin.y = inset + (CGFloat(i) * self.sepeatorDistance)
                card.frame = frame
            })
        }
    }
    
    @objc private func loadAnimation() {
    }
    
    fileprivate func removeCardAndAddNewCard(){
        
        index += 1
        let card = loadedCards.first!
        card.index = index
        Timer.scheduledTimer(timeInterval: 1.01, target: self, selector: #selector(enableUndoButton), userInfo: card, repeats: false)
        loadedCards.remove(at: 0)
        
        if (index + loadedCards.count) < allCards.count {
            let swipeCard = createSwipeCard(index: index + loadedCards.count, element: allCards[index + loadedCards.count])
            self.insertSubview(swipeCard, belowSubview: loadedCards.last!)
            loadedCards.append(swipeCard)
        }
        
        animateCardAfterSwiping()
    }
    
    public func makeLeftSwipeAction() {
        if let card = loadedCards.first {
            card.leftClickAction()
        }
    }
    
    public func makeRightSwipeAction() {
        if let card = loadedCards.first {
            card.rightClickAction()
        }
    }
    
    public func undoCurrentSwipeCard() {
        
        guard let undoCard = currentCard else{
            return
        }
        
        index -= 1
        if loadedCards.count == bufferSize {
            let lastCard = loadedCards.last
            lastCard?.rollBackCard()
            loadedCards.removeLast()
        }
        
        undoCard.layer.removeAllAnimations()
        self.insertSubview(undoCard, aboveSubview: loadedCards.first!)
        loadedCards.insert(undoCard, at: 0)
        undoCard.makeUndoAction()
        animateCardAfterSwiping()
        delegate?.undoCardsDone(model: undoCard.model!)
        currentCard = nil
    }
    
    @objc private func enableUndoButton(timer: Timer){
        
        let card = timer.userInfo as! SwipeCard
        if card.index == index{
            currentCard = card
        }
    }
}

extension SwipeCardView : SwipeCardDelegate {
    
    func didSelectCard(card: SwipeCard) {
        self.delegate?.didSelectCard(model: card.model!)
    }
    
    func fallbackCard(card: SwipeCard) {
        self.delegate?.fallbackCard(model: card.model!)
    }
    
    func cardGoesRight(card: SwipeCard) {
        removeCardAndAddNewCard()
        self.delegate?.cardGoesRight(model: card.model!)
    }
    
    func cardGoesLeft(card: SwipeCard) {
        removeCardAndAddNewCard()
        self.delegate?.cardGoesLeft(model: card.model!)
    }
    
    func currentCardStatus(card: SwipeCard, distance: CGFloat) {
        self.delegate?.currentCardStatus(card: card, distance: distance)
    }
}
