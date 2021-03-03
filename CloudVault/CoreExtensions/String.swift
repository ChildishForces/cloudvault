//
//  String.swift
//  CloudVault
//
//  Created by Chris Schofield on 03/03/2021.
//

import Foundation

fileprivate let badChars = CharacterSet.alphanumerics.inverted

extension String {
  var withoutSpecialCharacters: String {
    return self.components(separatedBy: CharacterSet.symbols).joined(separator: "")
  }

  var uppercasingFirst: String {
    return prefix(1).uppercased() + dropFirst()
  }

  var lowercasingFirst: String {
    return prefix(1).lowercased() + dropFirst()
  }

  func substring(_ nsrange: NSRange) -> Substring? {
    guard let range = Range(nsrange, in: self) else { return nil }
    return self[range]
  }

  func matchString(_ regex: String) -> String? {
    if let range = self.range(of: regex, options: .regularExpression) {
      return String(self[range])
    }
    return nil
  }

  var camelCase: String {
    guard !isEmpty else { return "" }

    let parts = components(separatedBy: badChars)
    let first = String(describing: parts.first!).lowercasingFirst
    let rest = parts.dropFirst().map({String($0).uppercasingFirst})

    return ([first] + rest).joined(separator: "")
  }

  var snakeCase: String {
    guard !isEmpty else { return "" }
    return components(separatedBy: badChars)
      .map { $0.lowercased() }
      .joined(separator: "_")
  }

  var afterSlash: String? {
    if let slash = self.firstIndex(of: "/") {
      return String(self[self.index(after: slash)..<self.endIndex])
    }
    return nil
  }

  func searchMatch(_ matchString: String) -> Bool {
    return self.lowercased().matchString(matchString.lowercased()) != nil
  }
}
