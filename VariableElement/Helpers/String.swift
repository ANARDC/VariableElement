//
//  String.swift
//  VariableElement
//
//  Created by Anar on 28.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

extension String {
  subscript(bounds: CountableClosedRange<Int>) -> String {
    String(
      self[
        self.index(startIndex, offsetBy: bounds.lowerBound)
        ..<
        self.index(startIndex, offsetBy: bounds.upperBound)
      ]
    )
  }
  
  subscript(bounds: CountableRange<Int>) -> String {
    String(
      self[
        self.index(startIndex, offsetBy: bounds.lowerBound)
        ..<
        self.index(startIndex, offsetBy: bounds.upperBound)
      ]
    )
  }
}
