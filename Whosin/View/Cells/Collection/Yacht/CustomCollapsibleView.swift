import Foundation
import RealmSwift
import UIKit
import SnapKit


class CustomCollapsibleView: UIView {
    
    
    @IBOutlet weak var _titleBgView: UIView!
    @IBOutlet weak var _titleText: UILabel!
    @IBOutlet weak var _arrowIcon: UIImageView!
    @IBOutlet weak var _discriptionView: UIView!
    @IBOutlet weak var _discriptionText: UILabel!
    @IBOutlet weak var _textView: UITextView!
    @IBOutlet weak var _readMoreBtn: UIButton!
    var callback: ((_ isExpand: Bool)-> Void)?
    private var _subTitleText: String = kEmptyString
    
    var isExpanded: Bool = false {
        didSet {
            _discriptionView.isHidden = !isExpanded
            let angle: CGFloat = isExpanded ? CGFloat.pi : 0.0
            _arrowIcon.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        _titleBgView.addGestureRecognizer(tapGesture)
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomCollapsibleView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    public func setUp(_ title: String, subTitle: String) {
        _titleText.text = title
        _subTitleText = subTitle
        _titleBgView.backgroundColor = ColorBrand.paigerBgColor
        if subTitle.containsHTML() {
            _discriptionText.attributedText = Utils.convertHTMLToAttributedString(from: subTitle)
            _discriptionView.backgroundColor = ColorBrand.paigerBgColor.withAlphaComponent(0.8)
        } else {
            _discriptionText.text = subTitle
            _discriptionView.backgroundColor = ColorBrand.paigerBgColor.withAlphaComponent(0.8)
            if title == "🚨 DISCLAIMER"  {
                _discriptionView.backgroundColor = UIColor(hexString: "#FF0404").withAlphaComponent(0.10)
            }
        }
        
        _readMoreBtn.isHidden = !_discriptionText.isActuallyTruncated
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleReadMoreEvent(_ sender: CustomButton) {
        let vc = INIT_CONTROLLER_XIB(DeclaimerBottomSheet.self)
        vc.disclaimerTitle = _titleText.text ?? ""
        vc.disclaimerdescriptions = _subTitleText
        parentBaseController?.presentAsPanModal(controller: vc)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        isExpanded.toggle()
        callback?(isExpanded)
    }
    
}
