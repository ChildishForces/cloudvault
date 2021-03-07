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
  lazy var profileController = ProfileViewController()
  //  lazy var profileSingle = ProfileSingleController()
  //  lazy var settingsController = SettingsViewController()
  private var viewKey: ViewKey = .profileIndex;
  public var currentController: NSViewController {
    get { getViewController(key: viewKey) }
  }

  private func getViewController(key: ViewKey) -> NSViewController {
    switch viewKey {
    case .profileIndex: return profileController;
    case .profileSingle: return profileController;
    case .settings: return profileController;
    }
  }

  override func viewDidAppear() {
    //
  }

  private func navigate(_ viewIdentifier: ViewKey) {
    transition(
      from: currentController,
      to: getViewController(key: viewIdentifier),
      options: .crossfade,
      completionHandler: { print("Switched view") }
    )
  }

  public func navigateToProfiles() {

  }

  public func navigateToProfiles(tag: UUID) {

  }

  public func navigateToProfile(id: UUID) {

  }

  public func navigateToSettings() {
    
  }
}
