//
//  ImagePicker.swift
//  Scoff
//
//  Created by Scott Brown on 12/01/2021.
//
//  Tutorial used https://www.hackingwithswift.com/books/ios-swiftui/importing-an-image-into-swiftui-using-uiimagepickercontroller
//

import SwiftUI

// Create wrapper
struct ImagePicker: UIViewControllerRepresentable {
    
    // Create delegate
    class Coordinator: NSObject,
                       UINavigationControllerDelegate,
                       UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker){
            self.parent = parent
        }
        
        // User has selected an image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as?
                UIImage {
                // Pass image to parent
                parent.image = uiImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        
        
    }
    
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    // Use delegate
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Called when view is created
    func makeUIViewController(context:
                                UIViewControllerRepresentableContext<ImagePicker>)
    -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>){
        
    }
}
