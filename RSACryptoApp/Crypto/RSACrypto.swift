//
//  RSACrypto.swift
//  RSACryptoApp
//
//  Created by radjabb on 4/14/25.
//

import Foundation
import Security

enum CryptoError: Error {
    case keyGenerationFailed
    case keyStorageFailed
    case keyRetrievalFailed
    case encryptionFailed
    case decryptionFailed
}

class RSACrypto {
    
    // MARK: Генерация ключей
    func generateKeys() throws -> (publicKey: SecKey, privateKey: SecKey) {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecAttrIsPermanent as String: false
        ]
        var error: Unmanaged<CFError>? // Передает словарь атрибутов и ссылку на переменную для ошибки
        
        // Обработка ошибок
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Ошибка генерации приватного ключа: \(error!.takeRetainedValue())")
            throw CryptoError.keyGenerationFailed
        }
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            print("Не удалось извлечь публичный ключ из приватного")
            throw CryptoError.keyGenerationFailed
        }
        print("Ключи успешно сгенерированы: приватный ключ - \(privateKey), публичный ключ - \(publicKey)")
        return (publicKey, privateKey)
    }
    
    // MARK: Сохранение ключа в Keychain
    func saveKey(_ key: SecKey, tag: String) throws {
        
        // Проверяет, что переданный ключ не nil
        guard key != nil else {
            print("Ключ с тегом \(tag) является nil")
            throw CryptoError.keyStorageFailed
        }
        
        
        /* Формируется запрос (checkQuery) для SecItemCopyMatching,
            чтобы проверить, существует ли уже ключ с таким тегом (kSecAttrApplicationTag). */
        let checkQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecReturnRef as String: true
        ]
        
        var item: CFTypeRef?
        let checkStatus = SecItemCopyMatching(checkQuery as CFDictionary, &item)
        if checkStatus == errSecSuccess {
            print("Ключ с тегом \(tag) уже существует")
        } else if checkStatus == errSecItemNotFound {
            print("Ключ с тегом \(tag) не найден")
        } else {
            print("Ошибка проверки ключа: \(checkStatus)")
        }
        
        /* Формирует запрос (deleteQuery) для SecItemDelete, чтобы удалить любой существующий ключ с таким же тегом. */
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Выполняет удаление с помощью SecItemDelete. Логирует результат.
        let deleteStatus = SecItemDelete(deleteQuery as CFDictionary)
        if deleteStatus != errSecSuccess && deleteStatus != errSecItemNotFound {
            print("Ошибка удаления ключа: \(deleteStatus)")
        } else {
            print("Удаление ключа с тегом \(tag) выполнено: \(deleteStatus)")
        }
        
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA, // тип ключа
            kSecValueRef as String: key, // сам ключ SecKey
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock, // ключ доступен после первой разблокировки устройства
            kSecAttrIsPermanent as String: true, // ключ сохраняется в Keychain
            kSecAttrComment as String: tag, // метаданные (коментарий)
            kSecAttrLabel as String: tag
        ]
        
        // Вызывается SecItemAdd для сохранения ключа в Keychain.
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Ошибка сохранения ключа: \(status)")
            throw CryptoError.keyStorageFailed
        }
        print("Ключ с тегом \(tag) успешно сохранён")
    }
    
    // MARK: Загрузка ключа из Keychain
    
    // Загружает ключ (SecKey) из Keychain по его тегу.
    
    
    func loadKey(tag: String) throws -> SecKey {
        
        /* Формируется запрос для SecItemCopyMatching,
            ищет элемент класса kSecClassKey, с указанным kSecAttrApplicationTag (тег, преобразованный в Data), типа kSecAttrKeyTypeRSA,
            указывает, что нужно вернуть саму ссылку на ключ (kSecReturnRef = true)
         */
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecReturnRef as String: true
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            print("Ошибка загрузки ключа с тегом \(tag): \(status)")
            throw CryptoError.keyRetrievalFailed
        }
        let key = item as! SecKey
        return key
    }
    
    // MARK: Получение списка ключей из Keychain
    
    /* Формирует запрос (query) для SecItemCopyMatching:
     ищет все (kSecMatchLimitAll) элементы класса kSecClassKey типа kSecAttrKeyTypeRSA.
     Указывает, что нужно вернуть атрибуты (kSecReturnAttributes = true), а не сами ключи.
     */
    func fetchKeys() -> [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true
        ]
        var item: CFTypeRef?
        
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let items = item as? [[String: Any]] else {
            print("Ошибка получения ключей: \(status)")
            return []
        }
        
        var tags: [String] = []
        for keyItem in items {
            if let tagData = keyItem[kSecAttrApplicationTag as String] as? Data,
               let tag = String(data: tagData, encoding: .utf8) {
                tags.append(tag)
            }
        }
        return tags
    }
    
    // MARK: Шифрование данных публичным ключом
    func encrypt(data: Data, withPublicKey publicKeyTag: String) throws -> Data {
        let publicKey = try loadKey(tag: publicKeyTag) // Загружает публичный ключ из Keychain с помощью loadKey
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, .rsaEncryptionOAEPSHA256) else { // проверяет, поддерживает ли загруженный публичный ключ алгоритм шифрования
            print("Публичный ключ не поддерживает шифрование RSA-OAEP-SHA256")
            throw CryptoError.encryptionFailed
        }
        
        var error: Unmanaged<CFError>?
        
        // передаётся публичный ключ, алгоритм (.rsaEncryptionOAEPSHA256), данные для шифрования (CFData) и ссылку на переменную для ошибки.
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey,
                                                            .rsaEncryptionOAEPSHA256,
                                                            data as CFData,
                                                            &error) as Data? else {
            print("Ошибка шифрования: \(error!.takeRetainedValue())")
            throw CryptoError.encryptionFailed
        }
        return encryptedData // Возвращает зашифрованные данные (Data)
    }
    
    // MARK: Расшифровка данных приватным ключом
    func decrypt(data: Data, withPrivateKey privateKeyTag: String) throws -> Data {
        let privateKey = try loadKey(tag: privateKeyTag) // Загружает приватный ключ из Keychain
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, .rsaEncryptionOAEPSHA256) else {
            print("Приватный ключ не поддерживает расшифровку RSA-OAEP-SHA256")
            throw CryptoError.decryptionFailed
        }
        
        var error: Unmanaged<CFError>?
        
        // Вызывает SecKeyCreateDecryptedData, передавая приватный ключ, алгоритм (.rsaEncryptionOAEPSHA256), зашифрованные данные (как CFData) и ссылку на переменную для ошибки.
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey,
                                                            .rsaEncryptionOAEPSHA256,
                                                            data as CFData,
                                                            &error) as Data? else {
            print("Ошибка расшифровки: \(error!.takeRetainedValue())")
            throw CryptoError.decryptionFailed
        }
        return decryptedData
    }
}
