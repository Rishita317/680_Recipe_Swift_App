import SwiftUI

struct LoginView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("userName") var userName: String = ""
    @AppStorage("lastRegisteredEmail") var lastRegisteredEmail: String = ""

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Log In")
                .font(.largeTitle)
                .padding()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .onAppear {
                    if email.isEmpty {
                        email = lastRegisteredEmail
                    }
                }

            HStack {
                Group {
                    if showPassword {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                .textFieldStyle(.roundedBorder)

                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Button("Log In") {
                login()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isValidEmail(email))

            Spacer()
        }
        .padding()
    }

    func isValidEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }

    func login() {
        guard let url = URL(string: API.loginURL) else { return }

        let body = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                DispatchQueue.main.async {
                    errorMessage = "Invalid response"
                }
                return
            }

            DispatchQueue.main.async {
                if decoded.statusCode == 0 {
                    userName = decoded.data.userName
                    isLoggedIn = true
                } else {
                    errorMessage = decoded.statusMessage
                }
            }
        }.resume()
    }
}

struct LoginResponse: Decodable {
    let statusCode: Int
    let statusMessage: String
    let data: LoginUserData
}

struct LoginUserData: Decodable {
    let userName: String
}
