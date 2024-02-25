//
//  Double+Extension.swift
//  TemplateOfDealsViewer
//
//  Created by Anton Abramov on 25.02.2024.
//

extension Double {
  var roundedToHundredths: Double {
    (self * 100.0).rounded() / 100.0
  }
}
