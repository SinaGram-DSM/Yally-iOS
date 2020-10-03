//
//  TokenUtils.swift
//  Yally
//
//  Created by 이가영 on 2020/10/03.
//

import Foundation
import Alamofire
import Security

final class TokenUtils {
    private let account = "Service"
    private let service = Bundle.main.bundleIdentifier

    private lazy var query: [CFString: Any]? = {
        guard let service = self.service else { return nil }
        return [kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account]
    }()

    func createUser(_ user: User) -> Bool {
        guard let data = try? JSONEncoder().encode(user),
              let service = self.service else { return false }

        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrService: service,
                     kSecAttrAccount: account,
                     kSecAttrGeneric: data] as [CFString : Any]

        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)

        return status == noErr
    }

    func readUser() -> User? {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                        kSecAttrService: "서비스",
                                        kSecAttrAccount: "계정",
                                        kSecMatchLimit: kSecMatchLimitOne,
                                        kSecReturnAttributes: true,
                                        kSecReturnData: true]
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) != errSecSuccess { return nil }

        guard let existingItem = item as? [CFString: Any],
              let data = existingItem[kSecAttrGeneric] as? Data,
              let user = try? JSONDecoder().decode(User.self, from: data) else { return nil }

        return user
    }

    func updateUser(_ user: User) -> Bool {
      guard let data = try? JSONEncoder().encode(user) else { return false }

      let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                    kSecAttrService: "서비스",
                                    kSecAttrAccount: "계정"]
      let attributes: [CFString: Any] = [kSecAttrAccount: "계정",
                                         kSecAttrGeneric: data]

      return SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == errSecSuccess
    }

    func deleteUser() -> Bool {
        guard let query = self.query else { return false }

        return SecItemDelete(query as [String: Any] as CFDictionary) == noErr
    }

}
