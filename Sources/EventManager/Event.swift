//
//  File.swift
//  
//
//  Created by Лев Бондаренко on 17.02.2022.
//

import Foundation

public class Event {
  var target: AnyObject
  var handler: (AnyObject) -> ()
  
  init(
    target: AnyObject,
    handler: @escaping (AnyObject) -> ()
  ) {
    self.target = target
    self.handler = handler
  }
}
