import Foundation

public protocol GenericBuildParams {
    var asJSONEncodedHTTPBody: Data { get }
}
