import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.1, green: 0.0, blue: 0.3),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Title
                VStack(spacing: 12) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Change Password")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Secure your account 🔒")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 50)
                
                // Form
                VStack(spacing: 20) {
                    CustomSecureField(
                        icon: "lock.fill",
                        placeholder: "Current Password",
                        text: $oldPassword
                    )
                    
                    CustomSecureField(
                        icon: "lock.fill",
                        placeholder: "New Password",
                        text: $newPassword
                    )
                    
                    CustomSecureField(
                        icon: "lock.fill",
                        placeholder: "Confirm New Password",
                        text: $confirmPassword
                    )
                    
                    // Password Match Indicator
                    if !newPassword.isEmpty && !confirmPassword.isEmpty {
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
                    
                    // Change Password Button
                    Button(action: handleChangePassword) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Change Password")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "checkmark")
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
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
            Text("Password changed successfully!")
        }
    }
    
    private var passwordsMatch: Bool {
        newPassword == confirmPassword
    }
    
    private var isFormValid: Bool {
        !oldPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        passwordsMatch &&
        newPassword.count >= 6
    }
    
    private func handleChangePassword() {
        isLoading = true
        Task {
            do {
                try await authManager.changePassword(oldPassword: oldPassword, newPassword: newPassword)
                await MainActor.run {
                    showSuccess = true
                }
            } catch {
                print(error)
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
    ChangePasswordView()
        .environmentObject(AuthenticationManager.shared)
}
