//
//  Color+custom.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/13/24.
//

import SwiftUI

extension Color {
    static func color(hex: String) -> Color {
        var cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cleanedHex.hasPrefix("#") {
            cleanedHex.removeFirst()
        }
        
        guard cleanedHex.count == 6 else {
            return Color.gray // Return a default color if the hex code is not valid
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        return Color(red: red, green: green, blue: blue)
    }
    
    static let brown1: Color = Color(red: 95/255, green: 63/255, blue: 22/255)
    static let brown2: Color = Color(red: 118/255, green: 86/255, blue: 45/255)
    static let brown3: Color = Color(red: 141/255, green: 109/255, blue: 69/255)
    static let brown4: Color = Color(red: 164/255, green: 132/255, blue: 92/255)
    static let brown5: Color = Color(red: 186/255, green: 155/255, blue: 115/255)
    static let brown6: Color = Color(red: 209/255, green: 178/255, blue: 138/255)
    static let brown7: Color = Color(red: 232/255, green: 201/255, blue: 162/255)
    static let brownColors: [Color] = [Color.brown1, Color.brown2, Color.brown3, Color.brown4, Color.brown5, Color.brown6, Color.brown7]
    
    static let customGray1: Color = Color("customGray1")
    static let dynamicWhite: Color = Color("dynamicWhite")
    static let dynamicBlack: Color = Color("dynamicBlack")
    
//    static let brown1: Color = color(hex: "#5f3f16")
//    static let brown2: Color = color(hex: "#68481f")
//    static let brown3: Color = color(hex: "#715129")
//    static let brown4: Color = color(hex: "#7b5b32")
//    static let brown5: Color = color(hex: "#84643c")
//    static let brown6: Color = color(hex: "#8d6d45")
//    static let brown7: Color = color(hex: "#96764e")
//    static let brown8: Color = color(hex: "#9f7f57")
//    static let brown9: Color = color(hex: "#a88961")
//    static let brown10: Color = color(hex: "#b1926a")
//    static let brown11: Color = color(hex: "#ba9b73")
//    static let brown12: Color = color(hex: "#c3a47c")
//    static let brown13: Color = color(hex: "#ccad86")
//    static let brown14: Color = color(hex: "#d6b78f")
//    static let brown15: Color = color(hex: "#dfc099")
//    static let brown16: Color = color(hex: "#e8c9a2")
//    static let brown17: Color = color(hex: "#ebd1b1")
//    static let brown18: Color = color(hex: "#eed9c0")
//    static let brown19: Color = color(hex: "#f0e0cf")
//    static let brown20: Color = color(hex: "#f3e8de")
//    static let brown21: Color = color(hex: "#f6f0ed")
}
