import Foundation

protocol EventManagerProtocol {
  /// Регестрируем событие
  func register(target: AnyObject, handler: @escaping (AnyObject) -> ())
  /// Отменяем событие
  func undo()
  /// Восстанавливаем событие
  func redo()

  var canUndo: Bool { get }
  var canRedo: Bool { get }
}

public protocol EventManagerDelegate: AnyObject {}

public final class EventManager: EventManagerProtocol {
  
  public var canUndo: Bool = false
  public var canRedo: Bool = false
  
  private var currentLevel: Int
  private var groupList = LinkedList()
  private var groupOpen: Bool = false
  
  private var currentGroup: EventGroup {
    groupList[currentLevel]
  }
  
  private var enableRegistrationUndo: Bool = true
  private var calledUndo: Bool = false
  
  weak var delegate: EventManagerDelegate?
  
  public init() {
    currentLevel = 0
    groupList.append(EventGroup())
  }
  
  public func register(
    target: AnyObject,
    handler: @escaping (AnyObject) -> ()
  ) {
    let event = Event(target: target, handler: handler)
    
    if enableRegistrationUndo {
      currentGroup.undoList.push(event)
      currentGroup.redoList = EventStack()
    } else {
      if calledUndo {
        currentGroup.redoList.push(event)
      } else {
        currentGroup.undoList.push(event)
      }
      enableRegistrationUndo = true
    }
    canRedo = !currentGroup.redoList.isEmpty
    canUndo = !currentGroup.undoList.isEmpty
  }

  public func undo() {
    if let event = currentGroup.undoList.pop() {
      RunLoop.main.perform { [weak self] in
        self?.enableRegistrationUndo = false
        self?.calledUndo = true
        event.handler(event.target)
      }
    }
    
    canRedo = !currentGroup.redoList.isEmpty
    canUndo = !currentGroup.undoList.isEmpty
  }

  public func redo() {
    if let event = currentGroup.redoList.pop() {
      RunLoop.main.perform { [weak self] in
        self?.enableRegistrationUndo = false
        self?.calledUndo = false
        event.handler(event.target)
      }
    }
    canRedo = !currentGroup.redoList.isEmpty
  }
  
  func beginGroup() {
    currentLevel += 1
    groupList.append(EventGroup())
  }
  
  func endGroup() {
    if currentLevel > 0 {
      currentLevel -= 1
      groupList.removeLast()
    }
  }
}
