//
//  OTPProtocols.swift
//  VariableElement
//
//  Created by Anar on 27.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

import UIKit

// MARK: View

protocol OTPViewProtocol: UIViewController, OTPUIProtocol {
  var presenter: OTPViewPresenterProtocol! { get set }
}

protocol OTPUIProtocol: class, OTPNewCodeLabelMutable, OTPViewReactive {
  func makeView()
  func makeTitleLabel()
  func makeNumbersTextFields()
  func makeNumbersStackView()
  func makeNewCodeLabel()
  func makeSuccessAlert()
  func changeNumberTextFields(state correctInput: Bool)
  func configureNumberTextFields()
}

protocol OTPNewCodeLabelMutable {
  var newCodeLabelState: NewCodeLabelState! { get set }
}

protocol OTPViewReactive {
  func bindNumberTextFields()
  func bindNewCodeLabelTapRecognizer()
}

// MARK: Presenter

protocol OTPPresenterGeneralProtocol: OTPViewPresenterProtocol {}

protocol OTPViewPresenterProtocol: OTPLifeCyclePresenterProtocol, OTPPresenterReactive {
  var view: OTPUIProtocol! { get set }
}

protocol OTPLifeCyclePresenterProtocol: class {
  func viewDidLoad()
}

protocol OTPPresenterReactive: class {
  var input  : OTPInput { get }
  var output : OTPOutput { get }
}


// MARK: Configurator

protocol OTPConfiguratorProtocol {
  func configure(_ view: OTPViewProtocol)
}
