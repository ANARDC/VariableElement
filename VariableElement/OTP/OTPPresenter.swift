//
//  OTPPresenter.swift
//  VariableElement
//
//  Created by Anar on 27.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

import RxSwift

final class OTPPresenter: OTPPresenterGeneralProtocol {
  weak var view: OTPUIProtocol!
  
  let input  : OTPInput
  let output : OTPOutput
  
  let newCodeManager: NewCodeManager
  
  let bag = DisposeBag()
  
  init(_ view: OTPUIProtocol, _ input: OTPInput, _ output: OTPOutput, _ newCodeManager: NewCodeManager) {
    self.view           = view
    self.input          = input
    self.output         = output
    self.newCodeManager = newCodeManager
  }
}

// MARK: - View Life Cycle
extension OTPPresenter: OTPLifeCyclePresenterProtocol {
  func viewDidLoad() {
    self.makeView()
    self.makeReactive()
    self.bindReactive()
  }
  
  func makeView() {
    self.view.makeView()
    self.view.makeTitleLabel()
    self.view.makeNumbersTextFields()
    self.view.makeNumbersStackView()
    self.view.makeNewCodeLabel()
    self.view.configureNumberTextFields()
  }
  
  func makeReactive() {
    self.setupMatchObserver()
    self.setupNewCodeLabelTapRecognizerObserver()
    self.setupResultSubscriber()
    self.setupErrorsSubscriber()
  }
  
  func bindReactive() {
    self.view.bindNumberTextFields()
    self.view.bindNewCodeLabelTapRecognizer()
    self.makeCode()
  }
}

// MARK: - Reactive
private extension OTPPresenter {
  func makeCode() {
    self.input.smsCode.onNext("1234")
  }
  
  func setupMatchObserver() {
    Observable
      .combineLatest(self.input.userCode, self.input.smsCode)
      .withPrevious(startWith: ("", ""))
      .filter { $0.0 != $0.1 }
      .map { $0.1 }
      .subscribe(onNext: { [unowned self] userCode, smsCode in
        if !userCode.isEmpty {
          self.view.changeNumberTextFields(state: userCode == smsCode[0..<userCode.count])
        } else {
          self.view.changeNumberTextFields(state: true)
        }
        
        if userCode == smsCode {
          self.output.result.onNext(true)
        }
        
        guard userCode.count == smsCode.count else { return }
        
        if userCode != smsCode {
          self.newCodeManager.newErrorInput() { errorInputLimit in
            self.view.newCodeLabelState = .afterErrorInput(errorInputLimit)
          }
          self.output.result.onNext(false)
        }
      })
      .disposed(by: self.bag)
  }
  
  func setupNewCodeLabelTapRecognizerObserver() {
    self.input.newCodeLabelTapRecognizer
      .skip(1)
      .subscribe(onNext: { [unowned self] recognizer in
        self.newCodeManager.newCodeRequest { currentFreezeTime in
          self.view.newCodeLabelState = .freezeBeforeErrorInput(currentFreezeTime)
        }
        `default`: {
          self.view.newCodeLabelState = .beforeErrorInput
        }
        afterErrorInput: { errorInputLimit, currentFreezeTime in
          self.view.newCodeLabelState = .freezeAfterErrorInput(errorInputLimit, currentFreezeTime)
        }
        self.makeCode()
      })
      .disposed(by: self.bag)
  }
  
  func setupResultSubscriber() {
    self.output.result
      .subscribe(onNext: { [unowned self] match in
        switch match {
          case true:
            self.view.makeSuccessAlert()
          case false:
            self.output.errors.onNext(OTPError())
        }
      })
      .disposed(by: self.bag)
  }
  
  func setupErrorsSubscriber() {
    self.output.errors
      .subscribe(onNext: { error in
        print(error)
      })
      .disposed(by: self.bag)
  }
}
