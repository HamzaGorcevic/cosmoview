import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var posts: [NASAPost] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    
    private var currentOffset = 0
    private let limit = 10
    
    func loadPosts() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        currentOffset = 0
        
        Task {
            do {
                let response = try await APIService.shared.getAllPosts(limit: limit, offset: currentOffset)
                if response.status, let fetchedPosts = response.data {
                    posts = fetchedPosts
                    currentOffset = fetchedPosts.count
                }
            } catch {
                errorMessage = "Failed to load posts: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    func loadMorePosts() {
        guard !isLoadingMore && !isLoading else { return }
        
        isLoadingMore = true
        
        Task {
            do {
                let response = try await APIService.shared.getAllPosts(limit: limit, offset: currentOffset)
                if response.status, let fetchedPosts = response.data {
                    posts.append(contentsOf: fetchedPosts)
                    currentOffset += fetchedPosts.count
                }
            } catch {
                print("Failed to load more posts: \(error.localizedDescription)")
            }
            isLoadingMore = false
        }
    }
    
    func refresh() async {
        currentOffset = 0
        do {
            let response = try await APIService.shared.getAllPosts(limit: limit, offset: currentOffset)
            if response.status, let fetchedPosts = response.data {
                posts = fetchedPosts
                currentOffset = fetchedPosts.count
            }
        } catch {
            errorMessage = "Failed to refresh: \(error.localizedDescription)"
        }
    }
}
