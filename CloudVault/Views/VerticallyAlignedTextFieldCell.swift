//
//  VerticallyAlignedTextFieldCell.swift
//  CloudVault
//
//  Created by Chris Schofield on 24/01/2021.
//

import Foundation
import AppKit

class VerticallyAlignedTextFieldCell: NSTextFieldCell {
  override func drawingRect(forBounds rect: NSRect) -> NSRect {
    let newRect = NSRect(x: 0, y: (rect.size.height - 22) / 2, width: rect.size.width, height: 22)
    return super.drawingRect(forBounds: newRect)
  }
}
