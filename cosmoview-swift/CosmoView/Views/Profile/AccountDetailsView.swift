import SwiftUI

struct AccountDetailsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.isDarkMode ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(authManager.currentUser?.username.prefix(1).uppercased() ?? "?")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        Text(authManager.currentUser?.username ?? "Explorer")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                    }
                    .padding(.top, 40)
                    
                    // Details List
                    VStack(spacing: 0) {
                        DetailRow(label: "Username", value: authManager.currentUser?.username ?? "N/A")
                        Divider()
                        DetailRow(label: "Email", value: authManager.currentUser?.email ?? "N/A")
                        Divider()
                        DetailRow(label: "User ID", value: authManager.userId ?? "N/A")
                    }
                    .background(themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Account Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(themeManager.isDarkMode ? .white : .black)
        }
        .padding()
    }
}

#Preview {
    AccountDetailsView()
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(ThemeManager.shared)
}
