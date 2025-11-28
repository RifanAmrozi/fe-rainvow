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
    var isEditable: Bool = true
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer().frame(height: 4)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.darkGray)
                        .padding(.leading, 8)
                }
                
                HStack {
                    if isSecure {
                        SecureField("", text: $text)
                            .disabled(isDisabled || !isEditable)
                            .foregroundColor(.black)
                    } else {
                        TextField("", text: $text)
                            .textInputAutocapitalization(autocapitalization)
                            .disabled(isDisabled || !isEditable)
                            .foregroundColor(.black)
                    }
                    
                    if isDisabled || !isEditable {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                            .padding(.trailing, 4)
                    }
                }
                .padding(8)
            }
            .background(
                (isDisabled || !isEditable)
                ? Color.gray.opacity(0.15)
                : Color.gray.opacity(0.1)
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        (isDisabled || !isEditable)
                        ? Color.gray.opacity(0.6)
                        : Color.gray.opacity(0.4),
                        lineWidth: 1
                    )
            )
        }
    }
}
