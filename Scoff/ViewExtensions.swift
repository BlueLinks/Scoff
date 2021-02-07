//
//  ViewExtensions.swift
//  Scoff
//
//  Created by Scott Brown on 29/01/2021.
//

import SwiftUI


struct formButtonStyle: ButtonStyle {
 
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(40)
            .padding(.horizontal, 20)
    }
}

struct blueButton : ViewModifier {
    func body(content: Content) -> some View {
        content.font(.title)
            .padding()
            .background(Color.blue)
            .clipShape(Capsule())
            .foregroundColor(.white)
    }
}

struct blueButtonStyle : ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .blueButtonStyle()
    }
}
extension View {
    func blueButtonStyle() -> some View {
        self.modifier(blueButton())
    }
}
