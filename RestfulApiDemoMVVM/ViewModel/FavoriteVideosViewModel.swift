//
//  FavoriteVideosViewModel.swift
//  RestfulApiDemoMVVM
//
//  Created by Lydia Lu on 2024/11/5.
//

import Foundation


class FavoriteVideosViewModel {
    // MARK: - Properties
    private(set) var favorites = Observable<[FavoriteVideo]>([])
    private(set) var error = Observable<String?>(nil)
    private(set) var isLoading = Observable<Bool>(false)
    private let favoriteManager: FavoriteManageable
    
    // MARK: - Initialization
    init(favoriteManager: FavoriteManageable = FavoriteManagerProvider.shared.favoriteManager) {
        self.favoriteManager = favoriteManager
    }
    
    // MARK: - Methods
    func fetchFavorites() {
        isLoading.value = true
        
        favoriteManager.fetchFavorites { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading.value = false
                
                switch result {
                case .success(let favorites):
                    self?.favorites.value = favorites
                case .failure(let error):
                    self?.error.value = error.localizedDescription
                }
            }
        }
    }
    
    func updateFavorite(_ favorite: FavoriteVideo, completion: @escaping (Result<Void, Error>) -> Void) {
        favoriteManager.updateFavorite(favorite) { result in
            DispatchQueue.main.async {
                completion(result.map { _ in () })
            }
        }
    }
    
    func deleteFavorite(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = favorites.value[index].id else {
            completion(.failure(FavoriteError.invalidData))
            return
        }
        
        favoriteManager.deleteFavorite(id: id) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func getFavorite(at index: Int) -> FavoriteVideo? {
        guard index < favorites.value.count else { return nil }
        return favorites.value[index]
    }
}
