//
//  MenuEditView.swift
//  Scoff
//
//  Created by Scott Brown on 04/01/2021.
//

import SwiftUI
import Firebase

struct addNewItemSheet: View {
    
    @EnvironmentObject var session: SessionStore
    @Binding var data: [itemRaw]
    var menu: menuRaw
    @Binding var isPresented: Bool
    @State var name : String = ""
    @State var price : String = ""
    @State var image : String = ""
    @State var vegetarian : Bool = false
    @State var vegan : Bool = false
    @State var gluten : Bool = false
    
    
    var body: some View{
        NavigationView{
            Form{
                HStack{
                    Text("Name:")
                    Spacer()
                    TextField("",text: $name)
                }
                TextField("Price:", text: $price).keyboardType(.decimalPad)
                TextField("Image:", text: $image)
                Toggle(isOn: $vegetarian) {
                    Text("Suitable for vegetarians?")
                }
                Toggle(isOn: $vegan) {
                    Text("Suitable for vegans?")
                }
                Toggle(isOn: $gluten) {
                    Text("Contains gluten?")
                }
                Button(action: {
                    let doublePrice = Double(price)
                    addItem(name: name, price: doublePrice!, image: image, vegetarian: vegetarian, vegan: vegan, gluten: gluten)
                    
                }){
                    HStack{
                        Image(systemName: "plus.circle")
                        Text("Add item")
                    }.foregroundColor(.blue)
                }
            }
            .navigationTitle("Add new item")
            .navigationBarItems(trailing: Button(action: {
                isPresented = false
            }) {
                Text("Canel").bold()
            })
        }
    }
    
    func addItem(name: String, price: Double, image: String, vegetarian: Bool, vegan : Bool, gluten : Bool){
        if let user = session.session{
            var ref: DocumentReference? = nil
            ref = db.collection("restaurants").document(user.restaurantID!).collection("menus").document(menu.id).collection("items").addDocument(data: [
                "name" : name,
                "price" : price,
                "image" : image,
                "vegetarian" : vegetarian,
                "vegan" : vegan,
                "gluten" : gluten
            ]) {
                err in
                if let err = err {
                    print("Error adding menu: \(err)")
                } else {
                    print("Menu added with ID: \(ref!.documentID)")
                    data.append(itemRaw(id: ref!.documentID, name: name, price: price, image: image, vegetarian: vegetarian, vegan: vegan, gluten: gluten))
                    self.isPresented = false
                }
            }
        }
    }
    
}




struct MenuEditView: View {
    var menu : menuRaw
    
    @EnvironmentObject var session: SessionStore
    
    let db = Firestore.firestore()
    @State var data : [itemRaw] = []
    @State var firstLoad = true
    @State var showingAddItem = false
    @State var deleteWarning = false
    @State private var toBeDeleted: IndexSet?
    @State private var nameToBeDeleted : String?
    
    var body: some View {
        VStack(spacing: 0) {
            List{
                Section(header: Text("Menu Details")){
                    HStack{
                        Text("ID:")
                        Text(menu.id).foregroundColor(.gray)
                    }
                    HStack{
                        Text("Name:")
                        Text(menu.name).foregroundColor(.gray)
                    }
                    HStack{
                        Text("Start Time:")
                        Text(String("Start Time")).foregroundColor(.gray)
                    }
                    HStack{
                        Text("End Time:")
                        Text(String("End Time")).foregroundColor(.gray)
                    }
                }
                Section(header: Text("Items")){
                    ForEach(self.data){ item in
                            NavigationLink(destination: ItemEditView(item: item, menu: menu)){
                            Text("\(item.name)")
                        }
                        // display each item from menu
                    }.onDelete(perform: deleteItem)
                    
                    // Button for adding new Items
                    Button(action: {
                        showingAddItem = true
                    }){
                        HStack{
                            Image(systemName: "plus.circle")
                            Text("Add item")
                        }.foregroundColor(.blue)
                    }
                    .sheet(isPresented: $showingAddItem){
                        addNewItemSheet(data: $data, menu: menu, isPresented: self.$showingAddItem)
                    }
                }
            }
            Spacer()
        }
        .alert(isPresented:$deleteWarning){
            Alert(title: Text("Delete"), message: Text("Are you sure you want to delete \(nameToBeDeleted!)? This will delete this item and all of it's extras."), primaryButton: .destructive(Text("Delete")){
                for row in self.toBeDeleted!{
                    print("Deleting", self.data[row].name)
                    if let user = session.session{
                        db.collection("restaurants").document(user.restaurantID!).collection("menus").document(menu.id).collection("items").document(self.data[row].id).delete { err in
                            if let err = err {
                                print("Error removing item: \(err)")
                            } else {
                                print("Item successfully removed!")
                            }
                        }
                    }
                }
                data.remove(atOffsets: self.toBeDeleted!)
                self.toBeDeleted = nil
                
            }, secondaryButton: .cancel(){
                self.toBeDeleted = nil
            }
            )
        }
        .navigationBarItems(trailing: EditButton())
        .navigationBarTitle("\(menu.name)", displayMode: .automatic)
        
        .onAppear(){
            if firstLoad {
                self.getItems()
                self.firstLoad = false
            }
        }
    }
    
    func deleteItem(at offsets: IndexSet) {
        for row in offsets{
            self.nameToBeDeleted = self.data[row].name
        }
        self.toBeDeleted = offsets
        self.deleteWarning = true
    }
    
    
    func getItems() {
        // get item documents
        if let user = session.session{
            db.collection("restaurants").document(user.restaurantID!).collection("menus").document(menu.id).collection("items").getDocuments() { (itemList, err) in
                
                
                if err != nil{
                    print((err?.localizedDescription)!)
                    return
                }
                
                // Loop through items in retrieved menus
                for newItem in itemList!.documents{
                    
                    // construct new item
                    let item = itemRaw(id: newItem.documentID, name: newItem.get("name") as! String, price: newItem.get("price") as! Double, image: newItem.get("image") as! String, vegetarian: newItem.get("vegetarian") as! Bool, vegan: newItem.get("vegan") as! Bool, gluten: newItem.get("gluten") as! Bool)
                    
                    // append new item to list of items
                    self.data.append(item)
                    
                }
            }
        }
    }
    
    
    
}

struct MenuEditView_Previews: PreviewProvider {
    static var previews: some View {
        MenuEditView(menu: menuRaw(id : "", name: ""))
    }
}
