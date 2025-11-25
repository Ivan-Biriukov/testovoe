import Foundation
import RxSwift

protocol NetworkServiceProtocol {
    func fetchUsers() -> Observable<[User]>
    func fetchStatistics() -> Observable<[StatisticsItem]>
}

final class NetworkService: NetworkServiceProtocol {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    func fetchUsers() -> Observable<[User]> {
        return fetch(endpoint: .users, responseType: UsersResponse.self)
            .map { $0.users }
    }
    
    func fetchStatistics() -> Observable<[StatisticsItem]> {
        return fetch(endpoint: .statistics, responseType: StatisticsResponse.self)
            .map { $0.statistics }
    }
    
    private func fetch<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) -> Observable<T> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            let task = self.session.dataTask(with: endpoint.url) { data, response, error in
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
                    let decoded = try self.decoder.decode(T.self, from: data)
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
