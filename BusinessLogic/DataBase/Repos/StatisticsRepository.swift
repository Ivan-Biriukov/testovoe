import Foundation
import RxSwift

protocol StatisticsRepositoryProtocol {
    func getStatistics() -> Observable<[StatisticsItem]>
    func saveStatistics(_ items: [StatisticsItem]) -> Observable<Void>
    func hasCache() -> Bool
}

// MARK: - StatisticsRepository
final class StatisticsRepository: StatisticsRepositoryProtocol {
    private let database: Datable
    
    init(database: Datable = DatabaseService()) {
        self.database = database
    }
}

// MARK: - Public Interface
extension StatisticsRepository {
    func getStatistics() -> Observable<[StatisticsItem]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            do {
                let objects = try self.database.fetchAll(StatisticsObject.self)
                let items = objects.map { $0.toDomain() }
                observer.onNext(items)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
        .subscribe(on: MainScheduler.instance)
    }
    
    func saveStatistics(_ items: [StatisticsItem]) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            do {
                try self.database.deleteAll(StatisticsObject.self)
                let objects = items.map { StatisticsObject($0) }
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
            let objects = try database.fetchAll(StatisticsObject.self)
            return !objects.isEmpty
        } catch {
            return false
        }
    }
}
