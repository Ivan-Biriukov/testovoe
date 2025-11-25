import Foundation
import RxSwift

public protocol UserServiceProtocol {
    func loadUsers(forceRefresh: Bool) -> Observable<[User]>
    func getUser(by id: Int) -> Observable<User?>
}

public final class UserService: UserServiceProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let repository: UserRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        repository: UserRepositoryProtocol = UserRepository()
    ) {
        self.networkService = networkService
        self.repository = repository
    }
    
    public func loadUsers(forceRefresh: Bool) -> Observable<[User]> {
        if !forceRefresh && repository.hasCache() {
            return repository.getUsers()
        }
        
        return networkService.fetchUsers()
            .flatMap { [weak self] users -> Observable<[User]> in
                guard let self = self else {
                    return Observable.just(users)
                }
                return self.repository.saveUsers(users)
                    .map { users }
            }
    }
    
    public func getUser(by id: Int) -> Observable<User?> {
        return loadUsers(forceRefresh: false)
            .map { users in
                users.first(where: { $0.id == id })
            }
    }
}
