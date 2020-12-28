import Foundation
import Combine

typealias Workflow = String

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
        var publishers = [AnyPublisher<BitriseBuilds, Error>]()

        let workflows = config.workflowList.isEmpty ? ["primary"] : config.workflowList

        for workflow in workflows {
            publishers.append(builds(config: config, forWorkflow: workflow, forBranch: branch, limit: limit))
        }

        return Publishers.Sequence(sequence: publishers)
            .flatMap{ $0 }
            .collect()
            .map { bitriseBuildsArray in
                var result = BitriseBuilds()

                for builds in bitriseBuildsArray {
                    result.data.append(contentsOf: builds.data)
                }

                return result
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private static func builds(config: BitriseConfiguration, forWorkflow workflow: String, forBranch branch: String? = nil, limit: Int = 50) -> AnyPublisher<BitriseBuilds, Error> {
        var baseURL = URL(string: config.baseUrl)!
        baseURL.appendPathComponent(config.appSlug)
        baseURL.appendPathComponent("builds")

        var queryItems = [
            URLQueryItem(name: "workflow", value: workflow),
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
        .map {
            $0.data
        }
        .decode(type: BitriseBuilds.self, decoder: jsonDecoder)
        .mapError { e in
            e
        }

        return publisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Trigger builds
extension BitriseAPI {
    static func triggerBuild(config: BitriseConfiguration, buildParams: GenericBuildParams) -> AnyPublisher<Void, Error> {
        // POST to /apps/{app-slug}/builds
        var baseURL = URL(string: config.baseUrl)!
        baseURL.appendPathComponent(config.appSlug)
        baseURL.appendPathComponent("builds")

        var urlRequest = URLRequest(url: baseURL)
        urlRequest.setValue(config.authToken, forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "POST"

        let bitriseBuildParams = buildParams

        urlRequest.httpBody = buildParams.asJSONEncodedHTTPBody

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601

        let publisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
        .tryMap() { element -> Void in
            guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
        }

        return publisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    static func cancelBuild(config: BitriseConfiguration, buildSlug: String, reason: String) -> AnyPublisher<Void, Error> {
        // POST to /apps/{app-slug}/builds/{build-slug}/abort
        var baseURL = URL(string: config.baseUrl)!
        baseURL.appendPathComponent(config.appSlug)
        baseURL.appendPathComponent("builds")
        baseURL.appendPathComponent(buildSlug)
        baseURL.appendPathComponent("abort")

        var urlRequest = URLRequest(url: baseURL)
        urlRequest.setValue(config.authToken, forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "POST"
        let params = BuildAbortParams(abortReason: reason, abortWithSuccess: false, skipNotifications: false)
        let body = try! JSONEncoder().encode(params)
        urlRequest.httpBody = body

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601

        let publisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
        .tryMap() { element -> Void in
            guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
        }
        
        return publisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
