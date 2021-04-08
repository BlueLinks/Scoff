//
//  DietarySymbols.swift
//  Scoff
//
//  Created by Scott Brown on 22/01/2021.
//

import Foundation
import SwiftUI

// extension used for custom defined colour
extension Color {
    // Used for vegetarian symbol
    static let darkGreen = Color("darkGreen")
}

struct vegetarianSymbol : View {
    var body: some View {
        Text("VEG")
            .font(.caption)
            .foregroundColor(.white)
            .frame(width: 30, height: 30, alignment: .center)
            .background(Circle()
                            .fill(Color.darkGreen)
            )
    }
}

struct veganSymbol : View {
    var body: some View {
        Text("V")
            .foregroundColor(.white)
            .frame(width: 30, height: 30, alignment: .center)
            .background(Circle()
                            .fill(Color.green)
            )
    }
}

struct glutenFreeSymbol : View {
    var body: some View {
        Text("GF")
            .foregroundColor(.white)
            .frame(width: 30, height: 30, alignment: .center)
            .background(Circle()
                            .fill(Color.orange)
            )
    }
}

struct userDietSymbol : View {
    var body: some View {
        Text("ME")
            .foregroundColor(.white)
            .frame(width: 30, height: 30, alignment: .center)
            .background(Circle()
                            .fill(Color.blue)
            )
    }
}

struct dietaryItemSymbolsView : View {
    // View will show dietary symbols given an item
    
    var item : itemRaw
    
    var body : some View {
        HStack{
            if item.vegetarian {
                vegetarianSymbol()
            }
            if item.vegan {
                veganSymbol()
            }
            if !item.gluten {
                glutenFreeSymbol()
            }
        }
    }
}

struct dietaryExtraSymbolsView : View {
    // View will show dietary symbols given an item extra
    var extra : extraRaw
    
    var body : some View {
        HStack{
            if extra.vegetarian {
                vegetarianSymbol()
            }
            if extra.vegan {
                veganSymbol()
            }
            if !extra.gluten {
                glutenFreeSymbol()
            }
        }
    }
}

