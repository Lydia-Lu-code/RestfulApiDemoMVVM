import Foundation

class VideoListViewModel {
    // MARK: - Properties
    private(set) var videos = Observable<[Video]>([])
    private(set) var error = Observable<String?>(nil)
    private(set) var isLoading = Observable<Bool>(false)
    private let favoriteManager: FavoriteManageable
    
    // MARK: - Initialization
    init(favoriteManager: FavoriteManageable = FavoriteManagerProvider.shared.favoriteManager) {
        self.favoriteManager = favoriteManager
    }
    
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
    
    func addToFavorites(at index: Int, note: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let video = getVideo(at: index) else {
            completion(.failure(FavoriteError.invalidData))
            return
        }
        
        let favoriteVideo = FavoriteVideo(from: video, note: note)
        favoriteManager.addToFavorites(favoriteVideo) { result in
            DispatchQueue.main.async {
                completion(result.map { _ in () })
            }
        }
    }
    
    func getVideo(at index: Int) -> Video? {
        guard index < videos.value.count else { return nil }
        return videos.value[index]
    }
}

