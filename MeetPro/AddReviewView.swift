//import SwiftUI
//import FirebaseFirestore
//
//struct AddReviewView: View {
//    @State private var rating: Double = 1
//    @State private var comment: String = ""
//    @State private var successMessage = ""
//    @State private var errorMessage = ""
//    var specialistId: String
//    
//    var body: some View {
//        VStack {
//            Text("Оставьте отзыв о специалисте")
//                .font(.title)
//                .padding()
//            
//            // Простой виджет для рейтинга (например, Slider или звезды)
//            Slider(value: $rating, in: 1...5, step: 1) {
//                Text("Рейтинг")
//            }
//            .padding()
//            
//            // Текст отзыва
//            TextField("Ваш отзыв", text: $comment)
//                .padding()
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .frame(height: 100)
//            
//            Button(action: {
//                self.submitReview()
//            }) {
//                Text("Отправить отзыв")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//            
//            if !errorMessage.isEmpty {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//            }
//            
//            if !successMessage.isEmpty {
//                Text(successMessage)
//                    .foregroundColor(.green)
//            }
//        }
//        .padding()
//    }
//    
//    func submitReview() {
//        let db = Firestore.firestore()
//        
//        // Создаем новый отзыв
//        let newReview = Review(rating: rating, comment: comment)
//        
//        do {
//            // Добавляем отзыв в коллекцию отзывов
//            let _ = try db.collection("specialists").document(specialistId).collection("reviews").addDocument(from: newReview)
//            
//            // Обновляем средний рейтинг специалиста
//            updateSpecialistRating()
//            
//            successMessage = "Отзыв успешно отправлен!"
//            errorMessage = ""
//        } catch {
//            errorMessage = "Ошибка при отправке отзыва: \(error.localizedDescription)"
//            successMessage = ""
//        }
//    }
//    
//    func updateSpecialistRating() {
//        let db = Firestore.firestore()
//        
//        // Получаем все отзывы
//        db.collection("specialists").document(specialistId).collection("reviews").getDocuments { snapshot, error in
//            if let error = error {
//                print("Ошибка при получении отзывов: \(error.localizedDescription)")
//                return
//            }
//            
//            // Рассчитываем средний рейтинг
//            let reviews = snapshot?.documents.compactMap { document -> Review? in
//                try? document.data(as: Review.self)
//            } ?? []
//            
//            let totalRating = reviews.reduce(0.0) { $0 + $1.rating }
//            let averageRating = reviews.isEmpty ? 0 : totalRating / Double(reviews.count)
//            
//            // Обновляем рейтинг специалиста
//            db.collection("specialists").document(specialistId).updateData([
//                "rating": averageRating
//            ]) { error in
//                if let error = error {
//                    print("Ошибка при обновлении рейтинга: \(error.localizedDescription)")
//                } else {
//                    print("Рейтинг специалиста обновлен успешно!")
//                }
//            }
//        }
//    }
//}
import SwiftUI
import FirebaseFirestore

//struct Review: Identifiable, Codable {
//    var id: String?
//    var rating: Double
//    var comment: String
//    
//    init(rating: Double, comment: String) {
//        self.rating = rating
//        self.comment = comment
//    }
//}

struct AddReviewView: View {
    @State private var rating: Double = 1
    @State private var comment: String = ""
    @State private var successMessage = ""
    @State private var errorMessage = ""
    var specialistId: String
    
    var body: some View {
        VStack {
            Text("Оставьте отзыв о специалисте")
                .font(.title)
                .padding()
            
            // Простой виджет для рейтинга (например, Slider или звезды)
            Slider(value: $rating, in: 1...5, step: 1) {
                Text("Рейтинг")
            }
            .padding()
            
            // Текст отзыва
            TextField("Ваш отзыв", text: $comment)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(height: 100)
            
            Button(action: {
                self.submitReview()
            }) {
                Text("Отправить отзыв")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            if !successMessage.isEmpty {
                Text(successMessage)
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
    
    func submitReview() {
        let db = Firestore.firestore()
        
        // Создаем новый отзыв
        let newReview = Review(rating: rating, comment: comment)
        
        do {
            // Добавляем отзыв в коллекцию отзывов
            let _ = try db.collection("specialists").document(specialistId).collection("reviews").addDocument(from: newReview)
            
            // Обновляем средний рейтинг специалиста
            updateSpecialistRating()
            
            successMessage = "Отзыв успешно отправлен!"
            errorMessage = ""
        } catch {
            errorMessage = "Ошибка при отправке отзыва: \(error.localizedDescription)"
            successMessage = ""
        }
    }
    
    func updateSpecialistRating() {
        let db = Firestore.firestore()
        
        // Получаем все отзывы
        db.collection("specialists").document(specialistId).collection("reviews").getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка при получении отзывов: \(error.localizedDescription)")
                return
            }
            
            // Рассчитываем средний рейтинг
            let reviews = snapshot?.documents.compactMap { document -> Review? in
                try? document.data(as: Review.self)
            } ?? []
            
            let totalRating = reviews.reduce(0.0) { $0 + $1.rating }
            let averageRating = reviews.isEmpty ? 0 : totalRating / Double(reviews.count)
            
            // Обновляем рейтинг специалиста
            db.collection("specialists").document(specialistId).updateData([
                "rating": averageRating
            ]) { error in
                if let error = error {
                    print("Ошибка при обновлении рейтинга: \(error.localizedDescription)")
                } else {
                    print("Рейтинг специалиста обновлен успешно!")
                }
            }
        }
    }
}
