import Foundation
import RxSwift

public final class BusinessLogicCore {
    
    public static let shared = BusinessLogicCore()
    
    public let userService: UserServiceProtocol
    
    public let statisticsService: StatisticsServiceProtocol
    
    private init() {
        let network = NetworkService()
        let database = DatabaseService()
        
        let userRepo = UserRepository(database: database)
        let statsRepo = StatisticsRepository(database: database)
        
        let userSvc = UserService(
            networkService: network,
            repository: userRepo
        )
        
        self.userService = userSvc
        self.statisticsService = StatisticsService(
            networkService: network,
            repository: statsRepo,
            userService: userSvc
        )
    }
}
