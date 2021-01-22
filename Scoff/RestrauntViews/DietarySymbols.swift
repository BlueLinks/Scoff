//
//  DietarySymbols.swift
//  Scoff
//
//  Created by Scott Brown on 22/01/2021.
//

import Foundation
import SwiftUI

struct vegetarianSymbol : View {
    var body: some View {
        //        ZStack {
        //            Circle()
        //                .fill(Color.green)
        //                .frame(width: 30)
        //
        //            Text("VEG")
        //                .foregroundColor(.white)
        //        }
        Text("VEG")
            .font(.caption)
            .foregroundColor(.white)
            .frame(width: 30, height: 30, alignment: .center)
            .background(Circle()
                            .fill(Color.green)
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

struct dietaryItemSymbolsView : View {
    var item : itemRaw
    
    var body : some View {
        HStack{
            if item.vegetarian {
                vegetarianSymbol()
            }
            if item.vegan {
                veganSymbol()
            }
            if item.gluten {
                glutenFreeSymbol()
            }
        }
    }
}

struct dietaryExtraSymbolsView : View {
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

