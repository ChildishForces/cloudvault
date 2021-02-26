//
//  CustomTableRow.swift
//  CloudVault
//
//  Created by Chris Schofield on 24/02/2021.
//

import Foundation
import AppKit

class CustomTableRowView: NSTableRowView {
  override var isEmphasized: Bool {
    get { return false }
    // swiftlint:disable:next unused_setter_value
    set {}
  }
}
