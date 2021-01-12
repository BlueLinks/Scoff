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
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var loading = false
    @State var error = false
    @State var passwordMatchAlert = false
    
    let db = Firestore.firestore()

    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    func getUser () {
        session.listen()
        if (session.session != nil) {
            self.mode.wrappedValue.dismiss()
        }
    }
    
    func signUp () {
        loading = true
        error = false
        session.signUp(email: email, password: password) { (result, error) in
            self.loading = false
            if error != nil {
                self.error = true
            } else {
                db.collection("users").document(result!.user.uid).setData([
                    "firstName" : self.firstName,
                    "lastName" : self.lastName,
                    "email" : self.email,
                    "dateOfBirth" : self.dob
                ]){ err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
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
            TextField("email address", text: $email).keyboardType(/*@START_MENU_TOKEN@*/.emailAddress/*@END_MENU_TOKEN@*/)
            SecureField("Password", text: $password)
            SecureField("Confirm Password", text: $confirmPassword)
            }
            if (error) {
                Text("ahhh crap")
            }
            Button(action: {
                if password == confirmPassword{
                signUp()
                } else {
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
            Alert(title: Text("Confirm Password"), message: Text("Passwords do not match!"), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("Sign Up")
    }
}
