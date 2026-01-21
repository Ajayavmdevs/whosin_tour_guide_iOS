import RealmSwift

class UserRepository: Repository {
    
    func saveUsers(users: [UserDetailModel], callback: @escaping(_ model: Results<UserDetailModel>?) -> Void) {
        DISPATCH_ASYNC_BG { autoreleasepool {
            try! self.realm.write {
                self.realm.add(users, update: .modified)
            }
            DISPATCH_ASYNC_MAIN {
                self.realm.refresh()
                callback(nil)
            }
        }}
    }
    
    func getUserById(userId: String) -> UserDetailModel? {
        let predicate = UserDetailModel.idPredicate(userId)
        let results = self.realm.objects(UserDetailModel.self).filter(predicate).first
        return results
    }
    
    func getUsers() -> [UserDetailModel]? {
        let results = self.realm.objects(UserDetailModel.self)
        return results.toArrayDetached(ofType: UserDetailModel.self)
    }
    
    func fatchUsers(_ userIds:[String], callback: @escaping(_ model: Results<UserDetailModel>?) -> Void) {
        WhosinServices.getUserByIds(userIds: userIds) { container , error in
            guard let data = container?.data else {
                return
            }
            if !data.isEmpty {
                DISPATCH_ASYNC_BG { autoreleasepool {
                    try! self.realm.write {
                        self.realm.add(data, update: .all)
                    }
                    DISPATCH_ASYNC_MAIN {
                        self.realm.refresh()
                        callback(nil)
                    }
                }}
            }
            else {
                callback(nil)
            }
        }
        
    }
    
}

