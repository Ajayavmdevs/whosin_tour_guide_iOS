import Foundation
import UIKit

class BadgeButton: UIButton {
    
    private var _label: UILabel = UILabel()
  
    public var badgeNumber: Int = 0 {
        didSet {
            _updateBadge()
        }
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
      
    override init(frame: CGRect) {
        _label.font = FontBrand.SFregularFont(size: 10)
        _label.backgroundColor = .red
        _label.alpha = 0.9
        _label.layer.cornerRadius = 7
        _label.clipsToBounds = true
        _label.isUserInteractionEnabled = false
        _label.translatesAutoresizingMaskIntoConstraints = false
        _label.textAlignment = .center
        _label.textColor = .white
        _label.layer.zPosition = 1
        super.init(frame: frame)
    }
      
    required init?(coder aDecoder: NSCoder) {
        _label.font = FontBrand.SFregularFont(size: 10)
        _label.backgroundColor = .red
        _label.alpha = 0.9
        _label.layer.cornerRadius = 7
        _label.clipsToBounds = true
        _label.isUserInteractionEnabled = false
        _label.translatesAutoresizingMaskIntoConstraints = false
        _label.textAlignment = .center
        _label.textColor = .white
        _label.layer.zPosition = 1
        super.init(coder: aDecoder)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
      
    private func _updateBadge() {
        _label.text = "\(badgeNumber)"
        if self.badgeNumber > 0 && _label.superview == nil {
            addSubview(_label)
            _label.widthAnchor.constraint(equalToConstant: 20).isActive = true
            _label.heightAnchor.constraint(equalToConstant: 14).isActive = true
            _label.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 7).isActive = true
            _label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -7).isActive = true
        } else if self.badgeNumber == 0 && _label.superview != nil {
            _label.removeFromSuperview()
        }
    }
}
