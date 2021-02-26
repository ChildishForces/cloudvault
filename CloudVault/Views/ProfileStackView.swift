//
//  ProfileStackView.swift
//  CloudVault
//
//  Created by Chris Schofield on 21/02/2021.
//

import Foundation
import AppKit

/**
  Custom NSStackView for handling AWSProfile cards
*/
class ProfileStackView: NSStackView {
  let storyboard = NSStoryboard(name: "Main", bundle: nil)

  func clear() {
    self.subviews = []
  }

  func addProfilePartials(_ profiles: [AWSProfile]) {
    profiles.forEach { addProfilePartial($0) }
  }

  func addProfilePartial(_ profile: AWSProfile) {
    print("Should now layout profile \(String(describing: profile.name))")
    guard let partial = storyboard.instantiateController(
      withIdentifier: "profileFragment"
    ) as? ProfileFragmentController else { return }

    partial.profile = profile
    partial.view.wantsLayer = true

    partial.view.heightAnchor.constraint(equalToConstant: 56).isActive = true
    addArrangedSubview(partial.view)

    partial.view.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
    partial.view.rightAnchor.constraint(equalTo: rightAnchor, constant: 15).isActive = true
    updateConstraintsForSubtreeIfNeeded()
  }
}
