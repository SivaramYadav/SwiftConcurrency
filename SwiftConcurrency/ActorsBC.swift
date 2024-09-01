//
//  ActorsBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 01/09/24.
//

import SwiftUI

/*
 
 1. What is the problem that actors are solving? - Answer is Data Race Problem
 2. How was this problem solved prior to actors?
 3. Actors can solve the problem!
 
 Data Race Problem:
 - means two different threads trying to access the same memory location atleast one of them is trying to write to that memory location.
 
*/

class ActorsDataManager {
    
    static let instance = ActorsDataManager()
    private init() { }
    
    var data: [String] = []
    let queueForLock = DispatchQueue(label: "com.myapp.ActorsDataManager")
    
    // here facing data race problem
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return data.randomElement()
    }
    
    // here the above data race problem is solved
    // like below way
    func getRandomData_DataRace_Problem_Solved(completion: @escaping (_ item: String?) -> Void) {
        queueForLock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completion(self.data.randomElement())
        }
    }
}


actor ActorDataManager {
    static let instance = ActorDataManager()
    private init() { }
    var data: [String] = []
    
    nonisolated let randomText = "acfhjwvqwfqqwkhvqkh"

    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return data.randomElement()
    }
    
    nonisolated func getSavedData() -> String {
        return "NEW DATA!"
    }
    
    static func getRandomDataFromStaticMethod() -> String {
        return "tytyytytyyytyty"
    }
    
    // getting error like this
    // Class properties are only allowed within classes; use 'static' to declare a static property
    // class let randomTextClass = "ewgegegeg"
}

struct HomeView: View {
    
    let manager = ActorsDataManager.instance
    let actorManager = ActorDataManager.instance
    @State var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
//        .onReceive(timer) { _ in
//            DispatchQueue.global().async {
//                if let data = manager.getRandomData() {
//                    DispatchQueue.main.async {
//                        self.text = data
//                    }
//                }
//            }
//        }
        .onReceive(timer) { _ in
//            DispatchQueue.global().async {
//                manager.getRandomData_DataRace_Problem_Solved { item in
//                    if let data = item {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
            
            Task {
                if let data = await actorManager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }

        .onAppear {
            let newData = actorManager.getSavedData()
            let randomText = actorManager.randomText
            let randomData = ActorDataManager.getRandomDataFromStaticMethod()
        }
    }
}

struct BrowseView: View {

    let manager = ActorsDataManager.instance
    let actorManager = ActorDataManager.instance
    @State var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack  {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
//        .onReceive(timer) { _ in
//            DispatchQueue.global().async {
//                if let data = manager.getRandomData() {
//                    DispatchQueue.main.async {
//                        self.text = data
//                    }
//                }
//            }
//        }
        .onReceive(timer) { _ in
//            DispatchQueue.global().async {
//                manager.getRandomData_DataRace_Problem_Solved { item in
//                    if let data = item {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
            
            Task {
                if let data = await actorManager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct ActorsBC: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorsBC()
}
