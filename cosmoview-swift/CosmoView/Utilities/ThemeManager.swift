import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    private init() {}
}
