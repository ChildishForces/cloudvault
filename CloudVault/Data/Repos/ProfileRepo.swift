//
//  ProfileRepo.swift
//  CloudVault
//
//  Created by Chris Schofield on 22/02/2021.
//

import Foundation
import RxSwift
import RxCocoa
import CoreData

enum ProfileError: Error {
  case couldNotCreateProfile
  case couldNotReadProfile
  case couldNotUpdateProfile
  case couldNotDestroyProfile
  case couldNotMakeProfileActive
  case notValidRequest
  case notValidAWSProfile
}

struct AWSProfileSchema: Codable {
  var name: String
  var description: String?
  var accessKey: String
  var secretKey: String
  var email: String?
  var arn: String?
  var accountId: String?
  var userId: String?
}

struct ProfileUpdateObject {
  var id: String
  var name: String?
  var description: String?
  var accessKey: String?
  var secretKey: String?
  var email: String?
  var arn: String?
  var accountId: String?
  var userId: String?
}

func profileRepoErrorHandler(_ error: ProfileError) -> String {
  switch error {
  case .couldNotCreateProfile: return "Could not create the profile!"
  case .couldNotReadProfile: return "Could not find the profile!"
  case .couldNotUpdateProfile: return "Could not update the profile!"
  case .couldNotDestroyProfile: return "Could not destroy the profile!"
  case .couldNotMakeProfileActive: return "Could not make profile active!"
  case .notValidAWSProfile: return "Profile argument not valid!"
  case .notValidRequest: return "Received an invalid update object!"
  }
}

/**
  AWSProfile repository, extends CoreDataRepo and implements RepoProtocol
*/
class ProfileRepo: CoreDataRepo, RepoProtocol {
  typealias Item = AWSProfile

  let items: BehaviorRelay<[AWSProfile]> = BehaviorRelay(value: [])

  func fetchLatest() {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AWSProfile")
    items.accept(self.fetch(request: request) as? [AWSProfile] ?? [])
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

  func create(_ toCreate: Any) throws -> AWSProfile {
    guard let obj = toCreate as? AWSProfileSchema else { throw ProfileError.notValidAWSProfile }
    guard let newEntity = NSEntityDescription.entity(forEntityName: "AWSProfile", in: context) else {
      throw ProfileError.couldNotCreateProfile
    }

    let awsProfile = AWSProfile.init(entity: newEntity, insertInto: context)
    let newId = UUID()

    awsProfile.name = obj.name
    awsProfile.accessKey = obj.accessKey
    awsProfile.secretKey = obj.secretKey
    awsProfile.accountId = obj.accountId
    awsProfile.userId = obj.userId
    awsProfile.arn = obj.arn
    awsProfile.id = newId
    awsProfile.createdAt = Date()

    try saveOrFailWith(ProfileError.couldNotCreateProfile)

    return awsProfile
  }

  func read (_ profileId: String) throws -> AWSProfile? {
    return items.value.first(where: { $0.id!.uuidString == profileId })
  }

  func update(_ toUpdate: AnyObject) throws -> AWSProfile {
    guard let update = toUpdate as? ProfileUpdateObject else { throw ProfileError.notValidRequest }
    guard let awsProfile = items.value.first(where: { $0.id!.uuidString == update.id }) else {
      throw ProfileError.notValidAWSProfile
    }

    awsProfile.name = update.name ?? awsProfile.name
    awsProfile.profileDescription = update.description ?? awsProfile.profileDescription
    awsProfile.accessKey = update.accessKey ?? awsProfile.accessKey
    awsProfile.secretKey = update.secretKey ?? awsProfile.secretKey
    awsProfile.accountId = update.accountId ?? awsProfile.accountId
    awsProfile.email = update.email ?? awsProfile.email

    try saveOrFailWith(ProfileError.couldNotUpdateProfile)

    return awsProfile
  }

  func destroy(_ id: String) throws {
    guard let awsProfile = items.value.first(where: { $0.id!.uuidString == id }) else {
      throw ProfileError.notValidAWSProfile
    }
    context.delete(awsProfile)

    try saveOrFailWith(ProfileError.couldNotDestroyProfile)
  }

  //    func makeActive(_ id: String) throws {
  //        guard let awsProfile = items.value?.first(where: { $0.id.uuidString == id }) else { throw ProfileError.notValidAWSProfile }
  //        items.value!.forEach { $0.isActive = false }
  //        awsProfile.isActive = true;
  //
  //        try saveOrFailWith(ProfileError.couldNotMakeProfileActive);
  //    }
}
