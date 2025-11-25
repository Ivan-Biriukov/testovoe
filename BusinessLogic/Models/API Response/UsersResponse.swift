import Foundation

public struct UsersResponse: Decodable {
    public let users: [User]
}

public struct User: Decodable, Identifiable {
    public let id: Int
    public let sex: String
    public let username: String
    public let isOnline: Bool
    public let age: Int
    public let files: [UserFile]
    
    public var avatarURL: URL? {
        files.first(where: { $0.type == "avatar" })?.url
    }
}

public struct UserFile: Decodable {
    public let id: Int
    public let url: URL
    public let type: String
}
