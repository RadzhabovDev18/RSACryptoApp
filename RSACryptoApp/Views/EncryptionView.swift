//
//  EncryptionView.swift
//  RSACryptoApp
//
//  Created by radjabb on 4/14/25.
//

import SwiftUI

struct EncryptionView: View {
    @State private var inputText = ""
    @State private var encryptedText = ""
    @State private var status = ""
    @State private var selectedPublicKeyTag = ""
    @State private var availablePublicKeys: [String] = []
    
    private let crypto = RSACrypto()
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Шифрование")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 12)
            
            // Form-like container for inputs
            
            VStack {
                // Public Key
                Picker("Публичный ключ:", selection: $selectedPublicKeyTag) {
                    Text("Выберите ключ").tag("")
                    ForEach(availablePublicKeys.filter { $0.contains("public") }, id: \.self) { tag in
                        Text(tag).tag(tag)
                    }
                }
                .onAppear {
                    availablePublicKeys = crypto.fetchKeys()
                }
                
                // Input TextField
                TextField("Введите текст для шифрования", text: $inputText, axis: .vertical)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .textFieldStyle(.roundedBorder)
                    .frame(minHeight: 60)
                
                // Encrypt Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        guard !selectedPublicKeyTag.isEmpty else {
                            status = "Ошибка: выберите публичный ключ"
                            return
                        }
                        guard !inputText.isEmpty else {
                            status = "Ошибка: введите текст для шифрования"
                            return
                        }
                        do {
                            let data = inputText.data(using: .utf8)!
                            let encryptedData = try crypto.encrypt(data: data, withPublicKey: selectedPublicKeyTag)
                            encryptedText = encryptedData.base64EncodedString()
                            status = "Done!"
                        } catch {
                            status = "Ошибка шифрования: \(error)"
                        }
                    }
                }) {
                    Text("Зашифровать")
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
                
                // Encrypted Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Зашифрованный текст:")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(encryptedText.isEmpty ? "Нет данных" : encryptedText)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(NSColor.textBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                        .contextMenu {
                            Button("Копировать") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(encryptedText, forType: .string)
                            }
                        }
                }
                
                // Status
                if !status.isEmpty {
                    Text(status)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(status.contains("Ошибка") ? .red : .green)
                        .padding(.top, 4)
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
        .frame(minWidth: 400, minHeight: 300)
    }
}

struct EncryptionView_Previews: PreviewProvider {
    static var previews: some View {
        EncryptionView()
    }
}
