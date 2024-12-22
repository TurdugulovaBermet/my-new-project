import SwiftUI

struct StaffPage: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Страница персонала")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Text("Здесь будет список специалистов.")
                    .font(.headline)
                    .padding()
            }
            .navigationTitle("Персонал")
        }
    }
}

