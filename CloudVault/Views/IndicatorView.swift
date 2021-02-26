//
//  IndicatorView.swift
//  CloudVault
//
//  Created by Chris Schofield on 24/01/2021.
//

import Foundation
import AppKit

enum IndicatorStatus {
  case waiting
  case success
  case failure
}

func getColor(_ status: IndicatorStatus) -> CGColor {
  switch status {
  case .waiting: return CGColor.init(red: 1, green: 0.5, blue: 0, alpha: 1)
  case .success: return CGColor.init(red: 0, green: 1, blue: 0.5, alpha: 1)
  case .failure: return CGColor.init(red: 1, green: 0.25, blue: 0.25, alpha: 1)
  }
}

/**
  Custom view for displaying statuses. Similar to indicator NSImages provided by Apple, but can be any color.
*/
class IndicatorView: NSView {
  var status: IndicatorStatus = .waiting {
    didSet(value) { draw(self.bounds) }
  }

  override func draw(_ dirtyRect: NSRect) {
    layer = CALayer()

    // Indicator Shape
    let indicatorShape = CAShapeLayer()
    indicatorShape.path = NSBezierPath(ovalIn: dirtyRect).cgPath
    indicatorShape.fillColor = getColor(status)

    // Indicator Stroke Shape
    let indicatorShapeStroke = CAShapeLayer()
    indicatorShapeStroke.fillColor = .clear
    indicatorShapeStroke.path = NSBezierPath(
      ovalIn: CGRect.init(x: 0.5, y: 0.5, width: dirtyRect.width - 1, height: dirtyRect.height - 1)
    ).cgPath
    indicatorShapeStroke.lineWidth = 0.5
    indicatorShapeStroke.strokeColor = CGColor.init(red: 1, green: 1, blue: 1, alpha: 0.25)

    // Compose
    layer?.addSublayer(indicatorShape)
    layer?.addSublayer(indicatorShapeStroke)
  }
}
