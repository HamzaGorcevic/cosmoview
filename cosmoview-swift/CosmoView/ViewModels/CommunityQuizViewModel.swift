import SwiftUI

@MainActor
class CommunityQuizViewModel: ObservableObject {
    @Published var quizzes: [CommunityQuiz] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Create Quiz
    @Published var newQuestion = ""
    @Published var newOption1 = ""
    @Published var newOption2 = ""
    @Published var newOption3 = ""
    @Published var newOption4 = ""
    @Published var newCorrectAnswerIndex = 0
    @Published var isCreating = false
    
    // Submitting
    @Published var selectedQuizId: String?
    @Published var selectedAnswer: String?
    @Published var submissionResult: QuizSubmissionResponse?
    @Published var isSubmitting = false
    
    @Published var optionErrors: [Bool] = [false, false, false, false]
    @Published var questionError: Bool = false

    private func validateInputs() -> Bool {
        questionError = newQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        let options = [newOption1, newOption2, newOption3, newOption4]
        optionErrors = options.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        return !questionError && !optionErrors.contains(true)
    }

    
    func fetchQuizzes(userId: String) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetchedQuizzes = try await APIService.shared.getCommunityQuizzes(userId: userId)
                self.quizzes = fetchedQuizzes
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to fetch quizzes: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func createQuiz(userId: String) async -> Bool {
        guard validateInputs() else {
            errorMessage = "Please fill all fields"
            return false
        }

        
        isCreating = true
        let options = [newOption1, newOption2, newOption3, newOption4]
        let correctAnswer = options[newCorrectAnswerIndex]
        
        do {
            _ = try await APIService.shared.createCommunityQuiz(
                userId: userId,
                question: newQuestion,
                options: options,
                correctAnswer: correctAnswer
            )
            self.newQuestion = ""
            self.newOption1 = ""
            self.newOption2 = ""
            self.newOption3 = ""
            self.newOption4 = ""
            self.isCreating = false
            self.fetchQuizzes(userId: userId) // Refresh\
            self.questionError = false
            self.optionErrors = [false, false, false, false]
            return true
        } catch {
            self.errorMessage = "Failed to create quiz: \(error.localizedDescription)"
            self.isCreating = false
            return false
        }
    }
    
    func submitAnswer(userId: String, quizId: String, answer: String) {
        isSubmitting = true
        selectedQuizId = quizId
        selectedAnswer = answer
        
        Task {
            do {
                let result = try await APIService.shared.submitCommunityQuiz(
                    userId: userId,
                    quizId: quizId,
                    answer: answer
                )
                self.submissionResult = result
                self.isSubmitting = false
                
                // Update local model to persist UI state
                if let index = self.quizzes.firstIndex(where: { $0.id == quizId }) {
                    let updatedQuiz = CommunityQuiz(
                        id: self.quizzes[index].id,
                        question: self.quizzes[index].question,
                        options: self.quizzes[index].options,
                        correctAnswer: self.quizzes[index].correctAnswer,
                        creatorId: self.quizzes[index].creatorId,
                        users: self.quizzes[index].users,
                        attempted: true,
                        isCorrect: result.correct
                    )
                    self.quizzes[index] = updatedQuiz
                }
                
                // Reset transient state
                self.selectedQuizId = nil
                self.selectedAnswer = nil
                self.submissionResult = nil
            } catch {
                self.errorMessage = "Failed to submit answer"
                self.isSubmitting = false
                
                // Reset selection so user can try again
                self.selectedQuizId = nil
                self.selectedAnswer = nil
            }
        }
    }

    func deleteQuiz(quizId: String) {
        Task {
            do {
                _ = try await APIService.shared.deleteCommunityQuiz(quizId: quizId)
                if let index = self.quizzes.firstIndex(where: { $0.id == quizId }) {
                    self.quizzes.remove(at: index)
                }
            } catch {
                self.errorMessage = "Failed to delete quiz: \(error.localizedDescription)"
            }
        }
    }
}
