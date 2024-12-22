import SwiftUI

struct ContentView: View {
    @State private var isLogin = true // Переключение между входом и регистрацией
    
    var body: some View {
        VStack {
            if isLogin {
                LoginView()
            } else {
                RegistrationView()
            }
            
            Button(action: {
                isLogin.toggle()
            }) {
                Text(isLogin ? "Нет аккаунта? Зарегистрироваться" : "Уже есть аккаунт? Войти")
                    .foregroundColor(.blue)
            }
            .padding(.top)
        }
    }
}


