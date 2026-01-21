//
//  TabbyPaymentViewController.swift
//  Whosin
//
//  Created by Creative Infoway on 24/03/2025.
//

import UIKit
import WebKit

enum PaymentTabbyStatus {
    case success
    case failure
    case cancelled
}


class TabbyPaymentViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
  
    
    var webView: WKWebView!
        var paymentURL: String = ""
        var onPaymentResult: ((PaymentTabbyStatus) -> Void)? // Callback for payment status
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            loadPaymentPage()
        }
        
        // MARK: - Setup UI
        func setupUI() {
            view.backgroundColor = .white
            title = "Payment"
            
            // Add Close Button in Navigation Bar
//            navigationItem.rightBarButtonItem = UIBarButtonItem(
//                barButtonSystemItem: .close,
//                target: self,
//                action: #selector(closeTapped)
//            )
//            navigationItem.rightBarButtonItem?.tintColor = .black

            let configuration = WKWebViewConfiguration()
            configuration.preferences.javaScriptEnabled = true
            configuration.userContentController.add(self, name: "tabbyMobileSDK")
            // Initialize WebView
            webView = WKWebView(frame: .zero, configuration: configuration)
            webView.uiDelegate = self
            webView.navigationDelegate = self
            webView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(webView)
            
            // Layout Constraints
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        // MARK: - Load Payment Page
        func loadPaymentPage() {
            guard let url = URL(string: paymentURL) else { return }
            webView.load(URLRequest(url: url))
        }
        
        // MARK: - Close Button Action
        @objc func closeTapped() {
            onPaymentResult?(.cancelled)
            dismiss(animated: true, completion: nil)
        }
        
        // MARK: - Handle Payment Completion
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url?.absoluteString {
                if url.contains("https://whosin.me/tabby/success") {
                    print("Payment Successful!")
                    dismiss(animated: true) {
                        self.onPaymentResult?(.success)
                    }
//                    dismiss(animated: true, completion: nil)
                } else if url.contains("https://whosin.me/tabby/cancel") {
                    print("Payment Successful!")
                    onPaymentResult?(.cancelled)
                    dismiss(animated: true, completion: nil)
                } else if url.contains("https://whosin.me/tabby/failure") {
                    print("Payment Failed!")
                    onPaymentResult?(.failure)
                    dismiss(animated: true, completion: nil)
                }
            }
            decisionHandler(.allow)
        }
    
//    var webView: WKWebView!
//    var paymentURL: String = "" // Set this before presenting the view
//    var onPaymentResult: ((PaymentStatus) -> Void)? // Callback for result
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadPaymentPage()
//    }
//    
//    // MARK: - Setup UI
//    func setupUI() {
//        view.backgroundColor = .white
//        
//        // Add WebView
//        webView = WKWebView()
//        webView.navigationDelegate = self
//        webView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(webView)
//        
//        // Add Close Button
//        let closeButton = UIButton(type: .system)
//        closeButton.setTitle("✕", for: .normal)
//        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        closeButton.tintColor = .black
//        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(closeButton)
//        
//        // Layout Constraints
//        NSLayoutConstraint.activate([
//            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30),
//            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
//            
//            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
//            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    // MARK: - Load Payment Page
//    func loadPaymentPage() {
//        guard let url = URL(string: paymentURL) else { return }
//        webView.load(URLRequest(url: url))
//    }
//    
//    // MARK: - Close Button Action
//    @objc func closeTapped() {
//        onPaymentResult?(.cancelled)
//        dismiss(animated: true, completion: nil)
//    }
//    
//    // MARK: - Handle Payment Completion
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        if let url = navigationAction.request.url?.absoluteString {
//            if url.contains("payment-success") {
//                print("Payment Successful!")
//                onPaymentResult?(.success)
//                dismiss(animated: true, completion: nil)
//            } else if url.contains("payment-failed") {
//                print("Payment Failed!")
//                onPaymentResult?(.failure)
//                dismiss(animated: true, completion: nil)
//            }
//        }
//        decisionHandler(.allow)
//    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        print(message.body)
        guard let msg = message.body as? String else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        DispatchQueue.main.async {
            let parsedMessage = msg.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            switch parsedMessage {
            case "close":
                self.onPaymentResult?(.cancelled)
                self.dismiss(animated: true, completion: nil)
                break
            case "authorized":
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    print("Payment Successful!")
                    self.dismiss(animated: true) {
                        self.onPaymentResult?(.success)
                    }
                }
                break
            case "rejected":
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.onPaymentResult?(.failure)
                    self.dismiss(animated: true, completion: nil)
                }
                break
            default:
                break
            }
        }
    }
}
