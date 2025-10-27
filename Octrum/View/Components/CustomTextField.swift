//
//  CustomTextField.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 24/10/25.
//

import SwiftUI

struct CustomTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isDisabled: Bool = false
    var isSecure: Bool = false
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
            
            Spacer().frame(height: 4)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .disabled(isDisabled)
            } else {
                TextField(placeholder, text: $text)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .textInputAutocapitalization(autocapitalization)
                    .disabled(isDisabled)
            }
        }
    }
}
