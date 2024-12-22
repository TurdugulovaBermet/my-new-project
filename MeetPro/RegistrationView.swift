import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                registerUser(email: email, password: password) { error in
                    if let error = error {
                        errorMessage = error
                        successMessage = ""
                    } else {
                        successMessage = "Пользователь успешно зарегистрирован!"
                        errorMessage = ""
                    }
                }
            }) {
                Text("Зарегистрироваться")
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
    
    private func registerUser(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                // Если регистрация успешна, добавляем пользователя в Firestore с ролью "user"
                let db = Firestore.firestore()
                if let userId = authResult?.user.uid {
                    db.collection("users").document(userId).setData([
                        "role": "user",
                        "email": email
                    ]) { firestoreError in
                        if let firestoreError = firestoreError {
                            completion(firestoreError.localizedDescription)
                        } else {
                            completion(nil)
                        }
                    }
                } else {
                    completion("Не удалось получить идентификатор пользователя.")
                }
            }
        }
    }
    
    
    struct RegistrationView_Previews: PreviewProvider {
        static var previews: some View {
            RegistrationView()
        }
    }
}
