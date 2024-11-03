//
//  VideoListViewModel.swift
//  RestfulApiDemoMVVM
//
//  Created by Lydia Lu on 2024/11/3.
//

import Foundation

// MARK: - VideoListViewModel.swift
class VideoListViewModel {
    // MARK: - Properties
    private(set) var videos = Observable<[Video]>([])
    private(set) var error = Observable<String?>(nil)
    private(set) var isLoading = Observable<Bool>(false)
    
    // MARK: - Methods
    func fetchVideos() {
        isLoading.value = true
        
        NetworkManager.shared.fetchVideos { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading.value = false
                
                switch result {
                case .success(let videos):
                    self?.videos.value = videos
                case .failure(let error):
                    self?.error.value = error.localizedDescription
                }
            }
        }
    }
    
    func addToFavorites(video: Video, note: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        let favoriteVideo = FavoriteVideo(from: video, note: note)
        
        LocalFavoriteManager.shared.addToFavorites(favoriteVideo) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getVideo(at index: Int) -> Video? {
        guard index < videos.value.count else { return nil }
        return videos.value[index]
    }
}
