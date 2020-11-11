//
//  ScoffApp.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI
import Firebase

@main
struct ScoffApp: App {
    
    init() {
      FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
