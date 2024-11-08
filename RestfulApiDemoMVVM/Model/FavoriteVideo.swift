// MARK: - FavoriteVideo.swift
import Foundation

// MARK: - Models
struct FavoriteVideo: Codable {
    let id: String?
    
    var title: String
    var description: String
    let thumbnailURL: String
    var note: String?
    
    init(from video: Video, note: String? = nil) {
        self.id = video.id ?? UUID().uuidString
        self.title = video.title
        self.description = video.description
        self.thumbnailURL = video.thumbnailURL
        self.note = note
    }
}

// MARK: - Protocols
protocol FavoriteManageable {
    func fetchFavorites(completion: @escaping (Result<[FavoriteVideo], Error>) -> Void)
    func addToFavorites(_ video: FavoriteVideo, completion: @escaping (Result<FavoriteVideo, Error>) -> Void)
    func updateFavorite(_ video: FavoriteVideo, completion: @escaping (Result<FavoriteVideo, Error>) -> Void)
    func deleteFavorite(id: String, completion: @escaping (Result<Void, Error>) -> Void)
}

