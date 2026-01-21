import Foundation
import FirebaseAuth

class AuthManager {
    
    static let shared = AuthManager()
    private let auth = Auth.auth()
    private var verificationId: String?
    
    public func verifyPhoneNumber(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider()
          .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
              guard let verificationId = verificationID, error == nil else {
                completion(false)
                return
              }
              self?.verificationId = verificationID
              completion(true)
          }
    }
    
    public func verifyOtp(verificationCode: String, completion: @escaping (Bool) -> Void) {
        
        guard let verificationId = verificationId else {
            completion(false)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationId,
            verificationCode: verificationCode
        )
        
        auth.signIn(with: credential) { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            completion(true)
            let currentUser = self.auth.currentUser
            currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error {
                    // Handle error
                    return;
                }
            }
        }
    }
}
