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
                if response.status, let post = response.data {
                    apod = post
                }
            } catch {
                // If today's APOD fails (likely 404), try yesterday's
                do {
                    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let dateString = formatter.string(from: yesterday)
                    
                    let response = try await APIService.shared.getAPOD(date: dateString)
                    if response.status, let post = response.data {
                        apod = post
                    }
                } catch {
                    errorMessage = "Failed to load picture: \(error.localizedDescription)"
                }
            }
            isLoading = false
        }
    }
}

#Preview {
    APODView()
}
