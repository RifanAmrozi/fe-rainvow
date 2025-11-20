//
//  CustomAlert.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 20/11/25.
//

import SwiftUI

struct CustomAlert: View {
    let title: String
    let message: String
    let isSuccess: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 16) {
                Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(isSuccess ? .green : .red)
                
                Text(message)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
            )
            .padding(16)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: true)
        .onTapGesture {
            onDismiss()
        }
    }
}

struct CustomAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let isSuccess: Bool
    let onDismiss: (() -> Void)?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                CustomAlert(
                    title: title,
                    message: message,
                    isSuccess: isSuccess,
                    onDismiss: {
                        isPresented = false
                        onDismiss?()
                    }
                )
                .zIndex(999)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
                        if isPresented {
                            withAnimation {
                                isPresented = false
                            }
                            onDismiss?()
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func customAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        isSuccess: Bool,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self.modifier(
            CustomAlertModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                isSuccess: isSuccess,
                onDismiss: onDismiss
            )
        )
    }
}

struct CustomAlert_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Background Content")
        }
        .overlay(
            CustomAlert(
                title: "Success!",
                message: "Camera added successfully!",
                isSuccess: true,
                onDismiss: {}
            )
        )
    }
}
