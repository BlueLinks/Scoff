//
//  SafariView.swift
//  Scoff
//
//  Created by Scott Brown on 22/01/2021.
//
//  Code from https://itnext.io/open-urls-in-your-swiftui-app-and-let-the-user-change-the-browser-b0e6a490238d
//

import SafariServices
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
    var url: URL
        
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let safariView = SFSafariViewController(url: url)
        return safariView
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }
}
