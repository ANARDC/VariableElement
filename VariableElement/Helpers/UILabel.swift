//
//  UILabel.swift
//  VariableElement
//
//  Created by Anar on 27.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

import UIKit

extension UILabel {
  convenience init(superview: UIView, configuring: (UILabel) -> (), constraints: (UILabel) -> ()) {
    self.init()
    configuring(self)
    superview.addSubview(self)
    constraints(self)
  }
}
