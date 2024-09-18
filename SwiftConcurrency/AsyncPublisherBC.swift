//
//  AsyncPublisherBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 10/09/24.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
//actor AsyncPublisherDataManager {

    @Published var dataArr: [String] = []
    
    func addData() async {
        dataArr.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        dataArr.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        dataArr.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        dataArr.append("Watermelon")        
    }
}

class AsyncPublisherViewModel: ObservableObject {
    
    @MainActor @Published var data: [String] = []
    let manager = AsyncPublisherDataManager()
    var cancallables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        
        // make same below code, using async-await approach
        Task {
            for await value in manager.$dataArr.values {
                await MainActor.run {
                    self.data = value
                }
            }
        }
        
        // below is the Combine way
//        manager.$dataArr
//            .receive(on: DispatchQueue.main)
//            .sink { dataArray in
//                self.data = dataArray
//            }
//            .store(in: &cancallables)
    }
    
    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisherBC: View {
    
    @StateObject var viewModel = AsyncPublisherViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.data, id: \.self) {
                    Text($0)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherBC()
}
