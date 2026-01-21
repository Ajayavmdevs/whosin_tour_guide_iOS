import ObjectMapper

@objc protocol ModelProtocol {
    @objc optional var searchCriteria: String { get }
    @objc optional var statusMessage: String? { get }
    @objc func isValid() -> Bool
}
