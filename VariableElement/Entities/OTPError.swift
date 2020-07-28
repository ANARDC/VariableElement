//
//  OTPError.swift
//  VariableElement
//
//  Created by Anar on 28.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

struct OTPError: Error, CustomDebugStringConvertible {
  var debugDescription: String {
    "Коды не совпадают"
  }
}
