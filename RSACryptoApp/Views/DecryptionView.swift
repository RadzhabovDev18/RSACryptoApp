//
//  DecryptionView.swift
//  RSACryptoApp
//
//  Created by radjabb on 4/14/25.
//

import SwiftUI

struct DecryptionView: View {
    @State private var encryptedText = ""
    @State private var decryptedText = ""
    @State private var status = ""
    @State private var selectedPrivateKeyTag = ""
    @State private var availablePrivateKeys: [String] = []
    
    private let crypto = RSACrypto()
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Расшифровка")
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.primary)
                .padding(.top, 12)
            
            // Form-like container
            VStack {
                // Private Key Picker
                Picker("Приватный ключ:", selection: $selectedPrivateKeyTag) {
                    Text("Выберите ключ").tag("")
                    ForEach(availablePrivateKeys.filter { $0.contains("private") }, id: \.self) { tag in
                        Text(tag).tag(tag)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .onAppear {
                    availablePrivateKeys = crypto.fetchKeys()
                }
                
                // Input TextField
                TextField("Введите зашифрованный текст", text: $encryptedText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .frame(minWidth: 400, minHeight: 60)
                    .padding(.horizontal)
                
                // Decrypt Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        guard !selectedPrivateKeyTag.isEmpty else {
                            status = "Ошибка: выберите приватный ключ"
                            return
                        }
                        guard !encryptedText.isEmpty else {
                            status = "Ошибка: введите зашифрованный текст"
                            return
                        }
                        do {
                            guard let encryptedData = Data(base64Encoded: encryptedText) else {
                                status = "Ошибка: неверный формат зашифрованного текста"
                                return
                            }
                            let decryptedData = try crypto.decrypt(data: encryptedData, withPrivateKey: selectedPrivateKeyTag)
                            decryptedText = String(data: decryptedData, encoding: .utf8) ?? ""
                            status = "Done!"
                        } catch {
                            status = "Ошибка расшифровки: \(error)"
                        }
                    }
                }) {
                    Text("Расшифровать")
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
                .padding(.horizontal)
                
                // Decrypted Text Output
                VStack(alignment: .leading, spacing: 4) {
                    Text("Расшифрованный текст:")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(decryptedText.isEmpty ? "Нет данных" : decryptedText)
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
                .padding(.horizontal)
                
                // Status Message
                if !status.isEmpty {
                    Text(status)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(status.contains("Ошибка") ? .red : .green)
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
        .frame(minWidth: 450, minHeight: 300)
    }
}

struct DecryptionView_Previews: PreviewProvider {
    static var previews: some View {
        DecryptionView()
    }
}
