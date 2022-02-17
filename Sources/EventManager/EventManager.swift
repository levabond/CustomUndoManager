import Foundation

protocol EventManagerProtocol {
  /// Регестрируем событие
  func register(target: AnyObject, handler: @escaping (AnyObject) -> ())
  /// Отменяем событие
  func undo()
  /// Восстанавливаем событие
  func redo()
  
  func beginGroup()
  func endGroup()

  var canUndo: Bool { get }
  var canRedo: Bool { get }
}

public protocol EventManagerDelegate: AnyObject {}

public final class EventManager: EventManagerProtocol {
  
  public var canUndo: Bool = false
  public var canRedo: Bool = false
  
  private var currentLevel: Int = 0
  private var undoGroup: [EventGroup] = []
  private var redoGroup: [EventGroup] = []
  private var groupOpen: Bool = false
  
  private var currentNode: EventGroup {
    undoGroup.isEmpty ? EventGroup() : undoGroup[currentLevel]
  }
  
  private var enableRegistrationUndo: Bool = true
  private var calledUndo: Bool = false
  
  weak var delegate: EventManagerDelegate?
  
  public init() {
    
  }
  
  public func register(
    target: AnyObject,
    handler: @escaping (AnyObject) -> ()
  ) {
    let event = Event(target: target, handler: handler)
    
    if !groupOpen {
      let group = EventGroup()
      group.undoList.push(event)
      group.redoList = EventStack()
      
      if enableRegistrationUndo {
        undoGroup.append(group)
      } else {
        redoGroup.append(group)
        enableRegistrationUndo = true
      }
      canRedo = !redoGroup.isEmpty
      canUndo = !undoGroup.isEmpty
      //
    } else {
      if enableRegistrationUndo {
        currentNode.undoList.push(event)
        currentNode.redoList = EventStack()
      } else {
        if calledUndo {
          currentNode.redoList.push(event)
        } else {
          currentNode.undoList.push(event)
        }
        enableRegistrationUndo = true
      }
      
      canRedo = !currentNode.redoList.isEmpty
      canUndo = !currentNode.undoList.isEmpty
    }
    
  }

  public func undo() {
    if !groupOpen {
      guard let group = undoGroup.popLast() else {
        return
      }
      group.undoList.items.forEach({ event in
          RunLoop.main.perform { [weak self] in
            self?.enableRegistrationUndo = false
            self?.calledUndo = true
            event.handler(event.target)
          }
      })
      
      redoGroup.append(group)
      
      canRedo = !redoGroup.isEmpty
      canUndo = !undoGroup.isEmpty
    } else {
      
      
      canRedo = !currentNode.redoList.isEmpty
      canUndo = !currentNode.undoList.isEmpty
    }
  }

  public func redo() {
    if !groupOpen {
//      groupList.re
      guard let group = redoGroup.popLast() else {
        return
      }
      group.undoList.items.forEach({ event in
          RunLoop.main.perform { [weak self] in
            self?.enableRegistrationUndo = false
            self?.calledUndo = true
            event.handler(event.target)
        }
      })
      
      redoGroup.append(group)
      
      canRedo = !redoGroup.isEmpty
      canUndo = !undoGroup.isEmpty
    } else {
      if let event = currentNode.redoList.pop() {
        RunLoop.main.perform { [weak self] in
          self?.enableRegistrationUndo = false
          self?.calledUndo = false
          event.handler(event.target)
        }
      }
      
      canUndo = !currentNode.undoList.isEmpty
      canRedo = !currentNode.redoList.isEmpty
    }
  }
  
  func beginGroup() {
    currentLevel += 1
    
    groupOpen = true
//    groupList.append(EventGroup())
  }
  
  func endGroup() {
    if currentLevel > 0 {
      currentLevel -= 1
//      groupList.removeLast()
    }
  }
}
