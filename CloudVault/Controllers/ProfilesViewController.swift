//
//  ProfilesViewController.swift
//  CloudVault
//
//  Created by Chris Schofield on 24/01/2021.
//

import Foundation
import AppKit
import ReSwift

/**
Profile index view controller
*/
class ProfileViewController: NSViewController, StoreSubscriber {
  @IBOutlet var profileStackView: ProfileStackView?
  var sortedBy: ProfileOrdering?
  var search: String? = ""

  @objc func contextObjectsDidChange(_ notification: Notification) { draw() }

  func draw() {
    profileStackView?.clear()
    let processed = DataManager.shared.profiles.items.value
      .sorted {
        switch sortedBy {
        case .byNameAscending: return $1.name! > $0.name!
        case .byNameDescending: return $0.name! > $1.name!
        case .byDateAscending: return $0.createdAt! > $1.createdAt!
        case .byDateDescending: return $1.createdAt! > $0.createdAt!
        default: return true
        }
      }
      .filter {
        return search == nil || search!.isEmpty
          || $0.name!.searchMatch(search!)
          || $0.description.searchMatch(search!)
      }
    profileStackView?.addProfilePartials(processed)
  }

  override func viewDidAppear() {
    mainStore.subscribe(self)
    guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }

    draw()
    DataManager.shared.profiles.items.asObservable()
      .subscribe(onNext: { _ in self.draw() })
      .disposed(by: delegate.mainDisposeBag)
  }

  override func viewWillDisappear() {
    mainStore.unsubscribe(self)
  }

  func newState(state: AppState) {
    sortedBy = state.ordering
    search = state.search
    draw()
  }
}
