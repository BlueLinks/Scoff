//
//  MenuSelectView.swift
//  Scoff
//
//  Created by Scott Brown on 23/11/2020.
//

import SwiftUI
import URLImage
import Firebase

// View for displaying restraunt details
struct menuCardView : View {
    var menu: menuRaw
    var restaurantID : String
    
    var body: some View{
        // create link to view of menu
        NavigationLink(destination: MenuView(menu: menu, restaurantID : restaurantID)){
            HStack(spacing: 15){
                VStack(alignment: .leading, spacing: 8) {
                    Text(menu.name)
                        .font(.title)
                    if menu.description != "" {
                        Text(menu.description)
                            .font(.body).foregroundColor(.gray)
                    }
                }.padding(.leading, 10)
                Spacer()
                
                Image(systemName : "chevron.right").padding(.trailing, 10)
            }
        }.buttonStyle(PlainButtonStyle())
    }
}



struct MenuSelectView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let db = Firestore.firestore()
    var restaurant: restaurantRaw
    @EnvironmentObject var order : Order
    
    @State var data : [menuRaw] = []
    @State var firstLoad = true
    
    @State var orderWarn = false
    @State var trackWarn = true
    @Environment(\.openURL) var openURL
    @State var showSafariView = false
    @State var url : String = ""
    
    var body: some View {
        ZStack{
            
            ScrollView{
                VStack(spacing: 0){
                    // header image
                    URLImage(url: URL(string: restaurant.picture)!){ image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.size.width, height: 240, alignment : .center)
                            .clipped()
                    }
                    VStack{
                        // show distance
                        HStack(spacing: 5){
                            Text("0.25km")
                                .background(Color.gray)
                            
                            Text("From current location").foregroundColor(.white)
                            Spacer()
                            Spacer()
                        }
                        .padding(5)
                        HStack{
                            // show rating
                            Text("⭐️ 3/5")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.leading)
                        .padding(.bottom, 5)
                        HStack{
                            // show dietary info
                            Text("🌱 Vegetarian friendly").foregroundColor(.white)
                            Spacer()
                            Text("Book")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                        .padding(.leading)
                        .padding(.bottom, 5)
                    }
                }.background(Color.black)
                .alert(isPresented:$trackWarn){
                    // Show warning for track and trace
                    Alert(title: Text("Check in Scotland"), message: Text("One member of your party must complete a Check in Scotland Form"), primaryButton: .destructive(Text("I will")){
                        // User has agreed to fill out form
                        print("Open link")
                        self.url = "https://scoff-a30ae.web.app/?name=" + restaurant.name
                        // opens check in scotland in safari in app
                        self.showSafariView.toggle()
                    }, secondaryButton: .cancel(Text("Someone else will")))
                }
                .fullScreenCover(isPresented: $showSafariView) {
                    SafariView(url: URL(string: url)!).edgesIgnoringSafeArea(.all)
                }
                
                .onAppear(){
                    // load new menus
                    if firstLoad{
                        getMenus(restaurantID: restaurant.id)
                        self.firstLoad = false
                    }
                    self.order.restaurant = restaurant
                }
                VStack(spacing: 0){
                    // display each menu
                    ForEach(self.data){ menu in
                        menuCardView(menu : menu, restaurantID : restaurant.id)
                        Divider()
                    }
                    Spacer()
                }
            }.alert(isPresented:$orderWarn){
                // Show alert that the user has already got items in their basket
                // This is to avoid the user adding items from multiple restaurants to their order
                Alert(title: Text("You're already ordering here!"), message: Text("Empty basket and move to another restaurant?"), primaryButton: .destructive(Text("Empty basket")){
                    // User is moving to new restaurant
                    order.items = []
                    order.restaurant = nil
                    self.presentationMode.wrappedValue.dismiss()
                }, secondaryButton: .cancel(Text("I'll stay here")))
            }
            .padding(.top)
        }.navigationBarTitle("\(restaurant.name)", displayMode: .inline)
        // Hide the back button created by the navigation view
        .navigationBarBackButtonHidden(true)
        // Create new back button
        .navigationBarItems(leading: Button(action: {
            // Check if the user has items in their basket
            if order.items.count > 0 {
                orderWarn = true
            } else {
                // Users basket is empty to no need to warn, safe to move back to restaurant selection view
                self.presentationMode.wrappedValue.dismiss()
            }
        }){
            HStack{
                Image(systemName: "chevron.left")
                Text("Back")
            }
        })
    }
    
    
    func getMenus(restaurantID : String) {
        // get Menu documents
        db.collection("restaurants").document(restaurantID).collection("menus").getDocuments { (menuList, err) in
            
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            // Loop through items in retrieved menus
            for newMenu in menuList!.documents{
                
                // construct new menu
                let menu = menuRaw(id: newMenu.documentID, name: newMenu.get("name") as! String, description: newMenu.get("description") as! String)
                
                // append new menu to list of menus
                self.data.append(menu)
                
            }
        }
    }
    
}



struct MenuSelectView_Previews: PreviewProvider {
    static var previews: some View {
        MenuSelectView(restaurant: restaurantRaw(id: "1", name: "Placeholder", picture: "None", email: ""))
    }
}
