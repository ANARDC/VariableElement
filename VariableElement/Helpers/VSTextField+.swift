//
//  UITextField.swift
//  VariableElement
//
//  Created by Anar on 28.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

import UIKit

extension VSTextField {
  convenience init(superview: UIView, configuring: (VSTextField) -> (), constraints: (VSTextField) -> ()) {
    self.init()
    configuring(self)
    constraints(self)
  }
}

func *(lhs: Int, rhs: @autoclosure () -> VSTextField) -> [VSTextField] {
  Array(0..<lhs).map { _ in rhs() }
}
