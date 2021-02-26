//
//  FlippedClipView.swift
//  CloudVault
//
//  Created by Chris Schofield on 21/02/2021.
//

import Foundation
import AppKit

/**
  Clip view with reversed coordinates system because this couldn't have just been a simple checkbox, of course. \s
*/
class FlippedClipView: NSClipView {
  open override var isFlipped: Bool {
    return true
  }
}
