//
//  Observable.swift
//  VariableElement
//
//  Created by Anar on 28.07.2020.
//  Copyright © 2020 Commodo. All rights reserved.
//

import RxSwift

extension ObservableType {
  func withPrevious(startWith first: Element) -> Observable<(Element, Element)> {
    self
      .scan((first, first)) { ($0.1, $1) }
      .skip(1)
  }
}
