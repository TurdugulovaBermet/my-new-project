import SwiftUI
import FirebaseFirestore

struct AddSpecialistView: View {
    @State private var name = ""
    @State private var qualification = ""
    @State private var category = ""
    @State private var description = ""
    @State private var availableSlots: [String] = []
    @State private var reviews: [String] = []
    @State private var slotInput = "" // Для ввода нового слота

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о специалисте")) {
                    TextField("Имя", text: $name)
                    TextField("Квалификация", text: $qualification)
                    TextField("Категория", text: $category)
                    TextField("Описание", text: $description)
                    
                    TextField("Новый слот", text: $slotInput)
                        .padding()
                    
                    Button(action: {
                        self.addAvailableSlot()
                    }) {
                        Text("Добавить слот")
                    }
                    
                    // Отображение доступных слотов
                    ForEach(availableSlots, id: \.self) { slot in
                        Text(slot)
                    }
                }
                
                Button(action: {
                    self.addSpecialistToFirestore()
                }) {
                    Text("Добавить информацию о специалисте")
                        .foregroundColor(.blue)
                }
            }
            .navigationBarTitle("Добавить информацию о специалисте")
        }
    }
    
    // Добавление нового слота
    func addAvailableSlot() {
        if !slotInput.isEmpty {
            availableSlots.append(slotInput)
            slotInput = "" // Очистка поля ввода
        }
    }
    
    // Добавление специалиста в Firestore
    func addSpecialistToFirestore() {
        let db = Firestore.firestore()
        let newSpecialist = Specialist(
            id: nil, // Firestore присвоит свой id
            name: name,
            qualification: qualification,
            rating: 0.0, // начальный рейтинг
            availableSlots: availableSlots,
            category: category,
            description: description,
            reviews: reviews
        )
        
        do {
            // Добавляем специалиста в коллекцию "specialists"
            _ = try db.collection("specialists").addDocument(from: newSpecialist)
            print("Специалист добавлен успешно!")
        } catch {
            print("Ошибка при добавлении специалиста: \(error.localizedDescription)")
        }
    }
}
