//
//  FavoriteError.swift
//  RestfulApiDemoMVVM
//
//  Created by Lydia Lu on 2024/11/5.
//

import Foundation

// 新建一個 FavoriteError.swift 文件
enum FavoriteError: Error {
    case invalidData
    case invalidID
    case saveFailed
    case notFound
    case alreadyExists
    
    var localizedDescription: String {
        switch self {
        case .invalidData:
            return "無效的數據"
        case .invalidID:
            return "無效的ID"
        case .saveFailed:
            return "儲存失敗"
        case .notFound:
            return "找不到收藏"
        case .alreadyExists:
            return "已在收藏中"
        }
    }
}
