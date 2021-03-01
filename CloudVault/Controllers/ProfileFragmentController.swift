//
//  ProfileFragmentController.swift
//  CloudVault
//
//  Created by Chris Schofield on 21/02/2021.
//

import Foundation
import AppKit

/**
  AWSProfile card on index page controller.
*/
class ProfileFragmentController: NSViewController {
  @IBOutlet var indicatorView: IndicatorView?
  @IBOutlet var profileNameLabel: NSTextField?
  @IBOutlet var accessKeyLabel: NSTextField?
  @IBOutlet var dateAddedLabel: NSTextField?
  @IBOutlet var accountIdLabel: NSTextField?

  var profile: AWSProfile? {
    didSet(value) { setProps(value) }
  }

  func setProps(_ profile: AWSProfile?) {
    if profile == nil { return }
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy' 'HH:mm:ssZZZZZ"
    formatter.locale = Locale(identifier: "en_US_POSIX")


    profileNameLabel?.stringValue = profile!.name!
    accessKeyLabel?.stringValue = profile!.accessKey!
    dateAddedLabel?.stringValue = formatter.string(from: profile!.createdAt!)
    accountIdLabel?.stringValue = profile!.accountId!
  }

  override func viewDidAppear() {
    setProps(profile)
  }
}
