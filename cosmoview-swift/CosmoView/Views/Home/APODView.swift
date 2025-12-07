import SwiftUI

struct APODView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = APODViewModel()
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.0, green: 0.0, blue: 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if let post = viewModel.apod {
                PostDetailView(post: post)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 20) {
                    ErrorView(message: error) {
                        viewModel.loadAPOD()
                    }
                    
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            viewModel.loadAPOD()
        }
    }
}

@MainActor
class APODViewModel: ObservableObject {
    @Published var apod: NASAPost?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadAPOD() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.getAPOD()
                print("hello world")
                print(response)
                
                if response.status, let post = response.data {
                    apod = post
                } else {
                    errorMessage = "Invalid response from server."
                }
                
            } catch {
                print("⛔ APOD ERROR:", error)
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}

#Preview {
    APODView()
}
