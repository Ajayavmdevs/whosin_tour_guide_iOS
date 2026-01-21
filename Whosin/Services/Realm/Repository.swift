import RealmSwift
import UIKit

let REALMSCHEMAVERSION = 362

class Repository: NSObject {

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    private class var _path: URL? {
        Utils.getLocalDirectory("realm")?.appendingPathComponent("whosin_db", isDirectory: false).appendingPathExtension("realm")
    }
    
    func resetRealm () {
        DISPATCH_ASYNC_BG { autoreleasepool {
            try! self.realm.write {
                self.realm.deleteAll()
            }
            DISPATCH_ASYNC_MAIN {
                self.realm.refresh()
            }
        }}
    }

    class func configRealm() {
        let path: URL? = Repository._path
        Log.debug(String(format: "Realm path=%@", (path?.absoluteString)!))
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            // Realm directory
            fileURL: Repository._path,
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: UInt64(REALMSCHEMAVERSION),
            // Now that we've told Realm how to handle the schema change, opening the file
            // will automatically perform the migration
            migrationBlock: { _, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < UInt64(REALMSCHEMAVERSION) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            },
            deleteRealmIfMigrationNeeded: false)
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override required init() {}

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    var realm: Realm {
         let realm = try! Realm(fileURL: Repository._path!)
        realm.autorefresh = true
        return realm
    }
}


