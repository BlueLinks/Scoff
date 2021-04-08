//
//  ItemEditView.swift
//  Scoff
//
//  Created by Scott Brown on 05/01/2021.
//

import SwiftUI
import Firebase
import URLImage

struct editItemSheet : View {
    // View for editing details of item
    
    var menu : menuRaw
    @Binding var item : itemRaw
    @Binding var isPresented: Bool
    @EnvironmentObject var session: SessionStore
    let db = Firestore.firestore()
    @State var name : String = ""
    @State var price : String = ""
    @State var doublePrice : Double = 0
    @State var gluten : Bool = false
    @State var vegetarian : Bool = false
    @State var vegan : Bool = false
    @State var detailsChanged : Bool = false
    @State var showSaveWarn : Bool = false
    @State private var imageToDisplay: Image?
    @State private var imageSelected = false
    @State private var image : UIImage?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
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
                Button(action: {
                    self.showingImagePicker = true
                }){
                    HStack{
                        // User can change image of item
                        Text("Select image")
                        Spacer()
                        if !imageSelected{
                            if item.image != ""{
                                // Show current image
                                URLImage(url: URL(string: item.image)!){ image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                        } else {
                            // Show new selecred image
                            if imageToDisplay != nil {
                                imageToDisplay?
                                    .resizable()
                                    .scaledToFit()
                                
                            }
                        }
                    }.frame(height: 180)
                    .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                        // Present image picker
                        ImagePicker(image: self.$inputImage)
                    }
                }

            }.navigationBarTitle(Text("Edit Item"))
            .navigationBarItems(trailing: Button(action: {
                doublePrice = Double(price)!
                showSaveWarn = true
            }) {
                Text("Save").bold()
            }.disabled(!detailsChanged))
        }.alert(isPresented:$showSaveWarn){
            // Ensure user wishes to make changes
            Alert(title: Text("Save?"), message: Text("Are you sure you want to Save?"), primaryButton: .destructive(Text("Save")){
                saveChanges()
            }, secondaryButton: .cancel())
        }
        .onAppear(){
            self.name = self.item.name
            self.price = String(self.item.price)
            self.gluten = self.item.gluten
            self.vegan = self.item.vegan
            self.vegetarian = self.item.vegetarian
        }
    }
    
    
    func loadImage() {
        // Load selected image
        guard let inputImage = inputImage else { return }
        imageToDisplay = Image(uiImage: inputImage)
        image = inputImage
        imageSelected = true
        detailsChanged = true
    }
    
    func saveChanges(){
        // Save changes to item details
        print("Saving changes")
        
        if let user = session.session{
            var itemRef: DocumentReference? = nil
            // Update details in firestore
            itemRef = db.collection("restaurants").document(user.restaurantID!).collection("menus").document(menu.id).collection("items").document(item.id)
            itemRef?.updateData([
                "name" : self.name,
                "price" : self.doublePrice,
                "gluten" : self.gluten,
                "vegan" : self.vegan,
                "vegetarian" : self.vegetarian
            ]){
                err in
                if let err = err {
                    print("Error updating item: \(err)")
                } else {
                    print("Menu updated with ID: \(itemRef!.documentID)")
                    if (imageSelected){
                        // Upload selected image
                        uploadImage(docRef : itemRef!)
                    }
                    self.item.name = self.name
                    self.item.price = self.doublePrice
                    self.item.gluten = self.gluten
                    self.item.vegan = self.vegan
                    self.item.vegetarian = self.vegetarian
                    self.isPresented = false
                }
            }
        }
    }
    
    
    func uploadImage(docRef : DocumentReference){
        // upload selected item image
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let splashRef = storageRef.child("restaurants/\(session.session!.restaurantID!)/\(docRef.documentID).jpg")
        let localImage = image!.jpegData(compressionQuality: 0.15)
        
        // Begin upload task
        let uploadTask = splashRef.putData(localImage!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print("Error Occured")
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            print("File size: \(size)")
            // You can also access to download URL after upload.
            splashRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error Occured")
                    // Uh-oh, an error occurred!
                    return
                }
                print("downloadURL: \(downloadURL)")
            }
            
        }
        
        uploadTask.observe(.success) { snapshot in
            // Upload task finsihed
            
            if session.session != nil{
                splashRef.downloadURL{( url, error) in
                    guard let downloadURL = url else {
                        print("ERROR")
                        return
                    }
                    // update url for item image in firebase
                    let splashImageUrlString = downloadURL.absoluteString
                    print("download url is \(splashImageUrlString)")
                    print()
                    docRef.updateData([
                        "image" : splashImageUrlString
                    ]){ err in
                        if let err = err {
                            print("Error updating download url for item splash of firestore document: \(err)")
                        } else {
                            print("URL successfully updated")
                            self.item.image = splashImageUrlString
                            self.isPresented = false
                        }
                    }
                    
                }
                
            }
        }
    }
    
}


struct addNewExtraSheet: View {
    // View for adding new extra to item
    
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
                Text("Cancel").bold()
            })
        }
    }
    
    func addExtra(name: String, price: Double, vegetarian: Bool, vegan : Bool, gluten : Bool){
        // Upload extra data to firebase
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
    @State var item : itemRaw
    var menu : menuRaw
    
    @EnvironmentObject var session: SessionStore
    
    let db = Firestore.firestore()
    @State var data : [extraRaw] = []
    @State var firstLoad = true
    @State var showingAddExtra = false
    @State var deleteWarning = false
    @State private var toBeDeleted: IndexSet?
    @State private var nameToBeDeleted : String?
    @State var showEditItem = false
    
    var body: some View {
        VStack(spacing: 0) {
            Form{
                HStack{
                    Spacer()
                    // Show image of item
                    URLImage(url: URL(string: item.image)!){ image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                    Spacer()
                }.listRowBackground(Color(.systemGroupedBackground))
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
                        Text("Contains Gluten?")
                        Text(String(item.gluten)).foregroundColor(.gray)
                    }
                }
                Section{
                    HStack{
                        Button(action: {
                            // Button to edit item details
                            print("Edit item Button pressed")
                            self.showEditItem = true
                        }){
                            Text("Edit Item")
                                .font(.title)
                        }.buttonStyle(formButtonStyle())
                    }.sheet(isPresented: $showEditItem){
                        // Show edit item sheet
                        editItemSheet(menu : menu, item: $item, isPresented: $showEditItem)
                    }
                }
                .listRowBackground(Color(.systemGroupedBackground))
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
                        // Show sheet to add new extra
                        addNewExtraSheet(data: $data, menu: menu, item: item, isPresented: self.$showingAddExtra)
                    }
                }
            }
            Spacer()
        }
        .alert(isPresented:$deleteWarning){
            // Ensure user wishes to delete extra
            Alert(title: Text("Delete"), message: Text("Are you sure you want to delete \(nameToBeDeleted!)? This will delete this extra"), primaryButton: .destructive(Text("Delete")){
                // User wishes to delete extra
                for row in self.toBeDeleted!{
                    print("Deleting", self.data[row].name)
                    if let user = session.session{
                        // remove extra from firebase
                        db.collection("restaurants").document(user.restaurantID!).collection("menus").document(menu.id).collection("items").document(item.id).collection("extras").document(self.data[row].id).delete { err in
                            if let err = err {
                                print("Error removing extra: \(err)")
                            } else {
                                print("Extra successfully removed!")
                            }
                        }
                    }
                }
                // remove extra from local data array
                data.remove(atOffsets: self.toBeDeleted!)
                self.toBeDeleted = nil
                
            }, secondaryButton: .cancel(){
                // User does not wish to delete
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
        // Get index to delete extra at
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
