//
//  CoreDataRepo.swift
//  CloudVault
//
//  Created by Chris Schofield on 22/02/2021.
//

import Foundation
import AppKit
import CoreData
import RxSwift
import RxCocoa

/**
  CoreData repository base class
*/
class CoreDataRepo: NSObject {
  let context: NSManagedObjectContext

  override init() {
    // swiftlint:disable:next force_cast
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    self.context = appDelegate.persistentContainer.viewContext
    super.init()
  }

  func fetch(request: NSFetchRequest<NSFetchRequestResult>) -> Any? {
    request.returnsObjectsAsFaults = false

    do { return try context.fetch(request) } catch { return nil }
  }

  func saveOrFailWith<T: Error>(_ error: T) throws {
    do { try context.save() } catch { throw error }
  }
}
