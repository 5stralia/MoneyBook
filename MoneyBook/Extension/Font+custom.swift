//
//  Font+custom.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/9/24.
//

import SwiftUI

enum PretendardWeight {
    case black
    case bold
    case extraBold
    case ExtraLight
    case light
    case medium
    case regular
    case semiBold
    case thin

    var fontName: String {
        let prefix = "Pretendard-"

        switch self {
        case .ExtraLight: return "\(prefix)ExtraLight"
        case .black: return "\(prefix)Black"
        case .bold: return "\(prefix)Bold"
        case .extraBold: return "\(prefix)extraBold"
        case .light: return "\(prefix)Light"
        case .medium: return "\(prefix)Medium"
        case .regular: return "\(prefix)Regular"
        case .semiBold: return "\(prefix)SemiBold"
        case .thin: return "\(prefix)Thin"
        }
    }
}
extension Font {
    static func Pretendard(size: CGFloat, weight: PretendardWeight = .regular) -> Font {
        Font.custom(weight.fontName, size: size)
    }
}
