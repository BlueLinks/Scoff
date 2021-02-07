//
//  UserView.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI

//class isSignedIn : ObservableObject {
//    @Published var value = false
//}

struct UserView : View {
    
    @EnvironmentObject var session: SessionStore
    
    
    
    @State var showSignIn : Bool = true
    @State var signOutWarn = false
    @State var authenticated = false
    @State var showingSignInView = false
    
    func getUser () {
        if (session.session != nil) {
            showSignIn = false
        }
    }
    
    var body: some View {
        NavigationView {
            VStack{
                if (showSignIn){
                    VStack{
                        NavigationLink(destination: SignInView(authenticated: $authenticated, showView: $showingSignInView), isActive : $showingSignInView) {
                            Text("Sign In")
                        }                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign Up")
                        }                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                    }
                } else {
                    Form{
                        // Check if user is restaurant admin
                        if (session.session?.restaurantID == nil){
                            // User is normal customer
                            NavigationLink(destination: UserDetailsView()){
                                Image(systemName: "person")
                                Text("User Details")
                            }
                        
                        
                        NavigationLink(destination: ReceiptsView()){
                            Image(systemName: "folder")
                            Text("Receipts View")
                        }
                            
                        } else {
                            // User is restaurant admin
                            NavigationLink(destination: RestaurantDetailsView()){
                                Image(systemName: "person")
                                Text("Restaurant Details")
                            }
                            NavigationLink(destination: MenuCreationView()){
                                Image(systemName: "book")
                                Text("Edit Menus")
                            }
                            NavigationLink(destination: IncomingOrdersView()){
                                Image(systemName: "tray.and.arrow.down")
                                Text("Incoming Orders")
                            }
                        }
                        // Show sign out to all signed in users
                        Button(action: {
                            self.signOutWarn = true
                        }){
                            Text("Sign out")
                        }.alert(isPresented:$signOutWarn){
                            Alert(title: Text("Sign Out"), message: Text("Are you sure you want to sign out?"), primaryButton: .destructive(Text("Sign Out")){
                                print("Logged out?" , session.signOut())
                                session.session = nil
                                showSignIn = true

                            }, secondaryButton: .cancel())
                        }
                    }
                }
            }.onAppear(perform: getUser)
            .navigationBarTitle("User")
        }
    }
    
}


struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
