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
        // create link to view of restraunts menus
        NavigationLink(destination: MenuView(menu: menu, restaurantID : restaurantID)){
            HStack(spacing: 15){
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(menu.name)
                        .font(.title)
                    
                    Text("Description")
                        .font(.body)
                }.padding(.leading, 10)
                Spacer()
                
                Image(systemName : "chevron.right").padding(.trailing, 10)
            }
        }.buttonStyle(PlainButtonStyle())
    }
}



struct MenuSelectView: View {
    
    let db = Firestore.firestore()
    var restaurant: restaurantRaw
    @EnvironmentObject var order : Order
    
    @State var data : [menuRaw] = []
    @State var firstLoad = true
    
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
                    Alert(title: Text("Check in Scotland"), message: Text("One member of your party must complete a Check in Scotland Form"), primaryButton: .destructive(Text("I will")){
                        print("Open link")
                        self.url = "https://scoff-a30ae.web.app/?name=" + restaurant.name
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
                        // display each item from menu
                    }
                    
                    Spacer()
                }
            }.padding(.top)
        }.navigationBarTitle("\(restaurant.name)", displayMode: .inline)
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
                let menu = menuRaw(id: newMenu.documentID, name: newMenu.get("name") as! String)
                
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
