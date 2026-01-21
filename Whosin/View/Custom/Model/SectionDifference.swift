import DifferenceKit

enum SectionDifferenceModel: Equatable {
    case section(Int)

    func get() -> Int {
        switch self {
            case let .section(num):
                return num
        }
    }
}

extension SectionDifferenceModel: Differentiable {
    var differenceIdentifier: Int {
        return get()
    }
}

func == (lhs: SectionDifferenceModel, rhs: SectionDifferenceModel) -> Bool {
    switch (lhs, rhs) {
        case let (.section(code1), .section(code2)):
            return code1 == code2
    }
}

extension Dictionary: Differentiable where Key == String, Value == Any {
    public func isContentEqual(to source: [Key: Value]) -> Bool {
        let leftContentValue = self[kCellDifferenceContentKey] as? AnyHashable ?? AnyHashable(0xFBA1_2C4D)
        let rightContentValue = source[kCellDifferenceContentKey] as? AnyHashable ?? AnyHashable(0xFBA1_2C4D)
        return leftContentValue == rightContentValue
    }

    public var differenceIdentifier: String {
        let identifier = self[kCellDifferenceIdentifierKey] as? String ?? kEmptyString
        return identifier
    }
}
