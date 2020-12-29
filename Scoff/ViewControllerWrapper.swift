//
//  OrderView.swift
//  Scoff
//
//  Created by Scott Brown on 18/12/2020.
//

// https://www.captechconsulting.com/blogs/combining-swiftui-with-viewcontrollers

import SwiftUI
import UIKit

struct ViewControllerWrapper: UIViewControllerRepresentable {
    
    let controller: UIViewController?
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewControllerWrapper>) -> UIViewController {
        guard let controller = controller else {
            return UIViewController()
        }
        return controller
    }
    
    func updateUIViewController(_ uiviewController:
                                UIViewController, context: UIViewControllerRepresentableContext<ViewControllerWrapper>) {
        
    }
}
