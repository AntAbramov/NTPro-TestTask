import UIKit

final class DealCell: UITableViewCell {
  static let reuseIidentifier = "DealCell"
  
  // MARK: UI
  @IBOutlet weak var instrumentNameLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var sideLabel: UILabel!
  
  // MARK: - entry point
  func configure(with cellModel: DealCellModel) {
    instrumentNameLabel.text = cellModel.instrumentName
    priceLabel.text = cellModel.roundedPrice
    amountLabel.text = cellModel.roundedAmount
    sideLabel.text = sideLabelText(for: cellModel.side)
    sideLabel.textColor = sideLabelColor(for: cellModel.side)
  }
}

private extension DealCell {
  func sideLabelColor(for side: Deal.Side) -> UIColor {
    if case .sell = side {
      return .red
    }
    return .green
  }
  
  func sideLabelText(for side: Deal.Side) -> String {
    if case .sell = side {
      return "Sell"
    }
    return "Buy"
  }
}
