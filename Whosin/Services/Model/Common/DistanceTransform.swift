import Foundation
import ObjectMapper

class DistanceTransform: TransformType {
    
    public typealias Object = Double
    public typealias JSON = String
        
    init() { }
    
    func transformFromJSON(_ value: Any?) -> Double? {
        if let stringValue = value as? String {
            let distance = stringValue.components(separatedBy: " ").first ?? kEmptyString
            return Double(distance)
        }
        return value as? Double
    }
    
    func transformToJSON(_ value: Double?) -> String? {
        if let stringValue = value {
            return "\(stringValue)"
        }
        return nil
    }
}
