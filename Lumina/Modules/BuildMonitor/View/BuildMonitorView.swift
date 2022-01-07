import SwiftUI
import BuildStatusChecker

struct BuildMonitorView: View {
    #warning("UselStateObject")
    @ObservedObject var viewModel: BuildMonitorViewModel

    var body: some View {
        VStack(spacing: 0) {
            viewModel.buildQueueInfo.map { buildQueueInfo in
                BuildQueueInfoView(viewModel: BuildQueueInfoViewModel(buildQueueInfo: buildQueueInfo))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }

            SearchField(text: $viewModel.search, placeholder: "Filter for branches containing")
                .padding(.horizontal)
                .padding(.bottom)
                .padding(.top, 8)

            ScrollView(.vertical) {
                VStack(alignment: HorizontalAlignment.center, spacing: 20) {
                    if viewModel.isLoading {
                        ProgressIndicatorView()
                    }

                    viewModel.errorMessage.map { ErrorView(message: $0) }

                    ForEach(viewModel.filteredBuilds, id: \.self) { build in
                        BuildView(viewModel: BuildViewModel(model: viewModel.model, build: build, buildAPI: viewModel.buildAPIClient))
                    }

                    Spacer()
                }
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}


struct BuildMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        BuildMonitorView(viewModel: BuildMonitorViewModel(
            development: [BuildRepresentation(wrapped: Build(id: "asdfghjk", buildNumber: 12345, status: .running, branch: "develop", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc"), settings: SettingsMock.settings)],
            master: [BuildRepresentation(wrapped: Build(id: "asdfghjk", buildNumber: 12345, status: .success, branch: "master", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc"), settings: SettingsMock.settings)],
            release:
                [BuildRepresentation(wrapped: Build(id: "asdfghjk", buildNumber: 12345, status: .success, branch: "release/0.5.0", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc"), settings: SettingsMock.settings)],
            hotfix:
                [BuildRepresentation(wrapped: Build(id: "asdfghjk", buildNumber: 12345, status: .success, branch: "hotfix/0.5.1", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc"), settings: SettingsMock.settings)],
            feature: [
                BuildRepresentation(wrapped: Build(id: "asdfghjk", buildNumber: 12345, status: .running, branch: "feature/TICKET-1234", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc"), settings: SettingsMock.settings),
                BuildRepresentation(wrapped: Build(id: "asdfghjk", buildNumber: 12345, status: .failed(error: nil), branch: "feature/TICKET-5678", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc"), settings: SettingsMock.settings),
                BuildRepresentation(wrapped: Build(id: "asdfghjk", buildNumber: 12345, status: .success, branch: "feature/TICKET-12", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc"), settings: SettingsMock.settings),
                BuildRepresentation(wrapped: Build(id: "asdfghjk", buildNumber: 12345, status: .running, branch: "feature/TICKET-34", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io)", commitHash: "abc"), settings: SettingsMock.settings)
            ]
        ))
    }
}
