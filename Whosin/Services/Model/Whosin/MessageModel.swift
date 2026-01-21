import Foundation
import DifferenceKit
import ObjectMapper
import RealmSwift


class MessageModel: Object, Mappable, ModelProtocol, Differentiable, Identifiable {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var chatId: String = kEmptyString
    @objc dynamic var chatType: String = kEmptyString
    @objc dynamic var author: String = kEmptyString
    @objc dynamic var authorName: String = kEmptyString
    @objc dynamic var authorImage: String = kEmptyString
    @objc dynamic var _msg: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var date: String = kEmptyString
    @objc dynamic var audioDuration: String = kEmptyString
    
    dynamic var members: List<String> = List<String>()
    dynamic var receivers: List<String> = List<String>()
    dynamic var seenBy: List<String> = List<String>()
    @objc dynamic var replyBy: String = kEmptyString
    @objc dynamic var replyTo: ReplyToModel?
    
    var msg: String {
        get {
            let cryptLib = CryptLib()
            let cipherText = cryptLib.decryptCipherTextRandomIV(withCipherText: _msg, key: chatId) ?? kEmptyString
            return cipherText
        }
        set(newMsg) {
            let cryptLib = CryptLib()
            let cipherText = cryptLib.encryptPlainTextRandomIV(withPlainText: newMsg, key: chatId)
            _msg = cipherText ?? kEmptyString
        }
    }
        
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    override init() {
    }
    
    init(msg: String, chatModel: ChatModel, type: String = MessageType.text.rawValue, replyBy: String = kEmptyString,replyTo: ReplyToModel? = nil ) {
        guard let userDetail = APPSESSION.userDetail else { return }
        self.id = Utils.generateMessageId(Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id)
        self.chatId = chatModel.chatId
        self.chatType = chatModel.chatType
        self.members.removeAll()
        self.members.append(objectsIn: chatModel.members)
        if let userDetail = APPSESSION.userDetail {
            if Preferences.isSubAdmin {
                if !self.members.contains(where: { $0 == userDetail.promoterId }) {
                    if let index = members.firstIndex(where: { $0 == userDetail.id }) {
                        self.members.remove(at: index)
                    }
                    self.members.append(userDetail.promoterId)
                }
            } else {
                if !self.members.contains(where: { $0 == userDetail.id }) {
                    self.members.append(userDetail.id)
                }
            }
        }
        let cryptLib = CryptLib()
        self._msg = cryptLib.encryptPlainTextRandomIV(withPlainText: msg, key: chatId)
        self.type = type
        if !Utils.stringIsNullOrEmpty(replyBy) {
            self.replyBy = replyBy
        }
        self.author = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
        if chatModel.chatType == ChatType.promoterEvent.rawValue {
            self.authorName = chatModel.title
            self.authorImage = chatModel.image
        } else {
            let promoter = APPSESSION.promoterProfile
            self.authorName = Preferences.isSubAdmin ? promoter?.profile?.fullName ?? kEmptyString : userDetail.fullName
            self.authorImage = Preferences.isSubAdmin ? promoter?.profile?.image ?? kEmptyString :userDetail.image
        }
        if let data = replyTo {
            self.replyTo = data
        }
        self.date =  "\(Date().timeIntervalSince1970)"
    }
    
    required init?(map: Map) {}
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    func isSent(_ userId: String) -> Bool {
        return author == userId
    }
    
    func isSent() -> Bool {
        guard let userDetail = APPSESSION.userDetail else { return false }
        return Preferences.isSubAdmin ? author == userDetail.promoterId : author == userDetail.id
    }
    
    func decryptedMsg() -> String {
        let cryptLib = CryptLib()
        let cipherText = cryptLib.decryptCipherTextRandomIV(withCipherText: msg, key: chatId)
        return cipherText ?? kEmptyString
    }
    
    class func msgIdPredicate(_ msgId: String) -> NSPredicate {
        NSPredicate(format: "id == %@", msgId)
    }
    
    class func msgIdPredicate(_ msgIds: [String]) -> NSPredicate {
        NSPredicate(format: "id IN %@", msgIds)
    }
    
    class func chatIdPredicate(_ chatId: String) -> NSPredicate {
        NSPredicate(format: "chatId == %@", chatId)
    }
    
    class func unReadPredicate(_ chatId: String) -> NSPredicate {
        guard let userDetail = APPSESSION.userDetail else { return NSPredicate(format: "chatId == %@ AND NOT %@ IN seenBy AND author != %@", "", "", "") }
        let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
        return NSPredicate(format: "chatId == %@ AND NOT %@ IN seenBy AND author != %@", chatId, id, id)
    }
    class func unReadPredicateIds(_ chatIds: [String]) -> NSPredicate {
        guard let userDetail = APPSESSION.userDetail else { return NSPredicate(format: "chatId IN %@ AND NOT %@ IN seenBy AND author != %@", [], "", "") }
        let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
        return NSPredicate(format: "chatId IN %@ AND NOT %@ IN seenBy AND author != %@", chatIds, id, id)
    }
    
    class func unReadPredicateNotInIds(_ chatIds: [String], _ type: String) -> NSPredicate {
        guard let userDetail = APPSESSION.userDetail else { return NSPredicate(format: "chatId IN %@ AND NOT %@ IN seenBy AND author != %@", [], "", "") }
        let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
        return NSPredicate(format: "NOT chatId IN %@ AND chatType == %@ AND NOT %@ IN seenBy AND author != %@", chatIds, type, id, id)
    }
    
    class func unReadTypePredicate(_ type: String) -> NSPredicate {
        guard let userDetail = APPSESSION.userDetail else { return NSPredicate(format: "chatType == %@ AND NOT %@ IN seenBy AND author != %@", "", "", "") }
        let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
        return NSPredicate(format: "chatType == %@ AND NOT %@ IN seenBy AND author != %@", type, id, id)
    }
    
    class func unAllReadPredicate() -> NSPredicate {
        guard let userDetail = APPSESSION.userDetail else { return NSPredicate(format: "NOT %@ IN seenBy AND author != %@", "", "") }
        let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
        return NSPredicate(format: "NOT %@ IN seenBy AND author != %@", id, id)
    }
    
    class func pendingMsgPredicate(_ id: String) -> NSPredicate {
        NSPredicate(format: "NOT %@ IN receivers AND author == %@", id, id)
    }
    
    class func mediaPredicate(_ chatId: String, type:String = "image") -> NSPredicate {
        NSPredicate(format: "chatId == %@ AND type == %@", chatId, type)
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        chatId <- map["chatId"]
        chatType <- map["chatType"]
        author <- map["author"]
        authorName <- map["authorName"]
        authorImage <- map["authorImage"]
        _msg <- map["msg"]
        type <- map["type"]
        date <- map["date"]
        audioDuration <- map["audioDuration"]
        members <- (map["members"] , StringListTransform())
        receivers <- (map["receivers"] , StringListTransform())
        seenBy <- (map["seenBy"] , StringListTransform())
        replyBy <- map["replyBy"]
        replyTo <- map["replyTo"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    var differenceIdentifier: String {
        return id
    }
    
    func isContentEqual(to source: MessageModel) -> Bool {
        return self.id == source.id && self.msg == source.msg && self.receivers.count == source.receivers.count && self.seenBy.count == source.seenBy.count
    }
    
    func isValid() -> Bool {
        return true
    }
}

class ReplyToModel: Object, Mappable, ModelProtocol, Differentiable, Identifiable {
    
    @objc dynamic var id: String = kEmptyString
    @objc dynamic var type: String = kEmptyString
    @objc dynamic var data: String = kEmptyString
                
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------

    override init() {
    }
    
    
    required init?(map: Map) {}
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override class func primaryKey() -> String? {
        "id"
    }
        
    func mapping(map: Map) {
        id <- map["id"]
        data <- map["data"]
        type <- map["type"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}
