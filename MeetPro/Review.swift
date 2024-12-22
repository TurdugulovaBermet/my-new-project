import Foundation

struct Review: Identifiable, Codable {
    var id: String?
    var rating: Double
    var comment: String
    
    init(rating: Double, comment: String) {
        self.rating = rating
        self.comment = comment
    }
}
