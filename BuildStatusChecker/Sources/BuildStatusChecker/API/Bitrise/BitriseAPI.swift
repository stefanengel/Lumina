import Foundation
import Combine
import os.log

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
        .mapError { e -> Error in
            os_log("Unable to decode builds: %{PUBLIC}@", log: OSLog.buildFetcher, type: .error, e.localizedDescription)
            return e
        }

        return publisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    static func numberOfbuilds(config: BitriseConfiguration, onHold: Bool) -> AnyPublisher<Int, Error> {
        var base = URL(string: config.baseUrl)!
        base.appendPathComponent(config.appSlug)
        base.appendPathComponent("builds")

        let queryItems = [
            URLQueryItem(name: "owner_slug", value: config.orgSlug),
            URLQueryItem(name: "is_on_hold", value: onHold ? "true" : "false"),
            URLQueryItem(name: "status", value: "0"),
        ]

        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)!
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
        .map {
            $0.data.count
        }
        .mapError { e -> Error in
            os_log("Unable to decode builds: %{PUBLIC}@", log: OSLog.buildFetcher, type: .error, e.localizedDescription)
            return e
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
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

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

// MARK: - Get info about organization
extension BitriseAPI {
    static func organization(config: BitriseConfiguration) -> AnyPublisher<Organization, Error> {
        #warning("Sort out where the base url comes from! The current one already includes the component /apps/ which is why we cannot use it here")
        var url = URL(string: "https://api.bitrise.io/v0.1/organizations")!
        url.appendPathComponent(config.orgSlug)

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(config.authToken, forHTTPHeaderField: "Authorization")

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601

        let publisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
        .map {
            $0.data // this is the data representation of the response
        }
        .decode(type: OrganizationResponse.self, decoder: jsonDecoder)
        .map {
            $0.data // this is the property called "data" within the response
        }
        .mapError { e -> Error in
            os_log("Unable to decode organization: %{PUBLIC}@", log: OSLog.buildFetcher, type: .error, e.localizedDescription)
            return e
        }

        return publisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
