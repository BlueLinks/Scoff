//
//  ExtraEditView.swift
//  Scoff
//
//  Created by Scott Brown on 05/01/2021.
//

import SwiftUI
import Firebase

struct editExtraSheet: View {
    // View to edit extra details
    
    var menu : menuRaw
    var item: itemRaw
    @Binding var extra: extraRaw
    @Binding var isPresented: Bool
    @EnvironmentObject var session: SessionStore
    let db = Firestore.firestore()
    @State var name : String = ""
    @State var price : String = ""
    @State var doublePrice : Double = 0.0
    @State var gluten : Bool = false
    @State var vegetarian : Bool = false
    @State var vegan : Bool = false
    @State var detailsChanged : Bool = false
    @State var showSaveWarn : Bool = false
    
    var body : some View{
        NavigationView{
            Form{
                HStack{
                    Text("Name:")
                    TextField("",text: $name).onChange(of: name, perform: { (value) in
                        print("name changed to \(value)")
                        detailsChanged = true
                    })
                }
                HStack{
                    Text("Price: £")
                    TextField("", text: $price).keyboardType(.decimalPad).onChange(of: price, perform: { (value) in
                        print("price changed to \(price)")
                        detailsChanged = true
                    })
                }
                HStack{
                    Toggle("Contains Gluten?", isOn: $gluten).onChange(of: gluten, perform: { (value) in
                        print("gluten changed to \(value)")
                        detailsChanged = true
                    })
                }
                HStack{
                    Toggle("Vegetarian?", isOn: $vegetarian).onChange(of: vegetarian, perform: { (value) in
                        print("Vegetarian changed to \(value)")
                        detailsChanged = true
                    })
                }
                HStack{
                    Toggle("Vegan?", isOn: $vegan).onChange(of: vegan, perform: { (value) in
                        print("Vegan changed to \(value)")
                        detailsChanged = true
                    })
                }
            }.navigationBarTitle(Text("Edit Extra"))
            .navigationBarItems(trailing: Button(action: {
                // Present save alert
                showSaveWarn = true
            }) {
                Text("Save").bold()
            }.disabled(!detailsChanged))
            // Save button is disabled if no changes have been made
            
        }.alert(isPresented:$showSaveWarn){
            // Ensure user wishes to save changes
            Alert(title: Text("Save?"), message: Text("Are you sure you want to Save?"), primaryButton: .destructive(Text("Save")){
                doublePrice = Double(price)!
                saveChanges()
            }, secondaryButton: .cancel())
        }
        .onAppear(){
            self.name = self.extra.name
            self.price = String(self.extra.price)
            self.gluten = self.extra.gluten
            self.vegan = self.extra.vegan
            self.vegetarian = self.extra.vegetarian
        }
    }
    
    func saveChanges(){
        // Save changes to firebase and local copy
        print("Saving changes")
        
        if let user = session.session{
            var extraRef: DocumentReference? = nil
            // Update details in firebase
            extraRef = db.collection("restaurants").document(user.restaurantID!).collection("menus").document(menu.id).collection("items").document(item.id).collection("extras").document(extra.id)
            extraRef?.updateData([
                "name" : self.name,
                "price" : self.doublePrice,
                "gluten" : self.gluten,
                "vegan" : self.vegan,
                "vegetarian" : self.vegetarian
            ]){
                err in
                if let err = err {
                    print("Error updating extra: \(err)")
                } else {
                    print("Extra updated with ID: \(extraRef!.documentID)")
                    // update local copy
                    self.extra.name = self.name
                    self.extra.price = self.doublePrice
                    self.extra.gluten = self.gluten
                    self.extra.vegan = self.vegan
                    self.extra.vegetarian = self.vegetarian
                    self.isPresented = false
                }
            }
        }
    }
    
}

struct ExtraEditView: View {
    // View showing extra details
    
    var menu : menuRaw
    var item : itemRaw
    @State var extra : extraRaw
    
    @State var showEditExtra : Bool = false
    
    
    var body: some View {
        Form{
            Section(header: Text("Extra Details")){
                HStack{
                    Text("ID:")
                    Text(extra.id).foregroundColor(.gray)
                }
                HStack{
                    Text("Name:")
                    Text(extra.name).foregroundColor(.gray)
                }
                HStack{
                    Text("Price:")
                    Text("£\(String(extra.price))").foregroundColor(.gray)
                }
                HStack{
                    Text("Vegetarian?")
                    Text(String(extra.vegetarian)).foregroundColor(.gray)
                }
                HStack{
                    Text("Vegan?")
                    Text(String(extra.vegan)).foregroundColor(.gray)
                }
                HStack{
                    Text("Contains Gluten?")
                    Text(String(extra.gluten)).foregroundColor(.gray)
                }
            }
            Section{
                HStack{
                    Button(action: {
                        print("Edit extra Button pressed")
                        // Show sheet for editing extra details
                        self.showEditExtra = true
                    }){
                        Text("Edit Extra")
                            .font(.title)
                    }.buttonStyle(formButtonStyle())
                }.sheet(isPresented: $showEditExtra){
                    // present extra edit sheet
                    editExtraSheet(menu : menu, item: item, extra: $extra, isPresented: $showEditExtra)
                }
            }
            .listRowBackground(Color(.systemGroupedBackground))
        }
        .navigationTitle(Text("\(extra.name)"))
    }
}

struct ExtraEditView_Previews: PreviewProvider {
    static var previews: some View {
        ExtraEditView(menu: menuRaw(), item: itemRaw(), extra: extraRaw())
    }
}
