//
//  ColorIndicatorButton.swift
//  CloudVault
//
//  Created by Chris Schofield on 28/02/2021.
//

import Foundation
import AppKit

/**
  Custom view for displaying tag colors. Similar to indicator NSImages provided by Apple, but can be any color.
*/
class ColorIndicatorButton: NSView {
  override var acceptsFirstResponder: Bool {
    get { true }
  }

  var color: NSColor? = .clear {
    didSet(value) { draw(self.bounds) }
  }

  open override var focusRingMaskBounds: NSRect {
    return self.window?.firstResponder == self ? self.bounds : .zero
  }

  open override func drawFocusRingMask() {
    guard window?.firstResponder == self else { return }
    layer!.render(in: NSGraphicsContext.current!.cgContext)
  }

  override func draw(_ dirtyRect: NSRect) {
    layer = CALayer()

    // Indicator Shape
    let indicatorShape = CAShapeLayer()
    indicatorShape.path = NSBezierPath(ovalIn: dirtyRect).cgPath
    indicatorShape.fillColor = color!.cgColor
    layer?.addSublayer(indicatorShape)

    // Indicator Stroke Shape
    let indicatorStrokeShape = CAShapeLayer()
    indicatorStrokeShape.path = NSBezierPath(ovalIn: NSRect(
      x: 0.5,
      y: 0.5,
      width: CGFloat(dirtyRect.maxX - 1),
      height: CGFloat(dirtyRect.maxY - 1)
    )).cgPath
    indicatorStrokeShape.fillColor = .clear
    indicatorStrokeShape.strokeColor = NSColor(red: 1, green: 1, blue: 1, alpha: 0.25).cgColor
    indicatorStrokeShape.lineWidth = 0.5
    layer?.addSublayer(indicatorStrokeShape)
  }
}
