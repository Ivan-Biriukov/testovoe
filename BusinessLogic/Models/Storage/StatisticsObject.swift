import Foundation
import RealmSwift

final class StatisticsObject: Object {
    @Persisted(primaryKey: true) var id: String 
    @Persisted var userId: Int
    @Persisted var type: String
    @Persisted var dates: List<Int>
    
    convenience init(_ item: StatisticsItem) {
        self.init()
        self.id = item.id
        self.userId = item.userId
        self.type = item.type.rawValue
        self.dates.append(objectsIn: item.dates)
    }
    
    func toDomain() -> StatisticsItem {
        StatisticsItem(
            userId: userId,
            type: StatisticsType(rawValue: type) ?? .view,
            dates: Array(dates)
        )
    }
}
