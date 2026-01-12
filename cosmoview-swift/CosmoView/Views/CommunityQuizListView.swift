import SwiftUI

struct CommunityQuizListView: View {
    @StateObject private var viewModel = CommunityQuizViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showCreateSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else if viewModel.quizzes.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "questionmark.bubble.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)
                            Text("No community quizzes yet.")
                                .foregroundColor(.gray)
                            Text("Be the first to create one!")
                                .foregroundColor(.gray)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
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
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateQuizView(viewModel: viewModel)
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
    let userId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 30, height: 30)
                    .overlay(Text((quiz.users?.username.prefix(1) ?? "?").uppercased()).foregroundColor(.white))
                
                Text(quiz.users?.username ?? "Unknown")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let attempted = quiz.attempted, attempted {
                    if let isCorrect = quiz.isCorrect {
                        HStack(spacing: 4) {
                            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            Text(isCorrect ? "Correct" : "Incorrect")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(isCorrect ? .green : .red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        )
                    }
                }
            }
            
            Text(quiz.question)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 4)
            
            ForEach(quiz.options, id: \.self) { option in
                Button(action: {
                    if quiz.attempted != true && viewModel.selectedQuizId == nil { // Prevent multiple selections
                        viewModel.submitAnswer(userId: userId, quizId: quiz.id, answer: option)
                    }
                }) {
                    HStack {
                        Text(option)
                            .foregroundColor(.white)
                        Spacer()
                        
                        // Validating UI Logic
                        if let attempted = quiz.attempted, attempted {
                             // Persistent State
                             if option == quiz.correctAnswer {
                                 Image(systemName: "checkmark.circle.fill")
                                     .foregroundColor(.green)
                             } else if let isCorrect = quiz.isCorrect, !isCorrect, viewModel.selectedAnswer == option {
                                 // This only highlights user's wrong answer if we track WHICH wrong answer they picked.
                                 // Currently backend returns simple isCorrect. 
                                 // If we want to show their wrong answer, we need to return it from backend or just show correct one.
                                 // Since we don't store *which* option they picked persistently (only is_correct), we can just show the correct answer.
                                 // But if this is the transient state (just clicked), viewModel.selectedAnswer works.
                                 Image(systemName: "x.circle.fill") // Placeholder: we don't know if THIS was the wrong one they picked unless we store it.
                                     // For now, let's just show checkmark on correct answer.
                             }
                        } else if viewModel.selectedQuizId == quiz.id {
                            // Transient State (Submitting)
                            if viewModel.selectedAnswer == option {
                                if let result = viewModel.submissionResult {
                                    Image(systemName: result.correct ? "checkmark.circle.fill" : "x.circle.fill")
                                        .foregroundColor(result.correct ? .green : .red)
                                } else {
                                    ProgressView().tint(.white)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(getBackgroundColor(for: option))
                    )
                }
                .disabled((quiz.attempted == true) || (viewModel.selectedQuizId != nil && viewModel.selectedQuizId == quiz.id))
            }
        }
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    func getBackgroundColor(for option: String) -> Color {
        // Persistent State
        if let attempted = quiz.attempted, attempted {
            if option == quiz.correctAnswer {
                return Color.green.opacity(0.3)
            }
            // Since we don't store the specific wrong answer the user picked, 
            // we just dim everything else.
            return Color(white: 0.15) 
        }
        
        // Transient State
        guard viewModel.selectedQuizId == quiz.id else { return Color(white: 0.25) }
        
        if let result = viewModel.submissionResult {
            if option == quiz.correctAnswer {
                return Color.green.opacity(0.3)
            }
            if viewModel.selectedAnswer == option && !result.correct {
                return Color.red.opacity(0.3)
            }
        } else if viewModel.selectedAnswer == option {
            return Color.blue.opacity(0.3)
        }
        
        return Color(white: 0.25)
    }
}

struct CreateQuizView: View {
    @ObservedObject var viewModel: CommunityQuizViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Question")) {
                    TextField("Enter your question", text: $viewModel.newQuestion)
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
            }
            .navigationTitle("Create Quiz")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
