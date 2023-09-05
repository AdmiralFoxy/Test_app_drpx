//
//  NavigationNode.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation

public protocol NavigationEvent {}

public protocol NavigationEventDrivenInterface {
  
  func propagate<T: NavigationEvent>(event: T)
  func raise<T: NavigationEvent>(event: T)
  func addHandler<T: NavigationEvent>(_ handler: @escaping (T) -> Void)
  
}

public protocol NavigationEventHandleable {}

open class NavigationNode: NavigationEventDrivenInterface {
  
  private var parent: NavigationNode?
  private lazy var children = NSHashTable<NavigationNode>.weakObjects()
  private var eventHandlerContainers: [String: NavigationEventHandleable] = [:]
  
  fileprivate let identifier = ProcessInfo.processInfo.globallyUniqueString
  
  deinit { }
  
  public init(parent: NavigationNode?) {
    parent?.addChild(self)
  }
  
  public func propagate<T: NavigationEvent>(event: T) {
    let type = String(describing: T.self)
    guard let handler = eventHandlerContainers[type] as? NavigationEventHandlersContainer<T> else {
      children.allObjects.forEach {
        $0.propagate(event: event)
      }
      
      return
    }
    
    handler.propagate(event: event)
  }
  
  public func raise<T: NavigationEvent>(event: T, from sender: NavigationEventDrivenInterface) {
    guard let parent = parent else {
      propagate(event: event)
      
      return
    }
    
    let type = String(describing: T.self)
    guard let handler = eventHandlerContainers[type] as? NavigationEventHandlersContainer<T> else {
      parent.raise(event: event, from: sender)
      
      return
    }
    
    handler.propagate(event: event)
  }
  
  public func raise<T: NavigationEvent>(event: T) {
    // because we're using event for routing only it would be better to dispatch it directly to main queue
    DispatchQueue.main.async {
      self.raise(event: event, from: self)
    }
  }
  
  public func addChild(_ child: NavigationNode) {
    child.parent = self
    children.add(child)
  }
  
  public func addHandler<T: NavigationEvent>(_ handler: @escaping (T) -> Void) {
    let type = String(describing: T.self)
    var container = eventHandlerContainers[type]
    if container == nil {
      container = NavigationEventHandlersContainer<T>()
      eventHandlerContainers[type] = container
    }
    if let container = container as? NavigationEventHandlersContainer<T> {
      container.add(handler: handler)
    }
  }
  
}

private class NavigationEventHandlersContainer<T>: NavigationEventHandleable {
  
  private var handlers: [(T) -> Void] = []
  
  func add(handler: @escaping (T) -> Void) {
    handlers.append(handler)
  }
  
  func propagate(event: T) {
    for handler in handlers {
      handler(event)
    }
  }
  
}

extension NavigationNode: Equatable {}

public func == (lhs: NavigationNode, rhs: NavigationNode) -> Bool {
  return lhs.identifier == rhs.identifier
}
