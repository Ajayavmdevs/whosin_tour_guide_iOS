import UIKit
import Contacts

let WHOSINCONTACT = WhosinContactManager.shared

class WhosinContactManager: NSObject {
    
    private let syncQueue = DispatchQueue(label: "com.whosinContactManager.syncQueue")
    private var _didSync = false
    private var _contactList: [UserDetailModel] = []
    private var _inviteContactList: [UserDetailModel] = []


    // -------------------------------------
    // MARK: Singleton
    // --------------------------------------
    
    class var shared: WhosinContactManager {
        struct Static {
            static let instance = WhosinContactManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
    }
    
    // -------------------------------------
    // MARK: Getter
    // --------------------------------------
    
//    var didSync: Bool { _didSync }
//    
//    
//    var contactList: [UserDetailModel] { _contactList }
//
//    var inviteContactList: [UserDetailModel] {
//        _inviteContactList
//    }
    var didSync: Bool { syncQueue.sync { _didSync } }
    var contactList: [UserDetailModel] { syncQueue.sync { _contactList } }
    var inviteContactList: [UserDetailModel] { syncQueue.sync { _inviteContactList } }

    
    // -------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _requestContactList(callback: ((NSError?) -> Void)? = nil) {
        let contactStore = CNContactStore()
        
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            fetchContacts(from: contactStore, callback: callback)
        case .denied, .restricted:
            if CNContactStore.authorizationStatus(for: .contacts) == .denied {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(
                        title: "access_contacts".localized(),
                        message: contactsPermissionMessage,
                        preferredStyle: .alert
                    )
                    
                    alertController.addAction(UIAlertAction(title: "open_settings".localized(), style: .default) { _ in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    })
                    
                    alertController.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
                    Utils.presentViewController(alertController)
                }
            }
        case .notDetermined:
            DispatchQueue.main.async {
                contactStore.requestAccess(for: .contacts) { success, error in
                    if success {
                        self.fetchContacts(from: contactStore, callback: callback)
                    } else {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(
                                title: "access_contacts".localized(),
                                message: contactsPermissionMessage,
                                preferredStyle: .alert
                            )
                            
                            alertController.addAction(UIAlertAction(title: "open_settings".localized(), style: .default) { _ in
                                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(settingsURL)
                                }
                            })
                            
                            alertController.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
                            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                                keyWindow.rootViewController?.present(alertController, animated: true, completion: nil)
                            } else if let mainWindow = UIApplication.shared.connectedScenes
                                .filter({ $0.activationState == .foregroundActive })
                                .compactMap({ $0 as? UIWindowScene })
                                .first?.windows.first(where: { $0.isKeyWindow }) {
                                mainWindow.rootViewController?.present(alertController, animated: true, completion: nil)
                            } else {
                                UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
                            }

                        }
                    }
                }
            }
        @unknown default:
            print("contact access")
        }
    }
    
    private func fetchContacts(from contactStore: CNContactStore, callback: ((NSError?) -> Void)?) {
        do {
            let keysToFetch = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey,
                CNContactEmailAddressesKey
            ] as [CNKeyDescriptor]
            
            var contactList: [CNContact] = []
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            try contactStore.enumerateContacts(with: request) { contact, _ in
                contactList.append(contact)
            }
            _parseData(contacts: contactList, callback: callback)
        } catch {
            callback?(ErrorUtils.error(-1, message: "Failed to fetch contacts"))
        }
    }

    
    private func _parseData(contacts: [CNContact], callback: ((NSError?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var emailList: [String] = []
            var numberList: [String] = []
            
            contacts.forEach { contact in
                let firstName = contact.givenName
                let lastName = contact.familyName
                
                
                for email in contact.emailAddresses {
                    let emailAddress = email.value as String
                    if !emailAddress.isValidEmail() {
                        continue
                    }

                    emailList.append(emailAddress)

                    let model = UserDetailModel()
                    model.firstName = firstName
                    model.lastName = lastName
                    model.email = emailAddress

                    if !Utils.stringIsNullOrEmpty(model.firstName),
                       !Utils.stringIsNullOrEmpty(model.lastName),
                       !Utils.stringIsNullOrEmpty(model.email) {

                        DispatchQueue.main.async { [weak self] in
                            self?._inviteContactList.append(model)
                        }
                    }
                }

                
                contact.phoneNumbers.forEach { number in
                    let rawNumber = number.value.stringValue
                    let phoneNumber = rawNumber.numbersOnly
                    
                    guard !phoneNumber.isEmpty else { return }
                    numberList.append(phoneNumber)
                    
                    DispatchQueue.main.async {
                        let model = UserDetailModel()
                        model.firstName = firstName
                        model.lastName = lastName
                        model.phone = number.value.stringValue
                        self._inviteContactList.append(model)
                    }
                }
            }
            
            DispatchQueue.main.async {
                if !APPSESSION.didLogin {
                    callback?(nil)
                }
                self.syncContactApi()
            }
        }
    }


    func syncContactApi(callback: ((NSError?) -> Void)? = nil) {
        if !APPSESSION.didLogin {
            callback?(nil)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let numberList = self._inviteContactList.map({$0.phone.numbersOnly}).filter({!Utils.stringIsNullOrEmpty($0)})
            let emailList = self._inviteContactList.map({$0.email}).filter({!Utils.stringIsNullOrEmpty($0) && $0.isValidEmail()})
            DispatchQueue.main.async {
                WhosinServices.getContactList(emails: emailList, phones: numberList) { [weak self] container, error in
                    guard let self = self else { return }
                    self._syncInviteContacts(response: container?.data)
                    callback?(error)
                    guard !self._didSync else { return }
                    self._didSync = error == nil
                }
            }
        }
    }

    private func _syncInviteContacts(response : [UserDetailModel]?) {
        DispatchQueue.global(qos: .userInitiated).async {
            let userDetailPhone = APPSESSION.userDetail?.phone
            let contacts = response?.filter({ Utils.stringIsNullOrEmpty($0.phone) ? false : $0.phone != userDetailPhone })  ?? []
            self._contactList = contacts.filter({ !Utils.stringIsNullOrEmpty($0.fullName) })
            let numbers = self._contactList.map({$0.phone.numbersOnly}).filter({!Utils.stringIsNullOrEmpty($0)})
            var result = self._inviteContactList.filter { contact in
                let phone = contact.phone.numbersOnly
                return !numbers.contains { phone.contains($0) } && !numbers.contains( where: {$0.contains(phone)}) && !phone.contains(userDetailPhone ?? kEmptyString)
            }
            let emails = self._contactList.map({$0.email}).filter({ !Utils.stringIsNullOrEmpty($0) && $0.isValidEmail() })
            result = result.filter({ !emails.contains($0.email) })
            DispatchQueue.main.async {
                self._inviteContactList = result
            }
        }
    }

    // -------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func sync(callback: ((NSError?) -> Void)? = nil) {
        DISPATCH_ASYNC_MAIN {
            self._requestContactList(callback: callback)
        }
    }
}
