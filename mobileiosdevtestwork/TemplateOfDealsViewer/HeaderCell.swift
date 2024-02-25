import UIKit

class HeaderCell: UITableViewHeaderFooterView {
  static let reuseIidentifier = "HeaderCell"
  
  // MARK: @IBOutlet
  @IBOutlet weak var instrumentNameTitlLabel: UILabel!
  @IBOutlet weak var priceTitleLabel: UILabel!
  @IBOutlet weak var amountTitleLabel: UILabel!
  @IBOutlet weak var sideTitleLabel: UILabel!
  
  // MARK: DataSource
  private var sortType: SortType?
  private var parametersLabelArray: [UILabel] = []
  
  // MARK: Callback
  var onSortTypeChanged: ((SortType) -> Void)?
  
  // MARK: awakeFromNib
  override func awakeFromNib() {
    super.awakeFromNib()
    fillParametersLabelArray()
    configureLabels()
  }
  
  // MARK: - entry point
  func configure(sortType: SortType) {
    self.sortType = sortType
  }
}

// MARK: - Private Methods

private extension HeaderCell {
  func fillParametersLabelArray() {
    parametersLabelArray.append(contentsOf: [
      instrumentNameTitlLabel,
      priceTitleLabel,
      amountTitleLabel,
      sideTitleLabel
    ])
  }
  
  // Tag must match row property of SortType
  func configureLabels() {
    var tagCounter = 1
    parametersLabelArray.forEach { label in
      let tapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(labelDidTapped)
      )
      label.addGestureRecognizer(tapGestureRecognizer)
      label.isUserInteractionEnabled = true
      label.tag = tagCounter
      label.text = SortType.defaultLabelStringValue(for: label.tag)
      tagCounter += 1
    }
  }
}

private extension HeaderCell {
  @objc func labelDidTapped(sender: UITapGestureRecognizer) {
    guard let sortType, let label = sender.view as? UILabel else {
      return
    }
    defineNewSortType(for: label, oldSortType: sortType)
  }
  
  func defineNewSortType(for label: UILabel, oldSortType: SortType) {
    guard let labelAssociatedSortType = SortType(row: label.tag) else {
      return
    }
    let newSortType: SortType
    defer {
      performUpdate(with: newSortType, and: oldSortType)
    }
    if labelAssociatedSortType.row == oldSortType.row {
      newSortType = oldSortType.withReversedDirection()
      return
    }
    newSortType = labelAssociatedSortType
  }
  
  func performUpdate(with newSortType: SortType, and oldSortType: SortType) {
    onSortTypeChanged?(newSortType)
    updateTitleText(new: newSortType, old: oldSortType)
  }
  
  // Change sort direction arrow in label
  // Or set label's text to default if sort type was changed
  func updateTitleText(new newSortType: SortType, old oldSortType: SortType) {
    guard let newLabel = viewWithTag(newSortType.row) as? UILabel else { 
      return
    }
    defer {
      newLabel.text = newSortType.labelStringValueWithSortDirection
    }
    guard let oldLabel = viewWithTag(oldSortType.row) as? UILabel else { 
      return
    }
    if newSortType.row != oldSortType.row {
      oldLabel.text = oldSortType.defaultLabelStringValue
    }
  }
}
