import SwiftUI
import FirebaseFirestore

struct EditSpecialistsView: View {
    @State private var specialists: [Specialist] = [] // Список всех специалистов
    @State private var isLoading = true
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Загрузка специалистов...")
                } else if !errorMessage.isEmpty {
                    Text("Ошибка: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(specialists) { specialist in
                        NavigationLink(destination: EditSpecialistView(specialist: specialist)) {
                            VStack(alignment: .leading) {
                                Text(specialist.name)
                                    .font(.headline)
                                Text(specialist.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarItems(leading: Button(action: {
                            // Действие для возвращения назад
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.blue)
                        })
            .onAppear(perform: fetchSpecialists)
        }
    }

    private func fetchSpecialists() {
        let db = Firestore.firestore()
        isLoading = true
        errorMessage = ""
        
        db.collection("specialists").getDocuments { snapshot, error in
            if let error = error {
                errorMessage = "Не удалось загрузить специалистов: \(error.localizedDescription)"
                isLoading = false
            } else {
                specialists = snapshot?.documents.compactMap { doc in
                    var specialist = try? doc.data(as: Specialist.self)
                    specialist?.id = doc.documentID
                    return specialist
                } ?? []
                isLoading = false
            }
        }
    }
}

struct EditSpecialistView: View {
    @State var specialist: Specialist
    @State private var updatedDescription: String
    @State private var updatedQualification: String
    @State private var updatedAvailableSlots: [String]
    @State private var newSlot: String = "" // Текст для нового слота
    @State private var errorMessage: String = ""
    @State private var successMessage: String = ""
    @State private var editingSlotIndex: Int? = nil // Индекс редактируемого слота
    @State private var editedSlot: String = "" // Новый текст редактируемого слота
    @State private var isLoading = false // Флаг загрузки данных

    init(specialist: Specialist) {
        _specialist = State(initialValue: specialist)
        _updatedDescription = State(initialValue: specialist.description)
        _updatedQualification = State(initialValue: specialist.qualification)
        _updatedAvailableSlots = State(initialValue: specialist.availableSlots)
    }

    var body: some View {
        NavigationView {
            VStack {
                // Загрузка данных специалистов
                if isLoading {
                    ProgressView("Загрузка данных специалиста...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    Form {
                        Section(header: Text("Информация о специалисте")) {
                            TextField("Описание", text: $updatedDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            TextField("Квалификация", text: $updatedQualification)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        Section(header: Text("Доступные слоты")) {
                            ForEach(updatedAvailableSlots.indices, id: \.self) { index in
                                HStack {
                                    if editingSlotIndex == index {
                                        TextField("Редактировать слот", text: $editedSlot)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .onChange(of: editedSlot) { newValue in
                                                updatedAvailableSlots[editingSlotIndex!] = newValue
                                            }
                                    } else {
                                        Text(updatedAvailableSlots[index])
                                    }

                                    Spacer()

                                    Button(action: {
                                        startEditingSlot(at: index)
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())

                                    Button(action: {
                                        deleteSlot(at: index)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }

                            TextField("Введите новый слот", text: $newSlot)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button(action: addSlot) {
                                Text("Добавить слот")
                            }
                        }

                        Section {
                            Button(action: saveChanges) {
                                Text("Сохранить изменения")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }

                        if !successMessage.isEmpty {
                            Text(successMessage)
                                .foregroundColor(.green)
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Редактировать \(specialist.name)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func addSlot() {
        guard !newSlot.isEmpty else {
            errorMessage = "Пожалуйста, введите слот."
            return
        }

        updatedAvailableSlots.append(newSlot)
        newSlot = "" // Очистить поле для ввода нового слота
        errorMessage = "" // Очистить возможное сообщение об ошибке
    }

    func startEditingSlot(at index: Int) {
        editingSlotIndex = index
        editedSlot = updatedAvailableSlots[index] // Загружаем текущее значение слота в переменную
    }

    func deleteSlot(at index: Int) {
        updatedAvailableSlots.remove(at: index)
    }

    func saveChanges() {
        guard let specialistId = specialist.id else {
            errorMessage = "Ошибка: ID специалиста не найден"
            return
        }

        // Проверка, что все обязательные поля заполнены
        if updatedDescription.isEmpty || updatedQualification.isEmpty {
            errorMessage = "Пожалуйста, заполните все поля!"
            return
        }

        // Запись данных в Firestore
        let db = Firestore.firestore()
        db.collection("specialists").document(specialistId).updateData([
            "description": updatedDescription,
            "qualification": updatedQualification,
            "availableSlots": updatedAvailableSlots // Обновление слотов
        ]) { error in
            if let error = error {
                errorMessage = "Ошибка при обновлении данных: \(error.localizedDescription)"
                successMessage = ""
            } else {
                successMessage = "Информация успешно обновлена!"
                errorMessage = ""

                // Обновление текущего объекта specialist с новыми данными
                specialist.description = updatedDescription
                specialist.qualification = updatedQualification
                updateAvailableSlots() // Обновляем слоты локально
            }
        }
    }

    func updateAvailableSlots() {
        // Обновляем локальные данные о доступных слотах
        specialist.availableSlots = updatedAvailableSlots
    }

    func deleteSpecialist() {
        guard let specialistId = specialist.id else { return }

        let db = Firestore.firestore()
        db.collection("specialists").document(specialistId).delete { error in
            if let error = error {
                errorMessage = "Ошибка при удалении специалиста: \(error.localizedDescription)"
            } else {
                successMessage = "Специалист успешно удален!"
            }
        }
    }
}
