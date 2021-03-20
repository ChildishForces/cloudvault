//
//  NavigationController.swift
//  CloudVault
//
//  Created by Chris Schofield on 07/03/2021.
//

import Foundation
import AppKit

enum ViewKey {
  case profileIndex
  case profileSingle
  case settings
}

class NavigationController: NSViewController {
  lazy var profileController: ProfileViewController = {
    self.storyboard!.instantiateController(withIdentifier: "profileViewController") as! ProfileViewController
  }()
  lazy var profileSingleController: ProfileSingleViewController = {
    self.storyboard!.instantiateController(withIdentifier: "profileSingleViewController") as! ProfileSingleViewController
  }()
  lazy var settingsController: SettingsViewController = {
    self.storyboard!.instantiateController(withIdentifier: "settingsViewController") as! SettingsViewController
  }()
  @IBOutlet open weak var containerView: NSView! = nil
  private var viewKey: ViewKey = .profileIndex
  public var currentController: NSViewController {
    get { getViewController(key: viewKey) }
  }

  private func getViewController(key: ViewKey) -> NSViewController {
    switch key {
    case .profileIndex: return profileController
    case .profileSingle: return profileSingleController
    case .settings: return settingsController
    }
  }

  override func viewWillAppear() {
    addChild(profileController)
    addChild(profileSingleController)
    addChild(settingsController)

    profileController.view.frame = containerView.bounds
    containerView.addSubview(profileController.view)
  }

  override func viewDidAppear() {
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    appDelegate.navigator = self
  }

  private func navigate(_ viewIdentifier: ViewKey) {
    guard viewIdentifier != viewKey else { return }
    transition(
      from: currentController,
      to: getViewController(key: viewIdentifier),
      options: .allowUserInteraction,
      completionHandler: {
        print("transition complete")
      }
    )
    viewKey = viewIdentifier
  }

  public func navigateToProfiles() {
    navigate(.profileIndex)
  }

  public func navigateToProfiles(tag: UUID) {
    navigate(.profileIndex)
  }

  public func navigateToProfile(id: UUID) {
    navigate(.profileSingle)
  }

  public func navigateToSettings() {
    navigate(.settings)
  }
}
