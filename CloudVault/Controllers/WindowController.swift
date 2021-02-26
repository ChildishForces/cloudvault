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
  var popoverController: PopoverViewController?
  var sidebarController: SidebarController?

  @IBOutlet var sortMenu: NSMenu?

  override func windowDidLoad() {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    guard let popoverController = storyboard.instantiateController(
      withIdentifier: "popoverController"
    ) as? PopoverViewController else { return }

    self.popoverController = popoverController
    popover = NSPopover()
    popover?.contentViewController = popoverController
    popover?.contentSize = popoverController.view.frame.size

    popover?.behavior = .semitransient
    popover?.animates = true
  }

  @IBAction func openPopover(_ sender: AnyObject) {
    if popover == nil { return }
    popover!.isShown
      ? closePopover(sender)
      // swiftlint:disable:next force_cast
      : popover!.show(relativeTo: sender.bounds, of: sender as! NSView, preferredEdge: .maxX)
  }

  func closePopover(_ sender: AnyObject) {
    popover!.close()
  }

  // Sort Menu
  @IBAction func openSortMenu(_ sender: NSButton) {
    let location = NSPoint(x: 0, y: sender.frame.height + 5)
    sortMenu!.popUp(positioning: nil, at: location, in: sender)
  }

  @IBAction func sortByNameAscending(_ sender: NSMenuItem) {
    print(sender)
  }

  @IBAction func sortByNameDescending(_ sender: NSMenuItem) {
    print(sender)
  }

  @IBAction func sortByDateAscending(_ sender: NSMenuItem) {
    print(sender)
  }

  @IBAction func sortByDateDescending(_ sender: NSMenuItem) {
    print(sender)
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
