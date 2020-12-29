//
//  ScoffApp.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI
import Firebase
import Stripe

struct orderItem : Identifiable {
    var id = UUID()
    var quantity : Int
    var item : itemRaw
    var extras : [extraRaw] = []
    var price : Double
    
    init(item : itemRaw, quantity : Int, extras : [extraRaw]) {
        self.item = item
        self.quantity = quantity
        self.extras.append(contentsOf: extras)
        self.price = item.price + extras.lazy.map { $0.price}.reduce(0, +)
    }
}

class Order: ObservableObject {
    @Published var id = UUID()
    @Published var orderTime : Date?
    @Published var tableNumber : Int?
    @Published var restaurant : String?
    @Published var items : [orderItem] = []
    var total : Double{
        return items.lazy.map { $0.price * Double($0.quantity) }.reduce(0, +)
        
    }
}


class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        StripeAPI.defaultPublishableKey = "pk_test_51HzjrjGkZWQT55VmRsQ4o8nhNAPCtPavVBD4v37MFkhZC8bY27OWksEHBNo8ZFXlCh6V5YUKtNdODpVnaQ7Rzz7w00zpkm1vv5"
        // do any other necessary launch configuration
        return true
    }
}


@main
struct ScoffApp: App {
    
    init() {
        
        // For Firebase
        FirebaseApp.configure()
                
        // For top naviagtion bar
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        
        
    }
    
    // Set up AppDelegate for SwiftUI
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        var settings = Order()
        WindowGroup {
            AppView().environmentObject(settings)
        }
    }
}
