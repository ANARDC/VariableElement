//
//  Input.swift
//  VariableElement
//
//  Created by Anar on 28.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

import RxSwift

struct OTPInput {
  let userCode                  : PublishSubject<String>
  let smsCode                   : PublishSubject<String>
  let newCodeLabelTapRecognizer : PublishSubject<UITapGestureRecognizer>
}
