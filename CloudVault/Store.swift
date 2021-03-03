//
//  Store.swift
//  CloudVault
//
//  Created by Chris Schofield on 24/02/2021.
//

import Foundation
import ReSwift
import AppKit

let mainStore = Store<AppState>(
  reducer: stateReducer,
  state: AppState()
)

enum ProfileNameLetterCase {
  case camelCase
  case snakeCase
}

enum ProfileOrdering {
  case byNameAscending
  case byNameDescending
  case byDateAscending
  case byDateDescending
}

func getProfileNameLetterCaseString(_ letterCase: ProfileNameLetterCase) -> String {
  switch letterCase {
  case .camelCase: return "camelCase"
  case .snakeCase: return "snakeCase"
  }
}

func getProfileNameLetterCaseEnum(_ letterCase: String) -> ProfileNameLetterCase {
  switch letterCase {
  case "camelCase": return .camelCase
  case "snakeCase": return .snakeCase
  default: return .camelCase
  }
}

struct SettingsObject {
  var includeAllProfiles: Bool = true
  var letterCase: ProfileNameLetterCase = .camelCase
  var includeDefault: Bool = true
  var shouldWriteCredentials: Bool = false
}

struct AppState: StateType {
  var globalSettings = SettingsObject(
    includeAllProfiles: UserDefaults.standard.bool(forKey: "includeAll"),
    letterCase: getProfileNameLetterCaseEnum(UserDefaults.standard.string(forKey: "letterCase") ?? ""),
    includeDefault: UserDefaults.standard.bool(forKey: "includeDefault"),
    shouldWriteCredentials: UserDefaults.standard.bool(forKey: "shouldWriteCredentials")
  )
  var activeProfile: String?
  var location: String?
  var search: String?
  var ordering: ProfileOrdering = .byDateDescending
}

struct SetSettings: Action {
  var payload: SettingsObject
}

struct SetSearch: Action {
  var payload: String?
}

struct SetActiveProfile: Action {
  var payload: String?
}

struct SetLastLocation: Action {
  var payload: String
}

struct SetProfileOrdering: Action {
  var payload: ProfileOrdering
}

func stateReducer(action: Action, state: AppState?) -> AppState {
  var state = state ?? AppState()

  print(action)

  switch action {
  case let action as SetSettings: state.globalSettings = action.payload
  case let action as SetActiveProfile: state.activeProfile = action.payload
  case let action as SetSearch: state.search = action.payload
  case let action as SetLastLocation: state.location = action.payload
  case let action as SetProfileOrdering: state.ordering = action.payload
  default: break
  }

  return state
}
