import SwiftUI
import FirebaseFirestore

struct UserProfileView: View {
    var user: User

    var body: some View {
        VStack {
            Text("Профиль пользователя")
                .font(.largeTitle)
                .padding()

            Text("Email: \(user.email)")

            Spacer()
        }
        .navigationBarTitle(user.email, displayMode: .inline)
    }
}
