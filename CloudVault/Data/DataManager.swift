//
//  DataManager.swift
//  CloudVault
//
//  Created by Chris Schofield on 22/02/2021.
//

import Foundation

/**
Singleton class for exposing repos to application through shared instance
*/
class DataManager: NSObject {
  static let shared = DataManager()
  let profiles: ProfileRepo

  override init() {
    profiles = ProfileRepo()
  }
}
