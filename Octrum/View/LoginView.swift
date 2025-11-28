import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var session: SessionManager
    @State private var isTermsAccepted = false
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Image("TextLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
            
            Text("login_to_account")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundColor(.charcoal)
                .padding(.bottom, 16)
            
            VStack(spacing: 20) {
                CustomTextField(label: "Username", placeholder: "Username", text: $viewModel.username)
                CustomTextField(label: "Password", placeholder: "Password", text: $viewModel.password, isSecure: true)
                
                if let errorMessage = viewModel.errorMessage {
                    HStack {
                        Text(errorMessage)
                            .foregroundColor(.flashyRed)
                            .font(.caption)
                        Spacer()
                    }
                }
                
                HStack(spacing: 8) {
                    Button(action: {
                        isTermsAccepted.toggle()
                    }, label: {
                        Image(systemName: isTermsAccepted ? "record.circle" : "circle")
                            .foregroundColor(.solidBlue)
                            .font(.system(size: 18))
                    })
                    
                    Text("I agree to all the terms and privacy policy.")
                        .font(.footnote)
                        .foregroundColor(.black)
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
