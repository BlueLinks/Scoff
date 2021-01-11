//
//  ScoffApp.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI
import Firebase
import Stripe
import Combine

class SessionStore : ObservableObject {
    var didChange = PassthroughSubject<SessionStore, Never>()
    var session: User? { didSet { self.didChange.send(self) }}
    var handle: AuthStateDidChangeListenerHandle?
    
    func listen () {
        // monitor authentication changes using firebase
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let docRef = Firestore.firestore().collection("users").document(user.uid)
                docRef.getDocument { (document, err) in
                    print("Attempting to log in firebase \(user.uid)")
                    if err != nil{
                        print((err?.localizedDescription)!)
                        return
                    }
                    if let document = document{
                        if !document.exists{
                            print("Document does not exist")
                            return
                        }
                        // if we have a user, create a new user model
                        print("Got user: \(user)")
                        let timestamp: Timestamp = document.get("dateOfBirth") as! Timestamp
                        let date: Date = timestamp.dateValue()
                        self.session = User(
                            uid: user.uid,
                            firstName : document.get("firstName") as? String,
                            lastName : document.get("lastName") as? String,
                            dateOfBirth : date,
                            email: user.email,
                            restaurantID: document.get("restaurantID") as? String
                        )
                    }
                }
            } else {
                // if we don't have a user, set our session to nil
                self.session = nil
            }
            
        }
    }
    
    func signUp(
        email: String,
        password: String,
        handler: @escaping AuthDataResultCallback
    ) {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
    }
    
    func signIn(
        email: String,
        password: String,
        handler: @escaping AuthDataResultCallback
    ) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    }
    
    func signOut () -> Bool {
        do {
            try Auth.auth().signOut()
            self.session = nil
            return true
        } catch {
            return false
        }
    }
    
    func unbind () {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

class User {
    var uid: String
    var firstName : String?
    var lastName : String?
    var dateOfBirth : Date?
    var email: String?
    var restaurantID: String?
    
    init(uid: String, firstName: String?,lastName: String?, dateOfBirth: Date?, email: String?, restaurantID: String?) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.email = email
        self.restaurantID = restaurantID
    }
    
}

// for storing restraunts received from firebase
struct restaurantRaw : Identifiable {
    var id: String
    var name: String
    var picture: String
}

// For storing menus
struct menuRaw : Identifiable {
    var id: String = ""
    var name: String = ""
}

// For storing items from menu
struct itemRaw : Identifiable {
    var id: String = ""
    var name: String = ""
    var price : Double = 0.00
    var image : String = ""
    var vegetarian : Bool = false
    var vegan : Bool = false
    var gluten : Bool = false
}

// For storing extra's for items
struct extraRaw : Identifiable {
    var id: String = ""
    var name: String = ""
    var price : Double = 0.00
    var extraSelected : Bool = false
    var vegetarian : Bool = false
    var vegan : Bool = false
    var gluten : Bool = false
}

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
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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
            AppView().environmentObject(settings).environmentObject(SessionStore())
        }
    }
}
