//
//  KeyGenerationView.swift
//  RSACryptoApp
//
//  Created by radjabb on 4/14/25.
//

import SwiftUI

struct KeyGenerationView: View {
    @State private var status = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Генерация ключей")
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.primary)
                .padding(.top, 12)
            
            Form {
                Text("Создать пару публичного и приватного ключей для использования в шифровании и дешифровании. \n Ключи будут сохранены в Keychain.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                
                // Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        do {
                            let crypto = RSACrypto()
                            let (publicKey, privateKey) = try crypto.generateKeys()
                            try crypto.saveKey(publicKey, tag: "com.example.rsa.public")
                            try crypto.saveKey(privateKey, tag: "com.example.rsa.private")
                            status = "Ключи сгенерированы и сохранены!"
                        } catch {
                            status = "Ошибка: \(error)"
                        }
                    }}) {
                    Text("Сгенерировать ключи")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity, alignment: .center)
                
                // Status
                if !status.isEmpty {
                    Text(status)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(status.contains("Ключи сгенерированы и сохранены!") ? .green : .red)
                        .padding(.top, 4)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(
                Color(NSColor.windowBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .frame(minWidth: 400, minHeight: 200)
    }
}

struct KeyGenerationView_Previews: PreviewProvider {
    static var previews: some View {
        KeyGenerationView()
    }
}
