import RealmSwift

protocol DetachableObject: AnyObject {
    func detached() -> Self
}

extension Object: DetachableObject {
    
    func detached() -> Self {
        let detached = type(of: self).init()
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else {
                continue
            }
            if let detachable = value as? DetachableObject {
                detached.setValue(detachable.detached(), forKey: property.name)
            } else { // Then it is a primitive
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
}

extension List {
    
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        self.forEach { model in
            if let result = model as? T {
                array.append(result)
            }
        }
        return array
    }
    
    func toArrayDetached<T: DetachableObject>(ofType: T.Type) -> [T] {
        var array = [T]()
        self.forEach { model in
            if let result = model as? T {
                array.append(result.detached())
            }
        }
        return array
    }
}

extension Results {
    
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        return array
    }
    
    func toArrayDetached<T: DetachableObject>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result.detached())
            }
        }
        return array
    }
}
