import Foundation
import SwiftUI

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var userId: String?
    
    private init() {
        // Load saved authentication state
        loadAuthState()
    }
    
    // MARK: - Register
    func register(username: String, email: String, password: String) async throws {
        let response = try await APIService.shared.register(username: username, email: email, password: password)
        
        if response.status {
            print("Registration successful: \(response.message)")
        } else {
            throw AuthError.registrationFailed(response.message)
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws {
        let response = try await APIService.shared.login(email: email, password: password)
        
        if response.status {
            // Save auth state
            await MainActor.run {
                self.isAuthenticated = true
                // For now, we'll generate a temporary user ID based on email
                // In production, the backend should return user details
                self.userId = email
                self.saveAuthState()
            }
        } else {
            throw AuthError.loginFailed(response.message)
        }
    }
    
    // MARK: - Logout
    func logout() {
        isAuthenticated = false
        currentUser = nil
        userId = nil
        clearAuthState()
    }
    
    // MARK: - Change Password
    func changePassword(oldPassword: String, newPassword: String) async throws {
        guard let userId = userId else {
            throw AuthError.notAuthenticated
        }
        
        let response = try await APIService.shared.changePassword(
            userId: userId,
            oldPassword: oldPassword,
            newPassword: newPassword
        )
        
        if !response.status {
            throw AuthError.changePasswordFailed(response.message)
        }
    }
    
    // MARK: - Persistence
    private func saveAuthState() {
        UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        UserDefaults.standard.set(userId, forKey: "userId")
    }
    
    private func loadAuthState() {
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        userId = UserDefaults.standard.string(forKey: "userId")
    }
    
    private func clearAuthState() {
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "userId")
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case registrationFailed(String)
    case loginFailed(String)
    case changePasswordFailed(String)
    case notAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .registrationFailed(let message):
            return message
        case .loginFailed(let message):
            return message
        case .changePasswordFailed(let message):
            return message
        case .notAuthenticated:
            return "You are not authenticated"
        }
    }
}
