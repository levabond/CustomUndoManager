//
//  EventStack.swift
//  
//
//  Created by Лев Бондаренко on 17.02.2022.
//

import Foundation

public struct EventStack {
  var items: [Event] = []
  
  var top: Event? {
    items.last
  }
  
  mutating func push(_ item: Event) {
    items.append(item)
  }
  
  mutating func pop() -> Event? {
    items.popLast()
  }
  
  var count: Int {
    items.count
  }
  
  var isEmpty: Bool {
    items.isEmpty
  }
}
