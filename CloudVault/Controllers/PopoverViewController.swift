//
//  PopoverViewController.swift
//  CloudVault
//
//  Created by Chris Schofield on 24/01/2021.
//

import Foundation
import AppKit
import RxSwift
import RxCocoa
import SotoSTS

let accessKeyRegex = try! NSRegularExpression(pattern: "(?<![A-Z0-9])[A-Z0-9]{20}(?![A-Z0-9])")
let secretKeyRegex = try! NSRegularExpression(pattern: "(?<![A-Za-z0-9/+=])[A-Za-z0-9/+=]{40}(?![A-Za-z0-9/+=])")

enum StatusMessage {
  case incomplete
  case incorrect
  case loading
  case success
  case ready
  case failure
}

func getStatusMessage(_ value: StatusMessage) -> String {
  switch value {
  case .failure: return "Encountered an error"
  case .incomplete: return "Credentials incomplete"
  case .incorrect: return "Credentials not valid"
  case .loading: return "Checking credentials"
  case .ready: return "Ready to test"
  case .success: return "Credentials valid"
  }
}

/**
  "Add new profile" popup controller
*/
class PopoverViewController: NSViewController {
  @IBOutlet var accessKeyInput: NSTextField?
  @IBOutlet var secretKeyInput: NSTextField?
  @IBOutlet var profileNameInput: NSTextField?
  @IBOutlet var statusMessage: NSTextField?
  @IBOutlet var progressIndicator: NSProgressIndicator?
  @IBOutlet var indicator: IndicatorView?
  @IBOutlet var testProfileButton: NSButton?
  @IBOutlet var createProfileButton: NSButton?

  var stsResponse: STS.GetCallerIdentityResponse?

  override func viewDidAppear() {
    indicator?.status = .waiting
    statusMessage?.stringValue = getStatusMessage(.incomplete)
    profileNameInput?.delegate = self
    accessKeyInput?.delegate = self
    secretKeyInput?.delegate = self
  }

  @IBAction func testProfile(_ sender: Any) {
    guard profileNameInput?.stringValue.count ?? 0 > 0 else { return }
    guard accessKeyRegex.hasMatch(accessKeyInput!.stringValue) else { return }
    guard secretKeyRegex.hasMatch(secretKeyInput!.stringValue) else { return }

    // Reflect start of testing in UI
    indicator?.status = .waiting
    statusMessage?.stringValue = getStatusMessage(.loading)
    progressIndicator?.isHidden = false
    progressIndicator?.startAnimation(nil)

    var response: STS.GetCallerIdentityResponse?

    let name = profileNameInput!.stringValue
    let accessKey = accessKeyInput!.stringValue
    let secretKey = secretKeyInput!.stringValue

    let group = DispatchGroup()
    group.enter()

    DispatchQueue.global(qos: .utility).async {
      // Test the account
      let profileTestSchema = AWSProfileSchema(
        name: name,
        accessKey: accessKey,
        secretKey: secretKey
      )
      do {
        response = try AwsUtility.testProfile(profileTestSchema)
      } catch {
        print("Encountered error validating: \(error)")
      }
      group.leave()
    }

    group.notify(queue: .main) {
      // Reflect status of process
      self.indicator?.status = response != nil ? .success : .failure
      self.statusMessage?.stringValue = getStatusMessage(response != nil ? .success : .failure)
      self.progressIndicator?.isHidden = true
      self.progressIndicator?.stopAnimation(nil)

      self.createProfileButton?.isEnabled = response != nil
      if response != nil { self.stsResponse = response }
    }
  }

  @IBAction func createProfile(_ sender: Any) {
    do {
      _ = try DataManager.shared.profiles.create(
        AWSProfileSchema(
          name: profileNameInput!.stringValue,
          accessKey: accessKeyInput!.stringValue,
          secretKey: secretKeyInput!.stringValue,
          arn: stsResponse!.arn,
          accountId: stsResponse!.account,
          userId: stsResponse!.userId
        )
      )

      resetInputs()
      for window in NSApplication.shared.windows {
        guard let windowController = window.windowController as? WindowController else { return }
        windowController.closePopover(self)
      }
    } catch {
      print("Encountered an error whilst saving AWSProfile: \(error)")
    }
  }

  func resetInputs() {
    profileNameInput?.stringValue = ""
    accessKeyInput?.stringValue = ""
    secretKeyInput?.stringValue = ""
  }
}

extension PopoverViewController: NSTextFieldDelegate {
  public func controlTextDidChange(_ obj: Notification) {
    // check the identifier to be sure you have the correct textfield if more are used
    //        if let textField = obj.object as? NSTextField, self.profileNameField?.identifier == textField.identifier {
    //            print("Profile Name text = \(textField.stringValue)\n")
    //        }
    //        if let textField = obj.object as? NSTextField, self.accessKeyInput?.identifier == textField.identifier {
    //            print("Access key text = \(textField.stringValue)\n")
    //        }
    //        if let textField = obj.object as? NSTextField, self.secretKeyInput?.identifier == textField.identifier {
    //            print("Secret key text = \(textField.stringValue)\n")
    //        }

    guard profileNameInput?.stringValue.count ?? 0 > 0
      && accessKeyInput?.stringValue.count ?? 0 > 0
      && secretKeyInput?.stringValue.count ?? 0 > 0 else {
      statusMessage?.stringValue = getStatusMessage(.incomplete)
      indicator?.status = .waiting
      stsResponse = nil
      return
    }

    guard accessKeyRegex.hasMatch(accessKeyInput!.stringValue)
      && secretKeyRegex.hasMatch(secretKeyInput!.stringValue) else {
      statusMessage?.stringValue = getStatusMessage(.incorrect)
      indicator?.status = .waiting
      stsResponse = nil
      return
    }

    statusMessage?.stringValue = getStatusMessage(.ready)
    testProfileButton?.isEnabled = true
  }
}
