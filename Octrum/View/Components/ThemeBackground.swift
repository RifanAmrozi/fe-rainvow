//
//  ThemeBackground.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 03/11/25.
//

import SwiftUI

func themeBackground() -> LinearGradient {
    return LinearGradient(
        gradient: Gradient(colors: [.white, .white, .gray.opacity(0.2)]),
        startPoint: .top,
        endPoint: .bottom
    )
}
