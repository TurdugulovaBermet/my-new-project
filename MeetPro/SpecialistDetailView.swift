//import SwiftUI
//import FirebaseFirestore
//
//struct SpecialistDetailView: View {
//    @State var specialist: Specialist
//    @State private var showConfirmationAlert = false // Состояние для отображения алерта
//    @State private var selectedSlot: String? = nil // Выбранный слот для бронирования
//    @State private var bookingSuccessMessage: String? = nil // Сообщение об успешном бронировании
//    @State private var reminderMessage: String? = nil // Напоминание о консультации
//    @Environment(\.presentationMode) var presentationMode // Для кнопки "Назад"
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                // Кнопка "Назад"
//                HStack {
//                    Button(action: {
//                        presentationMode.wrappedValue.dismiss() // Возврат назад
//                    }) {
//                        HStack {
//                            Image(systemName: "arrow.left")
//                                .foregroundColor(.blue)
//                        }
//                        .padding()
//                    }
//                    Spacer()
//                }
//
//                // Имя специалиста
//                Text(specialist.name)
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                
//                // Квалификация специалиста
//                Text("Квалификация: \(specialist.qualification)")
//                    .font(.headline)
//
//                // Рейтинг специалиста
//                Text("Рейтинг: \(String(format: "%.1f", specialist.rating)) ⭐️")
//                    .font(.subheadline)
//
//                // Описание специалиста
//                Text("Описание:")
//                    .font(.headline)
//                Text(specialist.description)
//                    .font(.body)
//
//                // Категория
//                Text("Категория: \(specialist.category)")
//                    .font(.subheadline)
//
//                // Доступные слоты
//                Text("Доступные слоты:")
//                    .font(.headline)
//                if specialist.availableSlots.isEmpty {
//                    Text("Нет доступных слотов")
//                        .foregroundColor(.gray)
//                } else {
//                    ForEach(specialist.availableSlots, id: \.self) { slot in
//                        HStack {
//                            Text("- \(slot)")
//                                .font(.body)
//                            Spacer()
//                            Button(action: {
//                                self.selectedSlot = slot
//                                self.showConfirmationAlert = true // Показываем алерт для подтверждения
//                            }) {
//                                Text("Забронировать")
//                                    .foregroundColor(.blue)
//                            }
//                        }
//                    }
//                }
//
//                // Если есть сообщение об успешном бронировании
//                if let successMessage = bookingSuccessMessage {
//                    Text(successMessage)
//                        .foregroundColor(.green)
//                        .padding(.top, 20)
//                }
//
//                // Напоминание о предстоящей консультации
//                if let reminder = reminderMessage {
//                    Text(reminder)
//                        .foregroundColor(.orange)
//                        .padding(.top, 20)
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Профиль специалиста")
//        .alert(isPresented: $showConfirmationAlert) {
//            Alert(
//                title: Text("Подтверждение бронирования"),
//                message: Text("Вы уверены, что хотите забронировать консультацию с \(specialist.name) на \(selectedSlot ?? "")?"),
//                primaryButton: .destructive(Text("Забронировать")) {
//                    if let slot = selectedSlot {
//                        self.bookSlot(slot)
//                    }
//                },
//                secondaryButton: .cancel()
//            )
//        }
//    }
//
//    func bookSlot(_ slot: String) {
//        guard let index = specialist.availableSlots.firstIndex(of: slot) else { return }
//        specialist.availableSlots.remove(at: index)
//        
//        // Обновляем данные специалиста в Firestore
//        let db = Firestore.firestore()
//        if let specialistId = specialist.id {
//            db.collection("specialists").document(specialistId).updateData([
//                "availableSlots": specialist.availableSlots
//            ]) { error in
//                if let error = error {
//                    print("Ошибка при обновлении слота: \(error.localizedDescription)")
//                } else {
//                    // После успешного бронирования, обновляем сообщение
//                    bookingSuccessMessage = "Консультация с \(specialist.name) на \(slot) успешно забронирована!"
//                    
//                    // Выводим напоминание о предстоящей консультации
//                    reminderMessage = "У вас ожидается консультация с \(specialist.name) на \(slot). Не забудьте!"
//                }
//            }
//        }
//    }
//}
//
//
import SwiftUI
import FirebaseFirestore

struct SpecialistDetailView: View {
    @State var specialist: Specialist
    @State private var showConfirmationAlert = false // Состояние для отображения алерта
    @State private var selectedSlot: String? = nil // Выбранный слот для бронирования
    @State private var bookingSuccessMessage: String? = nil // Сообщение об успешном бронировании
    @State private var reminderMessage: String? = nil // Напоминание о консультации
    @State private var showReviewView = false // Флаг для отображения экрана с отзывами
    @State private var reviews: [Review] = [] // Отзывы специалиста
    @Environment(\.presentationMode) var presentationMode // Для кнопки "Назад"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Кнопка "Назад"
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Возврат назад
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                    Spacer()
                }

                // Имя специалиста
                Text(specialist.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Квалификация специалиста
                Text("Квалификация: \(specialist.qualification)")
                    .font(.headline)

                // Рейтинг специалиста
                Text("Рейтинг: \(String(format: "%.1f", specialist.rating)) ⭐️")
                    .font(.subheadline)

                // Описание специалиста
                Text("Описание:")
                    .font(.headline)
                Text(specialist.description)
                    .font(.body)

                // Категория
                Text("Категория: \(specialist.category)")
                    .font(.subheadline)

                // Доступные слоты
                Text("Доступные слоты:")
                    .font(.headline)
                if specialist.availableSlots.isEmpty {
                    Text("Нет доступных слотов")
                        .foregroundColor(.gray)
                } else {
                    ForEach(specialist.availableSlots, id: \.self) { slot in
                        HStack {
                            Text("- \(slot)")
                                .font(.body)
                            Spacer()
                            Button(action: {
                                self.selectedSlot = slot
                                self.showConfirmationAlert = true // Показываем алерт для подтверждения
                            }) {
                                Text("Забронировать")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }

                // Если есть сообщение об успешном бронировании
                if let successMessage = bookingSuccessMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding(.top, 20)
                }

                // Напоминание о предстоящей консультации
                if let reminder = reminderMessage {
                    Text(reminder)
                        .foregroundColor(.orange)
                        .padding(.top, 20)
                }

                // Отзывы
                Text("Отзывы:")
                    .font(.headline)
                if reviews.isEmpty {
                    Text("Нет отзывов")
                        .foregroundColor(.gray)
                } else {
                    ForEach(reviews, id: \.id) { review in
                        VStack(alignment: .leading) {
                            Text("Рейтинг: \(review.rating) ⭐️")
                                .font(.subheadline)
                            Text(review.comment)
                                .font(.body)
                        }
                        .padding(.bottom, 10)
                    }
                }
                
                // Кнопка для перехода к оставлению отзыва
                Button(action: {
                    self.showReviewView.toggle()
                }) {
                    Text("Оставить отзыв")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                .sheet(isPresented: $showReviewView) {
                    AddReviewView(specialistId: specialist.id ?? "")
                }
            }
            .padding()
        }
        .navigationTitle("Профиль специалиста")
        .alert(isPresented: $showConfirmationAlert) {
            Alert(
                title: Text("Подтверждение бронирования"),
                message: Text("Вы уверены, что хотите забронировать консультацию с \(specialist.name) на \(selectedSlot ?? "")?"),
                primaryButton: .destructive(Text("Забронировать")) {
                    if let slot = selectedSlot {
                        self.bookSlot(slot)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            // Загружаем отзывы
            loadReviews()
        }
    }

    func bookSlot(_ slot: String) {
        guard let index = specialist.availableSlots.firstIndex(of: slot) else { return }
        specialist.availableSlots.remove(at: index)
        
        // Обновляем данные специалиста в Firestore
        let db = Firestore.firestore()
        if let specialistId = specialist.id {
            db.collection("specialists").document(specialistId).updateData([
                "availableSlots": specialist.availableSlots
            ]) { error in
                if let error = error {
                    print("Ошибка при обновлении слота: \(error.localizedDescription)")
                } else {
                    // После успешного бронирования, обновляем сообщение
                    bookingSuccessMessage = "Консультация с \(specialist.name) на \(slot) успешно забронирована!"
                    
                    // Выводим напоминание о предстоящей консультации
                    reminderMessage = "У вас ожидается консультация с \(specialist.name) на \(slot). Не забудьте!"
                }
            }
        }
    }
    
    func loadReviews() {
        let db = Firestore.firestore()
        
        db.collection("specialists").document(specialist.id ?? "").collection("reviews").getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка при получении отзывов: \(error.localizedDescription)")
                return
            }
            
            // Загружаем отзывы
            reviews = snapshot?.documents.compactMap { document -> Review? in
                try? document.data(as: Review.self)
            } ?? []
        }
    }
}
