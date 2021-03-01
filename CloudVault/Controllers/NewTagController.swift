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
  @IBOutlet var textField: NSTextField?
  @IBOutlet var createButton: NSButton?
  @IBOutlet var indicator: ColorIndicatorButton?
  var colorPicker: NSColorPanel?
  var color: DynamicColor? {
    didSet {
      indicator?.color = color!
      colorPicker?.color = color!
    }
  }

  override func viewDidAppear() {
    guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
    textField?.delegate = self
    let index = DataManager.shared.tags.items.value.count
    if color == nil { color = DynamicColor(hexString: colorRotator(index)) }
    NSColorPanel.setPickerMask(.wheelModeMask)
    indicator?.color = color
    colorPicker = NSColorPanel()

    DataManager.shared.tags.items.asObservable()
      .subscribe(onNext: { value in
        self.color = DynamicColor(hexString: colorRotator(value.count))
        self.textField?.stringValue = ""
      })
      .disposed(by: delegate.mainDisposeBag)
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
    colorPicker?.color = color!
  }

  @IBAction func createTag(_ sender: AnyObject) {
    guard (textField?.stringValue.isEmpty) != nil else { return }
    do {
      _ = try DataManager.shared.tags.create(
        TagSchema(name: textField!.stringValue, color: (color?.toHexString())!)
      )

      for window in NSApplication.shared.windows {
        guard let windowController = window.windowController as? WindowController else { return }
        windowController.closeNewTagPopover(self)
      }
    } catch { print(error) }
  }
}

extension NewTagController: NSTextFieldDelegate {
  public func controlTextDidChange(_ obj: Notification) {
    guard let field = textField, !field.stringValue.isEmpty else {
      createButton?.isEnabled = false
      return
    }
    createButton?.isEnabled = true
  }
}
