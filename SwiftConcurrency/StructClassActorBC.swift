//
//  StructClassActorBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 31/08/24.
//

import SwiftUI

/*
 
 VALUE TYPE:
 - Struct, Enum, String, Int, Array, Disctionary, Set etc.
 - Stored in the Stack memory
 - Faster
 - Thread safe
 - Works as pass by value
 
 REFERENCE TYPE:
 - Class, Function, Actor
 - Stored in the Heap memory
 - Slower
 - Not Thread Safe
 - Works as pass by reference
 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
 STACK:
 - Stores value types
 - Fast access of stored variables
 - Each thread has its own stack
 
 HEAP:
 - Stores reference types
 - Shared across threads

 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

 STRUCT:
 - Based on VALUES
 - Stores in Stack memory
 - Thread safe
 - No inheritance
 
 CLASS:
 - Based on REFERENCES
 - Stores in Heap memory
 - Not Thread safe
 - Has Inheritance concept
 
 ACTOR:
 - Same as class but Thread safe
 - But don't support Inheritance concept
 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

 Struct : Data Models, Views
 Class  : Viewmodels
 Actor  : Shared 'Managers' and 'Datastores'
 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
 NOTES:
 - While view is intialized first time only ViewModel and View both intialized
 - Second time onwards the ViewModel don't initialized and but View can be intialized again.

 - Structs are 50 million times fater than classes.
 - Structs are super fast.
 - Classes are super slow.
 
*/

class StructClassActorViewModel: ObservableObject {
    
    init() {
        print("VIEWMODEL INIT")
    }
}

struct StructClassActorBC: View {
    
    @StateObject var viewModel = StructClassActorViewModel()
    
    let isActive: Bool
    
    init(isActive: Bool) {
        self.isActive = isActive
        print("VIEW INIT")
    }
    
    var body: some View {
        ZStack {
            Text("StructClassActorBC")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isActive ? Color.red : Color.green)
        }
    }
}

struct StructClassActorHomeView: View {
    
    @State var isActive: Bool = false
    
    var body: some View {
        StructClassActorBC(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
    }
}

#Preview {
    StructClassActorBC(isActive: true)
}
