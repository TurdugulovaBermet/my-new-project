import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// ViewModel для управления состоянием
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isAuthenticated = false
    @Published var role = "" // Храним роль пользователя
    
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Ошибка входа: \(error.localizedDescription)"
                return
            }
            
            guard let userId = result?.user.uid else {
                self.errorMessage = "Не удалось получить UID пользователя"
                return
            }
            
            self.fetchUserRole(userId: userId)
        }
    }
    
    private func fetchUserRole(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                self.errorMessage = "Ошибка при получении данных пользователя: \(error.localizedDescription)"
            } else if let document = document, document.exists {
                let userRole = document.data()?["role"] as? String ?? "user"
                self.role = userRole
                self.isAuthenticated = true
            } else {
                self.errorMessage = "Пользователь не найден"
            }
        }
    }
}

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $viewModel.password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                viewModel.loginUser()
            }) {
                Text("Войти")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .fullScreenCover(isPresented: $viewModel.isAuthenticated) {
            // В зависимости от роли, показываем нужную страницу
            switch viewModel.role {
            case "admin":
                AdminPage()
            case "staff":
                StaffPage()
            case "user":
                UserPage()
            default:
                Text("Неизвестная роль")
            }
        }
    }
}


