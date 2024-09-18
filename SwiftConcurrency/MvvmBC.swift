//
//  MvvmBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 18/09/24.
//

import SwiftUI


final class MvvmBCManagerClass {
    
    func getData() async throws -> String {
        return "Some Data"
    }
}

actor MvvmBCManagerActor {
    
    func getData() async throws -> String {
        return "Some Data from Actor"
    }
}

@MainActor // instead of giving at many places, we put directly to the class itself
final class MvvmBCViewModel: ObservableObject {
    
    let managerClass = MvvmBCManagerClass()
    let managerActor = MvvmBCManagerActor()
    var tasks: [Task<Void, Never>] = []
    //@MainActor
    @Published private(set) var data: String = "Starting Text"
    
    func cancelTasks() {
        tasks.forEach { $0.cancel() }
    }
    
    //@MainActor
    func onCallToActionButtonTapped() {
        let task1 = Task { //@MainActor in
            do {
                //data = try await managerClass.getData()
                data = try await managerActor.getData()
                // here the function call goes some Actor, which deals with some background threads,
                // after call back it returns back to MainActor, which deals with MainThread
                // the compiler will do automatically switching from Actor to MainActor after returning function call.
            } catch {
                print(error.localizedDescription)
            }
        }
        
        tasks.append(task1)
    }
}

struct MvvmBC: View {
    
    @StateObject private var viewModel = MvvmBCViewModel()
    
    var body: some View {
        VStack {
            Button("Button Tapped") {
                viewModel.onCallToActionButtonTapped()
            }
            
            Text(viewModel.data)
        }
        .onDisappear {
            viewModel.cancelTasks()
        }
    }
}

#Preview {
    MvvmBC()
}
