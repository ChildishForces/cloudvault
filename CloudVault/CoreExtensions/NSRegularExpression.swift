//
//  NSRegularExpression.swift
//  CloudVault
//
//  Created by Chris Schofield on 20/02/2021.
//

import Foundation
import AppKit

extension NSRegularExpression {
  /**
  Convenience method for testing strings against regular expressions
  */
  func hasMatch(_ string: String) -> Bool {
    let range = NSRange(location: 0, length: string.utf16.count)
    return firstMatch(in: string, options: [], range: range) != nil
  }
}
