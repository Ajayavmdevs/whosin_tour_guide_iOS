import PassKit

let WALLETMANAGER = WalletManager.shared

class WalletManager: NSObject {
    
    // -------------------------------------
    // MARK: Singleton
    // --------------------------------------

    class var shared: WalletManager {
        struct Static {
            static let instance = WalletManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func presentPass(from url: URL, on viewController: UIViewController) {
        guard PKAddPassesViewController.canAddPasses() else {
            print("Wallet not supported.")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let pass = try PKPass(data: data)
                    let vc = PKAddPassesViewController(pass: pass)
                    DispatchQueue.main.async {
                        viewController.present(vc!, animated: true)
                    }
                } catch {
                    print("Invalid .pkpass: \(error)")
                }
            } else {
                print("Failed to load pass: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
}
