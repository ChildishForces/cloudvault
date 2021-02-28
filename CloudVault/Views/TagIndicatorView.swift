//
//  TagIndicatorView.swift
//  CloudVault
//
//  Created by Chris Schofield on 27/02/2021.
//

import Foundation
import AppKit

/**
  Custom view for displaying tag colors. Similar to indicator NSImages provided by Apple, but can be any color.
*/
class TagIndicatorView: NSView {
  var color: NSColor? = .clear {
    didSet(value) { draw(self.bounds) }
  }

  override func draw(_ dirtyRect: NSRect) {
    layer = CALayer()
    let size = 10

    // Indicator Shape
    let indicatorShape = CAShapeLayer()
    indicatorShape.path = NSBezierPath(
      ovalIn: NSRect(
        x: Int(dirtyRect.midX) - (size / 2),
        y: Int(dirtyRect.midY) - (size / 2),
        width: size,
        height: size
      )
    ).cgPath
    indicatorShape.fillColor = color!.cgColor
    layer?.addSublayer(indicatorShape)
  }
}
