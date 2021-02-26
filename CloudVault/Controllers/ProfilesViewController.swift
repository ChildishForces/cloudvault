//
//  ProfilesViewController.swift
//  CloudVault
//
//  Created by Chris Schofield on 24/01/2021.
//

import Foundation
import AppKit

/**
Profile index view controller
*/
class ProfileViewController: NSViewController {
  @IBOutlet var profileStackView: ProfileStackView?

  @objc func contextObjectsDidChange(_ notification: Notification) { draw() }

  func draw() {
    profileStackView?.clear()
    profileStackView?.addProfilePartials(DataManager.shared.profiles.items.value)
  }

  override func viewDidAppear() {
    guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }

    draw()
    DataManager.shared.profiles.items.asObservable()
      .subscribe(onNext: { _ in self.draw() })
      .disposed(by: delegate.mainDisposeBag)
  }
}
