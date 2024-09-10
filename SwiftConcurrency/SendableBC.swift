//
//  SendableBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 04/09/24.
//

import SwiftUI

actor CurrentUserManager {
    
    func updateDatabase(userInfo: UserClassInfo) {
        
    }
}

struct UserInfo: Sendable {
    var name: String
}

final class UserClassInfo: @unchecked Sendable {
    var name: String
    let queue = DispatchQueue(label: "com.MyApp.UserClassInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func updateUserName(name: String) {
        queue.async {
            self.name = name
        }
    }
}

class SendableViewModel: ObservableObject {
    
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        //let info = UserInfo(name: "TEST USER")
        //await manager.updateDatabase(userInfo: info)
        
        let info = UserClassInfo(name: "TEST USER")
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableBC: View {
    
    @StateObject var viewModel = SendableViewModel()
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    SendableBC()
}
