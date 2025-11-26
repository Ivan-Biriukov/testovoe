import Foundation

enum APIEndpoint {
    case users
    case statistics
    
    var url: URL {
        let baseURL = "http://test-case.rikmasters.ru/api/episode"
        switch self {
        case .users:
            return URL(string: "\(baseURL)/users/")!
        case .statistics:
            return URL(string: "\(baseURL)/statistics/")!
        }
    }
}
