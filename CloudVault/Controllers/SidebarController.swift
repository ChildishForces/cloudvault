//
//  SidebarController.swift
//  CloudVault
//
//  Created by Chris Schofield on 24/02/2021.
//

import Foundation
import AppKit
import ReSwift
import DynamicColor

enum FactoryError: Error {
  case couldNotSplitColors
  case couldNotCreateCell
}

typealias TagCell = TagTableCell

class SidebarController: NSViewController, StoreSubscriber {
  @objc func navUpdate(_ notification: Notification) {
    let title = (notification.object as AnyObject)["title"]!! as? String ?? "No Title"
    //    self.handleNavigation(title);
    mainStore.dispatch(SetLastLocation(payload: title))
  }

  // Outlets
  //  @IBOutlet weak var scrollView: NSScrollView!
  //  @IBOutlet weak var clipView: NSClipView!
  @IBOutlet weak var outlineView: NSOutlineView!

  // Vars
  var mainWindowController: WindowController?
  var profileItems: [ProfileMenuItem] = []
  var tagItems: [TagMenuItem] = []
  var lastLocation: String?
  var items: [Any] = []

  // State vars
  var profileUuid: String?
  var profile: AWSProfile? {
    get {
      DataManager.shared.profiles.items.value.first(where: { $0.id?.uuidString == profileUuid })
    }
  }

  // Methods
  public func selectProfile(_ id: String) {
    // handle selection of correct item (necessary for selecting a profile from ProfileIndex)
    let index = DataManager.shared.profiles.items.value.firstIndex(where: { $0.id!.uuidString == id })
    outlineView.selectRowIndexes(IndexSet(integer: 4 + index!), byExtendingSelection: false)
  }

  private func generateItems() -> [MenuSegment] {
    profileItems = DataManager.shared.profiles.items.value
      .map {
        ProfileMenuItem(
          $0.name!,
          id: $0.id!.uuidString,
          icon: NSImage(systemSymbolName: "key.fill", accessibilityDescription: nil)!
        )
      }
      .sorted { $0.name < $1.name }

    tagItems = DataManager.shared.tags.items.value
      .map {
        TagMenuItem(
          $0.name!,
          id: $0.id!.uuidString,
          color: $0.color!
        )
      }
      .sorted { $0.name < $1.name }

    return [
      MenuSegment(name: "Navigation", items: [
        NavigationMenuItem(
          "Profiles",
          slug: .profileIndex,
          icon: NSImage(systemSymbolName: "person.2.circle.fill", accessibilityDescription: nil)!
        ),
        NavigationMenuItem(
          "Settings",
          slug: .settings,
          icon: NSImage(systemSymbolName: "gearshape.fill", accessibilityDescription: nil)!
        )
      ]),
      MenuSegment(name: "Profiles", items: profileItems),
      MenuSegment(name: "Tags", items: tagItems)
    ]
  }

  private func drawNav() {
    items = generateItems()

    let index = outlineView.selectedRow
    outlineView.reloadData()
    expandAll()
    outlineView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }

    DataManager.shared.profiles.items.asObservable()
      .subscribe(onNext: { _ in self.drawNav() })
      .disposed(by: delegate.mainDisposeBag)

    DataManager.shared.tags.items.asObservable()
      .subscribe(onNext: { _ in self.drawNav() })
      .disposed(by: delegate.mainDisposeBag)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(navUpdate(_:)),
      name: Notification.Name(rawValue: "NavigationUpdate"),
      object: nil
    )

    // Do view setup here
    self.outlineView.delegate = self
    self.outlineView.dataSource = self

    DataManager.shared.profiles.fetchLatest()
    drawNav()
  }

  override func viewDidAppear() {
    if outlineView!.selectedRow == -1 {
      outlineView.selectRowIndexes(IndexSet(integer: 1), byExtendingSelection: false)
    }

    self.mainWindowController = self.view.window?.windowController as? WindowController
    mainWindowController?.sidebarController = self
    expandAll()
  }

  private func expandAll() {
    for segment in self.items {
      self.outlineView.expandItem(segment)
    }
  }

  // MARK: - View Factory Methods

  private func generateTagView(_ menuItem: TagMenuItem, _ outlineView: NSOutlineView) throws -> TagTableCell {
    guard let view = outlineView.makeView(
      withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TagCell"),
      owner: self
    ) as? TagTableCell else { throw FactoryError.couldNotCreateCell }

    if let textField = view.textField {
      textField.stringValue = menuItem.name
    }

    if menuItem.color != nil, let indicatorView = view.customView {
      indicatorView.color = DynamicColor(hexString: menuItem.color!)
    }

    return view
  }

  private func generateProfileView(_ menuItem: ProfileMenuItem, _ outlineView: NSOutlineView) throws -> NSTableCellView {
    guard let view = outlineView.makeView(
      withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"),
      owner: self
    ) as? NSTableCellView else { throw FactoryError.couldNotCreateCell }

    if let textField = view.textField {
      textField.stringValue = menuItem.name
    }

    if let imageView = view.imageView {
      if menuItem.icon != nil { imageView.image = menuItem.icon } else { imageView.isHidden = true }
    }

    return view
  }

  private func generateNavigationView(_ menuItem: NavigationMenuItem, _ outlineView: NSOutlineView) throws -> NSTableCellView {
    guard let view = outlineView.makeView(
      withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"),
      owner: self
    ) as? NSTableCellView else { throw FactoryError.couldNotCreateCell }

    if let textField = view.textField {
      textField.stringValue = menuItem.name
    }

    if let imageView = view.imageView {
      if menuItem.icon != nil { imageView.image = menuItem.icon } else { imageView.isHidden = true }
    }

    return view
  }

  private func generateMenuSegmentView(_ menuItem: MenuSegment, _ outlineView: NSOutlineView) throws -> NSTableCellView {
    guard let view = outlineView.makeView(
      withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"),
      owner: self
    ) as? NSTableCellView else { throw FactoryError.couldNotCreateCell }

    if let textField = view.textField {
      textField.stringValue = menuItem.name
    }

    return view
  }

  // MARK: - Profile State

  override func viewWillAppear() {
    mainStore.subscribe(self)
  }

  override func viewWillDisappear() {
    mainStore.unsubscribe(self)
  }

  func newState(state: AppState) {
    profileUuid = mainStore.state.activeProfile
    lastLocation = mainStore.state.location
  }
}

// MARK: - NSOutlineViewDataSource

extension SidebarController: NSOutlineViewDataSource {
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    if let segment = item as? MenuSegment { return segment.items.count }
    return items.count
  }

  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    if let segment = item as? MenuSegment { return segment.items[index] }
    return items[index]
  }

  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    if item as? MenuSegment != nil { return true }
    return false
  }

  func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
    if item as? MenuSegment != nil { return true }
    return false
  }
}

// MARK: - NSOutlineViewDelegate

extension SidebarController: NSOutlineViewDelegate {
  func outlineView(_ outlineView: NSOutlineView, shouldShowCellExpansionFor tableColumn: NSTableColumn?, item: Any) -> Bool {
    return true
  }

  func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    if item as? MenuSegment != nil { return false }
    return true
  }

  func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
    return true
  }

  func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
    let view = CustomTableRowView(frame: NSRect.zero)
    return view
  }

  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    if let segment = item as? MenuSegment { return try? generateMenuSegmentView(segment, outlineView) } else
    if let menuItem = item as? ProfileMenuItem { return try? generateProfileView(menuItem, outlineView) } else
    if let menuItem = item as? TagMenuItem { return try? generateTagView(menuItem, outlineView) } else
    if let menuItem = item as? NavigationMenuItem { return try? generateNavigationView(menuItem, outlineView) } else {
      print("MenuController: Unknown type item=\(item)")
    }

    return nil
  }

  func outlineViewSelectionDidChange(_ notification: Notification) {
    guard let outlineView = notification.object as? NSOutlineView else {
      return
    }
    guard let delegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
    let selectedIndex = outlineView.selectedRow

    if let item = outlineView.item(atRow: selectedIndex) as? NavigationMenuItem {
      if mainWindowController != nil {
        print(delegate)
        print(item)
        switch item.slug {
          case .profileIndex: delegate.navigator?.navigateToProfiles()
          case .settings: delegate.navigator?.navigateToSettings()
          default: delegate.navigator?.navigateToProfiles()
        }
      }
    } else if let profileItem = outlineView.item(atRow: selectedIndex) as? ProfileMenuItem {
      if self.mainWindowController != nil {
        //                delegate.navigator?.switchView("profileSingle")
        mainStore.dispatch(SetActiveProfile(payload: profileItem.id))
        delegate.navigator?.navigateToProfile(id: UUID(uuidString: profileItem.id)!)
      }
    } else if let tagItem = outlineView.item(atRow: selectedIndex) as? TagMenuItem {
      if self.mainWindowController != nil {
        //                delegate.navigator?.switchView("profileSingle")
//        mainStore.dispatch(SetActiveProfile(payload: profileItem.id))
        delegate.navigator?.navigateToProfiles(tag: UUID(uuidString: tagItem.id)!)
      }
    } else if outlineView.item(atRow: selectedIndex) as? MenuSegment != nil {
      if self.mainWindowController != nil {
        //              self.mainWindowController!.selectedSegment!.value = segment
      }
    }
  }
}
