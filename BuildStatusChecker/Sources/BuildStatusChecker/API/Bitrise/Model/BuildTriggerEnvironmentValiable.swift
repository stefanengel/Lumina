struct BuildTriggerEnvironmentVariable: Codable {
    let mappedTo: String
    let value: String
    var isExpand: Bool = false
}
