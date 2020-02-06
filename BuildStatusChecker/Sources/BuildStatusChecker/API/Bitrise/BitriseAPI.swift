import Foundation
import Combine

class BitriseAPI {
}

// MARK: - Fetching branches
extension BitriseAPI {
    static func branches(config: BitriseConfiguration) -> AnyPublisher<BitriseBranches, Error> {
        let url = URL(string: "\(config.baseUrl)/\(config.appSlug)/branches")!
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(config.authToken, forHTTPHeaderField: "Authorization")

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601

        let publisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
        .map {
            return $0.data
        }
        .decode(type: BitriseBranches.self, decoder: jsonDecoder)

        return publisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Fetching builds
extension BitriseAPI {
    static func builds(config: BitriseConfiguration, forBranch branch: String? = nil, limit: Int = 50) -> AnyPublisher<BitriseBuilds, Error> {
        var baseURL = URL(string: config.baseUrl)!
        baseURL.appendPathComponent(config.appSlug)
        baseURL.appendPathComponent("builds")
        
        var queryItems = [
            URLQueryItem(name: "workflow", value: "primary"),
            URLQueryItem(name: "limit", value: "\(limit)"),
        ]
        
        if let branch = branch {
            queryItems.append(URLQueryItem(name: "branch", value: branch))
        }
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems

        let url = components.url!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(config.authToken, forHTTPHeaderField: "Authorization")

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601

        let publisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
        .map { $0.data }
        .decode(type: BitriseBuilds.self, decoder: jsonDecoder)

        return publisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
