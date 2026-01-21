import RealmSwift
import CloudKit

class ChatRepository: Repository {
    
    func getAllGroupChatListOffline() ->  MyBucketModel? {
        let results = realm.objects(MyBucketModel.self)
        if results.count > 0 {
            return results.first
        }
        return nil
    }

    func getGroupChatLit(shouldRefresh: Bool = false, callback: @escaping(_ model: MyBucketModel?, _ error: NSError?) -> Void) {
        
        if !shouldRefresh {
            let results = realm.objects(MyBucketModel.self)
            if results.count > 0 {
                callback(results.first, nil)
                NotificationCenter.default.post(name: kMessageCountNotification, object: nil)
            }
        }
        
        
        WhosinServices.requestMyBucketList { container, error in
            guard let data = container?.data else {
                callback(nil, error)
                return
            }
        
            DISPATCH_ASYNC_BG { autoreleasepool {
                try! self.realm.write {
                    let results = self.realm.objects(MyBucketModel.self)
                    self.realm.delete(results)
                    self.realm.add(data, update: .all)
                }
                DISPATCH_ASYNC_MAIN {
                    self.realm.refresh()
                    let results = self.realm.objects(MyBucketModel.self)
                    if !results.isEmpty {
                        callback(results.first, error)
                        NotificationCenter.default.post(name: kMessageCountNotification, object: nil)
                    } else {
                        callback(nil, error)
                    }
                }
            }}
        }
    }
    
    func getEventChatList(callback: @escaping(_ model: Results<EventChatModel>?, _ error: NSError?) -> Void) {
    
        let object = realm.objects(EventChatModel.self)
        if object.count > 0 {
            callback(object, nil)
        }
        
        WhosinServices.getEventChatList { container, error in
        
            guard let data = container?.data else { return }
            guard let events = data.data else { return }
            if !events.isEmpty {
                DISPATCH_ASYNC_BG { autoreleasepool {
                    try! self.realm.write {
                        self.realm.add(events, update: .all)
                        if let users = data.users {
                            if !users.isEmpty {
                                self.realm.add(users, update: .all)
                            }
                        }
                    }
                    DISPATCH_ASYNC_MAIN {
                        self.realm.refresh()
                        let results = self.realm.objects(EventChatModel.self)
                        callback(results, error)
                    }
                }}
            }
        }
        
    }
    
    func getBucketListList(callback: @escaping(_ model: Results<BucketDetailModel>?, _ error: NSError?) -> Void) {
    
        let object = realm.objects(BucketDetailModel.self)
        if object.count > 0 {
            callback(object, nil)
        }
        
        WhosinServices.getBucketList { container, error in
            guard let data = container?.data else { return }
            if !data.buckets.isEmpty {
                DISPATCH_ASYNC_BG { autoreleasepool {
                    try! self.realm.write {
                        self.realm.add(data.buckets, update: .all)
                        if !data.users.isEmpty {
                            self.realm.add(data.users, update: .all)
                        }
                    }
                    DISPATCH_ASYNC_MAIN {
                        self.realm.refresh()
                        let results = self.realm.objects(BucketDetailModel.self)
                        callback(results, error)
                    }
                }}
            }else {
                callback(nil, error)
            }
            
        }
    }
        
    func getFriendChatList() -> [ChatModel] {
        return realm.objects(ChatModel.self).toArrayDetached(ofType: ChatModel.self)
    }
    
    func fetchFriendChatList(completion: @escaping ([ChatModel]?, [String]) -> Void) {
        var notFoundUser: [String] = []
        let userRepo = UserRepository()
        guard let ownUserId = Preferences.isSubAdmin ? APPSESSION.userDetail?.promoterId : APPSESSION.userDetail?.id else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let chatList = self.realm.objects(ChatModel.self)
                var tmpChatList: [ChatModel] = []
                for chat in chatList {
                    let detechedChat = chat.detached();
                    if let lastMsg = self.getLastMessages(chatId: chat.chatId) {
                        detechedChat.lastMsg = lastMsg.detached()
                    }
                    let friendId = detechedChat.members.first { $0 !=  ownUserId} ?? kEmptyString
                    if let userModel = userRepo.getUserById(userId: friendId), !userModel.fullName.isEmpty {
                        if detechedChat.lastMsg?.author != ownUserId, detechedChat.lastMsg?.authorName != userModel.fullName || detechedChat.lastMsg?.authorImage != userModel.image {
                            if !Utils.stringIsNullOrEmpty(friendId) {
                                notFoundUser.append(friendId)
                            }
                        } else {
                            detechedChat.user = userModel.detached()
                        }
                    } else {
                        if !Utils.stringIsNullOrEmpty(friendId) {
                            notFoundUser.append(friendId)
                        }
                    }
                    tmpChatList.append(detechedChat)
                }
            
                let sortedChats = tmpChatList.sorted { $0.lastMsg?.date ?? "0" > $1.lastMsg?.date ?? "0" }
                DispatchQueue.main.async {
                    completion(sortedChats, notFoundUser)
                }
            } catch {
                print("Error fetching chat messages: \(error)")
                DispatchQueue.main.async {
                    completion(nil, [])
                }
            }
        }
    }

    
    func getFriendChatList(callback: @escaping(_ model: Results<ChatModel>?, _ error: NSError?) -> Void) {
        let object = realm.objects(ChatModel.self)
        if object.count > 0 {
            callback(object, nil)
        }
    }
    
    func removeChatWithID(id: String, callback: @escaping(_ model: Bool?) -> Void) {
        let predicate = ChatModel.chatIdPredicate(id)
        let msgPredicate = MessageModel.chatIdPredicate(id)
        DISPATCH_ASYNC_BG { autoreleasepool {
            try! self.realm.write {
                if let object = self.realm.objects(ChatModel.self).filter(predicate).first {
                    self.realm.delete(object)
                }
                let result = self.realm.objects(MessageModel.self).filter(msgPredicate)
                if !result.isEmpty {
                    self.realm.delete(result)
                }
            }
            DISPATCH_ASYNC_MAIN {
                self.realm.refresh()
                let result = self.realm.objects(MessageModel.self).filter(msgPredicate)
                if !result.isEmpty {
                    callback(true)
                    print("result : ")
                }
                callback(true)
            }
        }}
    }
    
    func getChatModel(_ msgModel: MessageModel, callback: @escaping (_ model: ChatModel, _ chatType: ChatType) -> Void) {
        if msgModel.chatType == "friend" || msgModel.chatType == ChatType.promoterEvent.rawValue {
            let predicate = ChatModel.chatIdPredicate(msgModel.chatId)
            if let results = self.realm.objects(ChatModel.self).filter(predicate).first {
                callback(results.detached(),msgModel.chatType == ChatType.promoterEvent.rawValue ? .promoterEvent : .user)
            } else {
                let chatModel = ChatModel(msg: msgModel)
                callback(chatModel,msgModel.chatType == ChatType.promoterEvent.rawValue ? .promoterEvent : .user)
            }
        }
        else if msgModel.chatType == "bucket" {
            let bucketPredicate = BucketDetailModel.idPredicate(msgModel.chatId)
            if let object = self.realm.objects(BucketDetailModel.self).filter(bucketPredicate).first {
                let _tmpChatModel = ChatModel()
                _tmpChatModel.chatId = object.id
                _tmpChatModel.title = object.name
                _tmpChatModel.chatType = "bucket"
                _tmpChatModel.image = object.coverImage
                _tmpChatModel.members.append(objectsIn: object.sharedUser)
                _tmpChatModel.members.append(object.userId)
                if let userDetail = APPSESSION.userDetail {
                    if !_tmpChatModel.members.contains(where: { $0 == userDetail.id }) {
                        _tmpChatModel.members.append(userDetail.id)
                    }
                }
                callback(_tmpChatModel, .bucket)
            }
        }
        else if msgModel.chatType == "event" {
            let eventPredicate = EventChatModel.idPredicate(msgModel.chatId)
            if let object = self.realm.objects(EventModel.self).filter(eventPredicate).first {
                let _tmpChatModel = ChatModel()
                _tmpChatModel.chatId = object.id
                _tmpChatModel.chatType = "event"
                _tmpChatModel.title = object.chatName
                _tmpChatModel.image = object.image
                let members = object.invitedUsers.map({ $0.userId })
                _tmpChatModel.members.append(objectsIn: members)
                if let userDetail = APPSESSION.userDetail {
                    if !_tmpChatModel.members.contains(where: { Preferences.isSubAdmin ? $0 == userDetail.promoterId : $0 == userDetail.id }) {
                        _tmpChatModel.members.append(userDetail.id)
                    }
                }
                callback(_tmpChatModel, .event)
            }
        }
        else if msgModel.chatType == "outing" {
            let eventPredicate = EventChatModel.idPredicate(msgModel.chatId)
            if let object = self.realm.objects(OutingListModel.self).filter(eventPredicate).first {
                let _tmpChatModel = ChatModel()
                _tmpChatModel.chatId = object.id
                _tmpChatModel.title = object.chatName
                _tmpChatModel.chatType = "outing"
                _tmpChatModel.image = object.venue?.logo ?? kEmptyString
                _tmpChatModel.members.append(objectsIn: object.members)
                _tmpChatModel.members.append(object.userId)
                if let userDetail = APPSESSION.userDetail {
                    if !_tmpChatModel.members.contains(where: { $0 == userDetail.id }) {
                        _tmpChatModel.members.append(userDetail.id)
                    }
                }
                callback(_tmpChatModel, .outing)
            }
        }
    }
    
    func addMessageIfNotExist(messageData: MessageModel, callback: ((_ model: MessageModel?) -> Void)?) {
        let predicate = MessageModel.msgIdPredicate(messageData.id)
        
        let chatPredicate = ChatModel.chatIdPredicate(messageData.chatId)
        let chatResult = self.realm.objects(ChatModel.self).filter(chatPredicate).first
        
        DISPATCH_ASYNC_BG { autoreleasepool {
            try! self.realm.write {
                let results = self.realm.objects(MessageModel.self).filter(predicate).first
                if results == nil {
                    self.realm.add(messageData, update: .all)
                    if chatResult == nil {
                        if messageData.chatType == "friend" {
                            let chatModel = ChatModel(msg: messageData.detached())
                            self.realm.add(chatModel, update: .all)
                        }
                    }
                }
            }
            DISPATCH_ASYNC_MAIN {
                self.realm.refresh()
                let results = self.realm.objects(MessageModel.self).filter(predicate).first
                callback?(results?.detached())
                
            }
        }}
    }
    
    func addChatMessage(messageData: MessageModel, callback: @escaping (_ model: MessageModel?) -> Void) {
        let chatPredicate = ChatModel.chatIdPredicate(messageData.chatId)
        let results = self.realm.objects(ChatModel.self).filter(chatPredicate).first
        
        let predicate = MessageModel.msgIdPredicate(messageData.id)
        DISPATCH_ASYNC_BG { autoreleasepool {
            try! self.realm.write {
                self.realm.add(messageData, update: .all)
                if results == nil {
                    if messageData.chatType == "friend" {
                        let chatModel = ChatModel(msg: messageData.detached())
                        self.realm.add(chatModel, update: .all)
                    } else if messageData.chatType == "bucket" || messageData.chatType == "event" || messageData.chatType == "outing" {
                        guard let groupList = self.realm.objects(MyBucketModel.self).first else { return }
                        if messageData.chatType == "bucket", !(groupList.bucketList.contains(where: { $0.id == messageData.chatId })) {
                            self.getGroupChatLit { model, error in }
                        } else if messageData.chatType == "event", !(groupList.events.contains(where: { $0.id == messageData.chatId })) {
                            self.getGroupChatLit { model, error in }
                        } else if messageData.chatType == "outing", !(groupList.outings.contains(where: { $0.id == messageData.chatId })) {
                            self.getGroupChatLit { model, error in }
                        }
                    }
                }
            }
            DISPATCH_ASYNC_MAIN {
                self.realm.refresh()
                let results = self.realm.objects(MessageModel.self).filter(predicate).first
                callback(results?.detached())
            }
        }}
    }
    
    func updateReceivers(id: [String], receiver:String, callback: @escaping (_ model: Results<MessageModel>?, _ error: Error?) -> Void) {
        DISPATCH_ASYNC_BG { autoreleasepool {
            let predicate = MessageModel.msgIdPredicate(id)
            let results = self.realm.objects(MessageModel.self).filter(predicate)
            results.forEach { model in
                try! self.realm.write {
                    if !model.receivers.contains(receiver) {
                        model.receivers.append(receiver)
                    }
                }
            }
            DISPATCH_ASYNC_MAIN {
                self.realm.refresh()
                let results = self.realm.objects(MessageModel.self).filter(predicate)
                callback(results, nil)
            }
        }}
    }
    
    func updateSeenBy(id: [String], seenBy:String, callback: @escaping (_ model: Results<MessageModel>?, _ error: Error?) -> Void) {
        DISPATCH_ASYNC_BG { autoreleasepool {
            let predicate = MessageModel.msgIdPredicate(id)
            let results = self.realm.objects(MessageModel.self).filter(predicate)
            results.forEach { model in
                try! self.realm.write {
                    if !model.seenBy.contains(seenBy) {
                        model.seenBy.append(seenBy)
                    }
                }
            }
            DISPATCH_ASYNC_MAIN {
                self.realm.refresh()
                let results = self.realm.objects(MessageModel.self).filter(predicate)
                callback(results, nil)
            }
        }}
    }
    
    func getPendingMsgs() -> [MessageModel] {
        guard let userDetail = APPSESSION.userDetail else {  return [] }
        let predicate = MessageModel.pendingMsgPredicate(Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id)
        let results = self.realm.objects(MessageModel.self).filter(predicate)
        return results.toArrayDetached(ofType: MessageModel.self)
    }
    
    func getChatMessages(chatId: String, page: Int, limit: Int, callback: @escaping(_ model: [MessageModel]?, _ notSeenMsgs:[MessageModel]?) -> Void) {
        
        let predicate = MessageModel.chatIdPredicate(chatId)
        let startIndex = page //* limit
        var endIndex = startIndex + limit
        DispatchQueue.global(qos: .background).async {
            do {
                let results = self.realm.objects(MessageModel.self).filter(predicate).sorted(byKeyPath: "date", ascending: false)
                var detechedArray = results.toArrayDetached(ofType: MessageModel.self)
                
                guard startIndex < results.count, startIndex != results.count  else {
                    DispatchQueue.main.async {
                        callback([], [])
                    }
                    return
                }
                
                if detechedArray.count < endIndex {
                    endIndex = detechedArray.count
                }
                let slicedArray = detechedArray[startIndex..<endIndex]
                let array = Array(slicedArray)
                detechedArray = array
                DispatchQueue.main.async {
                    callback(detechedArray, [])  // Pass messages array to the callback
                }
            }
        }
    }
    
    func getChatMessages(chatId: String, callback: @escaping(_ model: [MessageModel]?) -> Void) {
        let predicate = MessageModel.chatIdPredicate(chatId)
        DispatchQueue.global(qos: .background).async {
            do {
                let results = self.realm.objects(MessageModel.self).filter(predicate).sorted(byKeyPath: "date", ascending: false)
                let detechedArray = results.toArrayDetached(ofType: MessageModel.self)
                DispatchQueue.main.async {
                    callback(detechedArray)  // Pass messages array to the callback
                }
            }
        }
    }
    
    func getLastMessages(chatId: String) -> MessageModel? {
        let predicate = MessageModel.chatIdPredicate(chatId)
        let results = self.realm.objects(MessageModel.self).filter(predicate).sorted(byKeyPath: "date", ascending: false).first
        return results
    }
    
    func getLastMessagesForChats(chatIds: [String]) -> [MessageModel] {
        let lastMessages = realm.objects(MessageModel.self)
            .filter("chatId IN %@", chatIds)
            .sorted(byKeyPath: "date")
            .distinct(by: ["chatId"])
        
        return Array(lastMessages)
    }

    
    func getLastReceivedMsg() -> MessageModel? {
        let results = self.realm.objects(MessageModel.self).sorted(byKeyPath: "date", ascending: false).first
        return results
    }
    
    func getUnReadMessagesCount(chatId: String) -> Int {
        let predicate = MessageModel.unReadPredicate(chatId)
        let results = self.realm.objects(MessageModel.self).filter(predicate).sorted(byKeyPath: "date", ascending: false)
        return results.count
    }
    
    func getUnReadMessagesCount(chatId: String, callback: @escaping(_ model: Int) -> Void) {
        let predicate = MessageModel.unReadPredicate(chatId)
        DISPATCH_ASYNC_BG {
            let results = self.realm.objects(MessageModel.self).filter(predicate).sorted(byKeyPath: "date", ascending: false)
            let count = results.count
            DISPATCH_ASYNC_MAIN {
                callback(count)
            }
        }
    }
    
    func getNewMessage(model: MessageModel, callback: @escaping(_ model: [MessageModel]?) -> Void) {
        let predicate = MessageModel.unReadPredicate(model.chatId)
        DISPATCH_ASYNC_BG {
            let results = self.realm.objects(MessageModel.self).filter(predicate).sorted(byKeyPath: "date", ascending: false)
            let array = results.toArrayDetached(ofType: MessageModel.self)
            DISPATCH_ASYNC_MAIN {
                callback(array)
            }
        }
    }
    
    func updateNewMessage(msgIds: [String], callback: @escaping(_ model: [MessageModel]?) -> Void) {
        let predicate = MessageModel.msgIdPredicate(msgIds)
        DISPATCH_ASYNC_BG {
            let results = self.realm.objects(MessageModel.self).filter(predicate).sorted(byKeyPath: "date", ascending: false)
            let array = results.toArrayDetached(ofType: MessageModel.self)
            DISPATCH_ASYNC_MAIN {
                callback(array)
            }
        }
    }
    
    func getUnReadMessagesTypeCount(type: String, callback: @escaping(_ counts: Int) -> Void) {
        let predicate = MessageModel.unReadTypePredicate(type)
        DISPATCH_ASYNC_BG {
            let results = self.realm.objects(MessageModel.self).filter(predicate).sorted(byKeyPath: "date", ascending: false)
            let count = results.count
            DISPATCH_ASYNC_MAIN {
                callback(count)
            }
        }
    }
    
    func getUnReadMessagesTypeCount(type: String) -> Int {
        let predicate = MessageModel.unReadTypePredicate(type)
        let results = self.realm.objects(MessageModel.self).filter(predicate).sorted(byKeyPath: "date", ascending: false)
        return results.count
    }
    
    func getUnReadMessagesCountByType(type: String) -> Int {
        guard let ownUserId = Preferences.isSubAdmin ? APPSESSION.userDetail?.promoterId : APPSESSION.userDetail?.id else { return 0 }

        if type == "friend" {
            let userRepo = UserRepository()
            let chatIds = getFriendChatList().compactMap { chat -> String? in
                let userId = chat.members.first { $0 != ownUserId } ?? kEmptyString
                guard !userId.isEmpty else {
                    print("Warning: empty userId in friend chat members")
                    return nil
                }
                if let user = try? userRepo.getUserById(userId: userId){
                    return userId
                } else {
                    print("Warning: failed to get user or user is nil: \(userId)")
                    return nil
                }

            }
            let predicate = MessageModel.unReadPredicateNotInIds(chatIds, type)
            return realm.objects(MessageModel.self).filter(predicate).count

        } else if type == "promoter_event" {
            let predicateEvent = ChatModel.chatTypePredicate("promoter_event")
            let promoterChat = realm.objects(MessageModel.self).filter(predicateEvent).toArrayDetached(ofType: MessageModel.self)
            let chatIds = promoterChat.map { $0.chatId }
            guard !chatIds.isEmpty else { return 0 }
            let predicate = MessageModel.unReadPredicateIds(chatIds)
            return realm.objects(MessageModel.self).filter(predicate).count

        } else {
            guard let groupList = realm.objects(MyBucketModel.self).first else {
                print("Warning: No MyBucketModel found in Realm")
                return 0
            }
            let chatIds: [String] = {
                switch type {
                case "bucket":
                    return groupList.bucketList.toArrayDetached(ofType: BucketDetailModel.self).map { $0.id }
                case "event":
                    return groupList.events.toArrayDetached(ofType: EventModel.self).map { $0.id }
                case "outing":
                    return groupList.outings.toArrayDetached(ofType: OutingListModel.self).map { $0.id }
                default:
                    print("Warning: Unknown type '\(type)' passed to getUnReadMessagesCountByType")
                    return []
                }
            }()
            guard !chatIds.isEmpty else { return 0 }
            let predicate = MessageModel.unReadPredicateIds(chatIds)
            return realm.objects(MessageModel.self).filter(predicate).count
        }
    }

    
    // To count all unread messages without any Type.
    func getAllUnReadMessagesCountRegardlessOfType() -> Int {
        let results = self.realm.objects(MessageModel.self).filter(MessageModel.unAllReadPredicate())
        return results.count
    }
    
    func getAllUnReadMessagesCountForGroup(callback: @escaping(_ counts: Int) -> Void) {
        if !APPSESSION.didLogin {
            callback(0)
            return
        }
        DISPATCH_ASYNC_BG {
            let buckets = self.getUnReadMessagesCountByType(type: "bucket")
            let events = self.getUnReadMessagesCountByType(type: "event")
            let outings = self.getUnReadMessagesCountByType(type: "outing")
            DISPATCH_ASYNC_MAIN {
                callback(buckets + events + outings)
            }
        }
    }
    
    func getCMUnReadMessagesCount(callback: @escaping(_ counts: Int) -> Void) {
        if !APPSESSION.didLogin {
            callback(0)
            return
        }
        DISPATCH_ASYNC_BG {
            let promoterEvent = self.getUnReadMessagesCountByType(type: "promoter_event")
            DISPATCH_ASYNC_MAIN {
                callback(promoterEvent)
            }
        }
    }
    
    func getAllUnReadMessagesCount(callback: @escaping (_ counts: Int) -> Void) {
        guard APPSESSION.didLogin else {
            callback(0)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool {
                var totalCount = 0

                do {
                    let repo = ChatRepository()

                    if Preferences.isSubAdmin {
                        let friendCount = repo.getUnReadMessagesCountByType(type: "friend")
                        let promoterCount = repo.getUnReadMessagesCountByType(type: "promoter_event")
                        totalCount = friendCount + promoterCount
                    } else {
                        let friends = repo.getUnReadMessagesCountByType(type: "friend")
                        let buckets = repo.getUnReadMessagesCountByType(type: "bucket")
                        let events = repo.getUnReadMessagesCountByType(type: "event")
                        let outings = repo.getUnReadMessagesCountByType(type: "outing")
                        let promoterEvent = repo.getUnReadMessagesCountByType(type: "promoter_event")

                        totalCount = friends + buckets + events + outings + promoterEvent
                    }
                } catch {
                    print("⚠️ Failed to fetch unread message counts: \(error.localizedDescription)")
                    totalCount = 0
                }
                DispatchQueue.main.async {
                    callback(totalCount)
                }
            }
        }
    }


    
    func getMediaMessages(chatId: String) -> [MessageModel] {
        let predicate = MessageModel.mediaPredicate(chatId, type: "image")
        let results = self.realm.objects(MessageModel.self).filter(predicate)
        return results.toArrayDetached(ofType: MessageModel.self)
    }

    func getMediaMessagesCount(chatId: String) -> Int {
        let predicate = MessageModel.mediaPredicate(chatId, type: "image")
        let results = self.realm.objects(MessageModel.self).filter(predicate)
        return results.count
    }

    func unReceivedMsgs(callback: @escaping(_ model: Results<MessageModel>?, _ error: NSError?) -> Void) {
        var lastDate = Preferences.lastMsgSynced
        if Utils.stringIsNullOrEmpty(lastDate) {
            lastDate = "\(Utils.getDateBefore(months: 1)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970)"
        }
        if !lastDate.isEmpty {
            if let date = Double(lastDate) {
                lastDate = date.getDateStringFromGMT()
            }
        }
        
        WhosinServices.unreceivedMessages(lastDate){ container, error in
            guard let data = container?.data else {
                callback(nil, error)
                return
            }
            Preferences.lastMsgSynced = "\(Date().timeIntervalSince1970)"
            
            
            if !data.isEmpty {
                let ids = data.map{$0.id}
                let predicate = MessageModel.msgIdPredicate(ids)
                DISPATCH_ASYNC_BG { autoreleasepool {
                    try! self.realm.write {
                        self.realm.add(data, update: .all)
                        
                        data.forEach { msg in
                            let chatPredicate = ChatModel.chatIdPredicate(msg.chatId)
                            let results = self.realm.objects(ChatModel.self).filter(chatPredicate).first
                            if results == nil {
                                if msg.chatType == "friend" {
                                    let chatModel = ChatModel(msg: msg.detached())
                                    self.realm.add(chatModel, update: .all)
                                }
                            }
                        }
                    }
                    DISPATCH_ASYNC_MAIN {
                        self.realm.refresh()
                        let results = self.realm.objects(MessageModel.self).filter(predicate).sorted(byKeyPath: "date", ascending: false)
                        callback(results, error)
                    }
                }}
            }
        }
    }
    
}
