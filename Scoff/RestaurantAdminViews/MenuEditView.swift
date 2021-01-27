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
    @State var doublePrice : Double = 0.00
    @State var vegetarian : Bool = false
    @State var vegan : Bool = false
    @State var gluten : Bool = false
    
    @State private var imageToDisplay: Image?
    @State private var imageSelected = false
    @State private var image : UIImage?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var uploadProgress : Double = 0.00
    @State private var showUploadProgress = false
    
    
    var body: some View{
        NavigationView{
            Form{
                HStack{
                    Text("Name:")
                    Spacer()
                    TextField("",text: $name)
                }
                TextField("Price:", text: $price).keyboardType(.decimalPad)
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
                    self.showingImagePicker = true
                }){
                    HStack{
                        Text("Select an image")
                        if imageToDisplay != nil {
                            imageToDisplay?
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }.sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: self.$inputImage)
                }
                Button(action: {
                    doublePrice = Double(price)!
                    addItem()
                    
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
    
    func addItem(){
        if let user = session.session{
            var ref: DocumentReference? = nil
            ref = db.collection("restaurants").document(user.restaurantID!).collection("menus").document(menu.id).collection("items").addDocument(data: [
                "name" : name,
                "price" : doublePrice,
                "image" : "",
                "vegetarian" : vegetarian,
                "vegan" : vegan,
                "gluten" : gluten
            ]) {
                err in
                if let err = err {
                    print("Error adding menu: \(err)")
                } else {
                    print("Menu added with ID: \(ref!.documentID)")
                    uploadImage(docRef : ref!)
                }
            }
        }
    }
    
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        imageToDisplay = Image(uiImage: inputImage)
        image = inputImage
        imageSelected = true
    }
    
    func uploadImage(docRef : DocumentReference){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let splashRef = storageRef.child("restaurants/\(session.session!.restaurantID!)/\(docRef.documentID).jpg")
        let localImage = image!.jpegData(compressionQuality: 0.15)
        
        let uploadTask = splashRef.putData(localImage!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print("Error Occured")
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            splashRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error Occured")
                    // Uh-oh, an error occurred!
                    return
                }
                
            }
            
        }
        
        uploadTask.observe(.resume) { snapshot in
            showUploadProgress = true
        }
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            showUploadProgress = true
            self.uploadProgress = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print(self.uploadProgress)
        }
        
        uploadTask.observe(.success) { snapshot in
            showUploadProgress = false
            
            if let user = session.session{
                splashRef.downloadURL{( url, error) in
                    guard let downloadURL = url else {
                        print("ERROR")
                        return
                    }
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
                            data.append(itemRaw(id: docRef.documentID, name: name, price: doublePrice, image: splashImageUrlString, vegetarian: vegetarian, vegan: vegan, gluten: gluten))
                            self.isPresented = false
                        }
                    }
                    
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
                    // Deleting item
                    print("Deleting", self.data[row].name)
                    if let user = session.session{
                        let itemID = self.data[row].id
                        db.collection("restaurants").document(user.restaurantID!).collection("menus").document(menu.id).collection("items").document(itemID).delete { err in
                            if let err = err {
                                print("Error removing item: \(err)")
                            } else {
                                print("Item successfully removed!")
                            }
                        }
                        let storage = Storage.storage()
                        let storageRef = storage.reference()
                        let splashRef = storageRef.child("restaurants/\(user.restaurantID!)/\(itemID).jpg").delete { err in
                            if let err = err {
                                print("Error in removing item splash image : \(err)")
                            } else {
                                print("Splash image successfully removed!")
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
    
    
    
    
    
    struct MenuEditView_Previews: PreviewProvider {
        static var previews: some View {
            MenuEditView(menu: menuRaw(id : "", name: ""))
        }
    }
}
