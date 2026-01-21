import Foundation
import ObjectMapper
import RealmSwift

struct StringArrayTransform: TransformType {
    
    typealias Object = List<String>
    typealias JSON = [String]

    init() {}

    func transformFromJSON(_ value: Any?) -> List<String>? {
        guard let value = value, let objects = value as? [String] else {
            return nil
        }
        let list = List<String>()
        list.append(objectsIn: objects)
        return list
    }

    func transformToJSON(_ value: Object?) -> JSON? {
        Array(value ?? List<String>())
    }
}

struct DoubleArrayTransform: TransformType {
    
    typealias Object = List<Double>
    typealias JSON = [Double]

    init() {}

    func transformFromJSON(_ value: Any?) -> List<Double>? {
        guard let value = value, let objects = value as? [Double] else {
            return nil
        }
        let list = List<Double>()
        list.append(objectsIn: objects)
        return list
    }

    func transformToJSON(_ value: Object?) -> JSON? {
        Array(value ?? List<Double>())
    }
}
