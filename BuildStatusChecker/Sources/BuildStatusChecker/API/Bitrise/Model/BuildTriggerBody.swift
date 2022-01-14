struct BuildTriggerBody: Codable {
    var hookInfo: HookInfo = HookInfo()
    let buildParams: BuildTriggerParams
}
