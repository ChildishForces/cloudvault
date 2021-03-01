//
//  WindowController.swift
//  CloudVault
//
//  Created by Chris Schofield on 18/02/2021.
//

import Foundation
import AppKit
import LocalAuthentication

/**
  Main NSWindowController class
*/
class WindowController: NSWindowController {
  var popover: NSPopover?
  var newTagPopover: NSPopover?
  var popoverController: PopoverViewController?
  var sidebarController: SidebarController?
  var newTagController: NewTagController?

  @IBOutlet var sortMenu: NSMenu?

  override func windowDidLoad() {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)

    // Initialise Popovers

    guard let popoverController = storyboard.instantiateController(
      withIdentifier: "popoverController"
    ) as? PopoverViewController else { return }

    self.popoverController = popoverController
    popover = NSPopover()
    popover?.contentViewController = popoverController
    popover?.contentSize = popoverController.view.frame.size

    popover?.behavior = .semitransient
    popover?.animates = true


    guard let newTagController = storyboard.instantiateController(
      withIdentifier: "newTagController"
    ) as? NewTagController else { return }

    self.newTagController = newTagController
    newTagPopover = NSPopover()
    newTagPopover?.contentViewController = newTagController
    newTagPopover?.contentSize = newTagController.view.frame.size

    newTagPopover?.behavior = .semitransient
    newTagPopover?.animates = true

    // Menu Configuration
    sortMenu?.item(at: 0)?.state = .on
  }

  @IBAction func openPopover(_ sender: AnyObject) {
    if popover == nil { return }
    popover!.isShown
      ? closePopover(sender)
      // swiftlint:disable:next force_cast
      : popover!.show(relativeTo: sender.bounds, of: sender as! NSView, preferredEdge: .maxX)
  }

  @IBAction func openNewTagPopover(_ sender: AnyObject) {
    if newTagPopover == nil { return }
    newTagPopover!.isShown
      ? closeNewTagPopover(sender)
      // swiftlint:disable:next force_cast
      : newTagPopover!.show(relativeTo: sender.bounds, of: sender as! NSView, preferredEdge: .maxY)
  }

  func closePopover(_ sender: AnyObject) {
    popover!.close()
  }

  func closeNewTagPopover(_ sender: AnyObject) {
    newTagPopover!.close()
  }

  // Sort Menu
  @IBAction func openSortMenu(_ sender: NSButton) {
    let location = NSPoint(x: 0, y: sender.frame.height + 5)
    sortMenu!.popUp(positioning: nil, at: location, in: sender)
  }

  @IBAction func sortByDateAscending(_ sender: NSMenuItem) {
    print(sender)
    setMenuActiveItem(0)
  }

  @IBAction func sortByDateDescending(_ sender: NSMenuItem) {
    print(sender)
    setMenuActiveItem(1)
  }

  @IBAction func sortByNameAscending(_ sender: NSMenuItem) {
    print(sender)
    setMenuActiveItem(2)
  }

  @IBAction func sortByNameDescending(_ sender: NSMenuItem) {
    print(sender)
    setMenuActiveItem(3)
  }

  func setMenuActiveItem(_ index: Int) {
    sortMenu?.items.forEach { $0.state = .off }
    sortMenu?.item(at: index)?.state = .on
  }

  // Authenticate
  @IBAction func authenticateUser(_ sender: AnyObject) {
    let context = LAContext()
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
      let alert = NSAlert()
      alert.messageText = "Touch ID not available!"
      alert.informativeText = "Your device is not configured for Touch ID."
      alert.addButton(withTitle: "Okay")
      alert.runModal()
      return
    }

    let reason = "decrypt your cloud profiles"
    context.evaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics,
      localizedReason: reason
    ) { success, authenticationError in
      DispatchQueue.main.async {
        if success {
          print("Authenticated!")
          return
        }
        guard let error = authenticationError as? LAError else { return }

        if error.errorCode == -3 {
          print("fallback password!")
        }

        //                print(String(describing: authenticationError));
        //                let alert = NSAlert();
        //                alert.messageText = "Authentication failed!"
        //                alert.informativeText = "We are sorry but we cannot allow you access to the vault!"
        //                alert.addButton(withTitle: "Okay")
        //                alert.runModal()
      }
    }
  }
}
