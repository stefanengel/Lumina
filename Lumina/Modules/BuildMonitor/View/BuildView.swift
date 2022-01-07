import SwiftUI
import BuildStatusChecker

struct BuildView: View {
    private var viewModel: BuildViewModel
    @State var isRunning: Bool = false
    @State private var opacity = 1.0

    var repeatingAnimation: Animation {
        Animation.linear(duration: 1.0)
           .repeatForever()
    }

    init(viewModel: BuildViewModel) {
        self.viewModel = viewModel
        self.isRunning = viewModel.isRunning
    }

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("\(viewModel.decoratedTitle)")
                .font(.system(size: 20))
                Text("\(viewModel.triggeredAt)")
                .font(.system(size: 12))
                VStack {
                    Text("\(viewModel.subTitle)")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .padding(.top, 5)
                    if viewModel.hasSubBuilds {
                        HStack {
                            ForEach(viewModel.subBuilds, id: \.self) { subBuild in
                                SubBuildView(viewModel: SubBuildViewModel(model: viewModel.model, build: subBuild, buildAPIClient: viewModel.buildAPI))
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
            Spacer()
        }
        .padding(.top, 15)
        .padding(.bottom, 15)
        .background(viewModel.backgroundColor)
        .cornerRadius(15)
        .opacity(opacity)
        .contextMenu(menuItems: {
            Button(action: self.viewModel.copyBuildNumber) {
                // replace with Label once macOS 11.0 is the min. deployment target
                // Label("Copy Build Number", systemImage: "number")
                Text("Copy Build Number")
            }
            if viewModel.isRunning {
                Button(action: self.viewModel.cancelBuild) {
                    Text("Cancel Build")
                }
            }
            else {
                Button(action: self.viewModel.triggerBuild) {
                    Text("Trigger Build")
                }
            }
        })
        .onTapGesture {
            self.viewModel.openInBrowser()
        }
        .onAppear() {
            if self.viewModel.isRunning && !self.viewModel.hasSubBuilds {
                withAnimation(self.repeatingAnimation) { self.opacity = 0.5 }
            }
        }
    }
}

struct BuildView_Previews: PreviewProvider {
    static var previews: some View {
        let runningBuild = Build(id: "asdfghjk", buildNumber: 12345, status: .running, branch: "develop", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", info: "Some info text", commitHash: "abc")
        let succeededBuild = Build(id: "asdfghjk", buildNumber: 12345, status: .success, branch: "develop", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc")

        return Group {
            BuildView(
                viewModel: BuildViewModel(
                    model: BuildMonitorModel(buildAPIClient: BuildAPIClientMock.create()), build: BuildRepresentation(wrapped: runningBuild, settings: SettingsMock.settings), buildAPI: BuildAPIClientMock.create()))
            BuildView(viewModel: BuildViewModel(model: BuildMonitorModel(buildAPIClient: BuildAPIClientMock.create()), build: BuildRepresentation(wrapped: succeededBuild, settings: SettingsMock.settings), buildAPI: BuildAPIClientMock.create()))
            BuildView(viewModel: BuildViewModel(model: BuildMonitorModel(buildAPIClient: BuildAPIClientMock.create()), build: BuildRepresentation(wrapped: GroupedBuild(builds: [BuildRepresentation(wrapped: runningBuild, settings: SettingsMock.settings), BuildRepresentation(wrapped: succeededBuild, settings: SettingsMock.settings)]), settings: SettingsMock.settings), buildAPI: BuildAPIClientMock.create()))
        }
    }
}
