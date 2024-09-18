//
//  SearchableBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 18/09/24.
//

import SwiftUI
import Combine

struct Restaurent: Identifiable, Hashable {
    let id: String
    let name: String
    let cuisine: CuisineOption
}

enum CuisineOption: String {
    case american, italian, japanese
}

final class SearchableDataManager {
    
    func getAllRestaurents() async throws -> [Restaurent] {
        return [
            .init(id: "1", name: "Burgar Shack", cuisine: .american),
            .init(id: "2", name: "Pasta Palace", cuisine: .italian),
            .init(id: "3", name: "Sushi Heaven", cuisine: .japanese),
            .init(id: "4", name: "Local Market", cuisine: .american),
        ]
    }
}

class SearchableViewModel: ObservableObject {
    
    @Published var allRestaurents: [Restaurent] = []
    @Published var filteredRestaurents: [Restaurent] = []
    @Published var searchText: String = "" // act as a publisher
    
    let manager = SearchableDataManager()
    var cancellables = Set<AnyCancellable>()
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        $searchText // act as subscriber and also subscribed to searchText publisher
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.filterRestaurants(searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func filterRestaurants(searchText: String) {
        guard !searchText.isEmpty else {
            filteredRestaurents = []
            return
        }
        
        let search = searchText.lowercased()
        filteredRestaurents = allRestaurents.filter { restaurent in
            let titleContainsSearch = restaurent.name.lowercased().contains(search)
            let cuisineContaionsSearch = restaurent.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSearch || cuisineContaionsSearch
        }
    }
    
    func loadRestaurents() async {
        do {
            allRestaurents = try await manager.getAllRestaurents()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct SearchableBC: View {
    
    @StateObject var viewModel = SearchableViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.isSearching ? viewModel.filteredRestaurents : viewModel.allRestaurents) { restaurent in
                    restaurentRow(restaurent: restaurent)
                }
            }
            .padding()
        }
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: Text("Search restaurants..."))
        .navigationTitle("Restaurents")
        //.navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadRestaurents()
        }
    }
    
    private func restaurentRow(restaurent: Restaurent) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(restaurent.name)
                .font(.headline)
            Text(restaurent.cuisine.rawValue.capitalized)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
    }
}

#Preview {
    NavigationView {
        SearchableBC()
    }
}
