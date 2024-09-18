//
//  RefreshableBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 18/09/24.
//

import SwiftUI

final class RefreshableDataManager {
    
    func fetchData() async throws -> [String] {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        return ["Apple", "Banana", "Orange", "Mango"].shuffled()
    }
}

@MainActor
class RefreshableViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    let manager = RefreshableDataManager()
    
    func getData() async {
//        Task {
            do {
                dataArray = try await manager.fetchData()
            } catch {
                print(error.localizedDescription)
            }
//        }
    }
}

struct RefreshableBC: View {
    
    @StateObject private var viewModel = RefreshableViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(viewModel.dataArray, id: \.self) { item in
                        Text(item)
                            .font(.headline)
                    }
                }
            }
            .refreshable {
                await viewModel.getData()
            }
            .task {
                await viewModel.getData()
            }
            .navigationTitle("Refreshable BC")
        }
    }
}

#Preview {
    RefreshableBC()
}
