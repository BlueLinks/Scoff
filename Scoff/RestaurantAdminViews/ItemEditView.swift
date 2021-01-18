//
//  ItemEditView.swift
//  Scoff
//
//  Created by Scott Brown on 05/01/2021.
//

import SwiftUI
import Firebase

struct addNewExtraSheet: View {
    
    @EnvironmentObject var session: SessionStore
    @Binding var data: [extraRaw]
    var menu: menuRaw
    var item: itemRaw
    @Binding var isPresented: Bool
    @State var name : String = ""
    @State var price : String = ""
    @State var vegetarian : Bool = false
    @State var vegan : Bool = false
    @State var gluten : Bool = false
    
    
    var body: some View{
        NavigationView{
            Form{
                TextField("Name",text: $name)
                TextField("Price:", text: $price).keyboardType(.decimalPad)
                Toggle(isOn: $vegetarian) {
                    Text("Suitable for vegetarians?")
                }
                Toggle(isOn: $vegan) {
                    Text("Suitable for vegans??")
                }
                Toggle(isOn: $gluten) {
                    Text("Contains gluten?")
                }
                Button(action: {
                    let doublePrice = Double(price)
                    addExtra(name: name, price: doublePrice!, vegetarian: vegetarian, vegan: vegan, gluten: gluten)
                    
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
    
    func addExtra(name: String, price: Double, vegetarian: Bool, vegan : Bool, gluten : Bool){
        if let user = session.session{
            var ref: DocumentReference? = nil
            ref = db.collection("restaurants").document(user.restaurantID!).collection("menus").document(menu.id).collection("items").document(item.id).collection("extras").addDocument(data: [
                "name" : name,
                "price" : price,
                "vegetarian" : vegetarian,
                "vegan" : vegan,
                "gluten" : gluten
            ]) {
                err in
                if let err = err {
                    print("Error adding menu: \(err)")
                } else {
                    print("Menu added with ID: \(ref!.documentID)")
                    data.append(extraRaw(id: ref!.documentID, name: name, price: price, extraSelected: false))
                    self.isPresented = false
                }
            }
        }
    }
    
}


struct ItemEditView: View {
    var item : itemRaw
    var menu : menuRaw
    
    @EnvironmentObject var session: SessionStore
    
    let db = Firestore.firestore()
    @State var data : [extraRaw] = []
    @State var firstLoad = true
    @State var showingAddExtra = false
    @State var deleteWarning = false
    @State private var toBeDeleted: IndexSet?
    @State private var nameToBeDeleted : String?
    
    var body: some View {
        VStack(spacing: 0) {
            List{
                Section(header: Text("Item Details")){
                    HStack{
                        Text("ID:")
                        Text(item.id).foregroundColor(.gray)
                    }
                    HStack{
                        Text("Name:")
                        Text(item.name).foregroundColor(.gray)
                    }
                    HStack{
                        Text("Price:")
                        Text("£\(String(item.price))").foregroundColor(.gray)
                    }
                    HStack{
                        Text("Vegetarian?")
                        Text(String(item.vegetarian)).foregroundColor(.gray)
                    }
                    HStack{
                        Text("Vegan?")
                        Text(String(item.vegan)).foregroundColor(.gray)
                    }
                    HStack{
                        Text("Gluten?")
                        Text(String(item.vegan)).foregroundColor(.gray)
                    }
                }
                Section(header: Text("Extras")){
                    ForEach(self.data){ extra in
                        NavigationLink(destination: ExtraEditView(menu: menu, item: item, extra: extra)){
                        Text("\(extra.name)")
                    }
                        
                    }.onDelete(perform: deleteExtra)
                    
                    // Button for adding new Items
                    Button(action: {
                        showingAddExtra = true
                    }){
                        HStack{
                            Image(systemName: "plus.circle")
                            Text("Add extra")
                        }.foregroundColor(.blue)
                    }
                    .sheet(isPresented: $showingAddExtra){
                        addNewExtraSheet(data: $data, menu: menu, item: item, isPresented: self.$showingAddExtra)
                    }
                }
            }
            Spacer()
        }
        .alert(isPresented:$deleteWarning){
            Alert(title: Text("Delete"), message: Text("Are you sure you want to delete \(nameToBeDeleted!)? This will delete this extra"), primaryButton: .destructive(Text("Delete")){
                for row in self.toBeDeleted!{
                    print("Deleting", self.data[row].name)
                    if let user = session.session{
                        db.collection("restaurants").document(user.restaurantID!).collection("menus").document(menu.id).collection("items").document(item.id).collection("extras").document(self.data[row].id).delete { err in
                            if let err = err {
                                print("Error removing extra: \(err)")
                            } else {
                                print("Extra successfully removed!")
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
        .navigationBarTitle("\(item.name)", displayMode: .automatic)
        
        .onAppear(){
            if firstLoad {
                self.getExtras()
                self.firstLoad = false
            }
        }
    }
    
    func deleteExtra(at offsets: IndexSet) {
        for row in offsets{
            self.nameToBeDeleted = self.data[row].name
        }
        self.toBeDeleted = offsets
        self.deleteWarning = true
    }
    
    
    func getExtras() {
        // get item documents
        if let user = session.session{
            db.collection("restaurants").document(user.restaurantID!).collection("menus").document(menu.id).collection("items").document(item.id).collection("extras").getDocuments() { (extraList, err) in
                
                
                if err != nil{
                    print((err?.localizedDescription)!)
                    return
                }
                
                // Loop through items in retrieved menus
                for newExtra in extraList!.documents{
                    
                    // construct new item
                    let item = extraRaw(id: newExtra.documentID, name: newExtra.get("name") as! String, price: newExtra.get("price") as! Double, extraSelected: false, vegetarian: newExtra.get("vegetarian") as! Bool, vegan: newExtra.get("vegan") as! Bool, gluten: newExtra.get("gluten") as! Bool)
                    
                    // append new item to list of items
                    self.data.append(item)
                    
                }
            }
        }
    }
    
    
    
}

struct ItemEditView_Previews: PreviewProvider {
    static var previews: some View {
        ItemEditView(item: itemRaw(id: "", name: "", price: 0, image: "", vegetarian: false, vegan: false, gluten: false), menu: menuRaw(id: "", name: ""))
    }
}
