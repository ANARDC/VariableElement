//
//  OTPView.swift
//  VariableElement
//
//  Created by Anar on 27.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import SnapKit

final class OTPViewController: UIViewController, OTPViewProtocol {
  var configurator : OTPConfiguratorProtocol!
  var presenter    : OTPViewPresenterProtocol!
  
  var titleLabel        : UILabel!
  var numbersTextFields : [VSTextField]!
  var numbersStackView  : UIStackView!
  var newCodeLabel      : UILabel!
  
  var previousCode : String = ""
  var currentCode  : String = ""
  
  var newCodeLabelState: NewCodeLabelState! {
    willSet(newState) {
      newState.mutate(for: self.newCodeLabel)
    }
  }
  
  let bag = DisposeBag()
}

// MARK: - Life Cycle
extension OTPViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configurator = OTPConfigurator(self)
    self.configurator.configure(self)
    self.presenter.viewDidLoad()
  }
}

// MARK: - Reactive
extension OTPViewController {
  func bindNumberTextFields() {
    let firstNumber  = PublishSubject<String?>()
    let secondNumber = PublishSubject<String?>()
    let thirdNumber  = PublishSubject<String?>()
    let fourthNumber = PublishSubject<String?>()
    
    let userCodeNumbers = [firstNumber, secondNumber, thirdNumber, fourthNumber]
    
    self.numbersTextFields.enumerated().forEach { index, textField in
      textField.rx.text
        .subscribe(userCodeNumbers[index])
        .disposed(by: self.bag)
    }
    
    Observable
      .combineLatest(userCodeNumbers.map { $0.startWith("") })
      .subscribe(onNext: { self.presenter.input.userCode.onNext($0.compactMap { $0 }.joined()) })
      .disposed(by: self.bag)
  }
  
  func bindNewCodeLabelTapRecognizer() {
    self.newCodeLabel.rx
      .tapGesture()
      .subscribe(self.presenter.input.newCodeLabelTapRecognizer)
      .disposed(by: self.bag)
  }
}

// MARK: - UI Making
extension OTPViewController: OTPUIProtocol {
  func makeView() {
    self.view.backgroundColor = .white
  }
  
  func makeTitleLabel() {
    self.titleLabel = UILabel(
      superview: self.view,
      configuring: { label in
        label.font          = .systemFont(ofSize: 26, weight: .bold)
        label.text          = "Экран получения единовременного пароля"
        label.textColor     = .black
        label.numberOfLines = 0
    },
      constraints: { label in
        label.snp.makeConstraints { maker in
          maker.centerX.equalTo(self.view.snp.centerX)
          maker.top.equalTo(self.view.snp.top).offset(50)
          maker.left.greaterThanOrEqualTo(self.view.snp.left).offset(20)
          maker.right.lessThanOrEqualTo(self.view.snp.right).offset(-20)
        }
    })
  }
  
  func makeNumbersTextFields() {
    self.numbersTextFields = 4 * VSTextField(
        superview: self.view,
        configuring: { textField in
          let elementColor = UIColor.green
          
          textField.font               = .systemFont(ofSize: 26, weight: .bold)
          textField.textAlignment      = .center
          textField.keyboardType       = .numberPad
          textField.borderStyle        = .none
          textField.layer.cornerRadius = 16
          textField.layer.borderWidth  = 3
          textField.tintColor          = elementColor
          textField.textColor          = elementColor
          textField.layer.borderColor  = elementColor.cgColor
          
          textField.setFormatting("#", replacementChar: "#")
      },
        constraints: { textField in
          textField.snp.makeConstraints { $0.height.width.equalTo(52) }
      })
  }
  
  func makeNumbersStackView() {
    self.numbersStackView = UIStackView(
      superview: self.view,
      arrangedSubviews: self.numbersTextFields,
      configuring: { stackView in
        stackView.axis        = .horizontal
        stackView.spacing     = 31
        stackView.contentMode = .scaleToFill
    },
      constraints: { stackView in
        stackView.snp.makeConstraints { maker in
          maker.width.equalTo(301)
          maker.center.equalTo(self.view)
        }
    })
  }
  
  func makeNewCodeLabel() {
    self.newCodeLabel = UILabel(
      superview: self.view,
      configuring: { label in
        label.textColor = .black
        label.font      = .systemFont(ofSize: 16, weight: .regular)
        
        let resultText      = "Не получили СМС с кодом? Вы можете запросить новый код ."
        let resultTextAttrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.black]
        let resultString    = NSMutableAttributedString(string: resultText, attributes: resultTextAttrs)
        
        let markedBoldText       = "сейчас"
        let markedBoldTextArttrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold)]
        let markedBoldString     = NSMutableAttributedString(string: markedBoldText, attributes: markedBoldTextArttrs)
        
        resultString.insert(markedBoldString, at: resultText.count - 1)
        resultString.addAttribute(NSAttributedString.Key.foregroundColor,
                                  value: UIColor.green,
                                  range: NSRange(location: resultText.count - 1, length: markedBoldText.count))
        
        label.attributedText = resultString
        label.numberOfLines  = 0
        
    },
      constraints: { label in
        label.snp.makeConstraints { maker in
          maker.top.equalTo(self.numbersStackView.snp.bottom).offset(20)
          maker.left.equalTo(self.view.snp.left).offset(20)
          maker.right.equalTo(self.view.snp.right).offset(-20)
        }
    })
  }
  
  func makeSuccessAlert() {
    let alert = UIAlertController(title: "Ты угадал код", message: "🥳", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Я мамин хацкер", style: UIAlertAction.Style.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
}

// MARK: - UITextField
extension OTPViewController: UIGestureRecognizerDelegate, UITextFieldDelegate {
  func configureNumberTextFields() {
    self.numbersTextFields.forEach { textField in
      textField.delegate = self
      textField.addTarget(self, action: #selector(self.numberDidChange(textField:)), for: .editingChanged)
    }
    self.numbersTextFields.first?.becomeFirstResponder()
  }
  
  @objc func numberDidChange(textField: UITextField) {
    guard let text = textField.text else { return }
    
    self.previousCode = self.currentCode
    self.currentCode.append(text)
    
    if self.currentCode.count > self.previousCode.count {
      switch textField {
      case self.numbersTextFields[0]:
        self.numbersTextFields[1].becomeFirstResponder()
      case self.numbersTextFields[1]:
        self.numbersTextFields[2].becomeFirstResponder()
      case self.numbersTextFields[2]:
        self.numbersTextFields[3].becomeFirstResponder()
      case self.numbersTextFields[3]:
        self.numbersTextFields[3].resignFirstResponder()
      default:
        return
      }
    }
    else {
      switch textField {
      case self.numbersTextFields[0]:
        self.numbersTextFields[0].resignFirstResponder()
      case self.numbersTextFields[1]:
        self.numbersTextFields[0].becomeFirstResponder()
      case self.numbersTextFields[2]:
        self.numbersTextFields[1].becomeFirstResponder()
      case self.numbersTextFields[3]:
        self.numbersTextFields[2].becomeFirstResponder()
      default:
        return
      }
    }
  }
  
  func changeNumberTextFields(state correctInput: Bool) {
    self.numbersTextFields.forEach { textField in
      textField.tintColor         = correctInput ? UIColor.green : UIColor.red
      textField.textColor         = correctInput ? UIColor.green : UIColor.red
      textField.layer.borderColor = correctInput ? UIColor.green.cgColor : UIColor.red.cgColor
    }
  }
}
