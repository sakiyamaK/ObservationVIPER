//
//  API.swift
//
//
//  Created by sakiyamaK on 2024/09/16.
//

import Foundation

public struct APIResult: Codable {
    var results: [User]
}

public struct API {
    private init() {}
    static let shared = API()
    
    func getUsers() async throws -> [User] {
        let urlStr = "https://randomuser.me/api/?page=0&results=30&seed=abc"
        let url = URL(string: urlStr)!
        let urlRequest = URLRequest(url: url)
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let result = try JSONDecoder().decode(APIResult.self, from: data)
            return result.results
        }
        catch let e {
            throw e
        }
    }
}
