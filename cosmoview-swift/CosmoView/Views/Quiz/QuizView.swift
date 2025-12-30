import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            (themeManager.isDarkMode ? Color.black : Color.white)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(themeManager.isDarkMode ? .white : .black)
            } else if let quiz = viewModel.quiz {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            Text("Daily Cosmos Quiz")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(themeManager.isDarkMode ? .white : .black)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Total Points")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(authManager.currentUser?.totalPoints ?? 0)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        Divider()
                            .background(Color.gray.opacity(0.5))
                            
                        // Countdown
                        VStack(spacing: 4) {
                            Text("Next Quiz In")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(timeString)
                                .font(.system(size: 18, weight: .bold).monospacedDigit())
                                .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        }
                        .padding(.bottom, 10)
                        
                        // Question (reuse existing styling below)
                        
                        // Question
                        Text(quiz.question)
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                            .padding(.horizontal)
                            .padding(.vertical, 20)
                        
                // Options
                        if let attempted = quiz.attempted, attempted {
                             VStack(spacing: 20) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.green)
                                Text("You've already completed today's quiz!")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(themeManager.isDarkMode ? .white : .black)
                                Text("Come back tomorrow for a new challenge.")
                                    .font(.body)
                                    .foregroundColor(.gray)
                             }
                             .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(quiz.options, id: \.self) { option in
                                    Button(action: {
                                        viewModel.selectedAnswer = option
                                    }) {
                                        HStack {
                                            Text(option)
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(themeManager.isDarkMode ? .white : .black)
                                            
                                            Spacer()
                                            
                                            if viewModel.selectedAnswer == option {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            } else {
                                                Image(systemName: "circle")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(viewModel.selectedAnswer == option ? Color.blue.opacity(0.3) : (themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05)))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(viewModel.selectedAnswer == option ? Color.blue : Color.clear, lineWidth: 2)
                                                )
                                        )
                                    }
                                    .disabled(viewModel.isSubmitting)
                                }
                            }
                            .padding(.horizontal)
                        
                            Spacer()
                            
                            // Submit Button
                            Button(action: {
                                if let userId = authManager.currentUser?.id {
                                    viewModel.submitAnswer(userId: userId)
                                }
                            }) {
                                Text(viewModel.isSubmitting ? "Submitting..." : "Submit Answer")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(12)
                            }
                            .disabled(viewModel.selectedAnswer == nil || viewModel.isSubmitting)
                            .opacity(viewModel.selectedAnswer == nil || viewModel.isSubmitting ? 0.6 : 1.0)
                            .padding()
                        }
                    }
                }
            } else if let error = viewModel.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Error loading quiz")
                        .font(.headline)
                        .foregroundColor(themeManager.isDarkMode ? .white : .black)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        viewModel.fetchDailyQuiz(userId: authManager.currentUser?.id)
                    }
                    .padding()
                }
            } else {
                 Text("No loaded state")
            }
        }
        .onAppear {
            viewModel.fetchDailyQuiz(userId: authManager.currentUser?.id)
        }
        .onReceive(viewModel.timer) { targetDate in
             viewModel.updateTimeRemaining()
        }
        .alert(isPresented: $viewModel.showingResult) {
            if let result = viewModel.submissionResult {
                return Alert(
                    title: Text(result.correct ? "Correct!" : "Wrong Answer"),
                    message: Text(result.correct ? "You earned \(result.points) points!" : "Better luck next time."),
                    dismissButton: .default(Text("OK")) {
                        if result.correct {
                           authManager.currentUser = authManager.currentUser.map { user in
                               var updatedUser = user
                               let newPoints = (user.totalPoints ?? 0) + result.points
                               // This is a local hack to update UI immediately, ideally verify with backend fetch
                               return User(id: user.id, username: user.username, email: user.email, totalPoints: newPoints, createdAt: user.createdAt, updatedAt: user.updatedAt)
                           }
                        }
                        // Refresh to show "Completed" state
                        viewModel.fetchDailyQuiz(userId: authManager.currentUser?.id)
                        dismiss()
                    }
                )
            } else {
                return Alert(title: Text("Error"), message: Text("Unknown result"), dismissButton: .cancel())
            }
        }
    }
    
    private var timeString: String {
        let totalSeconds = Int(viewModel.timeRemaining)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
