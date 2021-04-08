//
//  SignUpView.swift
//  Scoff
//
//  Created by Scott Brown on 03/01/2021.
//

import SwiftUI
import Firebase


struct SignUpView : View {
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var dob : Date = Date()
    @State var email: String = ""
    @State var coeliac : Bool = false
    @State var vegetarian : Bool = false
    @State var vegan : Bool = false
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var error = false
    @State var errorText = ""
    @State var passwordMatchAlert = false
    
    let db = Firestore.firestore()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    func getUser () {
        // Get user session
        session.listen()
        if (session.session != nil) {
            // return from view
            self.mode.wrappedValue.dismiss()
        }
    }
    
    func signUp () {
        error = false
        // attempt to create new account
        session.signUp(email: email, password: password) { (result, error) in
            if error != nil {
                self.errorText = error!.localizedDescription
                self.error = true
            } else {
                // new account successfully created
                // upload account details to cloud firestore
                db.collection("users").document(result!.user.uid).setData([
                    "firstName" : self.firstName,
                    "lastName" : self.lastName,
                    "email" : self.email,
                    "dateOfBirth" : self.dob,
                    "coeliac" : self.coeliac,
                    "vegan": self.vegan,
                    "vegetarian" : self.vegetarian
                ]){ err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
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
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                DatePicker("Date Of Birth", selection: $dob, displayedComponents: .date)
                Toggle("Coeliac Disease?", isOn: $coeliac)
                Toggle("Vegetarian?", isOn: $vegetarian)
                Toggle("Vegan?", isOn: $vegan)
                TextField("email address", text: $email).keyboardType(/*@START_MENU_TOKEN@*/.emailAddress/*@END_MENU_TOKEN@*/)
                SecureField("Password", text: $password)
                SecureField("Confirm Password", text: $confirmPassword)
            }
            if (error) {
                // Show error for incorrect details
                Text(self.errorText)
            }
            Button(action: {
                if password == confirmPassword{
                    signUp()
                } else {
                    // Passwords do not match
                    passwordMatchAlert = true
                }
            }) {
                HStack{
                    Spacer()
                    Text("Sign Up")
                    Spacer()
                }
                .padding().background(Color.green)
                
            }
        }.alert(isPresented: $passwordMatchAlert) {
            // Alert when passwords do not match
            Alert(title: Text("Confirm Password"), message: Text("Passwords do not match!"), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("Sign Up")
    }
}
