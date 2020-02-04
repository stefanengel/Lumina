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

                if viewModel.errorMessage != nil {
                    ErrorView(message: viewModel.errorMessage!)
                }

                if viewModel.development != nil {
                    BuildView(viewModel: BuildViewModel(from: viewModel.development!))
                }

                if viewModel.master != nil {
                    BuildView(viewModel: BuildViewModel(from: viewModel.master!))
                }

                if viewModel.release != nil {
                    BuildView(viewModel: BuildViewModel(from: viewModel.release!))
                }

                if viewModel.hotfix != nil {
                    BuildView(viewModel: BuildViewModel(from: viewModel.hotfix!))
                }

                ForEach(viewModel.feature, id: \.self) { featureBuild in
                    BuildView(viewModel: BuildViewModel(from: featureBuild))
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
            development: Build(status: .running, branch: "develop", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"),
            master: Build(status: .success, branch: "master", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"),
            release:
                Build(status: .success, branch: "release/0.5.0", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"),
            hotfix:
                Build(status: .success, branch: "hotfix/0.5.1", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"),
            feature: [
                Build(status: .running, branch: "feature/TICKET-1234", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"),
                Build(status: .failed(error: nil), branch: "feature/TICKET-5678", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"),
                Build(status: .success, branch: "feature/TICKET-12", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io"),
                Build(status: .running, branch: "feature/TICKET-34", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io")
            ]
        ))
    }
}
