//
//  SortType.swift
//  TemplateOfDealsViewer
//
//  Created by Anton Abramov on 25.02.2024.
//

// MARK: - Direction

enum SortDirection {
  case new, old
  
  func reversed() -> SortDirection {
    if self == .new { return .old }
    return .new
  }
}

// MARK: - SortType

enum SortType {
  case dateModified(SortDirection)
  case instrumentName(SortDirection)
  case price(SortDirection)
  case amount(SortDirection)
  case side(SortDirection)
}

// MARK:  init
extension SortType {
  init?(row: Int, sortDirection: SortDirection = .new) {
    switch row {
    case 0: self = .dateModified(sortDirection)
    case 1: self = .instrumentName(sortDirection)
    case 2: self = .price(sortDirection)
    case 3: self = .amount(sortDirection)
    case 4: self = .side(sortDirection)
    default:
      return nil
    }
  }
}

// MARK: Methods
extension SortType {
  func withReversedDirection() -> SortType {
    self.with(direction: self.associatedValue.reversed())
  }
  
  private func with(direction: SortDirection) -> SortType {
    switch self {
    case .dateModified: return .dateModified(direction)
    case .instrumentName: return .instrumentName(direction)
    case .price: return .price(direction)
    case .amount: return .amount(direction)
    case .side: return .side(direction)
    }
  }
}

// MARK: Property
extension SortType {
  var row: Int {
    switch self {
    case .dateModified: return 0
    case .instrumentName: return 1
    case .price: return 2
    case .amount: return 3
    case .side: return 4
    }
  }
  
  var associatedValue: SortDirection {
    switch self {
    case .dateModified(let direction): return direction
    case .instrumentName(let direction): return direction
    case .price(let direction): return direction
    case .amount(let direction): return direction
    case .side(let direction): return direction
    }
  }
}

// MARK: Predicate for Sorting
extension Deal.Side: Comparable {
  static func < (lhs: Deal.Side, rhs: Deal.Side) -> Bool {
      switch (lhs, rhs) {
      case (.sell, .buy): return true
      default: return false
      }
  }
}

extension SortType {
  var predicate: ((Deal, Deal) -> Bool) {
    switch self {
      
    case let .dateModified(sortDirection):
      if sortDirection == .new {
        return { $0.dateModifier > $1.dateModifier }
      }
      return { $0.dateModifier < $1.dateModifier }
      
    case let .instrumentName(sortDirection):
      if sortDirection == .new {
        return { $0.instrumentName > $1.instrumentName }
      }
      return { $0.instrumentName < $1.instrumentName }
      
    case let .price(sortDirection):
      if sortDirection == .new {
        return { $0.price > $1.price }
      }
      return { $0.price < $1.price }
      
    case let .amount(sortDirection):
      if sortDirection == .new {
        return { $0.amount > $1.amount }
      }
      return { $0.amount < $1.amount }
      
    case let .side (sortDirection):
      if sortDirection == .new {
        return { $0.side > $1.side }
      }
      return { $0.side < $1.side }
    }
  }
}

// MARK: String Literals
extension SortType {
  static private let labelStringValues: [String] = [
    "", // Have not Date Modified Label in TableView's Header
    "Instrument",
    "Price",
    "Amount",
    "Side"
  ]
  
  static func defaultLabelStringValue(for tag: Int) -> String {
    Self.labelStringValues[tag]
  }
  
  var defaultLabelStringValue: String {
    Self.labelStringValues[row]
  }
  
  var labelStringValueWithSortDirection: String {
    if self.associatedValue == .new {
      return "↓ " + defaultLabelStringValue
    }
    return "↑ " + defaultLabelStringValue
  }
}
