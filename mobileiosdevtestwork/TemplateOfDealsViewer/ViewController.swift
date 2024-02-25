import UIKit

final class ViewController: UIViewController {
  // MARK: UI
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var sortBarButton: UIBarButtonItem!
  
  // MARK: Dependency
  private let server = Server()
  
  // MARK: - DataSource
  private var model: [Deal] = []
  private var dataSource: [DealCellModel] = []
  private var dataSourceCornerIndex = 100
  private var updateDataSourceIndex: Int {
    dataSourceCornerIndex - 20
  }
  
  // MARK: Sort
  private let sortingQueue = DispatchQueue(label: "DataSortingQueue", attributes: .concurrent)
  private let dataMappingQueue = DispatchQueue(label: "DataMappingQueue", attributes: .concurrent)
  private var sortType: SortType = .dateModified(.new)
  
  // MARK: viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    configureViewController()
    self.server.subscribeToDeals { [weak self] deals in
      guard let self else { return }
      self.updateData(
        cornerIndex: self.dataSourceCornerIndex,
        sortType: self.sortType,
        newDeals: deals
      )
    }
  }
}

// MARK: - Private Methods

private extension ViewController {
  func updateData(cornerIndex: Int, sortType: SortType, newDeals: [Deal] = []) {
    performSortData(newDeals, model: model, predicate: sortType.predicate) { sortedModel in
      self.model = sortedModel
      self.performMapData(for: sortedModel, with: cornerIndex) { cellData in
        self.dataSource = cellData
        self.tableView.reloadData()
      }
    }
  }
  
  func performSortData(
    _ newDeals: [Deal], model: [Deal],
    predicate: @escaping (Deal, Deal) -> Bool,
    completion: @escaping ([Deal]) -> Void
  ) {
    var tempDeals = model
    let sortWorkItem = DispatchWorkItem {
      tempDeals.append(contentsOf: newDeals)
      tempDeals.sort(by: predicate)
    }
    sortingQueue.async(execute: sortWorkItem)
    sortWorkItem.notify(queue: .main) {
      completion(tempDeals)
    }
  }
  
  func performMapData(
    for model: [Deal], with count: Int,
    completion: @escaping ([DealCellModel]) -> Void
  ) {
    var cellData = [DealCellModel]()
    let mapWorkItem = DispatchWorkItem {
      let neededModelSlice = Array(model.prefix(count))
      cellData = neededModelSlice.map {
        DealCellModel(
          instrumentName: $0.instrumentName,
          roundedPrice: "\($0.price.roundedToHundredths)",
          roundedAmount: String(format: "%.0f", $0.amount.rounded()),
          side: $0.side
        )
      }
    }
    dataMappingQueue.async(execute: mapWorkItem)
    mapWorkItem.notify(queue: .main) {
      completion(cellData)
    }
  }
  
  func configureViewController() {
    navigationItem.title = "Deals"
    tableView.dataSource = self
    tableView.delegate = self
    registerTableCells()
  }
  
  func registerTableCells() {
    tableView.register(UINib(nibName: DealCell.reuseIidentifier, bundle: nil), forCellReuseIdentifier: DealCell.reuseIidentifier)
    tableView.register(UINib(nibName: HeaderCell.reuseIidentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: HeaderCell.reuseIidentifier)
  }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int { 1 }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == updateDataSourceIndex {
      increaseDataSourceIndexes()
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: DealCell.reuseIidentifier, for: indexPath) as! DealCell
    cell.configure(with: dataSource[indexPath.row])
    return cell
  }
}

private extension ViewController {
  func increaseDataSourceIndexes() {
    self.dataSourceCornerIndex += 100
    performMapData(for: model,with: dataSourceCornerIndex) { [weak self] in
      guard let self else { return }
      self.dataSource = $0
      self.tableView.reloadData()
    }
  }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderCell.reuseIidentifier) as! HeaderCell
    cell.configure(sortType: sortType)
    cell.onSortTypeChanged = { [weak self] in
      guard let self else { return }
      self.sortType = $0
      self.updateData(cornerIndex: self.dataSourceCornerIndex, sortType: $0)
      self.tableView.reloadData()
    }
    return cell
  }
}
