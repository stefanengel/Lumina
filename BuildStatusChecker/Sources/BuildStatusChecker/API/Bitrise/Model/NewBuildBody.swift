struct NewBuildBody: Codable {
    let hookInfo: HookInfo = HookInfo()
    let buildParams: BuildParams
}
