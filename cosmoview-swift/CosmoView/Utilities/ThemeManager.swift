import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    private init() {}
    
    
    var backgroundColor: some View {
        LinearGradient(
            colors: isDarkMode ? [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)] : [Color(white: 0.95), Color.white],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var cardBackgroundColor: Color {
        isDarkMode ? Color(white: 0.15) : Color.white
    }
    
    var primaryTextColor: Color {
        isDarkMode ? .white : .black
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? .gray : .gray
    }
    
    var accentColor: Color {
        .purple
    }
}
