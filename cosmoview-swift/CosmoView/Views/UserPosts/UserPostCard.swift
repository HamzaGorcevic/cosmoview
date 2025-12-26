import SwiftUI

struct UserPostCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let post: UserPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            AsyncImage(url: URL(string: post.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                    .frame(height: 280)
                    .overlay(ProgressView())
            }
            
            // Content Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(post.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.isDarkMode ? .white : .black)
                    
                    Spacer()
                    
                    Text(formatDate(post.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Text(post.description)
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(post.users?.username.prefix(1).uppercased() ?? "?")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        Text(post.users?.username ?? "Unknown Explorer")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(themeManager.isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color.white)
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(themeManager.isDarkMode ? 0.3 : 0.1), radius: 10, x: 0, y: 5)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .none
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}
