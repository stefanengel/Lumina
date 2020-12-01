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
                Text("\(viewModel.title)")
                .font(.system(size: 20))
                Text("\(viewModel.triggeredAt)")
                .font(.system(size: 12))
                VStack {
                    if viewModel.subtitle != nil {
                        Text("\(viewModel.subtitle!)")
                        .font(.system(size: 12))
                    }
                    if viewModel.subBuilds.count > 0 {
                        HStack {
                            ForEach(viewModel.subBuilds, id: \.self) { subBuild in
                                SubBuildView(viewModel: SubBuildViewModel(from: subBuild))
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
        .onTapGesture {
            self.viewModel.openInBrowser()
        }
        .onAppear() {
            if self.viewModel.isRunning {
                withAnimation(self.repeatingAnimation) { self.opacity = 0.5 }
            }
        }
    }
}

struct BuildView_Previews: PreviewProvider {
    static var previews: some View {
        let runningBuild = Build(buildNumber: 12345, status: .running, branch: "develop", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc")
        let succeededBuild = Build(buildNumber: 12345, status: .success, branch: "develop", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc")

        return Group {
            BuildView(viewModel: BuildViewModel(from: BuildRepresentation(wrapped: runningBuild)))
            BuildView(viewModel: BuildViewModel(from: BuildRepresentation(wrapped: succeededBuild)))
            BuildView(viewModel: BuildViewModel(from: BuildRepresentation(wrapped: GroupedBuild(builds: [BuildRepresentation(wrapped: runningBuild), BuildRepresentation(wrapped: succeededBuild)]))))
        }
    }
}
