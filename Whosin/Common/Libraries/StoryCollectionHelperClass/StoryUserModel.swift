import Foundation

struct StoryUser: Equatable {
    static func == (lhs: StoryUser, rhs: StoryUser) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String = kEmptyString
    var name: String = kEmptyString
    var imageUrl: String = kEmptyString
    var content: [Content] = []
    
    init(userDetails: [String: Any]) {
        name = userDetails["name"] as? String ?? ""
        imageUrl = userDetails["imageUrl"] as? String ?? ""
        let aContent = userDetails["content"] as? [[String : Any]] ?? []
        for element in aContent {
            content += [Content(element: element)]
        }
    }
}

struct Content {
    var type: String
    var url: String
    init(element: [String: Any]) {
        type = element["type"] as? String ?? ""
        url = element["url"] as? String ?? ""
    }
}
