import UIKit
import WebKit

protocol purchaseSuccessDelegate: AnyObject {
    func purchaseSuccess()
}

class WebViewController: ChildViewController {
    
    weak var delegate: purchaseSuccessDelegate?
    @IBOutlet weak var _titleText: UILabel!
    var url: URL?
    var htmlTxt: String?
    var viewTitle: String = kEmptyString
	@IBOutlet weak private var _webView: WKWebView!

	private let _progressView = UIProgressView(progressViewStyle: .default)
	private var _estimatedProgressObserver: NSKeyValueObservation?

	// --------------------------------------
	// MARK: Life Cycle
	// --------------------------------------

    open override func viewDidLoad() {
		super.viewDidLoad()
		_setupWebView()
		_setupProgressview()
        _titleText.text = viewTitle
        if Utils.stringIsNullOrEmpty(htmlTxt) {
            _loadWebView()
        } else {
            _loadHTMLWebView()
        }
		
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		_progressView.removeFromSuperview()
	}

	// --------------------------------------
	// MARK: Private
	// --------------------------------------

	private func _setupWebView() {
		_webView.configuration.allowsInlineMediaPlayback = true
		_webView.configuration.allowsAirPlayForMediaPlayback = true
		_webView.configuration.allowsPictureInPictureMediaPlayback = true
		_webView.configuration.dataDetectorTypes = .all
		_webView.navigationDelegate = self
	}

	private func _setupProgressview() {
		guard let navigationBar = navigationController?.navigationBar else { return }
		_progressView.translatesAutoresizingMaskIntoConstraints = false
        _progressView.tintColor = ColorBrand.white
		navigationBar.addSubview(_progressView)
		_progressView.isHidden = true
		NSLayoutConstraint.activate([
			_progressView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
			_progressView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),
			_progressView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
			_progressView.heightAnchor.constraint(equalToConstant: 2.0)
		])
		_estimatedProgressObserver = _webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
			self?._progressView.progress = Float(webView.estimatedProgress)
		}
	}

	private func _loadWebView() {
        guard let url = url else { return }
        let request = URLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData)
        _webView.load(request)
	}

    private func _loadHTMLWebView() {
        guard let htmlTxt = htmlTxt else { return }
        _webView.loadHTMLString(htmlTxt, baseURL: nil)
    }
	// --------------------------------------
	// MARK: <WKNavigationDelegate>
	// --------------------------------------

	public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		alert(message: error.localizedDescription)
		Log.debug("error=\(error.localizedDescription)")
	}
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension WebViewController: WKNavigationDelegate {
	public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		if _progressView.isHidden {
			_progressView.isHidden = false
		}
		UIView.animate(withDuration: 0.33) {
			self._progressView.alpha = 1.0
		}
	}
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url?.absoluteString{
            if url == "https://whosin.me/v1/subscription/success" {
                APPSETTING.configureSubscrition()
                navigationController?.popViewController(animated: true)
            }
        }
    }

	public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		UIView.animate(withDuration: 0.33, animations: {
			self._progressView.alpha = 0.0
		}, completion: { isFinished in
			self._progressView.isHidden = isFinished
            APPSETTING.configureSubscrition()
		})
	}
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let url = navigationAction.request.url?.absoluteString {
                if url == "https://whosin.me/v1/subscription/success" {
                    decisionHandler(.cancel)
                    delegate?.purchaseSuccess()
                    navigationController?.popViewController(animated: true)
                    return
                }
            }
            
            decisionHandler(.allow)
        }
}
