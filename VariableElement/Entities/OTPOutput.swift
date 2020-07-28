//
//  Output.swift
//  VariableElement
//
//  Created by Anar on 28.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

import RxSwift

struct OTPOutput {
  let errors : PublishSubject<Error>
  let result : PublishSubject<Bool>
}
