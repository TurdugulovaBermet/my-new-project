import Foundation
import FirebaseFirestore

struct Specialist: Identifiable, Codable {
    var id: String? // ID документа в Firestore
    var name: String // Имя специалиста
    var qualification: String // Квалификация
    var rating: Double // Рейтинг специалиста
    var availableSlots: [String] // Доступные слоты
    var category: String // Категория специалиста
    var description: String // Описание специалиста
    var reviews: [String] // Отзывы
}
