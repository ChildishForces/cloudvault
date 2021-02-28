//
//  TagRepo.swift
//  CloudVault
//
//  Created by Chris Schofield on 26/02/2021.
//

import Foundation
import RxSwift
import RxCocoa
import CoreData

enum TagError: Error {
  case couldNotCreateTag
  case couldNotReadTag
  case couldNotUpdateTag
  case couldNotDestroyTag
  case notValidRequest
  case notValidTag
}

struct TagSchema: Codable {
  var name: String
  var color: String
}

struct TagUpdateObject {
  var id: String
  var name: String?
  var color: String?
}

func tagRepoErrorHandler(_ error: TagError) -> String {
  switch error {
  case .couldNotCreateTag: return "Could not create the tag!"
  case .couldNotReadTag: return "Could not find the tag!"
  case .couldNotUpdateTag: return "Could not update the tag!"
  case .couldNotDestroyTag: return "Could not destroy the tag!"
  case .notValidTag: return "Tag argument not valid!"
  case .notValidRequest: return "Received an invalid update object!"
  }
}

/**
  Tag repository, extends CoreDataRepo and implements RepoProtocol
*/
class TagRepo: CoreDataRepo, RepoProtocol {
  typealias Item = Tag

  let items: BehaviorRelay<[Tag]> = BehaviorRelay(value: [])

  func fetchLatest() {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
    items.accept(self.fetch(request: request) as? [Tag] ?? [])
  }

  @objc func contextObjectsDidChange(_ notification: Notification) { fetchLatest() }

  override init() {
    super.init()
    fetchLatest()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(contextObjectsDidChange(_:)),
      name: Notification.Name.NSManagedObjectContextObjectsDidChange,
      object: nil
    )
  }

  func create(_ toCreate: Any) throws -> Tag {
    guard let obj = toCreate as? TagSchema else { throw TagError.notValidTag }
    guard let newEntity = NSEntityDescription.entity(forEntityName: "Tag", in: context) else {
      throw TagError.couldNotCreateTag
    }

    let tag = Tag.init(entity: newEntity, insertInto: context)
    let newId = UUID()

    tag.name = obj.name
    tag.color = obj.color
    tag.id = newId

    try saveOrFailWith(TagError.couldNotCreateTag)

    return tag
  }

  func read (_ tagId: String) throws -> Tag? {
    return items.value.first(where: { $0.id!.uuidString == tagId })
  }

  func update(_ toUpdate: AnyObject) throws -> Tag {
    guard let update = toUpdate as? TagUpdateObject else { throw TagError.notValidRequest }
    guard let tag = items.value.first(where: { $0.id!.uuidString == update.id }) else {
      throw TagError.notValidTag
    }

    tag.name = update.name ?? tag.name

    try saveOrFailWith(TagError.couldNotUpdateTag)

    return tag
  }

  func destroy(_ id: String) throws {
    guard let tag = items.value.first(where: { $0.id!.uuidString == id }) else {
      throw TagError.notValidTag
    }
    context.delete(tag)

    try saveOrFailWith(TagError.couldNotDestroyTag)
  }
}
