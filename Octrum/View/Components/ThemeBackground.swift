//
//  ThemeBackground.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 03/11/25.
//

import SwiftUI

func themeBackground() -> LinearGradient {
    return LinearGradient(
        gradient: Gradient(colors: [.white, .white, Color.gradientGray]),
        startPoint: .top,
        endPoint: .bottom
    )
}
