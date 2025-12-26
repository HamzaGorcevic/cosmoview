import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showRegister = false
    
    var body: some View {
        ZStack {
            // Background Gradient
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
            
            // Animated Stars Background
            StarsBackgroundView()
                .environmentObject(themeManager)
            
            VStack(spacing: 0) {
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 70))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.5), radius: 20)
                    
                    Text("CosmoView")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.isDarkMode ? .white : .black)
                    
                    Text("Explore the Universe 🌌")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                }
                .padding(.bottom, 60)
                
                // Login Form
                VStack(spacing: 20) {
                    // Email Field
                    CustomTextField(
                        icon: "envelope.fill",
                        placeholder: "Email",
                        text: $email
                    )
                    .environmentObject(themeManager)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    
                    // Password Field
                    CustomSecureField(
                        icon: "lock.fill",
                        placeholder: "Password",
                        text: $password
                    )
                    .environmentObject(themeManager)
                    
                    // Login Button
                    Button(action: handleLogin) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Login")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "arrow.right")
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
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                    .padding(.top, 10)
                    
                    // Register Link
                    Button(action: { showRegister = true }) {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                            Text("Sign up")
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 15))
                    }
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
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(authManager)
                .environmentObject(themeManager)
        }
    }
    
    private func handleLogin() {
        isLoading = true
        Task {
            do {
                try await authManager.login(email: email, password: password)
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

// MARK: - Custom Text Field
struct CustomTextField: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .foregroundColor(themeManager.isDarkMode ? .white : .black)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Custom Secure Field
struct CustomSecureField: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let placeholder: String
    @Binding var text: String
    @State private var isSecure = true
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(themeManager.isDarkMode ? .white : .black)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(themeManager.isDarkMode ? .white : .black)
            }
            
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Stars Background
struct StarsBackgroundView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { i in
                Circle()
                    .fill(themeManager.isDarkMode ? Color.white.opacity(Double.random(in: 0.2...0.8)) : Color.black.opacity(Double.random(in: 0.1...0.4)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(animate ? 1 : 0.3)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 1...3))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(ThemeManager.shared)
}
