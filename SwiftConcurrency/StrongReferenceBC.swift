//
//  StrongReferenceBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 18/09/24.
//

import SwiftUI

class StrongReferenceDataManager {
    func getData() async -> String {
        "Updated Data!!!!"
    }
}

class StrongReferenceViewModel: ObservableObject {
    
    @Published var text: String = "Starting Text"
    let manager = StrongReferenceDataManager()
    private var someTask: Task<Void, Never>? = nil
    private var myTasks: [Task<Void, Never>?] = []

    func cancelTask() {
        someTask?.cancel()
        someTask = nil
        
        myTasks.forEach { $0?.cancel() }
        myTasks = []
    }
    
    // Here self is captured as strong reference
    func updateData() {
        Task {
            text = await manager.getData()
        }
    }
    
    // Here also same self is captured as strong reference
    func updateData2() {
        Task {
            self.text = await self.manager.getData()
        }
    }
    
    // Here also same self is captured as strong reference
    func updateData3() {
        Task { [self] in
            self.text = await self.manager.getData()
        }
    }

    // Here self is captured as weak reference
    func updateData4() {
        Task { [weak self] in
            if let data = await self?.manager.getData() {
                self?.text = data
            }
        }
    }
    
    // we don't need to manage weak/strong
    // but Task can manage them for us.
    // hence We can manage the Tasks, it will work automatically
    func updateData5() {
        someTask = Task {
            self.text = await self.manager.getData()
        }
    }
    
    // We can manage the tasks!
    func updateData6() {
        let task1 = Task {
            self.text = await self.manager.getData()
        }
        myTasks.append(task1)
        
        let task2 = Task {
            self.text = await self.manager.getData()
        }
        myTasks.append(task2)
    }
    
    // we purposefully keeping strong references
    func updateData7() {
        Task {
            self.text = await self.manager.getData()
        }
        
        Task.detached {
            self.text = await self.manager.getData()
        }
    }
    
    func updateData8() async {
        self.text = await self.manager.getData()
    }
}

struct StrongReferenceBC: View {
    
    @StateObject private var viewModel = StrongReferenceViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .onAppear {
                viewModel.updateData()
            }
            .onDisappear {
                viewModel.cancelTask()
            }
            .task {
                await viewModel.updateData8()
            }
    }
}

#Preview {
    StrongReferenceBC()
}
