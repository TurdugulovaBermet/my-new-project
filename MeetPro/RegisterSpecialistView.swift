import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterSpecialistView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var successMessage = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email для специалиста", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Пароль для специалиста", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                registerSpecialist(email: email, password: password)
            }) {
                Text("Зарегистрировать")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            if !successMessage.isEmpty {
                Text(successMessage)
                    .foregroundColor(.green)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .navigationTitle("Регистрация специалиста")
    }
    
    private func registerSpecialist(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.successMessage = ""
            } else {
                let db = Firestore.firestore()
                if let userId = authResult?.user.uid {
                    db.collection("users").document(userId).setData(["role": "specialist", "email": email]) { firestoreError in
                        if let firestoreError = firestoreError {
                            self.errorMessage = firestoreError.localizedDescription
                            self.successMessage = ""
                        } else {
                            self.successMessage = "Специалист успешно зарегистрирован!"
                            self.errorMessage = ""
                        }
                    }
                }
            }
        }
    }
}
