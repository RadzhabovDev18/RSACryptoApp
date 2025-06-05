//
//  ContentView.swift
//  RSACryptoApp
//
//  Created by radjabb on 4/14/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedView: String? = "KeyGeneration"
    
    var body: some View {
        NavigationSplitView {
            // боковая панель
            List(selection: $selectedView) {
                NavigationLink(value: "KeyGeneration") {
                    Label("Генерация ключей", systemImage: "key.fill")
                        .foregroundColor(.primary)
                }
                NavigationLink(value: "Encryption") {
                    Label("Шифрование", systemImage: "lock.fill")
                        .foregroundColor(.primary)
                }
                NavigationLink(value: "Decryption") {
                    Label("Расшифровка", systemImage: "lock.open.fill")
                        .foregroundColor(.primary)
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)
        } detail: {
            // представление
            if let selected = selectedView {
                switch selected {
                case "KeyGeneration":
                    KeyGenerationView()
                case "Encryption":
                    EncryptionView()
                case "Decryption":
                    DecryptionView()
                default:
                    Text("Выберите раздел")
                }
            } else {
                Text("Выберите раздел")
            }
        }
        .frame(minWidth: 800, minHeight: 400)

    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
