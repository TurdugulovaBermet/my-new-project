import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct User: Identifiable, Decodable {
    var id: String
    var email: String
    var role: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case role
    }
}

struct AdminPage: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = "Персонал"
    @State private var specialists: [Specialist] = [] // Массив для хранения специалистов
    @State private var users: [User] = [] // Массив для хранения пользователей
    @State private var errorMessage: String = "" // Для обработки ошибок
    
    var body: some View {
        NavigationView {
            VStack {
                // Кнопка "Назад"
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                    Spacer()
                }
                
                // Вкладки "Персонал" и "Пользователи"
                HStack {
                    Button(action: {
                        selectedTab = "Персонал"
                    }) {
                        Text("Персонал")
                            .fontWeight(selectedTab == "Персонал" ? .bold : .regular)
                            .foregroundColor(selectedTab == "Персонал" ? .blue : .black)
                            .padding()
                    }
                    Spacer()
                    Button(action: {
                        selectedTab = "Пользователи"
                    }) {
                        Text("Пользователи")
                            .fontWeight(selectedTab == "Пользователи" ? .bold : .regular)
                            .foregroundColor(selectedTab == "Пользователи" ? .blue : .black)
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                // Контент для выбранной вкладки
                if selectedTab == "Персонал" {
                    VStack(spacing: 20) {
                        // Переход на экран для регистрации специалиста
                        NavigationLink(destination: RegisterSpecialistView()) {
                            Text("Зарегистрировать специалиста")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        // Переход на экран для добавления информации о специалисте
                        NavigationLink(destination: AddSpecialistView()) {
                            Text("Добавить информацию о специалисте")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        // Переход на экран для редактирования специалистов
                        if !specialists.isEmpty {
                            NavigationLink(destination: EditSpecialistsView()) {
                                Text("Редактировать специалиста")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        } else {
                            Text("Нет специалистов для редактирования")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding()
                    .onAppear {
                        fetchSpecialists()  // Загружаем список специалистов при появлении экрана
                    }
                } else if selectedTab == "Пользователи" {
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    List(users) { user in
                        VStack(alignment: .leading) {
                            Text(user.email)
                                .font(.headline)
                            Text(user.role)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            // Кнопка для удаления пользователя
                            Spacer()  // Создаем пространство между текстом и иконкой
                                
                                // Кнопка для удаления пользователя с иконкой корзины
                                Button(action: {
                                    deleteUser(user) // Вызываем функцию для удаления
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red) // Цвет иконки
                                        .padding(5)
                                        .background(Color.gray.opacity(0.1)) // Фон за иконкой
                                        .cornerRadius(8)
                                }
                                .padding(.top, 5)  // Отступ сверху для выравнивания
                            }
                    }
                    .onAppear {
                        fetchUsers() // Загружаем список пользователей при появлении экрана
                    }
                }
            }
            .navigationTitle("Управление специалистами") // Применение navigationTitle
        }
    }
    
    // Функция для загрузки специалистов из Firebase
    private func fetchSpecialists() {
        let db = Firestore.firestore()
        db.collection("specialists").getDocuments { snapshot, error in
            if let error = error {
                errorMessage = "Ошибка при загрузке специалистов: \(error.localizedDescription)"
            } else {
                specialists = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Specialist.self)
                } ?? []
                print("Загружены специалисты: \(specialists)") // Отладка
            }
        }
    }
    
    // Функция для загрузки пользователей
    private func fetchUsers() {
        let db = Firestore.firestore()
        
        db.collection("users")
            .whereField("role", isEqualTo: "user")
            .getDocuments { snapshot, error in
                if let error = error {
                    errorMessage = "Ошибка при загрузке пользователей: \(error.localizedDescription)"
                    print("Ошибка при загрузке пользователей: \(error.localizedDescription)") // Для отладки
                } else {
                    if let documents = snapshot?.documents {
                        users = documents.compactMap { doc in
                            let data = doc.data()
                            if let email = data["email"] as? String,
                               let role = data["role"] as? String {
                                return User(id: doc.documentID, email: email, role: role)
                            }
                            return nil
                        }
                    } else {
                        errorMessage = "Не найдено пользователей с ролью 'user'."
                    }
                }
            }
    }
    
    // Функция для удаления пользователя
    private func deleteUser(_ user: User) {
        let db = Firestore.firestore()
        
        db.collection("users").document(user.id).delete { error in
            if let error = error {
                errorMessage = "Ошибка при удалении пользователя: \(error.localizedDescription)"
                print("Ошибка при удалении пользователя: \(error.localizedDescription)") // Для отладки
            } else {
                if let index = users.firstIndex(where: { $0.id == user.id }) {
                    users.remove(at: index) // Удаляем пользователя из локального массива
                    print("Пользователь удален: \(user.email)") // Для отладки
                }
            }
        }
    }
}

