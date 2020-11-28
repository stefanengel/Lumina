public struct BuildFilter {
    let hideFeatureBranchesContaining: [String]
    let settings = SettingsStore()

    public init() {
        hideFeatureBranchesContaining = settings.readBranchIgnoreList()
    }

    public func shouldHide(build: BuildRepresentation) -> Bool {
        guard hideFeatureBranchesContaining.count > 0 else {
            return false // per default show everything
        }

        for substring in hideFeatureBranchesContaining {
            if build.wrapped.branch.contains(substring) { return true }
        }

        return false
    }
}
