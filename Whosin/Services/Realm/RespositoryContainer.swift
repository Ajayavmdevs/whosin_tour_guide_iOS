import UIKit

let CONTAINER = RespositoryContainer.shared

class RespositoryContainer: NSObject {

    private var _persistenceDict: [String: Repository]

    // --------------------------------------
    // MARK: Singleton
    // --------------------------------------

    class var shared: RespositoryContainer {
        struct Static {
            static let instance = RespositoryContainer()
        }
        return Static.instance
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    private override init() {
        _persistenceDict = [:]
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func setRepository(_ clazz: AnyClass, repository: Repository?) {
        let key = NSStringFromClass(clazz.self)
        let currentRepository: Repository? = _persistenceDict[key]
        if currentRepository != nil {
            Log.debug(String(format: "Request duplicate instance of repository for %@", key))
        }
        _persistenceDict[key] = repository
    }

    func getRepository(_ clazz: AnyClass) -> Repository {
        let key = NSStringFromClass(clazz.self)
        var repository: Repository? = _persistenceDict[key]
        if repository == nil {
            let repositoryClass = clazz as! Repository.Type
            repository = repositoryClass.init()
            CONTAINER.setRepository(clazz, repository: repository)
        }
        return repository!
    }

    func clear() {
        for repository in _persistenceDict.values {
            DISPATCH_ASYNC_BG { autoreleasepool {
                do {
                    try repository.realm.write {
                        repository.realm.deleteAll()
                        repository.realm.refresh()
                    }
                } catch {
                    Log.debug("error=\(error.localizedDescription)")
                }
            } }
        }
    }
}
