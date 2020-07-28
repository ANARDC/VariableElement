//
//  NewCodeLabelState.swift
//  VariableElement
//
//  Created by Anar on 28.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

import UIKit

/// States of newCodeLabel
enum NewCodeLabelState {
  case beforeErrorInput
  case afterErrorInput(Int)
  case freezeBeforeErrorInput(Int)
  case freezeAfterErrorInput(Int, Int)
  
  /// Mutation of label for some state
  /// - Parameter label: newCodeLabel
  func mutate(for label: UILabel) {
    var firstPart  : String!
    var secondPart : String!
    
    defer { self.changeText(for: label, firstPart: firstPart, secondPart: secondPart) }
    
    switch self {
      case .beforeErrorInput:
        firstPart = "Не получили СМС с кодом? Вы можете запросить новый код ."
        secondPart = "сейчас"
      case .afterErrorInput(let errorInputLimit):
        firstPart = "Вы неверно ввели код более \(errorInputLimit) раз. ?"
        secondPart = "Запросить новый код"
      case .freezeBeforeErrorInput(let currentFreezeTime):
        firstPart = "Не получили СМС с кодом? Вы можете запросить новый код ."
        secondPart = "через \(currentFreezeTime) секунд(-у)"
      case .freezeAfterErrorInput(let errorInputLimit, let currentFreezeTime):
        firstPart = "Вы неверно ввели код более \(errorInputLimit) раз. Вы можете запросить новый код ."
        secondPart = "через \(currentFreezeTime) секунд(-у)"
    }
  }
  
  private func changeText(for label: UILabel, firstPart: String, secondPart: String) {
    let resultText      = firstPart
    let resultTextAttrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.black]
    let resultString    = NSMutableAttributedString(string: resultText, attributes: resultTextAttrs)
    
    let markedBoldText       = secondPart
    let markedBoldTextArttrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold)]
    let markedBoldString     = NSMutableAttributedString(string: markedBoldText, attributes: markedBoldTextArttrs)
    
    resultString.insert(markedBoldString, at: resultText.count - 1)
    resultString.addAttribute(NSAttributedString.Key.foregroundColor,
                              value: UIColor.green,
                              range: NSRange(location: resultText.count - 1, length: markedBoldText.count))
    
    label.attributedText = resultString
    label.numberOfLines  = 0
  }
}
