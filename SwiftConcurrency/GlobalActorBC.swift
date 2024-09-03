//
//  GlobalActorBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 01/09/24.
//

import SwiftUI

//@globalActor struct FirstGlobalActor {
//    static var shared = NewDataManager()
//}

@globalActor final class FirstGlobalActor {
    static var shared = NewDataManager()
}

actor NewDataManager {
    
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "Four", "Five", "Six", "Seven"]
    }
}

@MainActor class GlobalActorViewModel: ObservableObject {
    
    //@MainActor @Published var dataArray: [String] = []
    @Published var dataArray: [String] = []
    let manager = NewDataManager()
    
//    func getData() async {
//        let data = await manager.getDataFromDatabase()
//        self.dataArray = data
//    }
    
//    nonisolated func getData() {
//        
//        // HEAVY COMPLEX METHODS
//        
//        Task {
//            let data = await manager.getDataFromDatabase()
//            //self.dataArray = data
//            await MainActor.run {
//                self.dataArray = data
//            }
//        }
//    }
    
    @FirstGlobalActor func getData() {
        
        // HEAVY COMPLEX METHODS
        
        Task {
            let data = await manager.getDataFromDatabase()
            //self.dataArray = data
            await MainActor.run {
                self.dataArray = data
            }
        }
    }


}

struct GlobalActorBC: View {
    
    @StateObject var viewModel = GlobalActorViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

#Preview {
    GlobalActorBC()
}
