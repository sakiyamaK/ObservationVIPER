//
//  KingfisherManager.swift
//
//
//  Created by sakiyamaK on 2024/09/21.
//

import UIKit
import Kingfisher

extension KingfisherManager {
    func asyncRetrieveImage(with url: URL) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            self.retrieveImage(with: url) { result in
                switch result {
                case .success(let retrieveImageResult):
                    continuation.resume(returning: retrieveImageResult.image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
