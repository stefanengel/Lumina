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
        .contextMenu(menuItems: {
            Button(action: self.viewModel.copyBuildNumber) {
                // replace with Label once macOS 11.0 is the min. deployment target
                // Label("Copy Build Number", systemImage: "number")
                Text("Copy Build Number")
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
        let runningBuild = Build(buildNumber: 12345, status: .running, branch: "develop", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", info: "Some info text", commitHash: "abc")
        let succeededBuild = Build(buildNumber: 12345, status: .success, branch: "develop", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc")

        return Group {
            BuildView(viewModel: BuildViewModel(from: BuildRepresentation(wrapped: runningBuild)))
            BuildView(viewModel: BuildViewModel(from: BuildRepresentation(wrapped: succeededBuild)))
            BuildView(viewModel: BuildViewModel(from: BuildRepresentation(wrapped: GroupedBuild(builds: [BuildRepresentation(wrapped: runningBuild), BuildRepresentation(wrapped: succeededBuild)]))))
        }
    }
}
