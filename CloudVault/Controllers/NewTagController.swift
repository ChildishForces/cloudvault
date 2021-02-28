//
//  NewTagController.swift
//  CloudVault
//
//  Created by Chris Schofield on 28/02/2021.
//

import Foundation
import AppKit
import DynamicColor

class NewTagController: NSViewController {
  var colorPicker: NSColorPanel?
  var color = DynamicColor(hexString: "#fff") {
    didSet { indicator?.color = color }
  }
  @IBOutlet var indicator: ColorIndicatorButton?

  override func viewDidAppear() {
    NSColorPanel.setPickerMask(.wheelModeMask)
    colorPicker = NSColorPanel()
    indicator?.color = color
  }

  override func viewWillDisappear() {
    colorPicker?.setTarget(nil)
    colorPicker?.isContinuous = false
    colorPicker?.close()
  }

  @objc func changeColor(_ panel: NSColorPanel) {
    color = panel.color
  }

  @IBAction func displayColorPanel(_ sender: AnyObject) {
    colorPicker?.setAction(#selector(changeColor(_:)))
    colorPicker?.setTarget(self)
    colorPicker?.makeKeyAndOrderFront(self)
    colorPicker?.isContinuous = true
    colorPicker?.color = color
  }
}
