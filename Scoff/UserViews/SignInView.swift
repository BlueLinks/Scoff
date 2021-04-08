//
//  SignInView.swift
//  Scoff
//
//  Created by Scott Brown on 03/01/2021.
//

import SwiftUI
import Firebase

struct SignInView : View {
    
    @Binding var authenticated : Bool
    @State var signInError = false
    
    @State var email: String = ""
    @State var password: String = ""
    @State var loading = false
    @State var error : String? = ""
    
    let db = Firestore.firestore()
    
    @EnvironmentObject var session: SessionStore
    @Binding var showView : Bool
    
    func getUser () {
        // Get user session
        session.listen()
        if (session.session != nil) {
            print("Signing in")
            authenticated = true
            // Return from view
            self.showView = false
        }
        
        
    }
    
    func signIn () {
        // Sign in user
        loading = true
        error = ""
        session.signIn(email: email, password: password) { (result, error) in
            self.loading = false
            if error != nil {
                self.error = error?.localizedDescription
                self.signInError = true
                print((error?.localizedDescription)!)
            } else {
                db.collection("users").document(result!.user.uid).getDocument{ (document, err) in
                    if let err = err {
                        print("Error accessing document: \(err)")
                    } else {
                        // User authorised
                        print("Document successfully accessed!")
                        // Clear fields in form
                        self.email = ""
                        self.password = ""
                        getUser()
                    }
                }
                
            }
        }
    }
    
    var body: some View {
        VStack {
            Form{
                TextField("email address", text: $email).keyboardType(/*@START_MENU_TOKEN@*/.emailAddress/*@END_MENU_TOKEN@*/)
                SecureField("Password", text: $password)
                Button(action: {
                    signIn()
                }) {
                    HStack{
                        Spacer()
                        Text("Sign in")
                        Spacer()
                    }
                    .padding().background(Color.green)
                }
                
                Button(action: {
                    email = "testaurant@email.com"
                    password = "password1"
                    signIn()
                }) {
                    HStack{
                        Spacer()
                        Text("Restaurant dev sign in")
                        Spacer()
                    }
                    .padding().background(Color.black)
                }
                Button(action: {
                    email = "test@email.com"
                    password = "password1"
                    signIn()
                }) {
                    HStack{
                        Spacer()
                        Text("Customer dev sign in")
                        Spacer()
                    }
                    .padding().background(Color.yellow)
                }
            }.alert(isPresented: $signInError) {
                Alert(title: Text("Error Signing In"), message: Text(self.error!), dismissButton: .default(Text("Got it!")))
            }
            
        }
        .navigationTitle("Sign In")
    }
}
