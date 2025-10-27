import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Octrum")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            CustomTextField(label: "Username", placeholder: "Enter username", text: $viewModel.username)
            CustomTextField(label: "Password", placeholder: "Enter password", text: $viewModel.password, isSecure: true)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                viewModel.login()
            }, label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Login")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            })
            .disabled(viewModel.isLoading)
            
            Spacer()
        }
        .padding()
        .background(Color.charcoal.ignoresSafeArea())
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(SessionManager.shared)
    }
}
