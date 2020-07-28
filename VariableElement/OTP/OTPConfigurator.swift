//
//  OTPConfigurator.swift
//  VariableElement
//
//  Created by Anar on 27.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

import RxSwift

final class OTPConfigurator: OTPConfiguratorProtocol {
  var presenter: OTPPresenterGeneralProtocol!
  
  init(_ view: OTPUIProtocol) {
    let input = OTPInput(userCode: PublishSubject<String>(),
                          smsCode: PublishSubject<String>(),
                          newCodeLabelTapRecognizer: PublishSubject<UITapGestureRecognizer>())
    let output = OTPOutput(errors: PublishSubject<Error>(),
                            result: PublishSubject<Bool>())
    
    let newCodeManager = NewCodeManager(newRequestFreezeTime: 10,
    errorInputLimit: 3)
    
    self.presenter = OTPPresenter(view, input, output, newCodeManager)
  }
  
  func configure(_ view: OTPViewProtocol) {
    view.presenter = self.presenter
  }
}
