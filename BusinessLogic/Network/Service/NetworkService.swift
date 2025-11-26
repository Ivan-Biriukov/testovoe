import Foundation
import RxSwift

protocol NetworkServiceProtocol {
    func fetchUsers() -> Observable<[User]>
    func fetchStatistics() -> Observable<[StatisticsItem]>
}

final class NetworkService: NetworkServiceProtocol {
    // MARK: - Properties
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Init
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    // MARK: - Public Methods
    func fetchUsers() -> Observable<[User]> {
        return fetch(endpoint: .users, responseType: UsersResponse.self)
            .map { $0.users }
    }
    
    func fetchStatistics() -> Observable<[StatisticsItem]> {
        return fetch(endpoint: .statistics, responseType: StatisticsResponse.self)
            .map { $0.statistics }
    }
}

// MARK: - Private Networking
private extension NetworkService {
    
    func fetch<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) -> Observable<T> {
        
        let session = self.session
        let decoder = self.decoder
        let url = endpoint.url
        
        return Observable.create { observer in
            
            let task = session.dataTask(with: url) { data, response, error in
                
                if let error = error {
                    observer.onError(NetworkError.networkError(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(NetworkError.noData)
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    observer.onError(NetworkError.serverError(httpResponse.statusCode))
                    return
                }
                
                guard let data = data else {
                    observer.onError(NetworkError.noData)
                    return
                }
                
                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    observer.onNext(decoded)
                    observer.onCompleted()
                } catch {
                    observer.onError(NetworkError.decodingError(error))
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
