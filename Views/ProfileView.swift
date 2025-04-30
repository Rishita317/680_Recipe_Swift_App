import SwiftUI

struct ProfileView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("userName") var userName: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if isLoggedIn {
                    Text("Welcome, \(userName)")
                        .font(.title2)

                    Button("Log Out") {
                        isLoggedIn = false
                        userName = ""
                    }
                    .foregroundColor(.red)
                } else {
                    NavigationLink("Log In", destination: LoginView())
                        .buttonStyle(.borderedProminent)

                    NavigationLink("Register", destination: RegisterView())
                        .buttonStyle(.bordered)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}
