import Foundation
import RealmSwift

final class UserObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var sex: String
    @Persisted var username: String
    @Persisted var isOnline: Bool
    @Persisted var age: Int
    @Persisted var avatarURLString: String?
    
    convenience init(_ user: User) {
        self.init()
        self.id = user.id
        self.sex = user.sex
        self.username = user.username
        self.isOnline = user.isOnline
        self.age = user.age
        self.avatarURLString = user.avatarURL?.absoluteString
    }
    
    func toDomain() -> User {
        User(
            id: id,
            sex: sex,
            username: username,
            isOnline: isOnline,
            age: age,
            files: avatarURLString.flatMap { URL(string: $0) }.map {
                [UserFile(id: id, url: $0, type: "avatar")]
            } ?? []
        )
    }
}
