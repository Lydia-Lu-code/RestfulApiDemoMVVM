import UIKit

class FavoriteVideosViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = FavoriteVideosViewModel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(FavoriteVideoCell.self, forCellReuseIdentifier: FavoriteVideoCell.identifier)
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchFavorites()
    }
    
    private func bindViewModel() {
        viewModel.favorites.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        viewModel.error.bind { [weak self] error in
            if let error = error {
                self?.showError(error as! Error)  // 直接傳遞 Error 對象
            }
        }
        
        viewModel.isLoading.bind { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
            } else {
                self?.loadingIndicator.stopAnimating()
            }
        }
    }

}

extension FavoriteVideosViewController {
    // MARK: - UI Setup
    private func setupUI() {
        title = "我的收藏"
        view.backgroundColor = .systemBackground
        setupTableView()
        setupLoadingIndicator()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func handleRefresh() {
        viewModel.fetchFavorites()
        tableView.refreshControl?.endRefreshing()
    }
    
    // MARK: - Alert Controllers
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "錯誤",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    private func showEditAlert(for favorite: FavoriteVideo) {
        let alert = UIAlertController(
            title: "編輯收藏",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.text = favorite.title
            textField.placeholder = "標題"
        }
        
        alert.addTextField { textField in
            textField.text = favorite.note
            textField.placeholder = "筆記"
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "更新", style: .default) { [weak self] _ in
            guard let newTitle = alert.textFields?[0].text,
                  let newNote = alert.textFields?[1].text else { return }
            
            var updatedFavorite = favorite
            updatedFavorite.title = newTitle
            updatedFavorite.note = newNote
            
            self?.viewModel.updateFavorite(updatedFavorite) { result in
                switch result {
                case .success:
                    self?.viewModel.fetchFavorites()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        })
        
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource
extension FavoriteVideosViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favorites.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteVideoCell.identifier, for: indexPath) as? FavoriteVideoCell else {
            return UITableViewCell()
        }
        
        if let favorite = viewModel.getFavorite(at: indexPath.row) {
            cell.configure(with: favorite)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - TableView Methods
extension FavoriteVideosViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteFavorite(at: indexPath.row) { [weak self] result in
                switch result {
                case .success:
                    self?.viewModel.fetchFavorites()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let favorite = viewModel.getFavorite(at: indexPath.row) {
            showEditAlert(for: favorite)
        }
    }
}
