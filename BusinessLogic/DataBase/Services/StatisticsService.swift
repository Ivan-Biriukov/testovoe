import Foundation
import RxSwift

public protocol StatisticsServiceProtocol {
    func loadStatistics(forceRefresh: Bool) -> Observable<[StatisticsItem]>
    func loadAggregatedStatistics(forceRefresh: Bool) -> Observable<[UserStatistics]>
}

public final class StatisticsService: StatisticsServiceProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let repository: StatisticsRepositoryProtocol
    private let userService: UserServiceProtocol
    
    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        repository: StatisticsRepositoryProtocol = StatisticsRepository(),
        userService: UserServiceProtocol = UserService()
    ) {
        self.networkService = networkService
        self.repository = repository
        self.userService = userService
    }
    
    public func loadStatistics(forceRefresh: Bool) -> Observable<[StatisticsItem]> {
        if !forceRefresh && repository.hasCache() {
            return repository.getStatistics()
        }
        
        return networkService.fetchStatistics()
            .flatMap { [weak self] items -> Observable<[StatisticsItem]> in
                guard let self = self else {
                    return Observable.just(items)
                }
                return self.repository.saveStatistics(items)
                    .map { items }
            }
    }
    
    public func loadAggregatedStatistics(forceRefresh: Bool) -> Observable<[UserStatistics]> {
        return Observable.zip(
            loadStatistics(forceRefresh: forceRefresh),
            userService.loadUsers(forceRefresh: forceRefresh)
        )
        .map { [weak self] statistics, users in
            self?.aggregateStatistics(statistics, users: users) ?? []
        }
    }
    
    private func aggregateStatistics(
        _ items: [StatisticsItem],
        users: [User]
    ) -> [UserStatistics] {
        let grouped = Dictionary(grouping: items, by: { $0.userId })
        
        return grouped.map { userId, userItems in
            let user = users.first(where: { $0.id == userId })
            
            var viewsCount = 0
            var subscriptionsCount = 0
            var unsubscriptionsCount = 0
            var viewDates: [Date] = []
            
            for item in userItems {
                switch item.type {
                case .view:
                    viewsCount += item.dates.count
                    viewDates.append(contentsOf: item.dates.compactMap {
                        self.parseDate($0)
                    })
                case .subscription:
                    subscriptionsCount += item.dates.count
                case .unsubscription:
                    unsubscriptionsCount += item.dates.count
                }
            }
            
            return UserStatistics(
                userId: userId,
                user: user,
                viewsCount: viewsCount,
                subscriptionsCount: subscriptionsCount,
                unsubscriptionsCount: unsubscriptionsCount,
                viewDates: viewDates
            )
        }
        .sorted { $0.viewsCount > $1.viewsCount }
    }
    
    private func parseDate(_ dateInt: Int) -> Date? {
        let dateString = String(format: "%08d", dateInt)
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        return formatter.date(from: dateString)
    }
}
