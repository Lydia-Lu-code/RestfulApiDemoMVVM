//
//  ViewController.swift
//  RestfulApiDemoMVVM
//
//  Created by Lydia Lu on 2024/10/31.
//

import UIKit

// MARK: - VideoViewController.swift
class VideoViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = VideoListViewModel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(VideoTableViewCell.self, forCellReuseIdentifier: VideoTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchVideos()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "熱門影片"
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        tableView.frame = view.bounds
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.videos.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        viewModel.error.bind { [weak self] error in
            if let error = error {
                self?.showError(message: error)
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
    
    // MARK: - Alert Handlers
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "錯誤",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "成功",
            message: "已添加到收藏",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension VideoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.videos.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoTableViewCell.identifier,
                                                     for: indexPath) as? VideoTableViewCell,
              let video = viewModel.getVideo(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        cell.configure(with: video)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Favorite Feature
extension VideoViewController {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        
        let favoriteAction = UIContextualAction(style: .normal, title: "收藏") { [weak self] (action, view, completion) in
            self?.showAddToFavoritesAlert(for: indexPath)
            completion(true)
        }
        favoriteAction.backgroundColor = .systemYellow
        
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
    
    private func showAddToFavoritesAlert(for indexPath: IndexPath) {
        guard let video = viewModel.getVideo(at: indexPath.row) else { return }
        
        let alert = UIAlertController(
            title: "添加到收藏",
            message: "要添加筆記嗎？",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "筆記（選填）"
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "確定", style: .default) { [weak self] _ in
            let note = alert.textFields?.first?.text
            
            self?.viewModel.addToFavorites(video: video, note: note) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.showSuccessAlert()
                    case .failure(let error):
                        self?.showError(message: error.localizedDescription)
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
}

