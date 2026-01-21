import ObjectMapper
import RealmSwift

class ListTransform<T: RealmSwift.Object>: TransformType where T: Mappable {
    typealias Object = List<T>
    typealias JSON = [AnyObject]

    let mapper = Mapper<T>()

    init() {}

    func transformFromJSON(_ value: Any?) -> Object? {
        let results = List<T>()
        if let value = value as? [AnyObject] {
            for json in value {
                if let obj = mapper.map(JSONObject: json) {
                    results.append(obj)
                }
            }
        }
        return results
    }

    func transformToJSON(_ value: Object?) -> JSON? {
        var results = [AnyObject]()
        if let value = value {
            for obj in value {
                let json = mapper.toJSON(obj)
                results.append(json as AnyObject)
            }
        }
        return results
    }
}


class StringListTransform: TransformType {
    typealias Object = List<String>
    typealias JSON = [String]

    func transformFromJSON(_ value: Any?) -> List<String>? {
        if let jsonArray = value as? [String] {
            let list = List<String>()
            list.append(objectsIn: jsonArray)
            return list
        }
        return nil
    }

    func transformToJSON(_ value: List<String>?) -> [String]? {
        if let list = value {
            return Array(list)
        }
        return nil
    }
}

class IntStringTransform: TransformType {
    typealias Object = Int
    typealias JSON = Any

    func transformFromJSON(_ value: Any?) -> Int? {
        if let intVal = value as? Int {
            return intVal
        } else if let strVal = value as? String {
            return Int(strVal)
        }
        return nil
    }

    func transformToJSON(_ value: Int?) -> Any? {
        return value
    }
}

class StringTransform: TransformType {
    typealias Object = String
    typealias JSON = Any

    func transformFromJSON(_ value: Any?) -> String? {
        if let str = value as? String {
            return str
        } else if let intVal = value as? Int {
            return String(intVal)
        } else if let doubleVal = value as? Double {
            return String(doubleVal)
        } else if let boolVal = value as? Bool {
            return String(boolVal)
        }
        return nil
    }

    func transformToJSON(_ value: String?) -> Any? {
        return value
    }
}

class UserDetailListTransform: TransformType {
    func transformFromJSON(_ value: Any?) -> List<UserDetailModel>? {
        let result = List<UserDetailModel>()
        if let array = value as? [[String: Any]] {
            for item in array {
                if let model = Mapper<UserDetailModel>().map(JSON: item) {
                    result.append(model)
                }
            }
        }
        return result
    }

    func transformToJSON(_ value: List<UserDetailModel>?) -> Any? {
        return value?.map { $0.toJSON() }
    }
}

