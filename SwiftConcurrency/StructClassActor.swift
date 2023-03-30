//
//  StructClassActor.swift
//  SwiftConcurrency
//
//  Created by Dima Stepanov on 3/25/23.
//

import SwiftUI

struct StructClassActor: View {
    var body: some View {
        Text("Hello, World!")
            .onAppear{
                runTest()
            }
    }
}

struct StructClassActor_Previews: PreviewProvider {
    static var previews: some View {
        StructClassActor()
    }
}

struct MyStruct {
    var title: String
}
class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
}

extension StructClassActor {
    
    private func runTest() {
        print("Test running")
        stuctTest()
        print("- - - - -- -- - - - - - - ")
        classTest()
    }
    
    private func stuctTest() {
        print("Stuct is Value Type! Pass the  VALUE of objectA to objectB")
        print("- - - - -- -- - - - - - - ")
        
        let objectA = MyStruct(title: "Starting title")
        print("ObjectA", objectA.title)
        
        var objectB = objectA
        print("ObjectB", objectB.title)
        
        objectB.title = "Second Title"
        print("ObjectB Title Change to:", objectB.title)
        
        print("ObjectB", objectB.title)
        print("ObjectA", objectA.title)
    }
    
    private func classTest() {
        print("Class is Reference Type! Pass the VALUE of objectA to objectB")
        print("- - - - -- -- - - - - - - ")
        
        let objectA = MyClass(title: "Starting title")
        print("ObjectA", objectA.title)
        
        let objectB = objectA
        print("ObjectB", objectB.title)
        
        objectB.title = "Second Title"
        print("ObjectB Title Change to:", objectB.title)
        
        print("ObjectB", objectB.title)
        print("ObjectA", objectA.title)
    }
    
}
