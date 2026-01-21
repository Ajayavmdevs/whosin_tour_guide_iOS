import UIKit

class FaqVC: ChildViewController {

    @IBOutlet weak var _textView: CustomTextView!
    public var faqText: String = kEmptyString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _textView.text = Utils.convertHTMLToPlainText(from: faqText)
    }

    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismissOrBack()
    }
    
}
