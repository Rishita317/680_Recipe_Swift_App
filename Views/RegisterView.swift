import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss

    @AppStorage("lastRegisteredEmail") var lastRegisteredEmail: String = ""

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Register")
                .font(.largeTitle)
                .padding()

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Button("Register") {
                register()
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.isEmpty || !isValidEmail(email))

            Spacer()
        }
        .padding()
    }

    func isValidEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }

    func register() {
        guard let url = URL(string: API.registerURL) else { return }

        let body = ["name": name, "email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(RegisterResponse.self, from: data) else {
                DispatchQueue.main.async {
                    errorMessage = "Unexpected response from server"
                }
                return
            }

            DispatchQueue.main.async {
                if decoded.statusCode == 0 {
                    lastRegisteredEmail = email
                    dismiss()
                } else {
                    errorMessage = decoded.statusMessage
                }
            }
        }.resume()
    }
}

struct RegisterResponse: Decodable {
    let statusCode: Int
    let statusMessage: String
}
