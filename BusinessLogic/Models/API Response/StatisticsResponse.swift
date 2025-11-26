import Foundation

public struct StatisticsResponse: Decodable {
    public let statistics: [StatisticsItem]
}

public struct StatisticsItem: Decodable, Identifiable {
    public let userId: Int
    public let type: StatisticsType
    public let dates: [Int]
    
    public var id: String {
        "\(userId)_\(type.rawValue)"
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case type
        case dates
    }
}

public enum StatisticsType: String, Decodable {
    case view
    case subscription
    case unsubscription
}

public struct UserStatistics {
    public let userId: Int
    public let user: User?
    public let viewsCount: Int
    public let subscriptionsCount: Int
    public let unsubscriptionsCount: Int
    public let viewDates: [Date]
    
    public init(
        userId: Int,
        user: User? = nil,
        viewsCount: Int = 0,
        subscriptionsCount: Int = 0,
        unsubscriptionsCount: Int = 0,
        viewDates: [Date] = []
    ) {
        self.userId = userId
        self.user = user
        self.viewsCount = viewsCount
        self.subscriptionsCount = subscriptionsCount
        self.unsubscriptionsCount = unsubscriptionsCount
        self.viewDates = viewDates
    }
}
