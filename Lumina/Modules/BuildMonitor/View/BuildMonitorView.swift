import SwiftUI
import BuildStatusChecker

struct BuildMonitorView: View {
    @ObservedObject var viewModel: BuildMonitorViewModel

    init(viewModel: BuildMonitorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: HorizontalAlignment.center, spacing: 20) {
                Spacer()

                if viewModel.isLoading {
                    ProgressIndicatorView()
                }

                viewModel.errorMessage.map { ErrorView(message: $0) }

                ForEach(builds, id: \.self) { build in
                    BuildView(viewModel: BuildViewModel(from: build))
                }

                Spacer()
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var builds: [Build] {
        var allBuilds = [Build]()

        allBuilds.append(contentsOf: viewModel.development)
        allBuilds.append(contentsOf: viewModel.master)
        allBuilds.append(contentsOf: viewModel.release)
        allBuilds.append(contentsOf: viewModel.hotfix)
        allBuilds.append(contentsOf: viewModel.feature)

        return allBuilds
    }
}


struct BuildMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        BuildMonitorView(viewModel: BuildMonitorViewModel(
            development: [Build(status: .running, branch: "develop", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io")],
            master: [Build(status: .success, branch: "master", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io")],
            release:
                [Build(status: .success, branch: "release/0.5.0", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io")],
            hotfix:
                [Build(status: .success, branch: "hotfix/0.5.1", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io")],
            feature: [
                Build(status: .running, branch: "feature/TICKET-1234", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"),
                Build(status: .failed(error: nil), branch: "feature/TICKET-5678", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"),
                Build(status: .success, branch: "feature/TICKET-12", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"),
                Build(status: .running, branch: "feature/TICKET-34", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io")
            ]
        ))
    }
}
