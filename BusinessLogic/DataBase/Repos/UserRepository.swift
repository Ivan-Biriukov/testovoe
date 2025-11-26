import Foundation
import RxSwift

protocol UserRepositoryProtocol {
    func getUsers() -> Observable<[User]>
    func saveUsers(_ users: [User]) -> Observable<Void>
    func hasCache() -> Bool
}

// MARK: - UserRepository
final class UserRepository: UserRepositoryProtocol {
    private let database: Datable
        
    init(database: Datable = DatabaseService()) {
        self.database = database
    }
}

// MARK: - Public Interface
extension UserRepository {
    func getUsers() -> Observable<[User]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            do {
                let objects = try self.database.fetchAll(UserObject.self)
                let users = objects.map { $0.toDomain() }
                observer.onNext(users)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
        .subscribe(on: MainScheduler.instance)
    }
    
    func saveUsers(_ users: [User]) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            do {
                try self.database.deleteAll(UserObject.self)
                let objects = users.map { UserObject($0) }
                try self.database.addObjects(objects)
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
        .subscribe(on: MainScheduler.instance)
    }
    
    func hasCache() -> Bool {
        do {
            let objects = try database.fetchAll(UserObject.self)
            return !objects.isEmpty
        } catch {
            return false
        }
    }
}
