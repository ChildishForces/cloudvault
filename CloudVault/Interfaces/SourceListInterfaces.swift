//
//  SourceListInterfaces.swift
//  CloudVault
//
//  Created by Chris Schofield on 20/01/2021.
//

import Foundation
import AppKit

class MenuSegment: NSObject {
  let name: String
  var items: [Any] = []

  init (name: String, items: [Any]) {
    self.name = name
    self.items = items
  }
  init (name: String) {
    self.name = name
  }
}

class ProfileMenuItem {
  let name: String
  let icon: NSImage?
  let id: String

  init (_ name: String, id: String) {
    self.id = id
    self.name = name
    self.icon = nil
  }

  init (_ name: String, id: String, icon: NSImage) {
    self.id = id
    self.name = name
    self.icon = icon
  }
}

class NavigationMenuItem {
  let name: String
  let icon: NSImage?
  let slug: ViewKey

  init (_ name: String, slug: ViewKey) {
    self.name = name
    self.slug = slug
    self.icon = nil
  }

  init (_ name: String, slug: ViewKey, icon: NSImage) {
    self.name = name
    self.slug = slug
    self.icon = icon
  }
}

class TagMenuItem {
  let id: String
  let name: String
  let color: String?

  init (_ name: String, id: String, color: String) {
    self.id = id
    self.name = name
    self.color = color
  }
}
