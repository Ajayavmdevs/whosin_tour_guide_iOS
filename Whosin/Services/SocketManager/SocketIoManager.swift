import Foundation
import SocketIO
import ObjectMapper
import RealmSwift

let SOCKETMANAGER = SocketIoManager.shared

class SocketIoManager: NSObject {
    let manager = SocketManager(socketURL: URLMANAGER.kScoketIoUrl, config: [.log(false), .reconnects(true), .compress])
    var socket: SocketIOClient!
    
    // -------------------------------------
    // MARK: Singleton
    // --------------------------------------
    
    class var shared: SocketIoManager {
        struct Static {
            static let instance = SocketIoManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        socket = manager.defaultSocket
        addHandlers()
    }
    
    func establishConnection() {
        if socket.status == .notConnected {
            socket.connect()
        }
    }


    private func addHandlers() {
        
        socket.on("connect") { (data, ack) in
            print("Socket connected")
            if !APPSESSION.didLogin { return }
            self.syncUnReceivedMsg()
            self.resendPendingMsg()
        }
        
        socket.on(clientEvent: .reconnect) { (data, ack) in
           print("Socket reconnect")
            if !APPSESSION.didLogin { return }
            self.syncUnReceivedMsg()
        }
        
        socket.on("disconnect") { (data, ack) in
            print("Socket disconnected")
        }
        
        socket.on("connecting") { (data, ack) in
            print("Socket Connecting")
        }
        
        socket.on(clientEvent: .statusChange) {data, ack in
            print("Socket status changed: \(data)")
        }
        
        socket.on("update_data") { (data, ack) in
            guard let userDetail = APPSESSION.userDetail else { return }
            if !data.isEmpty {
                if let approvalData = data.first as? [String: Any] {
                    if let approvalModel = Mapper<LoginApprovalModel>().map(JSON: approvalData) {
                        if approvalModel.type == "circle-remove" {
                            NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
                            NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
                        }
                        if let userId = approvalModel.metadata?.userId, userId == userDetail.id, approvalModel.type == "authentication" {
                            if approvalModel.metadata?.status == "pending" && approvalModel.metadata?.deviceId != Utils.getDeviceID(){
                                let vc = INIT_CONTROLLER_XIB(SignInVerificationVC.self)
                                vc.modalPresentationStyle = .overFullScreen
                                vc.approvalModel = approvalModel
                                Utils.openViewController(vc)
                            } else {
                                NotificationCenter.default.post(name: .approvedAuthRequest, object: approvalModel)
                            }
                        }
                    } else if let type = approvalData["type"] as? String, let ids = approvalData["userIds"] as? [String] {
                        if type == "cart-sync" && ids.contains(userDetail.id) {
                            NotificationCenter.default.post(name: Notification.Name("addtoCartCount"), object: nil)
                        }
                    }
                }
               
            }
        }
        
        socket.on("in_app_notification") { (data, ack) in
            guard let userDetail = APPSESSION.userDetail, APPSESSION.didLogin else { return }
            if let event = data.first {
                print(event)
                guard let eventModel = Mapper<InAppNotificationModel>().map(JSON: event as! [String : Any]) else { return }
                if eventModel.userType == "individual" && eventModel.userId == APPSESSION.userDetail?.id {
                    NotificationCenter.default.post(name: kInAppNotification, object: eventModel)
                } else if eventModel.userType == "all" || eventModel.userType == "only-live" {
                    NotificationCenter.default.post(name: kInAppNotification, object: eventModel)
                }
            }
        }
        
        socket.on("typing") { (data, ack) in
            guard let userDetail = APPSESSION.userDetail else { return }
            if let event = data.first {
                guard let eventModel = Mapper<TypingEventModel>().map(JSON: event as! [String : Any]) else { return }
                if eventModel.isForStartTyping {
                    print("get typing event for start")
                } else {
                    print("get typing event for stopd")
                }
                if Preferences.isSubAdmin {
                    if eventModel.userId == userDetail.promoterId { return }
                    if eventModel.receivers.contains(userDetail.promoterId) {
                        NotificationCenter.default.post(name: kTypingNotification, object: eventModel)
                    }
                } else {
                    if eventModel.userId == userDetail.id { return }
                    if eventModel.receivers.contains(userDetail.id) {
                        NotificationCenter.default.post(name: kTypingNotification, object: eventModel)
                    }
                }
            }
        }
        
        socket.on("seen_event") { (data, ack) in
            guard let userDetail = APPSESSION.userDetail else { return }
            if let event = data.first {
                Preferences.lastMsgSynced = "\(Date().timeIntervalSince1970)"
                let msgModels = Mapper<MessageModel>().mapArray(JSONArray: event as! [[String : Any]])
                let filterd = msgModels.filter{ !$0.isSent() && $0.members.contains(Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id) }
                if filterd.isEmpty { return }
                let msgIds = filterd.map{$0.id}
                guard let author = filterd.first?.author else { return }
                self.updateSeenBy(msgIds: msgIds, seenBy: author)
            }
        }
        
        socket.on("delivered_event") { (data, ack) in
            guard let userDetail = APPSESSION.userDetail else { return }
            if let event = data.first {
                Preferences.lastMsgSynced = "\(Date().timeIntervalSince1970)"
                let msgModels = Mapper<MessageModel>().mapArray(JSONArray: event as! [[String : Any]])
                let filterd = msgModels.filter{ !$0.isSent() && $0.members.contains(Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id) }
                if filterd.isEmpty { return }
                let msgIds = filterd.map{$0.id}
                guard let author = filterd.first?.author else { return }
                self.updateReceivers(msgIds: msgIds, receiver: author)
            }
        }
        
        socket?.on(kScocketEmitKey) { (dataArray, socketAck) in
            if !APPSESSION.didLogin { return }
            print("Socket URL: \(self.socket.manager?.socketURL)")
            guard let userDetail = APPSESSION.userDetail else { return }
            if let message = dataArray.first {
                guard let chatMessage = Mapper<MessageModel>().map(JSON: message as! [String : Any]) else {
                    return
                }
                Preferences.lastMsgSynced = "\(Date().timeIntervalSince1970)"
                if !chatMessage.members.contains(Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id) { return }
                if Preferences.isSubAdmin {
                    if chatMessage.author != userDetail.promoterId {
                        let tmp = chatMessage.detached()
                        self.sendDelivedEvent(msgs: [tmp])
                    }
                } else {
                    if chatMessage.author != userDetail.id {
                        let tmp = chatMessage.detached()
                        self.sendDelivedEvent(msgs: [tmp])
                    }
                }
                let chatRepository = ChatRepository()
                chatRepository.addChatMessage(messageData: chatMessage) { model in
                    guard let _model = model?.detached() else { return }
                    let eventInfo = ["chatId": _model.chatId, "id": [_model.id]] as [String : Any]
                    NotificationCenter.default.post(name: kMessageNotification, object:nil, userInfo: eventInfo)
                }
            }
        }
    }
    
//    func isSocketConnected() -> Bool {
//        return socket?.status == .connected
//    }
    
    func sendMessage(model: MessageModel) {
        let jsonString = model.toJSONString()
        self.socket.emit(kScocketEmitKey, jsonString ?? kEmptyString)
    }
    
    func sendTypingStatus(chatId: String, members:[String]?, chatType: ChatType = .user, status: Bool = false) {
        guard let userDetail = APPSESSION.userDetail else { return }
        let params: [String: Any] = [
            "chatId": chatId,
            "userId": Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id,
            "userName": userDetail.fullName,
            "chatType":"\(chatType)",
            "isForStartTyping": status,
            "receivers": members ?? []
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)!
            socket.emit("typing", jsonString)
        } catch {
            print("Error converting params to string: \(error.localizedDescription)")
        }
    }
    
    func sendSeenEvent(msgs:[MessageModel]) {
        guard let userDetail = APPSESSION.userDetail else { return }
        var cellData = [[String: Any]]()
        msgs.forEach { msg in
            let params: [String: Any] = ["id": msg.id, "chatId": msg.chatId,"members": msg.members.toArray(ofType: String.self), "author": Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id]
            cellData.append(params)
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: cellData, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)!
            socket.emit("seen_event", jsonString) {
                let ids = msgs.map { $0.id }
                self.updateSeenBy(msgIds: ids, seenBy: Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id)
            }
        } catch {
            print("Error converting params to string: \(error.localizedDescription)")
        }
    }
    
    func sendDelivedEvent(msgs:[MessageModel]) {
        guard let userDetail = APPSESSION.userDetail else { return }
        var cellData = [[String: Any]]()
        msgs.forEach { model in
            let msg = model.detached()
            let params: [String: Any] = ["id": msg.id, "chatId": msg.chatId, "members": msg.members.toArray(ofType: String.self), "author": Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id]
            cellData.append(params)
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: cellData, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)!
            socket.emit("delivered_event", jsonString) {
                let ids = msgs.map { $0.id }
                self.updateReceivers(msgIds: ids, receiver: Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id)
            }
        } catch {
            print("Error converting params to string: \(error.localizedDescription)")
        }
    }
    
    func updateReceivers(msgIds: [String], receiver: String) {
        ChatRepository().updateReceivers(id: msgIds, receiver: receiver) { model, error in
            self._handleUpdateResponse(response: model)
        }
    }
    
    func updateSeenBy(msgIds: [String], seenBy: String) {
        ChatRepository().updateSeenBy(id: msgIds, seenBy: seenBy) { model, error in
            self._handleUpdateResponse(response: model)
        }
    }
    
    private func _handleUpdateResponse(response: Results<MessageModel>?) {
        guard let response = response else { return }
        let chatIds = response.toArray(ofType: MessageModel.self).map {$0.chatId}
        let uniqueChatIds = Array(Set(chatIds))
        uniqueChatIds.forEach { chatId in
            NotificationCenter.default.post(name: kUpdateMessageNotification, object:response.toArray(ofType: MessageModel.self), userInfo:  ["chatId": chatId])
        }
    }
    
    public func syncUnReceivedMsg() {
        if APPSESSION.didLogin {
            guard let userDetail = APPSESSION.userDetail else { return }
            let chatRepo = ChatRepository()
            chatRepo.unReceivedMsgs { model, error in
                guard let _model = model else { return }
                if _model.isEmpty { return }
                let updatedArray = _model.toArrayDetached(ofType: MessageModel.self)
                let filteredArray = updatedArray.filter{ !$0.receivers.contains(Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id)}
                self.sendDelivedEvent(msgs: filteredArray)
            }
        }
    }
    
    public func resendPendingMsg() {
        if APPSESSION.didLogin {
            let messageList  = ChatRepository().getPendingMsgs()
            if !messageList.isEmpty {
                messageList.forEach { model in
                    if model.type == MessageType.image.rawValue || model.type == MessageType.audio.rawValue {
                        resendImageMsg(msgModel: model)
                    } else {
                        sendMessage(model: model)
                    }
                }
            }
        }
    }
    
    private func resendImageMsg(msgModel : MessageModel) {
        let _imageUrl = msgModel.msg
        if _imageUrl.isValidURL {
            self.sendMessage(model: msgModel)
        }
        else {
            if let imageName = _imageUrl.toURL?.lastPathComponent {
                let fileUrl = Utils.getDocumentsUrl().appendingPathComponent(imageName)
                if Utils.isFileExist(atPath: fileUrl.path) {
                    WhosinServices.uploadFile(fileUrl: fileUrl) { container , error in
                        guard let photoUrl = container?.data else { return }
                        msgModel.msg = photoUrl
                        self.sendMessage(model: msgModel)
                    }
                }
            }
        }
    }
    
}

