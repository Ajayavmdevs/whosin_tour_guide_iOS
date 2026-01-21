import RealmSwift
import ObjectMapper

class CartRepository: Repository {
    
    func  addToCartItem(model: CartModel, callback: @escaping(_ updated: Bool) -> Void) {
        let predicate = CartModel.idPredicate(model.id)
        DISPATCH_ASYNC_BG { autoreleasepool {
            let results = self.realm.objects(CartModel.self).filter(predicate)
            try! self.realm.write {
                self.realm.delete(results)
                if model.quantity > 0 {
                    self.realm.add(model, update: .modified)
                }
            }
            DISPATCH_ASYNC_MAIN {
                self.realm.refresh()
                callback(true)
            }
        }}
    }
    
    func  addToCartItems(model: [CartModel], callback: @escaping(_ updated: Bool) -> Void) {
        let ids = model.map { $0.id }
        let predicate = CartModel.idsPredicate(ids)
        DISPATCH_ASYNC_BG { autoreleasepool {
            let results = self.realm.objects(CartModel.self).filter(predicate)
            try! self.realm.write {
                self.realm.delete(results)
                model.forEach { m in
                    if m.quantity > 0 {
                        self.realm.add(m, update: .modified)
                    }
                }
                
            }
            DISPATCH_ASYNC_MAIN {
                self.realm.refresh()
                callback(true)
            }
        }}
    }
    
    
    func removeFromCart(model: CartModel) {
        let predicate = CartModel.idPredicate(model.id)
        DISPATCH_ASYNC_BG { autoreleasepool {
            let results = self.realm.objects(CartModel.self).filter(predicate)
            try! self.realm.write {
                self.realm.delete(results)
            }
            DISPATCH_ASYNC_MAIN {
                NotificationCenter.default.post(name: Notification.Name("addtoCartCount"), object: nil, userInfo: nil)
                self.realm.refresh()
            }
        }}
    }
    
    func getCountById(id: String) -> [CartModel] {
        let predicate = CartModel.idPredicate(id)
        let object = realm.objects(CartModel.self).filter(predicate)
        return object.toArrayDetached(ofType: CartModel.self)
    }
    
    func getList() -> [CartModel] {
        let object = realm.objects(CartModel.self)
        return object.toArrayDetached(ofType: CartModel.self)
    }
    
    func getCartListCount() -> Int {
        let object = realm.objects(CartModel.self)
        return object.count
    }

    func clearCart(callback: @escaping(_ updated: Bool) -> Void) {
        DISPATCH_ASYNC_BG { autoreleasepool {
            let results = self.realm.objects(CartModel.self)
            try! self.realm.write {
                self.realm.delete(results)
            }
            DISPATCH_ASYNC_MAIN {
                self.realm.refresh()
                NotificationCenter.default.post(name: Notification.Name("addtoCartCount"), object: nil, userInfo: nil)
                callback(true)
            }
        }}
    }
}
