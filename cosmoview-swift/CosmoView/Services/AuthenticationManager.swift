import Foundation
import SwiftUI
import Combine

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var userId: String?
    
    private init() {
        loadAuthState()
    }
    
    func register(username: String, email: String, password: String) async throws {
        let response = try await APIService.shared.register(username: username, email: email, password: password)
        
        if response.status {
            print("Registration successful: \(response.message)")
        } else {
            throw AuthError.registrationFailed(response.message)
        }
    }
    
    func login(email: String, password: String) async throws {
        do {
            let response = try await APIService.shared.login(email: email, password: password)
            
            print("=== LOGIN RESPONSE DEBUG ===")
            print("Status: \(response.status)")
            print("Message: \(response.message)")
            print("Data: \(String(describing: response.data))")
            print("==========================")
            
            if response.status, let user = response.data {
                await MainActor.run {
                    self.isAuthenticated = true
                    self.currentUser = user
                    self.userId = user.id
                    self.saveAuthState()
                }
            } else {
                throw AuthError.loginFailed(response.message)
            }
        } catch {
            print("=== LOGIN ERROR ===")
            print("Error: \(error)")
            print("==================")
            throw error
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
        userId = nil
        clearAuthState()
    }
    
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
    
    private func saveAuthState() {
        UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        UserDefaults.standard.set(userId, forKey: "userId")
        
        if let user = currentUser {
            if let encoded = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encoded, forKey: "currentUser")
            }
        }
    }
    
    private func loadAuthState() {
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        let storedUserId = UserDefaults.standard.string(forKey: "userId")
        
        if let storedUserId = storedUserId, isValidUUID(storedUserId) {
            userId = storedUserId
        } else {
            userId = nil
            if storedUserId != nil {
                print("⚠️ Invalid userId detected (not a UUID): \(storedUserId ?? "nil"). Clearing cached data.")
                clearAuthState()
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: "currentUser") {
            currentUser = try? JSONDecoder().decode(User.self, from: data)
        }
    }
    
    private func isValidUUID(_ string: String) -> Bool {
        return UUID(uuidString: string) != nil
    }
    
    private func clearAuthState() {
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
}

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
