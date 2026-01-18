import SwiftUI

struct CommunityQuizListView: View {
    @StateObject private var viewModel = CommunityQuizViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showCreateSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic Background
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(themeManager.primaryTextColor)
                    } else if viewModel.quizzes.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "questionmark.bubble.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(themeManager.secondaryTextColor)
                            Text("No community quizzes yet.")
                                .foregroundColor(themeManager.secondaryTextColor)
                                .font(.headline)
                            Text("Be the first to create one!")
                                .foregroundColor(themeManager.secondaryTextColor)
                                .font(.subheadline)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(viewModel.quizzes) { quiz in
                                    CommunityQuizCard(quiz: quiz, viewModel: viewModel, userId: authManager.userId ?? "")
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Community Quizzes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(themeManager.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateQuizView(viewModel: viewModel)
                    .environmentObject(themeManager)
            }
            .onAppear {
                if let userId = authManager.userId {
                    viewModel.fetchQuizzes(userId: userId)
                }
            }
        }
    }
}

struct CommunityQuizCard: View {
    let quiz: CommunityQuiz
    @ObservedObject var viewModel: CommunityQuizViewModel
    @EnvironmentObject var themeManager: ThemeManager
    let userId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text((quiz.users?.username.prefix(1) ?? "?").uppercased())
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                    .shadow(radius: 2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(quiz.users?.username ?? "Unknown")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    Text("Community Contributor")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                
                Spacer()
                
                if let attempted = quiz.attempted, attempted {
                    if let isCorrect = quiz.isCorrect {
                        HStack(spacing: 6) {
                            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            Text(isCorrect ? "Correct" : "Incorrect")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(isCorrect ? .green : .red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isCorrect ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                        )
                    }
                }
            }
            
            // Question
            Text(quiz.question)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryTextColor)
                .padding(.vertical, 4)
            
            // Options
            VStack(spacing: 12) {
                ForEach(quiz.options, id: \.self) { option in
                    Button(action: {
                        if quiz.attempted != true && viewModel.selectedQuizId == nil {
                            viewModel.submitAnswer(userId: userId, quizId: quiz.id, answer: option)
                        }
                    }) {
                        HStack {
                            Text(option)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(getTextColor(for: option))
                            
                            Spacer()
                            
                            getIcon(for: option)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(getBackgroundColor(for: option))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(getBorderColor(for: option), lineWidth: 1)
                                )
                        )
                    }
                    .disabled((quiz.attempted == true) || (viewModel.selectedQuizId != nil && viewModel.selectedQuizId == quiz.id))
                }
            }
        }
        .padding(20)
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Helper Functions
    
    func getTextColor(for option: String) -> Color {
        if quiz.attempted == true {
             if option == quiz.correctAnswer { return .green }
        }
        return themeManager.primaryTextColor
    }
    
    func getIcon(for option: String) -> some View {
        Group {
            if let attempted = quiz.attempted, attempted {
                if option == quiz.correctAnswer {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if let isCorrect = quiz.isCorrect, !isCorrect, viewModel.selectedAnswer == option {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            } else if viewModel.selectedQuizId == quiz.id {
                if viewModel.selectedAnswer == option {
                    if let result = viewModel.submissionResult {
                        Image(systemName: result.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(result.correct ? .green : .red)
                    } else {
                        ProgressView()
                    }
                }
            } else {
                Image(systemName: "circle")
                    .foregroundColor(themeManager.secondaryTextColor.opacity(0.5))
            }
        }
    }
    
    func getBackgroundColor(for option: String) -> Color {
        // Persistent State
        if let attempted = quiz.attempted, attempted {
            if option == quiz.correctAnswer {
                return Color.green.opacity(0.15)
            }
            return themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05)
        }
        
        // Transient State
        if viewModel.selectedQuizId == quiz.id {
            if let result = viewModel.submissionResult {
                if option == quiz.correctAnswer {
                   return Color.green.opacity(0.15)
                }
                if viewModel.selectedAnswer == option && !result.correct {
                    return Color.red.opacity(0.15)
                }
            } else if viewModel.selectedAnswer == option {
                return Color.blue.opacity(0.15)
            }
        }
        
        return themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05)
    }
    
    func getBorderColor(for option: String) -> Color {
         if let attempted = quiz.attempted, attempted {
             if option == quiz.correctAnswer { return .green.opacity(0.5) }
         }
        
        if viewModel.selectedQuizId == quiz.id {
             if let result = viewModel.submissionResult {
                 if option == quiz.correctAnswer { return .green.opacity(0.5) }
                 if viewModel.selectedAnswer == option && !result.correct { return .red.opacity(0.5) }
             } else if viewModel.selectedAnswer == option {
                 return .blue.opacity(0.5)
             }
        }
        
        return Color.clear
    }
}

struct CreateQuizView: View {
    @ObservedObject var viewModel: CommunityQuizViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Question")) {
                        TextField("Enter your question", text: $viewModel.newQuestion)
                            .foregroundColor(themeManager.primaryTextColor)
                    }
                    
                    Section(header: Text("Options")) {
                        TextField("Option 1", text: $viewModel.newOption1)
                        TextField("Option 2", text: $viewModel.newOption2)
                        TextField("Option 3", text: $viewModel.newOption3)
                        TextField("Option 4", text: $viewModel.newOption4)
                    }
                    
                    Section(header: Text("Correct Answer")) {
                        Picker("Select Correct Option", selection: $viewModel.newCorrectAnswerIndex) {
                            Text("Option 1").tag(0)
                            Text("Option 2").tag(1)
                            Text("Option 3").tag(2)
                            Text("Option 4").tag(3)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        Task {
                            if await viewModel.createQuiz(userId: authManager.userId ?? "") {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isCreating {
                                ProgressView()
                            } else {
                                Text("Post Quiz")
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isCreating)
                    .listRowBackground(themeManager.accentColor)
                    .foregroundColor(.white)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Create Quiz")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
