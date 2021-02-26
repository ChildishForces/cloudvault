//
//  RepoProtocol.swift
//  CloudVault
//
//  Created by Chris Schofield on 22/02/2021.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa

/**
Associated Type Protocol (similar to generic) implementing schema for Repo classes
*/
protocol RepoProtocol {
  associatedtype Item
  var items: BehaviorRelay<[Item]> { get }
  func create(_ toCreate: Any) throws -> Item
  func read(_ id: String) throws -> Item?
  func update(_ toUpdate: AnyObject) throws -> Item
  func destroy(_ id: String) throws
}
