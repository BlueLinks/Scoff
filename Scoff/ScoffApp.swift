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
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}
