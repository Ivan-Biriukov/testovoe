import Foundation
import RealmSwift

protocol Datable: AnyObject {
    func addObject<T: Object>(_ object: T) throws
    func addObjects<T: Object>(_ objects: [T]) throws
    func readBy<T: Object, K>(_ objectType: T.Type, id key: K) throws -> T?
    func deleteBy<T: Object, K>(_ objectType: T.Type, key primaryKey: K) throws
    func updateObject<T: Object>(_ object: T) throws
    func fetchAll<T: Object>(_ objectType: T.Type) throws -> [T]
    func deleteAll<T: Object>(_ objectType: T.Type) throws
    func deleteAllData() throws
}

final class DatabaseService {
    
    private var realm: Realm?
    
    init() {
        openRealm()
    }
    
    private func openRealm() {
        do {
            let config = Realm.Configuration(
                schemaVersion: 1,
                migrationBlock: { _, oldSchemaVersion in
                    if oldSchemaVersion < 1 { }
                }
            )
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
        } catch {
            print("Error opening Realm: \(error)")
        }
    }
}

extension DatabaseService: Datable {
    
    func addObject<T: Object>(_ object: T) throws {
        guard let realm = realm else { return }
        try realm.write {
            realm.add(object, update: .all)
        }
    }
    
    func addObjects<T: Object>(_ objects: [T]) throws {
        guard let realm = realm else { return }
        try realm.write {
            realm.add(objects, update: .all)
        }
    }
    
    func readBy<T: Object, K>(_ objectType: T.Type, id key: K) throws -> T? {
        guard let realm = realm else { return nil }
        return realm.object(ofType: objectType, forPrimaryKey: key)
    }
    
    func deleteBy<T: Object, K>(_ objectType: T.Type, key primaryKey: K) throws {
        guard let realm = realm else { return }
        try realm.write {
            if let object = realm.object(ofType: objectType, forPrimaryKey: primaryKey) {
                realm.delete(object)
            }
        }
    }
    
    func updateObject<T: Object>(_ object: T) throws {
        guard let realm = realm else { return }
        try realm.write {
            realm.add(object, update: .modified)
        }
    }
    
    func fetchAll<T: Object>(_ objectType: T.Type) throws -> [T] {
        guard let realm = realm else { return [] }
        return Array(realm.objects(objectType))
    }
    
    func deleteAll<T: Object>(_ objectType: T.Type) throws {
        guard let realm = realm else { return }
        try realm.write {
            realm.delete(realm.objects(objectType))
        }
    }
    
    func deleteAllData() throws {
        guard let realm = realm else { return }
        try realm.write {
            realm.deleteAll()
        }
    }
}
