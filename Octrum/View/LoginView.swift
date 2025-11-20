import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var session: SessionManager
    @State private var isTermsAccepted = false
    
    var body: some View {
        VStack {
            Color.charcoal
                .frame(height: 150)
                .padding(.bottom, 10)
                .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.charcoal)
                
                CustomTextField(label: "Username", placeholder: "Enter username", text: $viewModel.username)
                CustomTextField(label: "Password", placeholder: "Enter password", text: $viewModel.password, isSecure: true)
                
                if let errorMessage = viewModel.errorMessage {
                    HStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                        Spacer()
                    }
                }
                
                HStack(spacing: 8) {
                    Button(action: {
                        isTermsAccepted.toggle()
                    }, label: {
                        Image(systemName: isTermsAccepted ? "record.circle" : "circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 18))
                    })
                    
                    Text("I agree to all the terms and privacy policy.")
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
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
                    .background(isTermsAccepted ? Color.charcoal : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                })
                .disabled(viewModel.isLoading || !isTermsAccepted)
            }
            .padding()
            
            Spacer()
        }
        .background(themeBackground())
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(SessionManager.shared)
    }
}
