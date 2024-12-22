import FirebaseAuth
import FirebaseFirestore

func registerUser(email: String, password: String, role: String, completion: @escaping (String?) -> Void) {
    Auth.auth().createUser(withEmail: email, password: password) { result, error in
        if let error = error {
            completion("Ошибка при регистрации: \(error.localizedDescription)")
            return
        }

        guard let userId = result?.user.uid else {
            completion("Не удалось получить UID пользователя")
            return
        }

        let db = Firestore.firestore()

        // Сохраняем данные в Firestore
        db.collection("users").document(userId).setData([
            "email": email,      // Сохраняем email
            "role": role         // Роль пользователя (admin, staff, user)
        ]) { error in
            if let error = error {
                completion("Ошибка сохранения данных: \(error.localizedDescription)")
            } else {
                completion(nil) // Успешно сохранили данные
            }
        }
    }
}
func getUserRole(completion: @escaping (String?, String?) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        completion(nil, "Не удалось получить UID пользователя")
        return
    }

    let db = Firestore.firestore()
    db.collection("users").document(userId).getDocument { document, error in
        if let error = error {
            completion(nil, "Ошибка при получении данных пользователя: \(error.localizedDescription)")
        } else if let document = document, document.exists {
            let role = document.data()?["role"] as? String
            completion(role, nil)
        } else {
            completion(nil, "Пользователь не найден")
        }
    }
}


