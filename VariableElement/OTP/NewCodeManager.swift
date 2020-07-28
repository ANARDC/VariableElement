//
//  NewCodeManager.swift
//  VariableElement
//
//  Created by Anar on 28.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

import Foundation

/// Class that contains all the logic and implements the passed behavior
final class NewCodeManager {
  private let newRequestFreezeTime : Int
  private let errorInputLimit      : Int
  
  private var currentFreezeTime = 0
  
  private var errorInputCount = 0
  
  private var timer: Timer!
  
  private var behavior                  : ((Int) -> ())!
  private var defaultBehavior           : (() -> ())!
  private var behaviorAfterErrorInput   : ((Int, Int) -> ())!
  private var defautBehaviorAfterErrors : ((Int) -> ())!
  
  /// Initialization of NewCodeManager necessary properties
  /// - Parameters:
  ///   - newRequestFreezeTime: Label tapping freeze time in seconds
  ///   - errorInputLimit: Limit of error input
  init(newRequestFreezeTime: Int, errorInputLimit: Int) {
    self.newRequestFreezeTime = newRequestFreezeTime
    self.errorInputLimit      = errorInputLimit
  }
  
  /// New code request logic realization
  /// - Parameters:
  ///   - behavior: Behavior when the error input limit is not exceeded
  ///   - currentFreezeTime: Remaining time of the label freeze
  ///   - defaultBehavior: Behavior after the end of the freeze time when the error input limit is not exceeded
  ///   - behaviorAfterErrorInput: Behavior when the error input limit is exceeded
  ///   - label: Label that will be mutated
  ///   - errorInputLimit: Limit of error input
  ///   - currentFreezeTime: Remaining time of the label freeze
  func newCodeRequest(with behavior: @escaping (_ currentFreezeTime: Int) -> Void,
                      default defaultBehavior: @escaping () -> (),
                      afterErrorInput behaviorAfterErrorInput: @escaping (_ errorInputLimit: Int, _ currentFreezeTime: Int) -> ()) {
    guard self.currentFreezeTime == 0 else { return }
    
    self.behavior                = behavior
    self.defaultBehavior         = defaultBehavior
    self.behaviorAfterErrorInput = behaviorAfterErrorInput
    
    self.startTimer(seconds: self.newRequestFreezeTime)
  }
  
  /// Operation that need to be called when the user entered the code incorrectly
  /// - Parameters:
  ///   - defautBehaviorAfterErrors: Behavior after the end of the freeze time when the error input limit is exceeded
  ///   - errorInputLimit: Limit of error input
  func newErrorInput(with defautBehaviorAfterErrors: @escaping (_ errorInputLimit: Int) -> Void) {
    self.defautBehaviorAfterErrors = defautBehaviorAfterErrors
    self.errorInputCount += 1
    if self.errorInputCount > self.errorInputLimit && self.currentFreezeTime == 0 {
      self.defautBehaviorAfterErrors(self.errorInputLimit)
    }
  }
  
  private func startTimer(seconds: Int) {
    self.currentFreezeTime = seconds
    self.timer             = Timer.scheduledTimer(timeInterval : 1,
                                                  target       : self,
                                                  selector     : #selector(self.timerSelectorMethod),
                                                  userInfo     : nil,
                                                  repeats      : true)
  }
  
  @objc func timerSelectorMethod() {
    if self.currentFreezeTime != 0 {
      self.currentFreezeTime -= 1
      if self.errorInputCount > self.errorInputLimit {
        self.behaviorAfterErrorInput(self.errorInputLimit, self.currentFreezeTime)
      } else {
        self.behavior(self.currentFreezeTime)
      }
    } else {
      self.timer.invalidate()
      if self.errorInputCount > self.errorInputLimit {
        self.defautBehaviorAfterErrors(self.errorInputLimit)
      } else {
        self.defaultBehavior()
      }
    }
  }
}
