import UIKit

class CryptoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    private let tableView: UITableView = {
        let tableview = UITableView(frame: .zero, style: .grouped)
        tableview.register(CryptoTableViewCell.self, forCellReuseIdentifier: CryptoTableViewCell.idendifier)
        return tableview
    }()
    
    private var viewModels = [CryptoTableViewCellViewModel]()
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.allowsFloats = true
        formatter.numberStyle = .currency
        formatter.formatterBehavior = .default
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Crypto Tracker"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        APICaller.shared.getAllCryptoData { [weak self] result in
            switch result {
            case .success(let models):
                
                self?.viewModels = models.compactMap({
                    let price = $0.price_usd ?? 0
                    let formatter = CryptoViewController.numberFormatter
                    let priceString = formatter.string(from: NSNumber (value: price))
                    let cryptoAssetId = $0.asset_id
                    let iconUrl = URL(
                        string:
                            APICaller.shared.icons.filter({ icon in
                                icon.asset_id == cryptoAssetId
                            }).first?.url ?? ""
                    )
                    
                    return  CryptoTableViewCellViewModel(
                        name:$0.name ?? "N/A",
                        symbol: $0.asset_id ?? "Empty",
                        price: priceString ?? "N/A",
                        iconUrl: iconUrl
                    )
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error:\(error)")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoTableViewCell.idendifier, for: indexPath) as? CryptoTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

