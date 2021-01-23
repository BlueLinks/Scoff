//
//  UserDetailsView.swift
//  Scoff
//
//  Created by Scott Brown on 03/01/2021.
//

import SwiftUI
import Firebase

struct changeEmailSheet: View {
    @EnvironmentObject var session: SessionStore
    @Binding var isPresented: Bool
    @State var reauthenticated = false
    @State var showingSignInView = false
    @State var oldEmail = ""
    @State var email = ""
    @State var emailChanged = false
    
    var body: some View{
        NavigationView{
            VStack{
                if (!reauthenticated){
                    SignInView(authenticated: $reauthenticated, showView: $showingSignInView)
                    
                } else {
                    Text("Re-authenticated!")
                    Text("Old Email: \(session.session!.email!)")
                    HStack{
                        Text("New Email:")
                        Spacer()
                        TextField("",text: $email).keyboardType(/*@START_MENU_TOKEN@*/.emailAddress/*@END_MENU_TOKEN@*/).onChange(of: email, perform: { (value) in
                                                                                                                                    print("Email changed to \(value)")
                                                                                                                                    emailChanged = true                        })
                    }
                    Button(action: {
                        saveNewEmail()
                    }) {
                        Text("Save").bold()
                    }.disabled(!emailChanged)
                }
            }.navigationTitle("Change email")
        }.onAppear(){
            self.oldEmail = session.session!.email!
            self.email = session.session!.email!
        }
    }
    
    func saveNewEmail(){
        print("Attempting to save new email")
        Auth.auth().currentUser?.updateEmail(to: email) { err in
            if let err = err {
                print("Error updating email: \(err)")
            } else {
                print("Email successfully updated")
                emailChanged = false
                isPresented = false
            }
        }
        print("Attempting to save changes to user details")
        if let user = session.session {
            let userRef = db.collection("users").document(user.uid)
            userRef.updateData([
                "email" : email
            ]){ err in
                if let err = err {
                    print("Error updating email in user document: \(err)")
                } else {
                    print("Email in user document successfully updated")
                }
            }
        }
    }
}

struct changePasswordSheet: View {
    @EnvironmentObject var session: SessionStore
    @Binding var isPresented: Bool
    @State var reauthenticated = false
    @State var showingSignInView = false
    @State var password = ""
    @State var confirmPassword = ""
    @State var passwordChanged = false
    @State var passwordMatchAlert = false
    
    var body: some View{
        NavigationView{
            VStack{
                if (!reauthenticated){
                    SignInView(authenticated: $reauthenticated, showView: $showingSignInView)
                    
                } else {
                    Text("Re-authenticated!")
                    HStack{
                        Text("New Password:")
                        Spacer()
                        SecureField("Password", text: $password).onChange(of: password, perform: { (value) in
                                                                            print("Password Changed")
                                                                            passwordChanged = true                        })
                    }
                    HStack{
                        Text("Confirm New Password:")
                        Spacer()
                        SecureField("Password", text: $confirmPassword).onChange(of: confirmPassword, perform: { (value) in
                                                                                    print("Confirm Password Changed")
                                                                                    passwordChanged = true                        })
                    }.alert(isPresented: $passwordMatchAlert) {
                        Alert(title: Text("Confirm Password"), message: Text("Passwords do not match!"), dismissButton: .default(Text("OK")))
                    }
                    Button(action: {
                        if password == confirmPassword {
                            saveNewPassword()
                        } else {
                            passwordMatchAlert = true
                        }
                    }) {
                        Text("Save").bold()
                    }.disabled(!passwordChanged)
                }
            }.navigationTitle("Change Password")
        }
    }
    
    func saveNewPassword(){
        print("Attempting to save new password")
        Auth.auth().currentUser?.updatePassword(to: password) { err in
            if let err = err {
                print("Error updating password: \(err)")
            } else {
                print("Password successfully updated")
                passwordChanged = false
                isPresented = false
            }
        }
    }
}



struct UserDetailsView: View {
    
    @EnvironmentObject var session: SessionStore
    
    
    @State var firstName = ""
    @State var lastName = ""
    @State var email = ""
    @State var dateOfBirth : Date = Date()
    @State var coeliac = false
    @State var vegetarian = false
    @State var vegan = false
    
    @State var detailsChanged = false
    
    @State var showSaveWarn = false
    @State var showChangeEmailSheet = false
    @State var showChangePasswordSheet = false
    
    var body: some View {
        if let user = session.session{
            
                Form{
                    HStack{
                        Text("First Name:")
                        Spacer()
                        TextField("",text: $firstName).onChange(of: firstName, perform: { (value) in
                            print("firstName changed to \(value)")
                            detailsChanged = true
                        })
                    }
                    HStack{
                        Text("Last Name:")
                        Spacer()
                        TextField("",text: $lastName).onChange(of: lastName, perform: { (value) in
                            print("lastName changed to \(value)")
                            detailsChanged = true
                        })
                    }
                    HStack{
                        Text("Email:")
                        Spacer()
                        TextField("",text: $email).keyboardType(/*@START_MENU_TOKEN@*/.emailAddress/*@END_MENU_TOKEN@*/).onChange(of: email, perform: { (value) in
                            print("Email changed to \(value)")
                            detailsChanged = true
                        })
                    }
                    HStack{
                        DatePicker("Date Of Birth", selection: $dateOfBirth, displayedComponents: .date).onChange(of: dateOfBirth, perform: { (value) in
                            print("dateOfBirth changed to \(value)")
                            detailsChanged = true
                        })
                    }
                    HStack{
                        Toggle("Coeliac Disease?", isOn: $coeliac).onChange(of: coeliac, perform: { (value) in
                            print("Coeliac changed to \(value)")
                            detailsChanged = true
                        })
                    }
                    HStack{
                        Toggle("Vegetarian", isOn: $vegetarian).onChange(of: vegetarian, perform: { (value) in
                            print("Vegetarian changed to \(value)")
                            detailsChanged = true
                        })
                    }
                    HStack{
                        Toggle("Vegan", isOn: $vegan).onChange(of: vegan, perform: { (value) in
                            print("Vegan changed to \(value)")
                            detailsChanged = true
                        })
                    }
                    HStack{
                        Button(action: {
                            showChangeEmailSheet = true
                        }){
                            Text("Change email")
                        }
                    }.sheet(isPresented: $showChangeEmailSheet){
                        changeEmailSheet(isPresented: self.$showChangeEmailSheet)
                    }
                    HStack{
                        Button(action: {
                            showChangePasswordSheet = true
                        }){
                            Text("Change password")
                        }.sheet(isPresented: $showChangePasswordSheet){
                            changePasswordSheet(isPresented: self.$showChangePasswordSheet)
                        }
                    }
                }
                
                // Button for saving changes
                .navigationBarItems(trailing: Button(action: {
                    showSaveWarn = true
                }) {
                    Text("Save").bold()
                }.disabled(!detailsChanged))
                .navigationBarTitle("User Details", displayMode: .inline)
            .alert(isPresented:$showSaveWarn){
                Alert(title: Text("Save?"), message: Text("Are you sure you want to Save?"), primaryButton: .destructive(Text("Save")){
                    saveChanges()
                    
                }, secondaryButton: .cancel())
            }
            .onAppear(){
                self.firstName = user.firstName!
                self.lastName = user.lastName!
                self.email = user.email!
                self.dateOfBirth = user.dateOfBirth!
                self.coeliac = user.coeliac!
                self.vegetarian = user.vegetarian!
                self.vegan = user.vegan!
            }
        }
    }
    
    func saveChanges(){
        print("Attempting to save changes to user details")
        if let user = session.session {
            let userRef = db.collection("users").document(user.uid)
            userRef.updateData([
                "firstName" : firstName,
                "lastName" : lastName,
                "email" : email,
                "dateOfBirth" : dateOfBirth,
                "coeliac" : coeliac,
                "vegetarian" : vegetarian,
                "vegan" : vegan
            ]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                    detailsChanged = false
                    user.firstName = firstName
                    user.lastName = lastName
                    user.email = email
                    user.dateOfBirth = dateOfBirth
                    user.coeliac = coeliac
                    user.vegetarian = vegetarian
                    user.vegan = vegan
                }
            }
        }
    }
}

struct UserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsView()
    }
}
