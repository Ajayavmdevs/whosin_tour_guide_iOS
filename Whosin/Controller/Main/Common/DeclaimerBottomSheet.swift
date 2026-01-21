import UIKit

class DeclaimerBottomSheet: PanBaseViewController, UITextViewDelegate {

    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _discriptions: UILabel!
//    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var _scrollView: UIScrollView!
    @IBOutlet weak var textView: CustomTextView!
    public var disclaimerTitle: String = kEmptyString
    public var disclaimerdescriptions: String = kEmptyString
    public var features: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        _titleLabel.text = disclaimerTitle
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.dataDetectorTypes = [.link]
        
        if !features.isEmpty {
            // 🔹 If features exist, show as bullet list
            textView.attributedText = createBulletList(from: features)
        } else if disclaimerdescriptions.containsHTML() {
            textView.attributedText = Utils.convertHTMLToAttributedString(from: disclaimerdescriptions)
        } else {
            textView.text = disclaimerdescriptions
        }
        
        adjustTextViewHeight()
    }
    
    private func createBulletList(from items: [String]) -> NSAttributedString {
        let bulletList = NSMutableAttributedString()
        let bullet = "• "
        
        // Configure paragraph style with tab stops for 2-column layout
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 4
        paragraphStyle.defaultTabInterval = 180 // adjust based on font size / device width
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: 180, options: [:])
        ]
        paragraphStyle.lineBreakMode = .byWordWrapping

        let font = UIFont.systemFont(ofSize: 15, weight: .regular)
        let textColor = UIColor.label
        
        // Generate lines with 2 items per row
        for i in stride(from: 0, to: items.count, by: 2) {
            let first = "\(bullet)\(items[i])"
            var line = first
            
            if i + 1 < items.count {
                let second = "\(bullet)\(items[i + 1])"
                // Tab before second bullet to align columns
                line += "\t" + second
            }
            
            line += "\n"
            
            bulletList.append(NSAttributedString(
                string: line,
                attributes: [
                    .font: font,
                    .foregroundColor: textColor,
                    .paragraphStyle: paragraphStyle
                ]
            ))
        }
        
        return bulletList
    }

    
    func adjustTextViewHeight() {
        textView.sizeToFit()
        textView.layoutIfNeeded()
        
        if let heightConstraint = textView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = textView.contentSize.height
        }
        
        _scrollView.contentSize = CGSize(width: _scrollView.frame.width, height: textView.frame.maxY + 20)
    }


    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
    }

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
