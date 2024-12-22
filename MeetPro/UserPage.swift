import SwiftUI
import FirebaseFirestore

struct UserPage: View {
    @State private var specialists: [Specialist] = [] // Список специалистов
    @State private var selectedSpecialist: Specialist? // Выбранный специалист для просмотра
    @State private var isLoading = false // Флаг загрузки данных
    @Environment(\.presentationMode) var presentationMode // Для кнопки "Назад"

    var body: some View {
        NavigationView {
            VStack {
                // Кнопка "Назад"
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Возврат на предыдущий экран (страница входа)
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                    Spacer()
                }

                if isLoading {
                    ProgressView("Загрузка специалистов...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if specialists.isEmpty {
                    Text("Нет доступных специалистов")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(specialists) { specialist in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(specialist.name)
                                    .font(.headline)
                                Text(specialist.qualification)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                selectedSpecialist = specialist
                            }) {
                                Text("Открыть")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Специалисты")
            .onAppear {
                fetchSpecialists()
            }
            .sheet(item: $selectedSpecialist) { specialist in
                SpecialistDetailView(specialist: specialist)
            }
        }
    }

    // Функция для получения специалистов из Firestore
    func fetchSpecialists() {
        isLoading = true
        let db = Firestore.firestore()
        db.collection("specialists").getDocuments { snapshot, error in
            isLoading = false
            if let error = error {
                print("Ошибка загрузки: \(error.localizedDescription)")
                return
            }
            specialists = snapshot?.documents.compactMap { document in
                var specialist = try? document.data(as: Specialist.self)
                specialist?.id = document.documentID // Присваиваем id документа
                return specialist
            } ?? []
        }
    }
}

