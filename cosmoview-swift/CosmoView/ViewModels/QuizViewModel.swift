import Foundation
import SwiftUI

@MainActor
class QuizViewModel: ObservableObject {
    @Published var quiz: Quiz?
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedAnswer: String?
    @Published var submissionResult: QuizSubmissionResponse?
    @Published var isSubmitting = false
    @Published var showingResult = false
    
    @Published var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let defaultsKey: String
    private var nextQuizDate: Date?
    
    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        self.defaultsKey = "DailyQuizCompleted_\(today)"
    }
    
    var isDailyQuizCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: defaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: defaultsKey) }
    }
    
    func fetchDailyQuiz(userId: String? = nil) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let fetchedQuiz = try await APIService.shared.getDailyQuiz(userId: userId)
                self.quiz = fetchedQuiz
                
                // Parse next update
                if let nextUpdateStr = fetchedQuiz.nextUpdate {
                    let isoFormatter = ISO8601DateFormatter()
                    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    if let date = isoFormatter.date(from: nextUpdateStr) {
                         self.nextQuizDate = date
                    } else {
                        // Fallback without fractional seconds
                        isoFormatter.formatOptions = [.withInternetDateTime]
                         if let date = isoFormatter.date(from: nextUpdateStr) {
                             self.nextQuizDate = date
                         }
                    }
                    self.updateTimeRemaining()
                }
                
                self.isLoading = false
            } catch {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func updateTimeRemaining() {
        guard let nextDate = nextQuizDate else { return }
        let remaining = nextDate.timeIntervalSinceNow
        if remaining > 0 {
            timeRemaining = remaining
        } else {
            timeRemaining = 0
            // Optionally refresh quiz if time is up
        }
    }
    
    func submitAnswer(userId: String) {
        guard let quiz = quiz, let answer = selectedAnswer else { return }
        
        isSubmitting = true
        
        Task {
            do {
                let result = try await APIService.shared.submitQuiz(userId: userId, quizId: quiz.id, answer: answer)
                self.submissionResult = result
                self.isSubmitting = false
                self.showingResult = true
                
                // Mark as completed for today if correct or if we just want to allow one attempt per device/user combo logic
                // For now, let's mark completed so banner disappears
                self.isDailyQuizCompleted = true
                
            } catch {
                self.error = error.localizedDescription
                self.isSubmitting = false
            }
        }
    }
    
    func reset() {
        showingResult = false
        submissionResult = nil
        selectedAnswer = nil
    }
}
