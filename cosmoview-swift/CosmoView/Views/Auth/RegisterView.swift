import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: themeManager.isDarkMode ? [
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.1, green: 0.0, blue: 0.3),
                    Color.black
                ] : [
                    Color(red: 0.95, green: 0.95, blue: 1.0),
                    Color(red: 0.9, green: 0.9, blue: 1.0),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            StarsBackgroundView()
                .environmentObject(themeManager)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                            .frame(width: 40, height: 40)
                            .background(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Title
                VStack(spacing: 12) {
                    Text("Create Account")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.isDarkMode ? .white : .black)
                    
                    Text("Join the cosmic journey 🚀")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                }
                .padding(.bottom, 50)
                
                // Form
                VStack(spacing: 20) {
                    CustomTextField(
                        icon: "person.fill",
                        placeholder: "Username",
                        text: $username
                    )
                    
                    CustomTextField(
                        icon: "envelope.fill",
                        placeholder: "Email",
                        text: $email
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    
                    CustomSecureField(
                        icon: "lock.fill",
                        placeholder: "Password",
                        text: $password
                    )
                    
                    CustomSecureField(
                        icon: "lock.fill",
                        placeholder: "Confirm Password",
                        text: $confirmPassword
                    )
                    
                    // Password Match Indicator
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        HStack {
                            Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(passwordsMatch ? .green : .red)
                            Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                                .font(.system(size: 14))
                                .foregroundColor(passwordsMatch ? .green : .red)
                            Spacer()
                        }
                        .padding(.horizontal, 5)
                    }
                    
                    // Register Button
                    Button(action: handleRegister) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "arrow.right")
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(!isFormValid || isLoading)
                    .opacity(isFormValid ? 1.0 : 0.6)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                Spacer()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Account created successfully! Please login.")
        }
    }
    
    private var passwordsMatch: Bool {
        password == confirmPassword
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        passwordsMatch &&
        password.count >= 6
    }
    
    private func handleRegister() {
        isLoading = true
        Task {
            do {
                try await authManager.register(username: username, email: email, password: password)
                await MainActor.run {
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(ThemeManager.shared)
}
