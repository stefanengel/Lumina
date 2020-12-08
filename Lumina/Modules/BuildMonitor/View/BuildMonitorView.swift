import SwiftUI
import BuildStatusChecker

struct BuildMonitorView: View {
    @ObservedObject var viewModel: BuildMonitorViewModel

    init(viewModel: BuildMonitorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchField(text: $viewModel.search, placeholder: "Filter for branches containing")
                .padding()
            ScrollView(.vertical) {
                VStack(alignment: HorizontalAlignment.center, spacing: 20) {
                    if viewModel.isLoading {
                        ProgressIndicatorView()
                    }

                    viewModel.errorMessage.map { ErrorView(message: $0) }

                    ForEach(viewModel.filteredBuilds, id: \.self) { build in
                        BuildView(viewModel: BuildViewModel(from: build))
                    }

                    Spacer()
                }
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}


struct BuildMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        BuildMonitorView(viewModel: BuildMonitorViewModel(
            development: [BuildRepresentation(wrapped: Build(buildNumber: 12345, status: .running, branch: "develop", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc"))],
            master: [BuildRepresentation(wrapped: Build(buildNumber: 12345, status: .success, branch: "master", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc"))],
            release:
                [BuildRepresentation(wrapped: Build(buildNumber: 12345, status: .success, branch: "release/0.5.0", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc"))],
            hotfix:
                [BuildRepresentation(wrapped: Build(buildNumber: 12345, status: .success, branch: "hotfix/0.5.1", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc"))],
            feature: [
                BuildRepresentation(wrapped: Build(buildNumber: 12345, status: .running, branch: "feature/TICKET-1234", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc")),
                BuildRepresentation(wrapped: Build(buildNumber: 12345, status: .failed(error: nil), branch: "feature/TICKET-5678", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc")),
                BuildRepresentation(wrapped: Build(buildNumber: 12345, status: .success, branch: "feature/TICKET-12", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc")),
                BuildRepresentation(wrapped: Build(buildNumber: 12345, status: .running, branch: "feature/TICKET-34", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io)", commitHash: "abc"))
            ]
        ))
    }
}
