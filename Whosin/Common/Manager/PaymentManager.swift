import Foundation
import PassKit
import StripePaymentSheet
import StripeCore
import UIKit
import NISdk

let PAYMENTMANAGER = PaymentManager.shared

// MARK: Purchase type enum
enum PurchaseType {
    case raynaTour
    case package
    case membership
    case penalty
    case paidPass
    case deal
    case cart
}

// MARK: Payment method
enum PaymentMethod: String {
    case tabby, stripe, ngenius
}

// MARK: Payment result enum
enum PaymentResult {
    case success
    case cancelled
    case failure(Error)
}

class PaymentManager: NSObject {
    
    // MARK: For NISdk callback
    private var niCompletion: ((PaymentResult) -> Void)?
    
    // -------------------------------------
    // MARK: Singleton
    // --------------------------------------
    
    class var shared: PaymentManager {
        struct Static {
            static let instance = PaymentManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
    }
    
    private var parentVC: BaseViewController?
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func showPaymentOptions(in viewController: BaseViewController, params: [String: Any], isTabbyDisable: Bool = false, purchaseType: PurchaseType, completion: @escaping (PaymentResult) -> Void) {
        var modifiedParams = params
        // MARK: Payment Sheet
        let bottomSheet = PaymentBottomSheet()
        self.parentVC = viewController
        // MARK: Tabby flag
        bottomSheet.isTabbyDisable = isTabbyDisable
        // MARK: Payment process
        let processPayment: (PaymentMethod, _ isApplePay: Bool) -> Void = { paymentMethod, isApplePay  in
            let method = paymentMethod.rawValue == "stripe" ? APPSETTING.appSetiings?.allowStripePayments == true ? "stripe" : "ngenius" : paymentMethod.rawValue
            modifiedParams["paymentMethod"] = method
            // MARK: Request booking api call Purchase type and payemnt method pass from here
            self.requestBooking(
                apiType: purchaseType,
                isApplePay: isApplePay,
                params: modifiedParams,
                paymentMethod: PaymentMethod(rawValue: method) ?? .stripe,
                vc: viewController,
                completion: completion
            )
        }
        // MARK: Tabby option selected action
        bottomSheet.tabbyAction = {
            // MARK: Check media permission
            Utils.checkMediaPermissionsAndPrompt(from: viewController) { camera, photos, microphone in
                if camera, photos, microphone {
                    if Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.phone) || Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.email) {
                        viewController.showCustomAlert(title: kAppName, message: "email_and_phone_required_for_tabby_payment".localized(), yesButtonTitle: "complete_profile".localized(), noButtonTitle: "cancel".localized(), okHandler: { UIAlertAction in
                            let vc = INIT_CONTROLLER_XIB(EditProfileVC.self)
                            vc.callback = {
                                if Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.phone) || Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.email) {
                                    viewController.showCustomAlert(title: kAppName, message: "still_email_and_phone_not_completed_in_profile".localized(), yesButtonTitle: "complete_profile".localized(), noButtonTitle: "cancel".localized(), okHandler: { UIAlertAction in
                                        // MARK: Process tabby payment
                                        processPayment(.tabby, false)
                                    }, noHandler:  { UIAlertAction in
                                    })
                                } else {
                                    // MARK: Process tabby payment
                                    processPayment(.tabby, false)
                                }
                            }
                            viewController.navigationController?.pushViewController(vc, animated: true)
                        }, noHandler:  { UIAlertAction in
                        })
                    } else {
                        // MARK: Process tabby payment
                        processPayment(.tabby, false)
                    }
                }
            }
        }
        // MARK: Apple pay action callback
        bottomSheet.applePayAction = { processPayment(.stripe, true) }
        // MARK: Credit card callback
        bottomSheet.creditCardAction = { processPayment(.stripe, false) }
        // MARK: Link Card callback
        bottomSheet.viaLinkAction = { processPayment(.stripe, false) }
//        bottomSheet.ngeniusAction = { processPayment(.ngenius) }
        // MARK: Learn more for tabby sheet
        bottomSheet.learnMore = {
            let price = params["amount"] as? Double
            let merchantCode = "WMARE"
            let publicKey = "pk_test_0195a8d6-d236-5bb9-c1b8-c397c0ae1dcd"
            
            guard let url = URL(string: "https://checkout.tabby.ai/promos/product-page/installments/en/?price=\(price ?? 0)&currency=AED&merchant_code=\(merchantCode)&public_key=\(publicKey)") else {
                return
            }
            let vc = INIT_CONTROLLER_XIB(WebViewController.self)
            vc.url = url
            vc.modalPresentationStyle = .custom
            viewController.navigationController?.pushViewController(vc, animated: true)
            
        }
        // MARK: Show sheet option
        bottomSheet.show(in: viewController)
    }
    
    // MARK: Request booking comman for all types purchase
    private func requestBooking(apiType: PurchaseType,isApplePay: Bool, params: [String: Any], paymentMethod: PaymentMethod, vc: BaseViewController, completion: @escaping (PaymentResult) -> Void) {
        var modifiedParams = params
        modifiedParams["paymentMethod"] = paymentMethod.rawValue == "stripe" ? APPSETTING.appSetiings?.allowStripePayments == true ? "stripe" : "ngenius" : paymentMethod.rawValue
        
        vc.showHUD()
        print(modifiedParams.toJSONString)
        
        let bookingAPI: ( [String: Any], @escaping (ContainerModel<PaymentCredentialModel>?, Error?) -> Void) -> Void
        // MARK: Purchse type API call handle
        switch apiType {
        case .raynaTour:
            bookingAPI = WhosinServices.raynaTourBooking
        case .penalty:
            bookingAPI = WhosinServices.penaltyPaymentCreate
        case .package:
            bookingAPI = WhosinServices.stripePaymentIntent
        case .membership:
            bookingAPI = WhosinServices.requestPurchaseMembership
        case .paidPass:
            bookingAPI = WhosinServices.paidPassPaymentCreate
        case .deal:
            bookingAPI = WhosinServices.stripePaymentIntent
        case .cart:
            bookingAPI = WhosinServices.checkOutCart
            
        }
        
        // MARK: Calling booking API
        bookingAPI(modifiedParams) { [weak self] container, error in
            if let error = error, error.localizedDescription.localizedCaseInsensitiveContains("Session expired, please login again!") {
                vc.hideHUD()
                vc.alert(message: "session_expired".localized()) { _ in
                    APPSESSION.logout { [weak self] success, logoutError in
                        vc.hideHUD(error: logoutError)
                        guard success, let window = APP.window else { return }
                        let navController = NavigationController(rootViewController: INIT_CONTROLLER_XIB(LoginVC.self))
                        navController.setNavigationBarHidden(true, animated: false)
                        window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction: .fade, style: .easeInOut))
                    }
                }
                return
            }
            
            vc.hideHUD(error: error as NSError?)
            
            guard let data = container?.data, let self = self else {
                completion(.failure(error ?? NSError(domain: "Payment Error", code: 0, userInfo: nil)))
                return
            }
            LOGMANAGER.logTicketEvent(.checkout, id: BOOKINGMANAGER.ticketModel?._id ?? "", name: BOOKINGMANAGER.ticketModel?.title ?? "")
            if (apiType == .deal || apiType == .package) && container?.message == "Vip User Order Successfully Created!" {
                completion(.success)
            }
            if paymentMethod == .tabby {
                self.startTabbyCheckOut(data: data, completion: completion)
            } else {
                // MARK: Validation check for allow stripe payment
                if APPSETTING.appSetiings?.allowStripePayments == false || paymentMethod.rawValue == "ngenius" || APPSETTING.appSetiings?.allowNgeniusPayments == true {
                    // MARK: Start NISdk Payment
                    self.startNIPayment(data: data, isApplePay: isApplePay, completion: completion)
                } else if APPSETTING.appSetiings?.allowStripePayments == true || paymentMethod.rawValue == "stripe" || APPSETTING.appSetiings?.allowNgeniusPayments == true  {
                    // MARK: Start Stripe Payment
                    self.startStripeCheckOut(data: data, completion: completion)
                }
            }
        }
    }
    
    // MARK: Start NISdk payment
    private func startNIPayment(data: PaymentCredentialModel,isApplePay: Bool,
                                completion: @escaping (PaymentResult) -> Void) {
        
        guard let vc = parentVC else {
            completion(.failure(NSError(domain: "No Parent VC", code: 0)))
            return
        }
        
        self.niCompletion = completion
        
        // MARK: Convert Payment credential to Order Response model
        do {
            guard let jsonString = data.toJSONString(),
                  let jsonData = jsonString.data(using: .utf8),
                  var jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {

                vc.alert(message: "Invalid JSON")
                completion(.failure(NSError(domain: "Invalid JSON", code: 0)))
                return
            }
            
            // MARK: JSON convert and set value for amount
            jsonDict["amount"] = [
                "currencyCode": data.amount?.currencyCode ?? "AED",
                "value": data.amount?.value ?? 0
            ]
            
            // MARK: Payment credential to raw data for convert
            guard let rawData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) else {
                vc.alert(message: "Invalid payment data from server.")
                completion(.failure(NSError(domain: "Invalid JSON", code: 0)))
                return
            }

            
            let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: rawData)
            orderResponse.amount = Amount.init(currencyCode: data.amount?.currencyCode, value: data.amount?.value)
            
            let niSdk = NISdk.sharedInstance

            niSdk.shouldShowCancelAlert = true
            niSdk.shouldShowOrderAmount = true
            niSdk.setSDKLanguage(language: LANGMANAGER.currentLanguage)
            if let jsonData = try? JSONEncoder().encode(orderResponse),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("order response)===========", jsonString)
            }
            // MARK: NISDK theme setup
            let theme = NISdkColors()
            
            theme.payButtonTitleColorHighlighted = ColorBrand.white
            theme.payButtonTitleColor = ColorBrand.white
            
            theme.cardPreviewLabelColor = ColorBrand.white
            theme.textFieldLabelColor = ColorBrand.white
            theme.payPageLabelColor = ColorBrand.white
            
            niSdk.setSDKColors(sdkColors: theme)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                vc.dismiss(animated: false) {
                    if niSdk.deviceSupportsApplePay() && isApplePay && self.canStartApplePay(from: data) {
                        let amount = Double(orderResponse.amount?.value ?? 0) / 100
                        let applePayRequest = self.createApplePayRequest(amount: amount,
                                                                         currency: orderResponse.amount?.currencyCode ?? "AED",
                                                                         countryCode: "AE")

                        niSdk.initiateApplePayWith(
                            applePayDelegate: self,
                            cardPaymentDelegate: self,
                            overParent: vc,
                            for: orderResponse,
                            with: applePayRequest
                        )
                    } else {
                        niSdk.showCardPaymentViewWith(
                            cardPaymentDelegate: self,
                            overParent: vc,
                            for: orderResponse
                        )
                    }
                    
                }
            }
        } catch {
            print("❌ NISdk JSON Decode Error:", error.localizedDescription)
            vc.alert(message: "Unable to start payment.")
            completion(.failure(error))
            self.niCompletion = nil
        }
    }

    // MARK: Apple payment request
    func createApplePayRequest(amount: Double,
                               currency: String = "AED",
                               countryCode: String = "AE") -> PKPaymentRequest {
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.ngenius.com.whosin.me"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = .capability3DS
        request.requiredBillingContactFields = [.postalAddress, .name]
        request.countryCode = countryCode
        request.currencyCode = currency
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Order Payment",
                                 amount: NSDecimalNumber(value: amount))
        ]
        
        return request
    }

    private func canStartApplePay(from data: PaymentCredentialModel) -> Bool {
        let link = data.embedded?.payment.first?.links?.applePay?.href
        let validate = data.embedded?.payment.first?.links?.webValidateApple?.href
        let hasApplePayLink = !(link ?? "").isEmpty || !(validate ?? "").isEmpty
        return hasApplePayLink
    }
    
    // MARK: Tabby payment request
    private func startTabbyCheckOut(data: PaymentCredentialModel,completion: @escaping (PaymentResult) -> Void) {
        guard let paymentUrl = data.tabby?.webUrl, let vc = parentVC else { return }
        if Utils.stringIsNullOrEmpty(paymentUrl) {
            vc.alert(message: "tabby_payment_failed".localized())
            return
        }
        let paymentVC = TabbyPaymentViewController()
        paymentVC.paymentURL = paymentUrl
        paymentVC.onPaymentResult = { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .success:
                completion(.success)
            case .failure:
                completion(.cancelled)
            case .cancelled:
                completion(.failure(NSError(domain: "Payment Cancelled", code: 0, userInfo: nil)))
            }
        }
        
        let navController = UINavigationController(rootViewController: paymentVC)
        navController.modalPresentationStyle = .fullScreen
        vc.present(navController, animated: true)
    }
    
    // MARK: Stripe payment request
    private func startStripeCheckOut(data: PaymentCredentialModel, completion: @escaping (PaymentResult) -> Void) {
        guard !Utils.stringIsNullOrEmpty(data.publishableKey), let vc = parentVC else {
            parentVC?.alert(title: kAppName, message: "payment_initialization_error".localized())
            return
        }
        
        StripeAPI.defaultPublishableKey = data.publishableKey
        STPAPIClient.shared.publishableKey = data.publishableKey
        
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Whosin, Inc."
        configuration.allowsDelayedPaymentMethods = true
        configuration.applePay = .init(merchantId: "merchant.com.whosin.me", merchantCountryCode: "AE")
        
        let paymentSheet = PaymentSheet(paymentIntentClientSecret: data.clientSecret, configuration: configuration)
        
        paymentSheet.present(from: vc) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .completed:
                completion(.success)
            case .canceled:
                completion(.cancelled)
            case .failed(let error):
                completion(.failure(error))
            }
        }
    }
    
}

// MARK: Apple pay delegate
extension PaymentManager: ApplePayDelegate {
    
    func applePayDidBegin() {
        print("NISdk → Apple Pay Did Begin")
        DispatchQueue.main.async { [weak self] in
            self?.parentVC?.showHUD()
        }
    }
    
    func applePayDidComplete(with status: PaymentStatus) {
        print("NISdk → Apple Pay Completed: \(status)")
        
        // Hide loading on main thread
        DispatchQueue.main.async { [weak self] in
            self?.parentVC?.hideHUD()
        }
        
        // Handle Apple Pay result
        let completion = self.niCompletion
        self.niCompletion = nil // Clear immediately
        
        switch status {
        case .PaymentSuccess:
            print("✅ Apple Pay → SUCCESS")
            completion?(.success)
            
        case .PaymentFailed:
            print("❌ Apple Pay → FAILED")
            completion?(.failure(
                NSError(
                    domain: "NGenius",
                    code: 2001,
                    userInfo: [NSLocalizedDescriptionKey: "Apple Pay payment failed."]
                )
            ))
            
        case .PaymentCancelled:
            print("⚠️ Apple Pay → CANCELLED")
            completion?(.cancelled)
            
        case .InValidRequest:
            print("❌ Apple Pay → INVALID REQUEST")
            completion?(.failure(
                NSError(
                    domain: "NGenius",
                    code: 2002,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid Apple Pay request."]
                )
            ))
            
        case .PaymentPostAuthReview:
            print("⏳ Apple Pay → POST AUTH REVIEW")
            completion?(.success)
            
        @unknown default:
            print("❓ Apple Pay → UNKNOWN STATUS")
            completion?(.failure(
                NSError(
                    domain: "NGenius",
                    code: 2003,
                    userInfo: [NSLocalizedDescriptionKey: "Unknown Apple Pay status."]
                )
            ))
        }
    }
    
    func applePayAuthorizationDidFinish(with paymentData: PKPayment) {
        print("🍎 NISdk → Apple Pay Authorization Finished")
        print("Payment Token: \(paymentData.token)")
        
        // You can access additional payment details here if needed
        if let billingContact = paymentData.billingContact {
            print("Billing Name: \(billingContact.name?.givenName ?? "") \(billingContact.name?.familyName ?? "")")
        }
        
        if let shippingContact = paymentData.shippingContact {
            print("Shipping Name: \(shippingContact.name?.givenName ?? "") \(shippingContact.name?.familyName ?? "")")
        }
    }
    
    func applePaymentAuthorizationDidFail(with error: Error) {
        print("❌ NISdk → Apple Pay Authorization Failed: \(error.localizedDescription)")
        
        DispatchQueue.main.async { [weak self] in
            self?.parentVC?.hideHUD()
        }
        
        let completion = self.niCompletion
        self.niCompletion = nil
        completion?(.failure(error))
    }
}

// MARK: Card payment delegate
extension PaymentManager: CardPaymentDelegate {
    
    // Optional callbacks
    func authorizationWillBegin() {
        print("NISdk → Authorization Will Begin")
    }
    
    func authorizationDidBegin() {
        print("NISdk → Authorization Did Begin")
    }
    
    func authorizationDidComplete(with status: AuthorizationStatus) {
        print("NISdk → Authorization Completed: \(status)")
//        if status == AuthorizationStatus.AuthSuccess {
//            niCompletion?(.success)
//        } else if status == AuthorizationStatus.AuthFailed {
//            niCompletion?(.failure(
//                NSError(domain: "NGenius Payment Failed", code: 0)
//            ))
//        }
    }
    
    func paymentDidBegin() {
        print("NISdk → Payment Started")
    }
    
    func threeDSChallengeDidBegin() {
        print("NISdk → 3DS Challenge Started")
    }
    
    func threeDSChallengeDidComplete(with status: ThreeDSStatus) {
        print("NISdk → 3DS Challenge Completed: \(status)")
    }
    
    
    func paymentDidComplete(with status: PaymentStatus) {
        
        print("NISdk → Payment Completed: \(status)")
        
        switch status {
        case .PaymentSuccess:
            print("NISdk → SUCCESS")
            niCompletion?(.success)
            
        case .PaymentFailed:
            print("NISdk → FAILED")
            niCompletion?(.failure(
                NSError(domain: "Payment Failed", code: 0)
            ))
            
        case .PaymentCancelled:
            print("NISdk → CANCELLED")
            niCompletion?(.cancelled)
            
        case .InValidRequest:
            print("NISdk → INVALID REQUEST")
            niCompletion?(.failure(
                NSError(domain: "Invalid Request", code: 0)
            ))
            
        case .PaymentPostAuthReview:
            print("NISdk → POST AUTH REVIEW")
            niCompletion?(.success) // or failure — depends on business logic

        case .PartialAuthDeclined:
            print("NISdk → PARTIAL AUTH DECLINED")
            niCompletion?(.failure(
                NSError(domain: "Partial Auth Declined", code: 0)
            )) // or failure — depends on business logic
        case .PartialAuthDeclineFailed:
            print("NISdk → PARTIAL AUTH DECLINED FAILED")
            niCompletion?(.failure(
                NSError(domain: "Partial Auth Declined Failed", code: 0)
            )) // or failure — depends on business logic

        case .PartiallyAuthorised:
            print("NISdk → PARTIALLY AUTHORISED")
            niCompletion?(.success)
        }
        
        niCompletion = nil
    }
}
