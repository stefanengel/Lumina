import SwiftUI
import BuildStatusChecker

struct BuildMonitorView: View {
    @ObservedObject var viewModel: BuildMonitorViewModel

    init(viewModel: BuildMonitorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView(.vertical) {
            TextField("🔍 Filter for branches containing", text: $viewModel.search)

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


struct BuildMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        BuildMonitorView(viewModel: BuildMonitorViewModel(
                            development: [BuildRepresentation(wrapped: Build(status: .running, branch: "develop", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"))],
            master: [BuildRepresentation(wrapped: Build(status: .success, branch: "master", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"))],
            release:
                [BuildRepresentation(wrapped: Build(status: .success, branch: "release/0.5.0", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"))],
            hotfix:
                [BuildRepresentation(wrapped: Build(status: .success, branch: "hotfix/0.5.1", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"))],
            feature: [
                BuildRepresentation(wrapped: Build(status: .running, branch: "feature/TICKET-1234", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io")),
                BuildRepresentation(wrapped: Build(status: .failed(error: nil), branch: "feature/TICKET-5678", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io")),
                BuildRepresentation(wrapped: Build(status: .success, branch: "feature/TICKET-12", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io")),
                BuildRepresentation(wrapped: Build(status: .running, branch: "feature/TICKET-34", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io)"))
            ]
        ))
    }
}
