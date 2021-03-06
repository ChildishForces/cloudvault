//
//  KeychainUtility.swift
//  CloudVault
//
//  Created by Chris Schofield on 23/02/2021.
//

import Foundation
import CryptoKit
import KeychainSwift

/**
Class for interacting with securely stored strings in Keychain
*/
class KeychainUtility: NSObject {
  static let shared = KeychainUtility()
  var keychain: KeychainSwift
  var privateKey: String?

  override init() {
    keychain = KeychainSwift(keyPrefix: Bundle.main.bundleIdentifier! + ".")
  }

  private func generateSecureKey() -> String {
    let privateKey = Curve25519.Signing.PrivateKey()
    return privateKey.rawRepresentation.base64EncodedString()
  }

  public func createOrRetrievePrivateKey() -> String {
    var key = keychain.get("vault-key")
    guard key == nil else {
      privateKey = key!
      return key!
    }
    key = generateSecureKey()
    keychain.set(key!, forKey: "vault-key", withAccess: .accessibleAfterFirstUnlock)
    return key!
  }

  public func setPassword(_ value: String) {
    do { try keychain.set(encrypt(value), forKey: "vault-password") }
    catch { print(error) }
  }

  public func checkPassword(_ value: String) -> Bool {
    let passHash = try? encrypt(value);
    let storedPass = keychain.get("vault-password")
    return passHash == storedPass
  }

  private func getSymetric(_ key: String) -> SymmetricKey {
    let hash = SHA256.hash(data: key.data(using: .utf8)!)
    let hashString = hash.map { String(format: "%02hhx", $0) }.joined()
    let subString = String(hashString.prefix(32))
    let keyData = subString.data(using: .utf8)!
    return SymmetricKey(data: keyData)
  }

  private func encrypt(_ value: String) throws -> String {
    if privateKey == nil { return "NO PRIVATE KEY" }
    let valueData = value.data(using: .utf8)
    let encryptedData = try ChaChaPoly.seal(valueData!, using: getSymetric(privateKey!))
    return encryptedData.combined.base64EncodedString()
  }

  private func decrypt(_ value: String) throws -> String {
    if privateKey == nil { return "NO PRIVATE KEY" }
    let data = Data(base64Encoded: value)!
    let box = try ChaChaPoly.SealedBox(combined: data)
    let decryptedData = try ChaChaPoly.open(box, using: getSymetric(privateKey!))
    return String(decoding: decryptedData, as: UTF8.self)
  }
}
