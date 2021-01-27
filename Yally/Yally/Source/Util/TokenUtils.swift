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

    static let shared = TokenUtils()

    private init() { }

    private let account = "Yally"
    private let service = Bundle.main.bundleIdentifier

    private lazy var query: [CFString: Any]? = {
        guard let service = self.service else { return nil }
        return [kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account]
    }()

    //생성
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

    //조회
    func readUser() -> User? {
        guard let service = self.service else { return nil }
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                        kSecAttrService: service,
                                        kSecAttrAccount: account,
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

    //수정
    func updateUser(_ user: User) -> Bool {
        guard let query = self.query, let data = try? JSONEncoder().encode(user) else { return false }

      let attributes: [CFString: Any] = [kSecAttrAccount: account,
                                         kSecAttrGeneric: data]

        return SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == errSecSuccess
    }

    //삭제
    func deleteUser() -> Bool {
        guard let query = self.query else { return false }

        return SecItemDelete(query as [String: Any] as CFDictionary) == noErr
    }

}

struct TokenManager {
    static var currentToken: Token? {
        return TokenUtils.shared.readUser()?.token
    }
}
